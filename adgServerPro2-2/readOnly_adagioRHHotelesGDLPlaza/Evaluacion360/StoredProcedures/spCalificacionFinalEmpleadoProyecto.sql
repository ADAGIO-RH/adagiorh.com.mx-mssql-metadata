USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Evaluacion360].[spCalificacionFinalEmpleadoProyecto] (
	@IDEmpleadoProyecto int
) as

	SET NOCOUNT ON;
    IF 1=0 BEGIN
		SET FMTONLY OFF
    END

	declare 
		@MaxValorEscalaValoracion decimal(10,2) = 0.0
		,@TipoPreguntaEscala int = 0
		,@NombreColaborador varchar(255) /* 8: Escala proyecto | 9: Escala Grupo*/
		,@Texto varchar(max)
		,@Procetaje  decimal(10,1)
		,@ProcetajeCompetencias  decimal(10,1)
		,@ProcetajeKPIs  decimal(10,1)
		,@ProcetajeValores  decimal(10,1)
		,@Divisor int = 0
	;

	select top 1 
		@NombreColaborador = coalesce(e.Nombre,'')+' '+coalesce(e.Paterno,'')+' '+coalesce(e.Materno,'')
	from [Evaluacion360].[tblEmpleadosProyectos] ep
		join [RH].[tblEmpleadosMaster] e on ep.IDEmpleado = e.IDEmpleado
	where ep.IDEmpleadoProyecto = @IDEmpleadoProyecto

	if object_id('tempdb..#tempHistorialEstatusEvaluacion') is not NULL drop table #tempHistorialEstatusEvaluacion;
	if object_id('tempdb..#tempEvaluacionesCompletas') is not null drop table #tempEvaluacionesCompletas;
	if object_id('tempdb..#tempEstadisticos') is not null drop table #tempEstadisticos;
	if object_id('tempdb..#tempEstadisticosFinal') is not null drop table #tempEstadisticosFinal;
	if object_id('tempdb..#tempGrupos') is not null drop table #tempGrupos;

	select ee.*
		,eee.IDEstatusEvaluacionEmpleado
		,eee.IDEstatus
		,estatus.Estatus
		,eee.IDUsuario
		,eee.FechaCreacion 
		,ROW_NUMBER()over(partition by eee.IDEvaluacionEmpleado 
							ORDER by eee.IDEvaluacionEmpleado, eee.FechaCreacion  desc) as [ROW]
	INTO #tempHistorialEstatusEvaluacion
	from [Evaluacion360].[tblEvaluacionesEmpleados] ee with (nolock)
		join [Evaluacion360].[tblEmpleadosProyectos] ep with (nolock) on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		left join [Evaluacion360].[tblEstatusEvaluacionEmpleado] eee with (nolock) on ee.IDEvaluacionEmpleado = eee.IDEvaluacionEmpleado --and eee.IDEstatus = 10
		left join (select * from Evaluacion360.tblCatEstatus where IDTipoEstatus  = 2) estatus on eee.IDEstatus = estatus.IDEstatus
	where ep.IDEmpleadoProyecto = @IDEmpleadoProyecto

	select  em.IDEvaluacionEmpleado,em.IDTipoRelacion,ctp.Relacion
	INTO #tempEvaluacionesCompletas
	from [Evaluacion360].[tblEvaluacionesEmpleados] em
		join [Evaluacion360].[tblEmpleadosProyectos] ep with (nolock) on em.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		join [Evaluacion360].[tblCatTiposRelaciones] ctp on em.IDTipoRelacion = ctp.IDTipoRelacion
		left join #tempHistorialEstatusEvaluacion estatus on em.IDEvaluacionEmpleado = estatus.IDEvaluacionEmpleado and estatus.ROW = 1
	where ep.IDEmpleadoProyecto = @IDEmpleadoProyecto and estatus.IDEstatus = 13 /*Estatus COMPLETA*/

	select cg.*
			,tctg.Nombre AS TipoGrupo
	INTO #tempGrupos
	from [Evaluacion360].[tblCatGrupos] cg
		join  #tempEvaluacionesCompletas e on cg.IDReferencia = e.IDEvaluacionEmpleado
		JOIN [Evaluacion360].[tblCatTipoGrupo] tctg	ON cg.IDTipoGrupo = tctg.IDTipoGrupo
	where (cg.TipoReferencia = 4) and Porcentaje is not null

	if exists (select top 1 1 from #tempGrupos where IDTipoGrupo = 1)
	begin
		set @Divisor = @Divisor+1;
	end;

	if exists (select top 1 1 from #tempGrupos where IDTipoGrupo = 2)
	begin
		set @Divisor = @Divisor+1;
	end;

	if exists (select top 1 1 from #tempGrupos where IDTipoGrupo = 3)
	begin
		set @Divisor = @Divisor+1;
	end;

	select
		@ProcetajeCompetencias = 
			case when count(*) > 0 then 
				cast(SUM(isnull(g.Porcentaje,0.0)) / count(*) AS decimal(10,1))
			else 0 end
	from #tempGrupos g
	where IDTipoGrupo = 1	

	select
		@ProcetajeKPIs = 
			case when count(*) > 0 then 
				cast(SUM(isnull(g.Porcentaje,0.0)) / count(*) AS decimal(10,1))
			else 0 end
	from #tempGrupos g
	where IDTipoGrupo = 2
	
	select
		@ProcetajeValores = 
			case when count(*) > 0 then 
				cast(SUM(isnull(g.Porcentaje,0.0)) / count(*) AS decimal(10,1))
			else 0 end
	from #tempGrupos g
	where IDTipoGrupo = 3

	set @Divisor = case when isnull(@Divisor,0) = 0 then 1 else @Divisor end

	select 
		'<b>Resumen de Evaluación de Desempeño:</b> Este es el resultado global de <b>'+@NombreColaborador+'</b> con respecto a su desempeño y la percepción del mismo.' as Texto
		--,isnull(@Procetaje,0) as Porcentaje
		,cast((isnull(@ProcetajeCompetencias,0.0)+isnull(@ProcetajeKPIs,0.0)+isnull(@ProcetajeValores,0.0)) / @Divisor AS decimal(10,1)) as Porcentaje
		,isnull(@ProcetajeCompetencias,0.0) as PorcentajeCompetencias
		,isnull(@ProcetajeKPIs,0.0) as PorcentajeKPIs
		,isnull(@ProcetajeValores,0.0) as PorcentajeValores
GO
