USE [p_adagioRHAC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure  Seguridad.spBorrarPermisosEspecialesUsuarioTodos
(
	@IDUsuario int,
	@IDUrl int
)
AS
BEGIN
	DELETE PEU
	from Seguridad.tblPermisosEspecialesUsuarios PEU
		inner join app.tblCatPermisosEspeciales pe
			on pe.IDPermiso = PEU.IDPermiso
	WHERE PEU.IDUsuario = @IDUsuario
	and pe.IDUrlParent = @IDUrl
END
GO
