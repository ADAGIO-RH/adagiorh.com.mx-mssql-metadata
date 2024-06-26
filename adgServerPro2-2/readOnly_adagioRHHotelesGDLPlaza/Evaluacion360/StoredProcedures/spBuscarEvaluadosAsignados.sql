USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca los colaboradores asignados al @IDEmpleado para evaluar
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@gmail.com
** FechaCreacion	: 2018-10-30
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
/*
 [Evaluacion360].[spBuscarEvaluadosAsignados]
		@IDEmpleado   = 20310
		--,@IDTipoRelacion  = 2
		,@IDUsuario  = 1
		,@IDProyecto = 2	
*/
CREATE proc [Evaluacion360].[spBuscarEvaluadosAsignados](
		@IDEmpleado		 int	 
		,@IDTipoRelacion int = 0
		,@IDUsuario		 int	 
		,@IDProyecto	 int	 
		) as
	select 
		ep.IDEmpleadoProyecto
		,ep.IDProyecto
		,ep.IDEmpleado
		,e.ClaveEmpleado
		,e.NOMBRECOMPLETO as Colaborador
		,ee.IDEvaluacionEmpleado
		,ee.IDTipoRelacion
		,tp.Relacion
		,ee.IDEvaluador
	from  [Evaluacion360].[tblEmpleadosProyectos] ep 
		join [Evaluacion360].[tblEvaluacionesEmpleados]  ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		join [RH].[tblEmpleadosMaster] e on ep.IDEmpleado = e.IDEmpleado
		join [Evaluacion360].[tblCatTiposRelaciones] tp on ee.IDTipoRelacion = tp.IDTipoRelacion
	where ep.IDProyecto = @IDProyecto 
		and (ee.IDTipoRelacion = @IDTipoRelacion or @IDTipoRelacion = 0)
		and ee.IDEvaluador = @IDEmpleado
GO
