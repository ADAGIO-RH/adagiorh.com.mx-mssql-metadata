USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Salud].[spBorrarPrueba]
(
	@IDPrueba int = 0,
	@IDUsuario int
)
AS
BEGIN
	EXEC [Salud].[spBuscarPruebas] @IDPrueba = @IDPrueba

	DELETE Salud.tblPruebas
	WHERE IDPrueba = @IDPrueba
END;
GO
