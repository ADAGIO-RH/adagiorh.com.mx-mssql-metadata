USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: <Descripción,varchar,Descripción>
** Autor			: <Autor,varchar,Nombre>
** Email			: <Email,varchar,@adagio.com.mx>
** FechaCreacion	: <FechaCreacion,Date,Fecha>
** Paremetros		:              

** DataTypes Relacionados: 

	Si se modifica el result set de este SP es necesario modificar los siguientes SP:
		-- [Evaluacion360].[spCalcularTotalesEvaluacionesEmpleadosPorProyecto]
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
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
		,@Procetaje  decimal(10,2)
		,@ProcetajeCompetencias  decimal(10,2)
		,@ProcetajeKPIs  decimal(10,2)
		,@ProcetajeValores  decimal(10,2)
		,@ProcetajeFuncionClave  decimal(10,2)
		,@ProcetajeSeccion decimal(10,2)
		,@Divisor int = 0
		,@ColorCompetencia VARCHAR(25)
		,@NombreCompetencia VARCHAR(100)
		,@ColorObjetivo VARCHAR(25)
		,@NombreObjetivo VARCHAR(100)
		,@ColorValor VARCHAR(25)
		,@NombreValor VARCHAR(100)
		,@NombreFuncionClave VARCHAR(100)
		,@ColorFuncionClave VARCHAR(25)
		,@NombreSeccion VARCHAR(100)
		,@ColorSeccion VARCHAR(25)
        ,@IDIdioma VARCHAR(max);
    
    select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')
	

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
		,JSON_VALUE(estatus.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Estatus')) as Estatus
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
	
	select  em.IDEvaluacionEmpleado,
    em.IDTipoRelacion,
     JSON_VALUE(ctp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Relacion')) as Relacion
	INTO #tempEvaluacionesCompletas
	from [Evaluacion360].[tblEvaluacionesEmpleados] em
		join [Evaluacion360].[tblEmpleadosProyectos] ep with (nolock) on em.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		join [Evaluacion360].[tblCatTiposRelaciones] ctp on em.IDTipoRelacion = ctp.IDTipoRelacion
		left join #tempHistorialEstatusEvaluacion estatus on em.IDEvaluacionEmpleado = estatus.IDEvaluacionEmpleado and estatus.ROW = 1
	where ep.IDEmpleadoProyecto = @IDEmpleadoProyecto and estatus.IDEstatus = 13 /*Estatus COMPLETA*/


	select cg.*
			,tctg.Nombre AS TipoGrupo
			,tctg.Color
	INTO #tempGrupos
	from [Evaluacion360].[tblCatGrupos] cg
		join #tempEvaluacionesCompletas e on cg.IDReferencia = e.IDEvaluacionEmpleado
		JOIN [Evaluacion360].[tblCatTipoGrupo] tctg	ON cg.IDTipoGrupo = tctg.IDTipoGrupo
	where cg.IDGrupo in (
		select cg.IDGrupo
		from [Evaluacion360].[tblCatGrupos] cg
			join Evaluacion360.tblCatPreguntas p on p.IDGrupo = cg.IDGrupo 
			join  #tempEvaluacionesCompletas e on cg.IDReferencia = e.IDEvaluacionEmpleado
			--JOIN [Evaluacion360].[tblCatTipoGrupo] tctg	ON cg.IDTipoGrupo = tctg.IDTipoGrupo			
		where (cg.TipoReferencia = 4) and cg.Porcentaje is not null and isnull(p.Calificar, 0) = 1
		GROUP BY cg.IDGrupo
	)	

	if exists (select top 1 1 from #tempGrupos where IDTipoGrupo = 1)
	begin
		set @Divisor = @Divisor+1;
		select top 1 @NombreCompetencia = TipoGrupo, @ColorCompetencia = Color from #tempGrupos where IDTipoGrupo = 1		
	end;

	if exists (select top 1 1 from #tempGrupos where IDTipoGrupo = 2)
	begin
		set @Divisor = @Divisor+1;
		select top 1 @NombreObjetivo = TipoGrupo, @ColorObjetivo = Color from #tempGrupos where IDTipoGrupo = 2	
	end;

	if exists (select top 1 1 from #tempGrupos where IDTipoGrupo = 3)
	begin
		set @Divisor = @Divisor+1;
		select top 1 @NombreValor = TipoGrupo, @ColorValor = Color from #tempGrupos where IDTipoGrupo = 3
	end;

	if exists (select top 1 1 from #tempGrupos where IDTipoGrupo = 4)
	begin
		set @Divisor = @Divisor+1;
		select top 1 @NombreFuncionClave = TipoGrupo, @ColorFuncionClave = Color from #tempGrupos where IDTipoGrupo = 4
	end;

	if exists (select top 1 1 from #tempGrupos where IDTipoGrupo = 5)
	begin
		set @Divisor = @Divisor+1;
		select top 1 @NombreSeccion = TipoGrupo, @ColorSeccion = Color from #tempGrupos where IDTipoGrupo = 5
	end;

	select
		@ProcetajeCompetencias = 
			case when count(*) > 0 then 
				cast(SUM(isnull(g.Porcentaje,0.00)) / count(*) AS decimal(10,2))
			else 0 end
	from #tempGrupos g
	where IDTipoGrupo = 1	

	select
		@ProcetajeKPIs = 
			case when count(*) > 0 then 
				cast(SUM(isnull(g.Porcentaje,0.00)) / count(*) AS decimal(10, 2))
			else 0 end
	from #tempGrupos g
	where IDTipoGrupo = 2
	
	select
		@ProcetajeValores = 
			case when count(*) > 0 then 
				cast(SUM(isnull(g.Porcentaje,0.00)) / count(*) AS decimal(10,2))
			else 0 end
	from #tempGrupos g
	where IDTipoGrupo = 3

	select
		@ProcetajeFuncionClave = 
			case when count(*) > 0 then 
				cast(SUM(isnull(g.Porcentaje,0.00)) / count(*) AS decimal(10,2))
			else 0 end
	from #tempGrupos g
	where IDTipoGrupo = 4

	select
		@ProcetajeSeccion = 
			case when count(*) > 0 then 
				cast(SUM(isnull(g.Porcentaje,0.00)) / count(*) AS decimal(10,2))
			else 0 end
	from #tempGrupos g
	where IDTipoGrupo = 5

	set @Divisor = case when isnull(@Divisor,0) = 0 then 1 else @Divisor end
	
	select 
		'<b>Resumen de Evaluación de Desempeño:</b> Este es el resultado global de <b>'+@NombreColaborador+'</b> con respecto a su desempeño y la percepción del mismo.' as Texto
		--,isnull(@Procetaje,0) as Porcentaje
		,cast((isnull(@ProcetajeCompetencias,0.0)+isnull(@ProcetajeKPIs,0.0)+isnull(@ProcetajeValores,0.0)+isnull(@ProcetajeFuncionClave,0.0)+isnull(@ProcetajeSeccion,0.0)) / @Divisor AS decimal(10,1)) as Porcentaje
		,isnull(@ProcetajeCompetencias,0.0) as PorcentajeCompetencias
		,isnull(@ProcetajeKPIs,0.0) as PorcentajeKPIs
		,isnull(@ProcetajeValores,0.0) as PorcentajeValores
		,isnull(@ProcetajeFuncionClave,0.0) as PorcentajeFuncionClave		
		,isnull(@ProcetajeSeccion,0.0) as PorcentajeSeccion
		,@NombreCompetencia as NombreCompetencia
		,@ColorCompetencia as ColorCompetencia
		,@NombreObjetivo as NombreObjetivoKpi 
		,@ColorObjetivo as ColorObjetivoKpi
		,@NombreValor as NombreValor 
		,@ColorValor as ColorValor
		,@NombreFuncionClave as NombreFuncionClave
		,@ColorFuncionClave as ColorFuncionClave
		,@NombreSeccion as NombreSeccion
		,@ColorSeccion as ColorSeccion
GO
