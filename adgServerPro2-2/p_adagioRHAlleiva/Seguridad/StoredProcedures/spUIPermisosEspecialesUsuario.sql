USE [p_adagioRHAlleiva]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seguridad].[spUIPermisosEspecialesUsuario]--  1,1
(
	@IDUsuario int
	,@IDPermiso int
	,@PermisoPersonalizado bit = 0
)
AS
BEGIN
	if not exists(select 1 from Seguridad.tblPermisosEspecialesUsuarios where IDUsuario = @IDUsuario and IDPermiso = @IDPermiso)
	Begin
		insert into Seguridad.tblPermisosEspecialesUsuarios(IDUsuario,IDPermiso,PermisoPersonalizado)
		select @IDUsuario,@IDPermiso,@PermisoPersonalizado
	END
END
GO
