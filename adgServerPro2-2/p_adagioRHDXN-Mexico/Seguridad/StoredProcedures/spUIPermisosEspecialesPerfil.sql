USE [p_adagioRHDXN-Mexico]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seguridad].[spUIPermisosEspecialesPerfil]--  1,1  
(  
 @IDPerfil int  
 ,@IDPermiso int  
   
)  
AS  
BEGIN  
  
  
  
 if not exists(select 1 from Seguridad.tblPermisosEspecialesPerfiles where IDPerfil = @IDPerfil and IDPermiso = @IDPermiso)  
 Begin  
   insert into Seguridad.tblPermisosEspecialesPerfiles(IDPerfil,IDPermiso)  
   select @IDPerfil,@IDPermiso  
 END  
  
   
END
GO
