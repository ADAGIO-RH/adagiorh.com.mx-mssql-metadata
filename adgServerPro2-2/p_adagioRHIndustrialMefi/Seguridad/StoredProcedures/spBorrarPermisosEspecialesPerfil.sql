USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seguridad].[spBorrarPermisosEspecialesPerfil] --1,1  
(  
 @IDPerfil int  
 ,@IDPermiso int  
 ,@IDUsuario int
)  
AS  
BEGIN  
   
     DECLARE @OldJSON Varchar(Max);

    Select @OldJSON = (SELECT * FROM Seguridad.tblPermisosEspecialesPerfiles WHERE IDPermiso = @IDPermiso and  IDPermiso = @IDPermiso   FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Seguridad].[tblFiltrosUsuarios]','[Seguridad].[spBorrarPermisosEspecialesPerfil]','DELETE','',@OldJSON

 if exists(select 1 from Seguridad.tblPermisosEspecialesPerfiles where IDPerfil = @IDPerfil and IDPermiso = @IDPermiso)  
 Begin  
   Delete Seguridad.tblPermisosEspecialesPerfiles  
   Where IDPerfil = @IDPerfil and IDPermiso = @IDPermiso  
 END  

END
GO
