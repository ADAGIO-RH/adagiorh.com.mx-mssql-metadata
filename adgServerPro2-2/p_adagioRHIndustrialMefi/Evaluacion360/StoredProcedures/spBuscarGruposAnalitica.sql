USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca los grupos de preguntas de la evaluación.
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

CREATE   PROCEDURE [Evaluacion360].[spBuscarGruposAnalitica](
	@IDProyecto		INT = 0
	, @IDUsuario	INT = 0
)
AS
	BEGIN		
		
		DECLARE @PRUEBA_FINAL					INT = 4
				, @IMPORTANCIA_DE_INDICADORES	INT = 6
		;

		SELECT P.IDProyecto
				--, G.IDGrupo
				, G.IDTipoPreguntaGrupo
				, G.Nombre AS Grupo				
				--, EE.IDEvaluacionEmpleado
				--, EE.IDEmpleadoProyecto
		FROM [Evaluacion360].[tblCatProyectos] P
			LEFT JOIN [Evaluacion360].[tblEmpleadosProyectos] EP ON P.IDProyecto = EP.IDProyecto
			LEFT JOIN [Evaluacion360].[tblEvaluacionesEmpleados] EE ON EP.IDEmpleadoProyecto = EE.IDEmpleadoProyecto
			JOIN [Evaluacion360].[tblCatGrupos] G ON EE.IDEvaluacionEmpleado = G.IDReferencia
		WHERE P.IDProyecto = @IDProyecto AND
			  G.TipoReferencia = @PRUEBA_FINAL AND
			  G.IDTipoPreguntaGrupo <> @IMPORTANCIA_DE_INDICADORES
		GROUP BY P.IDProyecto, G.IDTipoPreguntaGrupo, G.Nombre
		ORDER BY G.Nombre

	END
GO
