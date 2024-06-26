USE [p_adagioRHAC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [Seguridad].[spActivarCuentaUsuario](
    @IDUsuario int
    ,@Password varchar(255)
    ,@IDUsuarioKeysActivacion int
) as
    update Seguridad.tblUsuarios
	   set [Password] = @Password
		  ,Activo = 1
    where IDUsuario = @IDUsuario

    update Seguridad.TblUsuariosKeysActivacion
	   set Activo = 0
		  ,ActivationDate = getdate()
    where IDUsuarioKeysActivacion = @IDUsuarioKeysActivacion
GO
