USE [p_adagioRHAlleiva]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca las relaciones que tienen los evaluados asignados al @IDEmpleado para evaluar
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2022-09-28
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROC [Evaluacion360].[spBuscarRelacionEvaluadosAsignados](
	@IDEmpleado INT,
	@IDUsuario INT,
	@IDProyecto INT
) AS
	SELECT EE.IDTipoRelacion,
		   TP.Relacion,
		   EE.IDEvaluador,
		   CASE 
				WHEN EE.IDTipoRelacion = 4
					THEN CAST(0 AS BIT)
					ELSE CAST(1 AS BIT)
				END AS Evaluar
	FROM [Evaluacion360].[tblEmpleadosProyectos] EP 
		JOIN [Evaluacion360].[tblEvaluacionesEmpleados] EE ON EE.IDEmpleadoProyecto = EP.IDEmpleadoProyecto
		JOIN [Evaluacion360].[tblCatTiposRelaciones] TP ON EE.IDTipoRelacion = TP.IDTipoRelacion
	WHERE EP.IDProyecto = @IDProyecto AND
		  EE.IDEvaluador = @IDEmpleado AND
		  EP.TipoFiltro != 'Excluir Empleado'
	GROUP BY EE.IDTipoRelacion,
			 TP.Relacion,
			 EE.IDEvaluador
	ORDER by EE.IDTipoRelacion DESC
GO
