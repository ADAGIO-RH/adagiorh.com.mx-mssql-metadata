USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seguridad].[spBorrarPermisosEspecialesUsuarios] --1,1
(
	@IDUsuario int
	,@IDUsuarioLogin int
	,@IDPermiso int
)
AS
BEGIN
	
DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);

Select @OldJSON = LEFT (
        (SELECT PE.*, U.IDEmpleado, U.Nombre, u.Apellido  FROM Seguridad.tblPermisosEspecialesUsuarios PE 
     inner join Seguridad.TblUsuarios U on U.IDUsuario =PE.IDUsuario  
    WHERE PE.IDUsuario = @IDUsuario FOR JSON PATH,WITHOUT_ARRAY_WRAPPER),
     8000);

EXEC [Auditoria].[spIAuditoria] @IDUsuarioLogin,'[Seguridad].[tblPermisosEspecialesUsuarios]','[Seguridad].[spBorrarPermisosEspecialesUsuarios]','DELETE','',@OldJSON

	if exists(select 1 from Seguridad.tblPermisosEspecialesUsuarios where IDUsuario = @IDUsuario and IDPermiso = @IDPermiso)
	Begin
			Delete Seguridad.tblPermisosEspecialesUsuarios
			Where IDUsuario = @IDUsuario and IDPermiso = @IDPermiso
	END

	
	
select 
		ROW_NUMBER()over(Order by U.IDUrl) as RN,
		 isnull(PEP.IDPermisoEspecialUsuario,0)as IDPermisoEspecialUsuario
		,isnull(PEP.IDUsuario,@IDUsuario) as IDUsuario
		,ISNULL(U.IDUrl,0) as IDUrl
		,ISNULL(PE.IDPermiso,0) as IDPermiso
		,PE.Codigo as Permiso
		,PE.Descripcion AS Descripcion
		,cast(case when (PEP.IDPermiso is null) then 0 
			else 1
			end  as bit)as TienePermiso

	from App.tblCatUrls U
		inner join APP.tblCatPermisosEspeciales PE
			on u.IDUrl = PE.IDUrlParent
		left outer join Seguridad.tblPermisosEspecialesUsuarios PEP
			on PEP.IDPermiso = PE.IDPermiso and PEP.IDUsuario = @IDUsuario
	WHERE PE.IDPermiso = @IDPermiso



END
GO
