USE [p_adagioRHAC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure  [Seguridad].[spBorrarPermisosEspecialesPerfilTodos]
(
	@IDPerfil int,
	@IDUrl int
)
AS
BEGIN
	DELETE PEU
	from Seguridad.tblPermisosEspecialesPerfiles PEU
		inner join app.tblCatPermisosEspeciales pe
			on pe.IDPermiso = PEU.IDPermiso
	WHERE PEU.IDPerfil = @IDPerfil
	and pe.IDUrlParent = @IDUrl
END
GO
