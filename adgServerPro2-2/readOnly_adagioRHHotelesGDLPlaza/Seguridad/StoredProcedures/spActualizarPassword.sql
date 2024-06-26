USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Seguridad].[spActualizarPassword]
(
	@IDUsuario int,
	@Password varchar(max)
)
AS
BEGIN	
	update Seguridad.tblUsuarios
		set [Password] = @Password
	where IDUsuario = @IDUsuario
END
GO
