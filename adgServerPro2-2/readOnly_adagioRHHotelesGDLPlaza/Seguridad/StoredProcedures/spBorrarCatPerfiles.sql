USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Seguridad.spBorrarCatPerfiles
(
	@IDPerfil int = 0
	
)
AS
BEGIN
	Delete Seguridad.tblCatPerfiles
	Where (IDPerfil = @IDPerfil)
END
GO
