USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Reclutamiento.spBorrarPreguntaFiltro(
	 @IDPreguntaFiltro [int],
	  @IDUsuario int
)
AS
BEGIN
		BEGIN TRY  
		    DELETE [Reclutamiento].[tblPreguntasFiltro]
			WHERE IDPreguntaFiltro = @IDPreguntaFiltro
				
		END TRY  
		BEGIN CATCH  
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
			return 0;
		END CATCH ;
END
GO
