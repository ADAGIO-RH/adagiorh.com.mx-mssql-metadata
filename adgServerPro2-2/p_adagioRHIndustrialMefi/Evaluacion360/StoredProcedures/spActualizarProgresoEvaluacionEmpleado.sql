USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Evaluacion360].[spActualizarProgresoEvaluacionEmpleado](
	@IDEvaluacionEmpleado int
) as

	declare
		@TotalPreguntas int = 0
		,@TotalPreguntasRespondidas int = 0 
		,@IDProyecto int = 0
		,@SoloPreguntasRequeridas bit = 0
		,@Promedio   DECIMAL (10, 2)  
		,@Porcentaje DECIMAL (10, 2)  
		,@TIPO_REFERENCIA_EVALUACION int = 4
	;
	
	select @IDProyecto = ep.IDProyecto 
	from Evaluacion360.tblEvaluacionesEmpleados  ee
		join [Evaluacion360].[tblEmpleadosProyectos] ep on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
	where ee.IDEvaluacionEmpleado = @IDEvaluacionEmpleado

	select @SoloPreguntasRequeridas = case when  lower(Valor) = 'true' then cast(1 as bit) else cast(0 as bit) end
	from [Evaluacion360].[tblConfiguracionAvanzadaProyecto]
	where IDProyecto = @IDProyecto and IDConfiguracionAvanzada = 10

	if object_id('tempdb..#tempPreguntasEvaEmp') is not null drop table #tempPreguntasEvaEmp;

	create table #tempPreguntasEvaEmp(
		IDPregunta int
		,IDTipoPregunta int
		,Pregunta varchar(max)
		,EsRequerida bit
		,Calificar bit
		,Box9 bit
		,Complete bit
		,Respuesta nvarchar(max)
		,[Row] int
	);

	insert #tempPreguntasEvaEmp
	exec [Evaluacion360].[spBuscarPreguntasEvaluacionEmpleado] @IDEvaluacionEmpleado = @IDEvaluacionEmpleado

	select 
		@TotalPreguntas = sum(case when isnull(EsRequerida,cast(0 as bit)) = 1 or isnull(@SoloPreguntasRequeridas,cast(0 as bit)) = 0 then 1 else 0 end)
		,@TotalPreguntasRespondidas = sum(case when (isnull(EsRequerida,cast(0 as bit)) = 1 or isnull(@SoloPreguntasRequeridas,cast(0 as bit)) = 0 ) and isnull(Complete,cast(0 as bit)) = 1 then 1 else 0 end)
	from #tempPreguntasEvaEmp

	select 
		@Promedio = cast(SUM(Promedio)/count(*) as decimal(10,2)), 
		@Porcentaje = cast(SUM(Porcentaje)/count(*) as decimal(10,2))
	from Evaluacion360.tblCatGrupos
	where TipoReferencia = @TIPO_REFERENCIA_EVALUACION and IDReferencia = @IDEvaluacionEmpleado

	update Evaluacion360.tblEvaluacionesEmpleados 
		set 
			TotalPreguntas = isnull(@TotalPreguntas,0)
			,TotalPreguntasRespondidas = isnull(@TotalPreguntasRespondidas,0)
			,Progreso		= case when isnull(@TotalPreguntas,0) > 0 then (isnull(@TotalPreguntasRespondidas,0) * 100) /  isnull(@TotalPreguntas,0) else 0 end
			,[Promedio]		= @Promedio
			,[Porcentaje]	= @Porcentaje
	where IDEvaluacionEmpleado = @IDEvaluacionEmpleado

	--select * from Evaluacion360.tblEvaluacionesEmpleados where IDEvaluacionEmpleado = @IDEvaluacionEmpleado
	--select * from Evaluacion360.tblCatGrupos where TipoReferencia = 4
GO
