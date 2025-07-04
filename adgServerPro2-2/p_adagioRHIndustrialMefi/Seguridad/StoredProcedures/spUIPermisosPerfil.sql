USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seguridad].[spUIPermisosPerfil] -- 4,117
(
	@IDPerfil int
	,@IDUrl int
	,@IDUsuario int
)
AS
BEGIN
	DECLARE  
		@IDIdioma varchar(225)
	;
 
	select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))

	IF OBJECT_ID('tempdb..#tempParent') IS NOT NULL DROP TABLE #tempParent
	IF OBJECT_ID('tempdb..#tempChild') IS NOT NULL DROP TABLE #tempChild
	IF OBJECT_ID('tempdb..#temp') IS NOT NULL DROP TABLE #temp
	
	;WITH Parents as
	(
		SELECT D.IDUrlDependencia, D.IDUrl, D.Dependencias
		FROM App.tblUrlDependencias D
		WHERE D.Dependencias like '%,'+cast(@IDUrl as varchar)+',%' 

		UNION ALL

		SELECT D1.IDUrlDependencia, D1.IDUrl, D1.Dependencias
		FROM App.tblUrlDependencias D1
		INNER JOIN Parents P
		ON D1.Dependencias like '%,'+Cast( p.IDUrl as varchar)+',%'
	)
	SELECT distinct  * 
	into #tempParent
	from Parents

	;WITH Childs as
	(
		SELECT D.IDUrlDependencia, D.IDUrl, D.Dependencias
		FROM App.tblUrlDependencias D
		WHERE D.IDUrl = @IDUrl
		UNION ALL
		SELECT D1.IDUrlDependencia, D1.IDUrl, D1.Dependencias
		FROM App.tblUrlDependencias D1
			INNER JOIN Childs P on D1.IDUrl in (select item from App.Split(p.Dependencias,','))
		UNION ALL
		SELECT 0  as IDUrlDependencia, u.IDUrl, '' as Dependencias
		From App.tblCatUrls U
			inner join Childs C on Cast(U.IDUrl as varchar) in  (select item from App.Split(C.Dependencias,','))
	)
 
	SELECT * , ROW_NUMBER() over(partition by IDUrl order by IDUrl ASC) as RN
	into #temp
	From Childs

	select IDUrlDependencia, IDUrl, Dependencias
	into #tempChild
	from #temp
	where RN = 1
	
	insert into Seguridad.tblPermisosPerfiles(IDPerfil,IDUrl)
	select @IDPerfil, IDUrl
	from #tempParent pc
	where not exists( select 1 from Seguridad.tblPermisosPerfiles up where up.IDPerfil = @IDPerfil and up.IDUrl = pc.IDUrl)
	
	insert into Seguridad.tblPermisosPerfiles(IDPerfil,IDUrl)
	select @IDPerfil, IDUrl
	from #tempChild pc
	where not exists(select 1 from Seguridad.tblPermisosPerfiles up where up.IDPerfil = @IDPerfil and up.IDUrl = pc.IDUrl)

	if not exists(select 1 from Seguridad.tblPermisosPerfiles where IDPerfil = @IDPerfil and IDUrl = @IDUrl)
	begin
		insert into Seguridad.tblPermisosPerfiles(IDPerfil,IDUrl)
		select @IDPerfil,@IDUrl
	end

	select 
		PP.IDPermisoPerfil
		,PP.IDPerfil
		,A.IDArea
		,A.Descripcion as Area
		,M.IDModulo
		,M.Descripcion Modulo
		,ISNULL(U.IDUrl,0) as IDUrl
		,U.URL as URL
		,JSON_VALUE(U.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Accion
		,U.Tipo
		,cast(case when (pp.IDUrl = null) then 0 
			else 1
			end  as bit) as TienePermiso
	from App.tblCatUrls U
		left join Seguridad.tblPermisosPerfiles PP on PP.IDUrl = U.IDUrl
		Inner join App.tblCatModulos M on M.IDModulo = U.IDModulo
		Inner join App.tblCatAreas A on A.IDArea = M.IDArea
	Where U.IDUrl = @IDUrl and pp.IDPerfil = @IDPerfil
	
END
GO
