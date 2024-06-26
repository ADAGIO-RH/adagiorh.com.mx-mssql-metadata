USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seguridad].[spBuscarPermisosUsuarioTreeView] (
	@IDUsuario int
)
AS
BEGIN
	if OBJECT_ID('tempdb..#TempPermisosPadres') is not null drop table #TempPermisosPadres
	if OBJECT_ID('tempdb..#TempPermisos') is not null drop table #TempPermisos
	if OBJECT_ID('tempdb..#TempPermisos2') is not null drop table #TempPermisos2

	--if OBJECT_ID('tempdb..#TempPermisos3') is not null drop table #TempPermisos3

	--declare @IDPerfil int = 1
	declare	@Counter int = 1

	select 
		ROW_NUMBER()over(Order by U.IDUrl) as RN,
		 isnull(PP.IDUsuarioPermiso,0)as IDUsuarioPermiso
		,isnull(PP.IDUsuario,@IDUsuario) as IDUsuario
		,isnull(A.IDArea,0) as IDArea
		,A.Descripcion as Area
		,isnull(M.IDModulo,0) as IDModulo
		,M.Descripcion Modulo
		,ISNULL(U.IDUrl,0) as IDUrl
		,U.URL as URL
		,U.Descripcion as Accion
		,U.Tipo
		,cast(case when (pp.IDUrl is null) then 0 
			else 1
			end  as bit)as TienePermiso
		,0 as Padre
		,de.Dependencias
	into #TempPermisosPadres
	from App.tblCatUrls U with (nolock)
		inner join App.tblUrlDependencias de with (nolock) on u.IDUrl = de.IDUrl
		left outer join Seguridad.tblUsuariosPermisos PP with (nolock) on PP.IDUrl = U.IDUrl and PP.IDUsuario = @IDUsuario
		left join App.tblCatModulos M with (nolock) on M.IDModulo = U.IDModulo
		left join App.tblCatAreas A with (nolock) on A.IDArea = M.IDArea
	
	select * 
		into #TempPermisos
	from #TempPermisosPadres

	while(@Counter <= (select count(*) from #TempPermisosPadres))
	BEGIN
		insert into #TempPermisos(IDUsuarioPermiso,IDUsuario,IDArea,Area,IDModulo,Modulo,IDUrl,URL,Accion,Tipo,TienePermiso,Padre)
		select 
			--ROW_NUMBER()over(Order by U.IDUrl) as RN,
			 isnull(PP.IDUsuarioPermiso,0)as IDUsuarioPermiso
			,isnull(PP.IDUsuario,@IDUsuario) as IDUsuario
			,isnull(A.IDArea,0) as IDArea
			,A.Descripcion as Area
			,isnull(M.IDModulo,0) as IDModulo
			,M.Descripcion Modulo
			,ISNULL(U.IDUrl,0) as IDUrl
			,U.URL as URL
			,U.Descripcion as Accion
			,U.Tipo
			,cast(case when (pp.IDUrl is null) then 0 
				else 1
				end  as bit)as TienePermiso
			,(select top 1 IDURL from #TempPermisosPadres Where RN = @Counter) as Padre
		from App.tblCatUrls U
			left outer join Seguridad.tblUsuariosPermisos PP on PP.IDUrl = U.IDUrl and PP.IDUsuario = @IDUsuario
			left join App.tblCatModulos M on M.IDModulo = U.IDModulo
			left join App.tblCatAreas A on A.IDArea = M.IDArea
		WHERE U.IDUrl in (Select Item from app.Split((select Dependencias from #TempPermisosPadres Where RN = @Counter),','))

		set @Counter = @Counter + 1
	END

	--select distinct 0 as IDPermisoPerfil,IDPerfil,IDArea,Area,0 as IDModulo,'#' as Modulo,0 as IDUrl,'#',Area,'G' as Tipo,0 as TienePermiso,-1 as Padre from #TempPermisos
	--union
	select IDUsuarioPermiso,IDUsuario,IDArea,Area,IDModulo,Modulo,IDUrl,URL,Accion,Tipo,TienePermiso,Padre, ROW_NUMBER()Over(Partition by IDUrl order by padre desc ) as RN
		into #TempPermisos2				 
	from #TempPermisos p
	
	select IDUsuarioPermiso,IDUsuario,IDArea,Area,IDModulo,Modulo,IDUrl,URL,Accion,Tipo,TienePermiso,Padre
	from #TempPermisos2
	where RN = 1
	
	--select IDUsuarioPermiso,IDUsuario,IDArea,Area,IDModulo,Modulo,IDUrl,URL,Accion,Tipo,TienePermiso,Padre
	----into #TempPermisos3
	--from #TempPermisos2
	--where ConPa = 1
	
	--insert into #TempPermisos3(IDUsuarioPermiso,IDUsuario,IDArea,Area,IDModulo,Modulo,IDUrl,URL,Accion,Tipo,TienePermiso,Padre)
	--select IDUsuarioPermiso,IDUsuario,IDArea,Area,IDModulo,Modulo,IDUrl,URL,Accion,Tipo,TienePermiso,Padre
	--from #TempPermisos
	--where IDUrl not in (select IDUrl from #TempPermisos2)

	--select IDUsuarioPermiso,IDUsuario,IDArea,Area,IDModulo,Modulo,IDUrl,URL,Accion,Tipo,TienePermiso,Padre from #TempPermisos3
END
GO
