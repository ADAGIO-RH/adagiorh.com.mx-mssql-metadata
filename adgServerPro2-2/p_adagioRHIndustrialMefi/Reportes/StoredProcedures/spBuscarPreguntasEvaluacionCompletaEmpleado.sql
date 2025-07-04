USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca las preguntas de los grupos que le pertenecen a una evaluacion completa.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-03-30
** Paremetros		: @IDEmpleadoProyecto	Identificador de la evaluación.
					  @IDTipoGrupo			Identificador del tipo de grupo.

	TipoReferencia:
		0 : Catálogo
		1 : Asignado a una Prueba
		2 : Asignado a un colaborador
		3 : Asignado a un puesto
		4 : Asignado a una Prueba final para responder

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

CREATE   PROC [Reportes].[spBuscarPreguntasEvaluacionCompletaEmpleado]
(
	@IDEmpleadoProyecto INT,
	@IDTipoGrupo INT = NULL
) AS

	SET NOCOUNT ON;

		IF 1 = 0 
			BEGIN
				SET FMTONLY OFF
			END

		DECLARE @IDProyecto INT = 0,
				@MaxValorEscalaValoracion DECIMAL(10,2) = 0.0,
				@Completa INT = 13,
				@PruebaFinal INT = 4,
				@CalificarTRUE INT = 1,
                @IDIdioma VARCHAR(max);
        
select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')


		SELECT @IDProyecto = ep.IDProyecto
		FROM [Evaluacion360].[tblEmpleadosProyectos] EP WITH (NOLOCK)
		WHERE ep.IDEmpleadoProyecto = @IDEmpleadoProyecto
			
		SELECT @MaxValorEscalaValoracion = MAX(Valor)
		FROM [Evaluacion360].[tblEscalasValoracionesProyectos]
		WHERE IDProyecto = @IDProyecto


		-- TABLAS TEMPORALES
		IF OBJECT_ID('tempdb..#tempHistorialEstatusEvaluacion') IS NOT NULL
			DROP TABLE #tempHistorialEstatusEvaluacion;

		IF OBJECT_ID('tempdb..#tempEvaluacionesCompletas') IS NOT NULL
			DROP TABLE #tempEvaluacionesCompletas;


		-- HISTORIAL DE EVALUACIONES
		SELECT EE.*,
			   EEE.IDEstatusEvaluacionEmpleado,
			   EEE.IDEstatus,
			   JSON_VALUE(ESTATUS.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Estatus')) as Estatus,
			   EEE.IDUsuario,
			   EEE.FechaCreacion,
			   ROW_NUMBER() OVER(PARTITION BY EEE.IDEvaluacionEmpleado ORDER BY EEE.IDEvaluacionEmpleado, EEE.FechaCreacion DESC) AS [ROW]
		INTO #tempHistorialEstatusEvaluacion
		FROM [Evaluacion360].[tblEvaluacionesEmpleados] EE WITH (NOLOCK)
			JOIN [Evaluacion360].[tblEmpleadosProyectos] EP WITH (NOLOCK) ON EE.IDEmpleadoProyecto = EP.IDEmpleadoProyecto
			LEFT JOIN [Evaluacion360].[tblEstatusEvaluacionEmpleado] EEE WITH (NOLOCK) on EE.IDEvaluacionEmpleado = EEE.IDEvaluacionEmpleado
			LEFT JOIN (SELECT * FROM Evaluacion360.tblCatEstatus WHERE IDTipoEstatus = 2) ESTATUS ON EEE.IDEstatus = ESTATUS.IDEstatus
		WHERE EP.IDEmpleadoProyecto = @IDEmpleadoProyecto


		-- EVALUACIONES COMPLETAS
		SELECT EM.IDEvaluacionEmpleado,
			   EM.IDTipoRelacion,
			   JSON_VALUE(CTP.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Relacion')) as Relacion
		INTO #tempEvaluacionesCompletas
		FROM [Evaluacion360].[tblEvaluacionesEmpleados] EM
			JOIN [Evaluacion360].[tblCatTiposRelaciones] CTP ON EM.IDTipoRelacion = CTP.IDTipoRelacion
			LEFT JOIN #tempHistorialEstatusEvaluacion ESTATUS ON EM.IDEvaluacionEmpleado = ESTATUS.IDEvaluacionEmpleado AND ESTATUS.ROW = 1
		WHERE EM.IDEmpleadoProyecto = @IDEmpleadoProyecto AND 
			  ESTATUS.IDEstatus = @Completa


		-- OBTENEMOS LOS GRUPOS DE LAS EVALUACIONES COMPLETAS POR RELACION
		SELECT CG.IDGrupo,
			   CG.Nombre
		INTO #tempGrupos
		FROM [Evaluacion360].[tblCatGrupos] CG
			JOIN #tempEvaluacionesCompletas E ON CG.IDReferencia = E.IDEvaluacionEmpleado
		WHERE (CG.TipoReferencia = @PruebaFinal) AND (CG.IDTipoGrupo = @IDTipoGrupo OR @IDTipoGrupo IS NULL)

		
		SELECT P.Descripcion AS Pregunta,
			   replace( replace(
						replace(
						replace(
						replace(N'<p> <b>'+ G.Nombre +' </b> <br/>'+ P.Descripcion +'</p>'
								,'\', '\\' )
								,'%', '\%' )
								,'_', '\_' )
								,'[', '\[' )
								,'&','Y') AS PreguntaYCompetencia
		FROM #tempGrupos G
			JOIN [Evaluacion360].[tblCatPreguntas] P ON G.IDGrupo = P.IDGrupo
		WHERE P.Calificar = @CalificarTRUE
		GROUP BY G.Nombre, P.Descripcion
GO
