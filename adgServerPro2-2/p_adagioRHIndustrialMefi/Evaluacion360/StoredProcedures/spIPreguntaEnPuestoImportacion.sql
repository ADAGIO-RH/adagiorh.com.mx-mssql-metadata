USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Importacion masiva sobre las preguntas de un puesto
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-08-31
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE     PROCEDURE [Evaluacion360].[spIPreguntaEnPuestoImportacion]
( 
	@IDPuesto INT
    , @Grupo VARCHAR(250)               
    , @Pregunta VARCHAR(MAX)
    , @OpcionRespuesta VARCHAR(MAX)
	, @Activo BIT
	, @IDTipoEvaluacion INT
	, @IDTipoGrupo INT
    , @IDTipoPreguntaGrupo INT
	, @IDTipoPregunta INT
    , @IDUsuario INT
)
AS
	BEGIN
		
		-- VARIABLES
		DECLARE @TIPO_REFERENCIA_PUESTO INT = 3
				, @FUNCION_CLAVE INT = 11
				, @IS_REQUERIDA INT = 0
				, @CALIFICAR INT = 1
				, @BOX_9_FALSE INT = 0
				, @CATEGORIA_ESTRATEGICA INT = 2
				, @BOX_9_ES_REQUERIDO_FALSE INT = 0
				, @COMENTARIO_FALSE INT = 0
				, @COMENTARIO_IS_REQUERIDO_FALSE INT = 0
				, @MAXIMA_CALIFICACION_POSIBLE INT = 0	
				, @VITA_NULL INT = NULL
				, @ID_INDICADOR_NULL INT = NULL
				, @VALOR INT = 0
				, @JSON_DATA_NULL VARCHAR = NULL
				, @FECHA DATETIME = GETDATE()
				, @COPIADO_DEL_GRUPO_NULL INT = NULL				
				, @PuestoSinEspacios VARCHAR(250)
				, @IDGrupo INT = 0
				, @IDPregunta INT = 0
				;			

		
		-- VALIDAMOS GRUPO
		SELECT @IDGrupo = G.IDGrupo
		FROM [Evaluacion360].[tblCatGrupos] G
		WHERE G.TipoReferencia = @TIPO_REFERENCIA_PUESTO
				AND G.IDReferencia = @IDPuesto
				AND REPLACE(G.Nombre, ' ', '') = REPLACE(@Grupo, ' ', '')
				AND G.IDTipoEvaluacion = @IDTipoEvaluacion
				AND G.IDTipoGrupo = @IDTipoGrupo
				AND ISNULL(G.CopiadoDeIDGrupo, '') = ''
		
		-- NO EXISTE GRUPO
		IF(@IDGrupo = 0)
			BEGIN
				
				INSERT INTO [Evaluacion360].[tblCatGrupos]
				VALUES
				(
					@IDTipoGrupo
					, @Grupo
					, 'Grupo Importado'
					, @FECHA
					, @TIPO_REFERENCIA_PUESTO
					, @IDPuesto
					, @COPIADO_DEL_GRUPO_NULL
					, @IDTipoPreguntaGrupo
					, NULL
					, NULL
					, NULL
					, NULL
					, NULL
					, NULL
					, NULL
					, 0
					, NULL
					, 0
					, NULL
					, NULL
					, @IDTipoEvaluacion
					, @Activo
				)

				SET @IDGrupo = @@IDENTITY;
			END
		ELSE
			BEGIN
				UPDATE [Evaluacion360].[tblCatGrupos] SET Activo = @Activo WHERE IDGrupo = @IDGrupo
			END
		
		

		-- VALIDAMOS PREGUNTA
		SELECT @IDPregunta = IDPregunta FROM [Evaluacion360].[tblCatPreguntas] 
		WHERE IDGrupo = @IDGrupo
			  AND REPLACE(Descripcion, ' ', '') = REPLACE(@Pregunta, ' ', '')
			  AND IDTipoPregunta = @IDTipoPregunta 
		
		-- NO EXISTE PREGUNTA
		IF(@IDPregunta = 0)
			BEGIN
				
				INSERT INTO [Evaluacion360].[tblCatPreguntas] 
				VALUES 
				(
					@IDTipoPregunta
					, @IDGrupo
					, @Pregunta
					, @IS_REQUERIDA
					, @CALIFICAR
					, @BOX_9_FALSE
					, @CATEGORIA_ESTRATEGICA
					, @BOX_9_ES_REQUERIDO_FALSE
					, @COMENTARIO_FALSE
					, @COMENTARIO_IS_REQUERIDO_FALSE
					, @MAXIMA_CALIFICACION_POSIBLE
					, @VITA_NULL
					, @ID_INDICADOR_NULL
				)

				SET @IDPregunta = @@IDENTITY;

				IF(@IDTipoPregunta = @FUNCION_CLAVE)
					BEGIN
						
						INSERT INTO [Evaluacion360].[tblPosiblesRespuestasPreguntas]
						VALUES
						(
							@IDPregunta
							, @OpcionRespuesta
							, @VALOR
							, @FUNCION_CLAVE
							, @JSON_DATA_NULL
						)
					END
			END

	END
GO
