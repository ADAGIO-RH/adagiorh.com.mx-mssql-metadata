USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca preguntas de la evaluación.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-10-31
** Paremetros		: @IDProyecto			- Identificador del proyecto.
					  @IDUsuario			- Identificador del usuario.
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

CREATE   PROCEDURE [Evaluacion360].[spBuscarPreguntasAnalitica](
	@IDProyecto		INT = 0
	, @IDUsuario	INT = 0
)
AS
	BEGIN
		
		DECLARE @PRUEBA_FINAL	INT = 4
				, @SI			INT = 1
				;

		;WITH tblGrupos(IDProyecto, IDGrupo, Grupo, IDTipoPreguntaGrupo, IDEvaluacionEmpleado)
		AS(
			SELECT P.IDProyecto
					, G.IDGrupo
					, G.Nombre AS Grupo
					, G.IDTipoPreguntaGrupo
					, EE.IDEvaluacionEmpleado					
					--, G.Nombre
					--, EE.IDEmpleadoProyecto
			FROM [Evaluacion360].[tblCatProyectos] P
				LEFT JOIN [Evaluacion360].[tblEmpleadosProyectos] EP ON P.IDProyecto = EP.IDProyecto
				LEFT JOIN [Evaluacion360].[tblEvaluacionesEmpleados] EE ON EP.IDEmpleadoProyecto = EE.IDEmpleadoProyecto
				JOIN [Evaluacion360].[tblCatGrupos] G ON EE.IDEvaluacionEmpleado = G.IDReferencia
			WHERE P.IDProyecto = @IDProyecto AND
				  G.TipoReferencia = @PRUEBA_FINAL
			--GROUP BY P.IDProyecto, G.IDGrupo
			--ORDER BY G.IDGrupo
		)
		SELECT G.IDProyecto
				, G.IDTipoPreguntaGrupo
				, G.Grupo
				, P.Descripcion AS Pregunta
				, P.Calificar
		FROM tblGrupos G	
			JOIN Evaluacion360.tblCatPreguntas P ON G.IDGrupo = P.IDGrupo
		WHERE G.IDGrupo = P.IDGrupo
		GROUP BY G.IDProyecto, G.IDTipoPreguntaGrupo, G.Grupo, P.Descripcion, P.Calificar

	END
GO
