USE [p_adagioRHAfosa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar grupos de preguntas y sus comentarios
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-04-05
** Paremetros		: @IDEmpleadoProyecto			- Identificador del empleado proyecto	  
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

CREATE   PROC [Reportes].[spBuscarComentariosGrupos](
	@IDEmpleadoProyecto INT 
) AS
	
	DECLARE @PruebaFinal INT = 4;
	DECLARE @dtUsuarios [Seguridad].[dtUsuarios]

	INSERT @dtUsuarios
	EXEC [Seguridad].[spBuscarUsuarios]

	SELECT UPPER(TG.Nombre) + ' - ' + UPPER(G.Nombre) AS Grupo,
		   CTR.Relacion,
		   CreadoPor = COALESCE(U.Nombre, '') + ' ' + COALESCE(U.Apellido, ''),
		   G.Comentario
	FROM [Evaluacion360].[tblEmpleadosProyectos] P
		JOIN Evaluacion360.tblEvaluacionesEmpleados EE ON P.IDEmpleadoProyecto = EE.IDEmpleadoProyecto
		JOIN [Evaluacion360].[tblCatGrupos] G ON G.TipoReferencia = @PruebaFinal AND G.IDReferencia = EE.IDEvaluacionEmpleado
		JOIN [Evaluacion360].[tblCatTipoGrupo] TG ON TG.IDTipoGrupo = G.IDTipoGrupo
		JOIN [Evaluacion360].[tblCatTiposRelaciones] CTR ON EE.IDTipoRelacion = CTR.IDTipoRelacion
		JOIN @dtUsuarios U ON EE.IDEvaluador = U.IDEmpleado
	WHERE P.IDEmpleadoProyecto = @IDEmpleadoProyecto AND
		  G.Comentario IS NOT NULL
	ORDER BY G.Nombre, CTR.Relacion
GO
