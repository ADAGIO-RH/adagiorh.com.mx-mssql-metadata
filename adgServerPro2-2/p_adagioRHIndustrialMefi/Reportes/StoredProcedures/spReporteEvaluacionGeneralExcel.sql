USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   proc [Reportes].[spReporteEvaluacionGeneralExcel] (
	@dtFiltros [Nomina].[dtFiltrosRH] readonly,
	@IDUsuario int 
) as
	declare 
		@IDProyecto int 
		--,@IDUsuario int = 1
	,@IDIdioma VARCHAR(max)
select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');
	
	SET FMTONLY OFF;

	--select * from Evaluacion360.tblCatProyectos
	SET @IDProyecto = (select top 1 cast(Value as int) from @dtFiltros where catalogo = 'IDProyecto')

	IF OBJECT_ID('tempdb.dbo.##tempRelacionesPrueba_D4D3') IS NOT NULL DROP TABLE ##tempRelacionesPrueba_D4D3

	DECLARE @RelacionesProyecto TABLE(		
		IDEmpleadoProyecto INT,
		IDProyecto INT,
		IDEmpleado INT,
		ClaveEmpleado VARCHAR(20),
		Colaborador VARCHAR(254),
		IDEvaluacionEmpleado INT,
		IDTipoRelacion INT,
		Relacion VARCHAR(100),
		IDEvaluador INT,
		ClaveEvaluador VARCHAR(20),
		Evaluador  VARCHAR(100),
		Minimo INT,
		Maximo INT,
		Requerido BIT,
		Evaluar BIT,
		TotalPaginas INT,
		TotalRows INT
	);

	if object_id('tempdb..#tempCalificacionesColaboradores') is not null drop table #tempCalificacionesColaboradores;
	if object_id('tempdb..#tempHistorialEstatusEvaluacion') is not NULL drop table #tempHistorialEstatusEvaluacion;
	--if object_id('tempdb..#tempCalificacionesMAX') is not null drop table #tempCalificacionesMAX;
	--if object_id('tempdb..#tempCalificacionesMIN') is not null drop table #tempCalificacionesMIN;
	--if object_id('tempdb..#tempCalificacionesFinal') is not null drop table #tempCalificacionesFinal;

	insert @RelacionesProyecto
	exec [Evaluacion360].[spBuscarRelacionesProyecto]  
		 @IDProyecto =@IDProyecto 
		,@IDUsuario =@IDUsuario

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
	where ep.IDProyecto = @IDProyecto


	select 
		rp.IDEmpleado,
		rp.ClaveEmpleado,
		rp.Colaborador,
		--rp.ClaveEvaluador,
		--rp.Evaluador,
		rp.Relacion,
		--cg.Nombre as Grupo, 
		cast( sum(cg.Porcentaje) / count(*) as decimal(10,2)) as Porcentaje,
		cast( sum(cg.Promedio) / count(*) as decimal(10,2)) as Promedio
	INTO #tempCalificacionesColaboradores
	from @RelacionesProyecto rp
		join #tempHistorialEstatusEvaluacion hee on hee.IDEvaluacionEmpleado = rp.IDEvaluacionEmpleado and hee.IDEstatus = 13 /*Estatus COMPLETA*/
		join Evaluacion360.tblCatGrupos cg on cg.TipoReferencia = 4 and cg.IDReferencia = rp.IDEvaluacionEmpleado
		join Evaluacion360.tblCatPreguntas p on p.IDGrupo = cg.IDGrupo and isnull(p.Calificar, 0) = 1
	group by rp.IDEmpleado,
		rp.ClaveEmpleado,
		rp.Colaborador,
		--rp.ClaveEvaluador,
		--rp.Evaluador,
		rp.Relacion
	
	select distinct Relacion
	INTO ##tempRelacionesPrueba_D4D3
	from #tempCalificacionesColaboradores

	DECLARE 
		@colsExtra AS NVARCHAR(MAX),
		@queryExtra  AS NVARCHAR(MAX)
	;

	SET @colsExtra = STUFF((SELECT distinct ',' + QUOTENAME(c.Relacion) 
				FROM ##tempRelacionesPrueba_D4D3 c
				FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)') 
			,1,1,'')

	set @queryExtra = '
		SELECT 
		--	IDEmpleado,
			ClaveEmpleado as [CLAVE COLABORADOR],
			Colaborador as [COLABORADOR],
			' + @colsExtra + ',
			(select AVG(Porcentaje) from #tempCalificacionesColaboradores c where c.IDEmpleado = p.IDEmpleado) [TOTAL GENERAL]
		from (
			select 
				IDEmpleado,
				ClaveEmpleado,
				Colaborador,
				Relacion,
				Porcentaje
			from #tempCalificacionesColaboradores
		) x
		pivot (
			max(Porcentaje)
			for Relacion in (' + @colsExtra + ')
		) p '

	execute(@queryExtra)
GO
