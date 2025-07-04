USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--(Poner el próximo IDUrl correctamente y el IDModulo, en el Where colocar el área correcta, estas url ponerlas en el postdeploy y ejecutarlos para que las guarde en la tabla app.tbCatUrls)

CREATE proc [Bk].[spGenerarUrls] as

	declare 
		@MaxID int,
		@IDArea int  = 0,
		@IDModulo int = 19,
		@Prefijo int,
		@IDController int,
		@Controller varchar(max)
	;

	if OBJECT_ID('tempdb..#tempControllersActions') is not null drop table #tempControllersActions

	select
		ca.*
		,a.*
		,cu.IDUrl
		,cu.IDModulo
		,cu.Descripcion as DescripcionURL
		,cu.URL
		,cu.Tipo
		,cu.IDTipoPermiso
		,cu.IDController
		,cu.Traduccion
		,ROW_NUMBER()OVER(PARTITION BY a.IDArea order by ca.Area, ca.Controller) as RN
		,0 as NuevoID
	INTO #tempControllersActions
	from [App].[tblControllersActions] ca
		left join App.tblCatAreas a on a.Descripcion = ca.Area
		left join App.tblCatUrls cu on cu.URL = COALESCE(ca.area,'')
			+'/'+COALESCE(ca.Controller,'')
			+'/'+COALESCE(ca.[Action],'') 
	where ca.Area not in ('Interfaces','System.Web.Mvc','System','Kendo.Mvc.UI') --and ca.Area <> '' --and ca.Area in ('IMSS')
		and cu.IDUrl is null
		and CA.Attributes not like '%adgIgnore%'
		and CA.Attributes not like '%AllowAnonymous%'
		and ca.Area = 'Scheduler'
	order by ca.Area

	--select * from #tempControllersActions
	--select distinct Area from #tempControllersActions where IDUrl is null
	--return 

	select @IDArea = MIN(IDArea) from #tempControllersActions
	
	while exists(select top 1 1 from #tempControllersActions where IDArea >= @IDArea)
	begin
		select @Prefijo = PrefijoURL from App.tblCatAreas where IDArea = @IDArea
		
		select @MaxID = isnull(MAX(u.IDUrl)	 ,0),
			@IDController = max(c.IDController)
		from App.tblCatUrls u
			join App.tblCatControllers c on c.IDController = u.IDController
			join App.tblCatAreas a on a.IDArea = c.IDArea
		where a.IDArea = @IDArea and CAST(u.IDUrl as varchar(100)) like CAST(a.PrefijoURL as varchar(100))+'%'

		update #tempControllersActions
			set
				NuevoID = CAST(
							CAST(@Prefijo as varchar(100))+
								CAST(
										CAST(
											REPLACE(
												CAST(@MaxID as varchar(100)),
												CAST(@Prefijo as varchar(100)),
												''
										)
									as int) + RN
							 as varchar(100))
							as int)
				,IDController = @IDController
		where IDArea = @IDArea

		select @IDArea = MIN(IDArea) 
		from #tempControllersActions
		where IDArea > @IDArea		
	end

	--select * from #tempControllersActions where NuevoID  not in (select IDUrl from App.tblCatUrls) and  ISNULL(Area, '') != ''
	delete #tempControllersActions
	where NuevoID  in (select IDUrl from App.tblCatUrls)
	
	select FORMATMESSAGE(N'insert into App.tblCatUrls(IDUrl,IDModulo,Descripcion,URL,Tipo,IDTipoPermiso, IDController, Traduccion) values (%d, %d, ''%s'', ''%s'',  ''%s'', ''%s'', %s, ''{"esmx": {"Descripcion": "%s"},"enus": {"Descripcion": "%s"}}'')', 
						NuevoID,
						@IDModulo,
						case when Area is not null and Area <> '' then COALESCE(area,'') +'/' else '' end +COALESCE(Controller,'') +'/'+COALESCE([Action],''),
						case when Area is not null and Area <> '' then COALESCE(area,'') +'/' else '' end +COALESCE(Controller,'') +'/'+COALESCE([Action],''),
						case when Attributes = 'adgView' then 'V' else 'A' end,
						case when Attributes = 'adgView' then 'RV' 
							when Attributes = 'adgPost' then 'RVW'
							when Attributes = 'adgGet' then 'R'
							when Attributes = 'adgDelete' then 'RVWD'
						else 'R' end,
						isnull(CAST(IDController as varchar), 'NULL'),
						case when Area is not null and Area <> '' then COALESCE(area,'') +'/' else '' end +COALESCE(Controller,'') +'/'+COALESCE([Action],''),
						case when Area is not null and Area <> '' then COALESCE(area,'') +'/' else '' end +COALESCE(Controller,'') +'/'+COALESCE([Action],'')
					)
	from #tempControllersActions
	where ISNULL(Area, '') != ''
	--	and NuevoID  not in (select IDUrl from App.tblCatUrls)
	order by IDArea
GO
