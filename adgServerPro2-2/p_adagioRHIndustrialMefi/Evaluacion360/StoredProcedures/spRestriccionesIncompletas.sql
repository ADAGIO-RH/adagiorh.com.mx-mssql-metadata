USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- [Evaluacion360].[spRestriccionesIncompletas]  2,1
CREATE PROC [Evaluacion360].[spRestriccionesIncompletas] (
	@IDProyecto int
	,@IDUsuario int
) as

if object_id('tempdb..#tempEvaluaciones') is not null
		drop table #tempEvaluaciones;

	create table #tempEvaluaciones(
		IDEmpleadoProyecto int
		,IDProyecto int
		,IDEmpleado int
		,ClaveEmpleado varchar(20)
		,Colaborador varchar(max)
		,IDEvaluacionEmpleado int
		,IDTipoRelacion int
		,Relacion varchar(255)
		,IDEvaluador int
		,ClaveEvaluador varchar(20)
		,Evaluador varchar(max)
		,Minimo int
		,Maximo int
		,Requerido bit 
		,[Row] int
		,IDEstatusEvaluacionEmpleado int
		,IDEstatus int
		,Estatus varchar(255)
		,Progreso int
	);

	insert #tempEvaluaciones
	exec [Evaluacion360].[spBuscarEvaluacionesEmpleadosPorProyecto] @IDProyecto,@IDUsuario

	select distinct IDEmpleadoProyecto,IDProyecto,IDEmpleado,ClaveEmpleado,Colaborador,Relacion
	from #tempEvaluaciones
	where Requerido = 1 and IDEvaluador = 0
GO
