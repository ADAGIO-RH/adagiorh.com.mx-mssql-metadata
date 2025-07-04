USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Contiene la configuracion de las graficas en grupo o pregunta del reporte de analitica
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-11-28
** Paremetros		: @IDProyecto		Identificador del proyecto
**					: @Descripcion		Nombre del grupo
**					: @EsGrupo			Bandera que indica si estamos calculando un grupo o una pregunta
**					: @IDGrafica		Identificador de la grafica
**					: @IDUsuario		Identificador del usuario
** IDIssue			: #652

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [Evaluacion360].[spConfiguracionGraficaAnalitica](
	@IDProyecto			INT = 0	
	, @Descripcion		VARCHAR(MAX) = ''		
	, @EsGrupo			BIT = 0
	, @IDGrafica		INT = 0
	, @IDUsuario		INT = 0
)
AS
	BEGIN
		
		DECLARE @CopiadoDeIDGrupo		INT = 0
				, @CopiadoDeIDPregunta	INT = 0
				, @IDConfig				INT = 0
				, @SI					INT = 1
				, @Error				VARCHAR(MAX)
				;

		DECLARE @tblPreguntasAll TABLE
		(
			IDGrupo				INT,
			Grupo				VARCHAR(MAX), 
			IDTipoPreguntaGrupo INT,
			IDEvaluador			INT,
			CopiadoDeIDGrupo	INT,
			IDPregunta			INT,
			IDTipoPregunta		INT,			
			Pregunta			VARCHAR(MAX),
			Calificar			INT,
			Respuesta			NVARCHAR(MAX)
		)

		INSERT INTO @tblPreguntasAll(IDGrupo, Grupo, IDTipoPreguntaGrupo, IDEvaluador, CopiadoDeIDGrupo, IDPregunta, IDTipoPregunta, Pregunta, Calificar, Respuesta)
		EXEC [Evaluacion360].[spObtenerGrupoPreguntaAnalitica] 
			@IDProyecto = @IDProyecto
			, @Descripcion = @Descripcion
			, @EsGrupo = @EsGrupo
			, @IDUsuario = @IDUsuario		

		
		-- OBTENEMOS EL IDGrupo DE DONDE FUE COPIADO EL GRUPO O LA PREGUNTA
		SELECT TOP 1 @CopiadoDeIDGrupo = CopiadoDeIDGrupo 
		FROM @tblPreguntasAll;


		-- BUSCAMOS SI EXISTE LA CONFIGURACION EN LA TABLA [Evaluacion360].[tblConfGraficasAnalitica]
		IF(@EsGrupo = @SI)
			BEGIN						
				
				SELECT @IDConfig = IDConfiguracion
				FROM [Evaluacion360].[tblConfGraficasAnalitica]
				WHERE IDProyecto = @IDProyecto
						AND EsGrupo = @EsGrupo
						AND CopiadoDeIDGrupo = @CopiadoDeIDGrupo
						AND IDUsuario = @IDUsuario
			END
		ELSE
			BEGIN

				SELECT @CopiadoDeIDPregunta = IDPregunta
				FROM [Evaluacion360].[tblCatPreguntas] 
				WHERE IDGrupo = @CopiadoDeIDGrupo
						AND Descripcion = @Descripcion

				SELECT @IDConfig = IDConfiguracion
				FROM [Evaluacion360].[tblConfGraficasAnalitica]
				WHERE IDProyecto = @IDProyecto
						AND EsGrupo = @EsGrupo
						AND CopiadoDeIDGrupo = @CopiadoDeIDGrupo
						AND IDUsuario = @IDUsuario
						AND CopiadoDeIDPregunta = @CopiadoDeIDPregunta
			END	

			
		BEGIN TRY
			-- AGREGARMOS CONFIGURACION
			IF(@IDConfig = 0)
				BEGIN
					BEGIN TRAN
						IF(@CopiadoDeIDGrupo > 0)
						BEGIN
							INSERT INTO [Evaluacion360].[tblConfGraficasAnalitica] VALUES(@EsGrupo, @IDProyecto, @IDGrafica, @CopiadoDeIDGrupo, @CopiadoDeIDPregunta, @IDUsuario)
						END

						IF @@ROWCOUNT = 1
							COMMIT TRAN
						ELSE
							ROLLBACK TRAN
				END
			ELSE
				-- ACTUALIZAMOS CONFIGURACION
				BEGIN				
					IF EXISTS(SELECT IDConfiguracion FROM [Evaluacion360].[tblConfGraficasAnalitica] WHERE IDConfiguracion = @IDConfig)
						BEGIN						
							BEGIN TRAN				
								
								UPDATE [Evaluacion360].[tblConfGraficasAnalitica]
									SET IDGrafica = @IDGrafica
								WHERE IDConfiguracion = @IDConfig

							IF @@ROWCOUNT = 1
								COMMIT TRAN
							ELSE
								ROLLBACK TRAN
						END
				END
		END TRY
		BEGIN CATCH
			SELECT @Error = ERROR_MESSAGE()
			RAISERROR(@Error, 16, 1);
		END CATCH

	END
GO
