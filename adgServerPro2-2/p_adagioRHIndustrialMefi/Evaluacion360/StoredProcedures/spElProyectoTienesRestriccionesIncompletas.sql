USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--[Evaluacion360].[spElProyectoTienesRestriccionesIncompletas] 2,1

CREATE PROC [Evaluacion360].[spElProyectoTienesRestriccionesIncompletas] (
	@IDProyecto int
	,@IDUsuario int
) as
	
	DECLARE @resp bit = 0		

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

	if exists (select top 1 1 
			from #tempEvaluaciones
			where Requerido = 1 and IDEvaluador = 0 )
	BEGIN
		set @resp = 1
	END ELSE
	BEGIN
		set @resp = 0
	END

	select @resp as RestriccionesIncompletas
GO
