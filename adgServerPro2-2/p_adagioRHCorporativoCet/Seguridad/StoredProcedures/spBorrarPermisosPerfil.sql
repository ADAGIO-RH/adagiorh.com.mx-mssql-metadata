USE [p_adagioRHCorporativoCet]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seguridad].[spBorrarPermisosPerfil]
(
	@IDPerfil int
	,@IDUrl int
)
AS
BEGIN
	
	select 
		 PP.IDPermisoPerfil
		,PP.IDPerfil
		,A.IDArea
		,A.Descripcion as Area
		,M.IDModulo
		,M.Descripcion Modulo
		,ISNULL(U.IDUrl,0) as IDUrl
		,U.URL as URL
		,U.Descripcion as Accion
		,U.Tipo
		,cast(0 as bit)as TienePermiso
	from App.tblCatUrls U
		inner join Seguridad.tblPermisosPerfiles PP
			on PP.IDUrl = U.IDUrl
		Inner join App.tblCatModulos M
			on M.IDModulo = U.IDModulo
		Inner join App.tblCatAreas A
			on A.IDArea = M.IDArea
	Where pp.IDPerfil = @IDPerfil
		and u.IDUrl = @IDUrl

	Delete Seguridad.tblPermisosPerfiles
	Where IDPerfil = @IDPerfil
		and IDUrl = @IDUrl


	IF OBJECT_ID('tempdb..#tempChild') IS NOT NULL
			DROP TABLE #tempChild
	
	IF OBJECT_ID('tempdb..#temp') IS NOT NULL
		DROP TABLE #temp
	



	;WITH Childs as
	(
	  SELECT D.IDUrlDependencia, D.IDUrl, D.Dependencias
	  FROM App.tblUrlDependencias D
	  WHERE D.IDUrl = @IDUrl
	  UNION ALL
	  SELECT D1.IDUrlDependencia, D1.IDUrl, D1.Dependencias
	  FROM App.tblUrlDependencias D1
	  INNER JOIN Childs P
	  on D1.IDUrl in (select item from App.Split(p.Dependencias,','))
	  UNION ALL
	  SELECT 0  as IDUrlDependencia, u.IDUrl, '' as Dependencias
	  From App.tblCatUrls U
		inner join Childs C
			on Cast(U.IDUrl as varchar) in  (select item from App.Split(C.Dependencias,','))
	 )
 
	SELECT * , ROW_NUMBER() over(partition by IDUrl order by IDURL ASC) as RN
		into #temp
	From Childs

	select IDUrlDependencia,IDURL,Dependencias
		into #tempChild
	from #temp
	where RN = 1
	
	
	delete  up
	from Seguridad.tblPermisosPerfiles up
		inner join #tempChild c
			on up.IDUrl = c.IDUrl
			and up.IDPerfil = @IDPerfil

END
GO
