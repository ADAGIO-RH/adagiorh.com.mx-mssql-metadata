USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--create table Reportes.tblCatReportes(
--	IDItem int not null identity(1,1) constraint Pk_ReportesTblCatReportes_IDItem primary key
--	,TipoItem int not null
--	,IDCarpeta int not null constraint D_ReportesTblCatReportes_IDCarpeta default 0
--	,Nombre varchar(254) not null
--);

--alter table Reportes.tblCatReportes add Constraint U_ReportesTblCatReportes_TipoItemIDCarpetaNombre unique(TipoItem,IDCarpeta,Nombre)

--alter table Reportes.tblCatReportes alter column Nombre varchar(254)  not null
--select * from Reportes.tblCatReportes

CREATE proc [Reportes].[spActualizarCarpetasArchivos](
	@RutasPrm [App].[dtDirectorios] readonly
) as 

--	truncate table  Reportes.tblCatReportes;
	
	declare @Root varchar(255) --'C:\AdagioTFS\adagioRHSolutions\Development\Version 1.1.0.0\'	
		,@CurrentPath varchar(max)
		,@CurrentItemName  varchar(254)
		,@CurrentItemID int
		,@CurrentItemType int
		,@CurrentItemIDCarpeta int
		,@FileID int 
		,@Rutas [App].[dtDirectorios]
	;

	--select @Root=Valor
	--from App.tblConfiguracionesGenerales with (nolock)
	--where [IDConfiguracion] = 'RutaCarpetaReportes'


	select top 1 @Root = substring([Path],0,PATINDEX('%Reports%', [Path])+7)
	from @RutasPrm

	print @Root

	insert @Rutas
	select * 
	from @RutasPrm
	where ([Path] not like '%SUBREPORTS%') and ([Path] not like '%init.html') and lower([Path]) not like '%\basicos\%'

	--values 
	--	 ('C:\AdagioTFS\adagioRHSolutions\Development\Version 1.1.0.0\adagioRH.Web\Reports\adagioRH.DB\App\Functions\App.fnAddString.sql')
	--  ,('C:\AdagioTFS\adagioRHSolutions\Development\Version 1.1.0.0\adagioRH.Web\Reports\samplefile.txt'	)
	--	,('C:\AdagioTFS\adagioRHSolutions\Development\Version 1.1.0.0\adagioRH.Web\Reports\adagioRH.DB\App\Functions\Archivo1.sql')
	--	,('C:\AdagioTFS\adagioRHSolutions\Development\Version 1.1.0.0\adagioRH.Web\Reports\adagioRH.DB\App\Functions\Archivo2.sql')
	--	,('C:\AdagioTFS\adagioRHSolutions\Development\Version 1.1.0.0\adagioRH.Web\Reports\adagioRH.DB\App\Functions\Archivo3.sql')
	--	,('C:\AdagioTFS\adagioRHSolutions\Development\Version 1.1.0.0\adagioRH.Web\Reports\adagioRH.DB\App\Functions\Archivo4.sql')
	--	,('C:\AdagioTFS\adagioRHSolutions\Development\Version 1.1.0.0\adagioRH.Web\Reports\adagioRH.DB\App\Functions\Archivo5.sql')
	--	,('C:\AdagioTFS\adagioRHSolutions\Development\Version 1.1.0.0\adagioRH.Web\Reports\adagioRH.DB\App\Functions\Carpeta1\Archivo55.sql')
	--	,('C:\AdagioTFS\adagioRHSolutions\Development\Version 1.1.0.0\adagioRH.Web\Reports\adagioRH.DB\App\Functions\Carpeta2\Archivo555.sql')
	--	,('C:\AdagioTFS\adagioRHSolutions\Development\Version 1.1.0.0\adagioRH.Web\Reports\adagioRH.DB\App\Functions\Carpeta2\Archivo555.sql')
	--	,('C:\AdagioTFS\adagioRHSolutions\Development\Version 1.1.0.0\adagioRH.Web\Reports\adagioRH.DB\App\Functions\Carpeta2\Archivo555.sql')
	--	,('C:\AdagioTFS\adagioRHSolutions\Development\Version 1.1.0.0\adagioRH.Web\Reports\adagioRH.DB\App\Functions\Carpeta2\Archivo555.sql')
	--	,('C:\AdagioTFS\adagioRHSolutions\Development\Version 1.1.0.0\adagioRH.Web\Reports\adagioRH.DB\App\Functions\Carpeta2\Archivo555.sql')
	--	,('C:\AdagioTFS\adagioRHSolutions\Development\Version 1.1.0.0\adagioRH.Web\Reports\adagioRH.DB\App\Functions\Carpeta2\Archivo555.sql')
	--	,('C:\AdagioTFS\adagioRHSolutions\Development\Version 1.1.0.0\adagioRH.Web\Reports\adagioRH.DB\App\Functions\Carpeta2\Archivo5455.sql')
	 
 
	update @Rutas
		set [Path] = REPLACE([Path],@Root,'')

	--select * from @Rutas

	-- Se borran de la tabla las rutas que no existen físicamente
	delete cr
	--select cr.FullPath,r.Path
	from Reportes.tblCatReportes cr 
		left join @Rutas r on r.Path =cr.FullPath
	where r.Path is null

	-- Se borran las rutas existentes en las dos listas			
	--select *
	delete r
	from @Rutas r
		join Reportes.tblCatReportes cr on r.Path =cr.FullPath

	--return
	select @CurrentPath = min([Path])
	from @Rutas			

	while exists(select top 1 1 from @Rutas where [Path] >= @CurrentPath)
	begin
		--print @CurrentPath

		if object_id('tempdb..#tempPaths') is not null drop table #tempPaths ;

		select *
		INTO #tempPaths
		from app.Split(@CurrentPath,'\')

		if (select count(*) from #tempPaths) = 1
		begin
			--print 'Archivo en el Root'
			
			select top 1 @CurrentItemName = item
			from #tempPaths

			if not exists(select top 1 1 
						from Reportes.tblCatReportes with(nolock)
						where (TipoItem = 1 and IDCarpeta  = 0 and Nombre = @CurrentItemName) and FullPath = @CurrentPath)
			begin
				insert Reportes.tblCatReportes(TipoItem,IDCarpeta,Nombre,FullPath)
				select 1,0,@CurrentItemName,@CurrentPath
			end;
		end else
		begin
			select @FileID = max(id) from #tempPaths
			select @CurrentItemID = min(id) from #tempPaths

			while exists (select top 1 1
						from #tempPaths
						where id >= @CurrentItemID)
			begin
				select @CurrentItemName = item
				from #tempPaths
				where id = @CurrentItemID

				if (@CurrentItemID = @FileID)
				begin
					set @CurrentItemType = 1
				end else 
				begin
					set @CurrentItemType = 0
				end;

				if (@CurrentItemID = 1)
				begin
					set @CurrentItemIDCarpeta = 0
				end;

				--select @CurrentItemType,@CurrentItemName,@CurrentItemIDCarpeta
				if not exists(select top 1 1
							from [Reportes].[tblCatReportes] with(nolock)
							where TipoItem = @CurrentItemType and Nombre = @CurrentItemName and IDCarpeta = @CurrentItemIDCarpeta)
				begin
					insert Reportes.tblCatReportes(TipoItem,IDCarpeta,Nombre,FullPath)
					select @CurrentItemType,@CurrentItemIDCarpeta,@CurrentItemName,@CurrentPath
					
					if @CurrentItemType = 0
						select @CurrentItemIDCarpeta = @@IDENTITY

				end else if (@CurrentItemType = 0)
				begin
					select top 1 @CurrentItemIDCarpeta = IDItem
					from [Reportes].[tblCatReportes] with(nolock)
					where TipoItem = @CurrentItemType and Nombre = @CurrentItemName and IDCarpeta = @CurrentItemIDCarpeta
				end;

				--if not exists(select top 1 1
				--			from [Reportes].[tblCatReportes] with(nolock)
				--			where TipoItem = @CurrentItemType and Nombre = @CurrentItemName and IDCarpeta = @CurrentItemIDCarpeta)
				--begin
				--	insert Reportes.tblCatReportes(TipoItem,IDCarpeta,Nombre)
				--	select @CurrentItemType,@CurrentItemIDCarpeta,@CurrentItemName
				--end

				select @CurrentItemID = min(id) from #tempPaths where id > @CurrentItemID;
			end;
			  

			--print 'Archivo o folder'
	 		--select * from #tempPaths
		end
		
		select @CurrentPath = min([Path]) from @Rutas where [Path] > @CurrentPath
	end;
 
-- select * from Reportes.tblCatReportes with (nolock)
 --truncate table  Reportes.tblCatReportes
GO
