USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seguridad].[spBorrarUsuarioPermisos]
(
	@IDUsuarioPermiso int = 0
	,@IDUsuario int
	,@IDUrl int
	
)
AS
BEGIN
	DECLARE  
		@IDIdioma varchar(225)
	;
          DECLARE @OldJSON Varchar(Max);
 
	select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))

	IF OBJECT_ID('tempdb..#tempChild') IS NOT NULL DROP TABLE #tempChild
	IF OBJECT_ID('tempdb..#temp') IS NOT NULL DROP TABLE #temp
	
	select 
		PP.IDUsuarioPermiso as IDUsuarioPermiso
		,PP.IDUsuario as IDUsuario
		,isnull(A.IDArea,0) as IDArea
		,A.Descripcion as Area
		,isnull(M.IDModulo,0) as IDModulo
		,M.Descripcion Modulo
		,ISNULL(U.IDUrl,0) as IDUrl
		,U.URL as URL
		,JSON_VALUE(U.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Accion
		,U.Tipo
		,cast(0 as bit)as TienePermiso
	from App.tblCatUrls U
		inner join Seguridad.tblUsuariosPermisos PP on PP.IDUrl = U.IDUrl
		Inner join App.tblCatModulos M on M.IDModulo = U.IDModulo
		Inner join App.tblCatAreas A on A.IDArea = M.IDArea
	Where pp.IDUsuario = @IDUsuario and U.IDUrl = @IDUrl

 Select @OldJSON = (SELECT PC.*, U.Nombre, u.Apellido FROM Seguridad.tblUsuariosPermisos PC 
                    inner join Seguridad.TblUsuarios U on U.IDUsuario =PC.IDUsuario  
                    WHERE PC.IDUsuario = @IDUsuario FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

 EXEC [Auditoria].[spIAuditoria] @IDUsuarioPermiso,'[Seguridad].[tblUsuariosPermisos]','[Seguridad].[spBorrarUsuarioPermisos]','UPDATE','',@OldJSON

	delete Seguridad.tblUsuariosPermisos
	Where IDUsuario = @IDUsuario and IDUrl = @IDUrl


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
	
	delete  up
	from Seguridad.tblUsuariosPermisos up
		inner join #tempChild c on up.IDUrl = c.IDUrl and up.IDUsuario = @IDUsuario
END
GO
