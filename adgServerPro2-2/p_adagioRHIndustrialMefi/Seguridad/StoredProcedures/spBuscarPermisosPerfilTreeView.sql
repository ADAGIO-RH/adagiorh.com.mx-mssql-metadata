USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seguridad].[spBuscarPermisosPerfilTreeView](
	@IDPerfil int,
	@IDUsuario int
)
AS
BEGIN
	declare	
		@Counter int = 1,
		@IDIdioma varchar(225)
	;
 
	select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))

	if OBJECT_ID('tempdb..#TempPermisosPadres') is not null drop table #TempPermisosPadres
	if OBJECT_ID('tempdb..#TempPermisos') is not null drop table #TempPermisos

	select 
		ROW_NUMBER()over(Order by U.IDUrl) as RN,
		isnull(PP.IDPermisoPerfil,0)as IDPermisoPerfil
		,isnull(PP.IDPerfil,@IDPerfil) as IDPerfil
		,isnull(A.IDArea,0) as IDArea
		,A.Descripcion as Area
		,isnull(M.IDModulo,0) as IDModulo
		,M.Descripcion Modulo
		,ISNULL(U.IDUrl,0) as IDUrl
		,U.URL as URL
		,JSON_VALUE(U.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Accion
		,U.Tipo
		,cast(case when (pp.IDUrl is null) then 0 
			else 1
			end  as bit)as TienePermiso
		,0 as Padre
		,de.Dependencias		
	into #TempPermisosPadres
	from App.tblCatUrls U
		inner join App.tblUrlDependencias de on u.IDUrl = de.IDUrl
		left outer join Seguridad.tblPermisosPerfiles PP on PP.IDUrl = U.IDUrl and PP.IDPerfil = @IDPerfil
		left join App.tblCatModulos M on M.IDModulo = U.IDModulo
		left join App.tblCatAreas A on A.IDArea = M.IDArea

	select * 
	into #TempPermisos
	from #TempPermisosPadres

	while(@Counter <= (select count(*) from #TempPermisosPadres))
	BEGIN
		insert into #TempPermisos(IDPermisoPerfil,IDPerfil,IDArea,Area,IDModulo,Modulo,IDUrl,URL,Accion,Tipo,TienePermiso,Padre)
		select 
			--ROW_NUMBER()over(Order by U.IDUrl) as RN,
			 isnull(PP.IDPermisoPerfil,0)as IDPermisoPerfil
			,isnull(PP.IDPerfil,@IDPerfil) as IDPerfil
			,isnull(A.IDArea,0) as IDArea
			,A.Descripcion as Area
			,isnull(M.IDModulo,0) as IDModulo
			,M.Descripcion Modulo
			,ISNULL(U.IDUrl,0) as IDUrl
			,U.URL as URL
			,JSON_VALUE(U.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Accion
			,U.Tipo
			,cast(case when (pp.IDUrl is null) then 0 
				else 1
				end  as bit)as TienePermiso
			,(select top 1 IDURL from #TempPermisosPadres Where RN = @Counter) as Padre
		from App.tblCatUrls U
			left outer join Seguridad.tblPermisosPerfiles PP on PP.IDUrl = U.IDUrl and PP.IDPerfil = @IDPerfil
			left join App.tblCatModulos M on M.IDModulo = U.IDModulo
			left join App.tblCatAreas A on A.IDArea = M.IDArea
		WHERE U.IDUrl in (Select Item from app.Split((select Dependencias from #TempPermisosPadres Where RN = @Counter),','))

		set @Counter = @Counter + 1
	END

	select IDPermisoPerfil,IDPerfil,IDArea,Area,IDModulo,Modulo,IDUrl,URL,Accion,Tipo,TienePermiso,Padre, ROW_NUMBER()Over(Partition by IDUrl order by padre desc ) as RN 
		into #TempPermisos2		
	from #TempPermisos

	select IDPermisoPerfil,IDPerfil,IDArea,Area,IDModulo,Modulo,IDUrl,URL,Accion,Tipo,TienePermiso,Padre, ROW_NUMBER()Over(Partition by IDUrl order by padre desc ) as RN 
	from #TempPermisos2
	where RN = 1

END
GO
