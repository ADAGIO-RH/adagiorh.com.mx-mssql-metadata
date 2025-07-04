USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Valida si colaborador ya ha sido evaluado
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-12-08
** Paremetros		: @IDProyecto	Identificador del proyecto
**					: @IDEmpleado	Identificador del empleado a evaluar
**					: @IDUsuario	Identificador del usuario
** IDAzure			: 

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROCEDURE [Evaluacion360].[spValidarExcluirColaborador](
	@IDProyecto INT,
	@IDEmpleado INT,
	@IDUsuario	INT
) AS
	
	BEGIN
			
			DECLARE @PRUEBA_FINAL INT = 4;

			DECLARE @TblRespuestas TABLE(
				IDEvaluado INT,
				IDEvaluador	INT,
				IDEvaluacionEmpleado INT,
				IDEmpleadoProyecto INT,
				IDGrupo INT,
				TipoReferencia INT,
				NoPreguntas INT,
				NoRespuestas INT
			) 

			
			INSERT INTO @TblRespuestas
			SELECT EP.IDEmpleado AS IDEvaluado
					, EE.IDEvaluador
					, EE.IDEvaluacionEmpleado
					, EE.IDEmpleadoProyecto
					, GR.IDGrupo
					, GR.TipoReferencia
					, COUNT(PR.IDPregunta) NoPreguntas
					, COUNT(RE.IDRespuestaPregunta) NoRespuestas
			FROM Evaluacion360.tblCatProyectos P
				LEFT JOIN [Evaluacion360].[tblEmpleadosProyectos] EP ON P.IDProyecto = EP.IDProyecto		
				LEFT JOIN [Evaluacion360].[tblEvaluacionesEmpleados] EE ON EP.IDEmpleadoProyecto = EE.IDEmpleadoProyecto
				LEFT JOIN [Evaluacion360].[tblCatGrupos] GR ON EE.IDEvaluacionEmpleado = GR.IDReferencia
				LEFT JOIN [Evaluacion360].[tblCatPreguntas] PR ON GR.IDGrupo = PR.IDGrupo
				LEFT JOIN [Evaluacion360].[tblRespuestasPreguntas] RE ON PR.IDPregunta = RE.IDPregunta
			WHERE P.IDProyecto = @IDProyecto AND
				  EP.IDEmpleado = @IDEmpleado AND
				  GR.TipoReferencia = @PRUEBA_FINAL
			GROUP BY EP.IDEmpleado
					, EE.IDEvaluador
					, EE.IDEvaluacionEmpleado
					, EE.IDEmpleadoProyecto
					, GR.IDGrupo
					, GR.TipoReferencia
				  
			-- RESULTADO
			SELECT * FROM @TblRespuestas WHERE NoRespuestas > 0

	END
GO
