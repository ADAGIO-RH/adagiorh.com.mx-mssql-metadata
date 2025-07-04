USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spBuscarHistorialPruebasEmpleado](
	@IDEmpleado int 
	,@IDUsuario int
 ) as

	declare @dtProyectos  Evaluacion360.dtProyectos
	--,@IDEmpleado int = 390
	--,@IDUsuario int = 1
		;

	insert @dtProyectos
	exec Evaluacion360.spBuscarProyectos @IDUsuario=@IDUsuario

	delete from @dtProyectos where IDEstatus <> 6

	select ep.*
		--,ee.IDEvaluacionEmpleado
		,p.Nombre as Proyecto
		,isnull(cl.Literal,'D') as Literal
		--,e.NOMBRECOMPLETO as Evaluador
		--,ctp.Relacion
	from Evaluacion360.tblEmpleadosProyectos ep 
		join @dtProyectos p on ep.IDProyecto = p.IDProyecto
		left join Evaluacion360.tblCatCalificacionesLiterales cl on floor(isnull(ep.TotalGeneral,0)) between cl.CalificacionInicial and cl.CalificacionFinal
		--join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		--join rh.tblEmpleadosMaster e on ee.IDEvaluador = e.IDEmpleado
		--join Evaluacion360.tblCatTiposRelaciones ctp on ee.IDTipoRelacion = ctp.IDTipoRelacion
	where ep.IDEmpleado = @IDEmpleado
	order by p.FechaInicio desc
GO
