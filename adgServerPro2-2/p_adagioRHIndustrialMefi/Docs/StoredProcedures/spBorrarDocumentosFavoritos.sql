USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Docs.spBorrarDocumentosFavoritos
(
	@IDDocumento int,
	@IDUsuario int
) 
AS
BEGIN
	IF EXISTS(Select * from Docs.tblDocumentosFavoritos where IDDocumento = @IDDocumento and IDUsuario = @IDUsuario)
	BEGIN
		DELETE Docs.tblDocumentosFavoritos 
		WHERE IDDocumento = @IDDocumento
		and IDUsuario = @IDUsuario
	END
END
GO
