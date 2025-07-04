USE [p_adagioRHIndustrialMefi]
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

	BEGIN TRY  

	DELETE Salud.tblPruebas
	WHERE IDPrueba = @IDPrueba

	END TRY  
	BEGIN CATCH  
	EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
	END CATCH ;
END;
GO
