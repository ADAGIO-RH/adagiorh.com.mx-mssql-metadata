USE [p_adagioRHLya]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seguridad].[spTransferirPermisosPerfilUsuario] --7,1  
(  
 @IDUsuario int  
 ,@IDPerfil int = null
)  
AS  
Begin  
   
	if (@IDPerfil is null) 
	begin
		select @IDPerfil = IDPerfil
		from [Seguridad].[tblUsuarios] with (nolock)
		where IDUsuario = @IDUsuario
	end;	

	Delete Seguridad.tblPermisosUsuarioControllers  
	where IDUsuario = @IDUsuario  
  
	Insert into Seguridad.tblPermisosUsuarioControllers(IDUsuario,IDController,IDTipoPermiso)  
	select @IDUsuario,IDController,IDTipoPermiso   
	from Seguridad.tblPermisosPerfilesControllers  
	where IDPerfil = @IDPerfil  
  
	Delete Seguridad.tblPermisosEspecialesUsuarios  
	where IDUsuario = @IDUsuario  
  
	Insert into Seguridad.tblPermisosEspecialesUsuarios(IDUsuario, IDPermiso)  
	Select @IDUsuario,IDPermiso  
	from Seguridad.tblPermisosEspecialesPerfiles  
	where IDPerfil = @IDPerfil  
  
	Delete App.tblAplicacionUsuario
	where IDUsuario = @IDUsuario 
  
	Insert into App.tblAplicacionUsuario(IDAplicacion,IDUsuario)  
	Select IDAplicacion,@IDUsuario  
	from App.tblAplicacionPerfiles  
	where IDPerfil = @IDPerfil  

	Delete Seguridad.tblPermisosReportesUsuarios
	where IDUsuario = @IDUsuario 

	insert into Seguridad.tblPermisosReportesUsuarios(IDItem,IDUsuario,Acceso)
	select prp.IDItem,@IDUsuario,1
	From tblPermisosReportesPerfiles prp
	where IDPerfil = @IDPerfil
END
GO
