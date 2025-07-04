USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seguridad].[spUIPermisosEspecialesPerfil]--  1,1  
(  
 @IDPerfil int  
 ,@IDPermiso int  
 ,@IDUsuario int  = 0
   
)  
AS  
BEGIN  
  
    DECLARE @NewJSON Varchar(Max);
  
 if not exists(select 1 from Seguridad.tblPermisosEspecialesPerfiles where IDPerfil = @IDPerfil and IDPermiso = @IDPermiso)  
 Begin  
   insert into Seguridad.tblPermisosEspecialesPerfiles(IDPerfil,IDPermiso)  
   select @IDPerfil,@IDPermiso  

    Select @NewJSON = (SELECT * FROM Seguridad.tblPermisosEspecialesPerfiles WHERE IDPerfil = @IDPerfil and IDPermiso = @IDPermiso FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Seguridad].[tblPermisosEspecialesPerfiles]','[Seguridad].[spUIPermisosEspecialesPerfil]','INSERT',@NewJSON,''


 END  
  
   
END
GO
