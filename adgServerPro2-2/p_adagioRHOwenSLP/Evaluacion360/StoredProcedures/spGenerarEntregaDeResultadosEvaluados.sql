USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Manejador de entrega de resultados para las direfentes tipos de evaluaciones.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-12-20
** Parametros		: @IDProyecto			Identificador del proyecto
**					: @FilesEvaluaciones	Lista de archivos
** IDAzure			: #1303

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [Evaluacion360].[spGenerarEntregaDeResultadosEvaluados](
	@IDProyecto				INT = 0
	, @FilesEvaluaciones	[App].[dtAdgFiles] READONLY
) AS
	BEGIN
		
		DECLARE @IDTipoProyecto				INT = 0
				, @EVALUACION_360			INT = 1
				, @EVALUACION_DESEMPENO		INT = 2
				, @EVALUACION_CLIMA_LABORAL INT = 3
				, @EVALUACION_ENCUESTA		INT = 4				
				, @SI						BIT = 1
				;
		

		-- INSERTAMOS LOS ARCHIVOS EN LA TABLA '[App].[tblAdgFiles]'
		MERGE [App].[tblAdgFiles] AS TARGET
		USING @FilesEvaluaciones AS SOURCE
		ON TARGET.[name] = SOURCE.[name]
		WHEN NOT MATCHED THEN
			INSERT
		   (
			  [name]
			  , extension
			  , pathFile
			  , relativePath
			  , downloadURL
			  , requiereAutenticacion
		   )
		   VALUES
		   (
			  SOURCE.[name]
			  , SOURCE.extension
			  , SOURCE.pathFile
			  , SOURCE.relativePath
			  , SOURCE.downloadURL
			  , @SI
		   );



		-- OBTENEMOS EL TIPO DEL PROYECTO
		SELECT @IDTipoProyecto = IDTipoProyecto FROM [Evaluacion360].[tblCatProyectos] WHERE IDProyecto = @IDProyecto;



		-- ***** CREA LA ENTREGA DE RESULTADOS DE LOS DIFERENTES TIPOS DE EVALUACIONES *****
		
		IF(@IDTipoProyecto = @EVALUACION_360)
			BEGIN

				-- RESULTADOS DEL EVALUADO
				EXEC [Evaluacion360].[spIEntregaDeResultadosEvaluadoEvaluacion360] @IDProyecto, @FilesEvaluaciones;

				SELECT IDEntregaDeResultado
				FROM [Evaluacion360].[tblEntregaDeResultadosEvaluadoEvaluacion360]
				WHERE IDProyecto = @IDProyecto
						AND EnviarResultadoAColaborador = @SI;

			END
		
		
		/*	QUEDA PENDIENTE (NO EXISTE UN FLUJO AUN DE LAS SIGUIENTES EVALUACIONES)

		IF(@IDTipoProyecto = @EVALUACION_DESEMPENO)
			BEGIN
				SELECT 'FLUJO NUEVO'
			END

		IF(@IDTipoProyecto = @EVALUACION_CLIMA_LABORAL)
			BEGIN
				SELECT 'FLUJO NUEVO'
			END

		IF(@IDTipoProyecto = @EVALUACION_ENCUESTA)
			BEGIN
				SELECT 'FLUJO NUEVO'
			END
		
		*/

 END
GO
