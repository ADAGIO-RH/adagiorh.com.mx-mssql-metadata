USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Manejador de recordatorios para las direfentes tipos de evaluaciones.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-12-12
** Parametros		: @IDProyecto				Identificador del proyecto
**					: @IDEvaluacionEmpleado		Identificador de la evaluación
**					: @IDUsuario				Identificador del usuario
** IDAzure			: #1286

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [Evaluacion360].[spGenerarRecordatorios](
	@IsGeneral				INT = 0
	, @IDProyecto			INT = 0
	, @IDEvaluacionEmpleado	INT = 0
	, @IDEvaluador			INT = 0	
	, @IDUsuario			INT = 0
) AS
	BEGIN
		
		DECLARE @IDTipoProyecto				INT = 0
				, @Tabla					VARCHAR(150) = NULL
				, @IDRecordatorio			INT = 0
				, @EVALUACION_360			INT = 1
				, @EVALUACION_DESEMPENO		INT = 2
				, @EVALUACION_CLIMA_LABORAL INT = 3
				, @EVALUACION_ENCUESTA		INT = 4
				, @NO						BIT = 0
				, @SI						BIT = 1
				;


		-- OBTENEMOS EL TIPO DEL PROYECTO
		SELECT @IDTipoProyecto = IDTipoProyecto FROM [Evaluacion360].[tblCatProyectos] WHERE IDProyecto = @IDProyecto;


		-- OBTENEMOS EL IDEvaluador
		IF(@IsGeneral = @NO)
			BEGIN
				SELECT @IDEvaluador = IDEvaluador
				FROM [Evaluacion360].[tblEvaluacionesEmpleados]
				WHERE IDEvaluacionEmpleado = @IDEvaluacionEmpleado;
			END


		-- ***** CREA RECORDATORIOS DE LOS DIFERENTES TIPOS DE EVALUACIONES *****
		
		IF(@IDTipoProyecto = @EVALUACION_360)
			BEGIN
				
				EXEC [Evaluacion360].[spIRecordatoriosEvaluacion360] @IsGeneral, @IDProyecto, @IDEvaluacionEmpleado, @IDEvaluador, @IDUsuario;

				SELECT TOP 1 @IDRecordatorio = MAX(IDRecordatorio)
				FROM [Evaluacion360].[tblRecordatoriosEvaluacion360]
				WHERE IDProyecto = @IDProyecto
						AND IDEvaluacionEmpleado = @IDEvaluacionEmpleado
						AND IDEvaluador = @IDEvaluador;

			END

		IF(@IDTipoProyecto = @EVALUACION_DESEMPENO)
			BEGIN

				EXEC [Evaluacion360].[spIRecordatoriosEvaluacionDesempeno] @IsGeneral, @IDProyecto, @IDEvaluacionEmpleado, @IDEvaluador, @IDUsuario;

				SELECT TOP 1 @IDRecordatorio = MAX(IDRecordatorio)
				FROM [Evaluacion360].[tblRecordatoriosEvaluacionDesempeno]
				WHERE IDProyecto = @IDProyecto
						AND IDEvaluacionEmpleado = @IDEvaluacionEmpleado
						AND IDEvaluador = @IDEvaluador;

			END


		IF(@IsGeneral = @SI)
			BEGIN
		
				IF(@IDTipoProyecto = @EVALUACION_CLIMA_LABORAL)
					BEGIN
			
						EXEC [Evaluacion360].[spIRecordatoriosEvaluacionClimaLaboral] @IDProyecto, @IDEvaluador, @IDUsuario;

						SELECT TOP 1 @IDRecordatorio = MAX(IDRecordatorio)
						FROM [Evaluacion360].[tblRecordatoriosEvaluacionClimaLaboral]
						WHERE IDProyecto = @IDProyecto								
								AND IDEvaluador = @IDEvaluador;

					END

				IF(@IDTipoProyecto = @EVALUACION_ENCUESTA)
					BEGIN
				
						EXEC [Evaluacion360].[spIRecordatoriosEvaluacionEncuesta] @IDProyecto, @IDEvaluador, @IDUsuario;

						SELECT TOP 1 @IDRecordatorio = MAX(IDRecordatorio)
						FROM [Evaluacion360].[tblRecordatoriosEvaluacionEncuesta]
						WHERE IDProyecto = @IDProyecto								
								AND IDEvaluador = @IDEvaluador;

					END
			END


		SELECT @IDRecordatorio
				, @IDEvaluador
				;

 END
GO
