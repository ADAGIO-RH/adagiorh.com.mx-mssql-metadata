USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [Reclutamiento].[spIUPreguntasFiltro](
	 @IDPreguntaFiltro [int] = null,
	 @IDTipoPreguntaFiltro [int],
	 @Pregunta [varchar](max),
	 @Respuestas [varchar](max),
	 @Orden [int] = null,
	 @TipoReferencia int,
	 @IDReferencia int null,
	 @IDUsuario int
)
AS
BEGIN
	
	IF(@IDPreguntaFiltro = 0 OR @IDPreguntaFiltro Is null)
	BEGIN
		INSERT INTO [Reclutamiento].[tblPreguntasFiltro](
			IDTipoPreguntaFiltro
			,Pregunta
			,Respuestas
			,TipoReferencia
			,IDReferencia
		)
		VALUES(
			@IDTipoPreguntaFiltro
			,@Pregunta
			,@Respuestas
			,isnull(@TipoReferencia,0)
			,isnull(@IDReferencia,0)
		)

		Set @IDPreguntaFiltro = @@IDENTITY
	END
	ELSE
	BEGIN	
		UPDATE [Reclutamiento].[tblPreguntasFiltro]
			SET  IDTipoPreguntaFiltro = @IDTipoPreguntaFiltro
				,Pregunta			  = @Pregunta			 
				,Respuestas			  = @Respuestas			 
				,TipoReferencia		  = isnull(@TipoReferencia,0)		 
				,IDReferencia		  = isnull(@IDReferencia,0)		 
		WHERE IDPreguntaFiltro = @IDPreguntaFiltro
		
	END
END;
GO
