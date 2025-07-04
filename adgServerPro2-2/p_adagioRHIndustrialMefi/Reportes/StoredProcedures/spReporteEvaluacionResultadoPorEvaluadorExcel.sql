USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     proc [Reportes].[spReporteEvaluacionResultadoPorEvaluadorExcel] (
	@dtFiltros [Nomina].[dtFiltrosRH] readonly,
	@IDUsuario int 
) as
	declare 
		@IDProyecto int 
		--,@IDUsuario int = 1
		, @Resultado VARCHAR(250)
		, @Privacidad BIT = 0
		, @PrivacidadDescripcion VARCHAR(25)
		, @ACTIVO BIT = 1

	
	  ,@IDIdioma VARCHAR(max);
select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')

	SET FMTONLY OFF;

	SET @IDProyecto = (select top 1 cast(Value as int) from @dtFiltros where catalogo = 'IDProyecto')

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

	if object_id('tempdb..#tempHistorialEstatusEvaluacion') is not NULL drop table #tempHistorialEstatusEvaluacion;
	if object_id('tempdb..#tempGrupos') is not null drop table #tempGrupos;


	-- VALIDACION PRUEBAS ANONIMAS
	EXEC [Evaluacion360].[spValidarPruebasAnonimas] 
		@IDProyecto = @IDProyecto
		, @Resultado = @Resultado OUTPUT
		, @Descripcion = @PrivacidadDescripcion OUTPUT
		;

	IF(@Resultado <> '0' AND @Resultado <> '1')
		BEGIN					
			RAISERROR(@Resultado, 16, 1);  
			RETURN
		END
	ELSE
		BEGIN
			SET @Privacidad = @Resultado;
		END
	-- TERMINA VALIDACION

	
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
		cg.*
		,e.*
	INTO #tempGrupos
	from [Evaluacion360].[tblCatGrupos] cg
		join @RelacionesProyecto e on cg.IDReferencia = e.IDEvaluacionEmpleado
	where cg.IDGrupo in (
		select cg.IDGrupo
		from [Evaluacion360].[tblCatGrupos] cg
			join Evaluacion360.tblCatPreguntas p on p.IDGrupo = cg.IDGrupo 
			join  @RelacionesProyecto e on cg.IDReferencia = e.IDEvaluacionEmpleado
			JOIN [Evaluacion360].[tblCatTipoGrupo] tctg	ON cg.IDTipoGrupo = tctg.IDTipoGrupo
		where (cg.TipoReferencia = 4) and cg.Porcentaje is not null and isnull(p.Calificar, 0) = 1
	)

	select 
		rp.ClaveEmpleado as [CLAVE COLABORADOR],
		rp.Colaborador AS [COLABORADOR],
		--rp.ClaveEvaluador AS [CLAVE EVALUADOR],
		CASE 
			WHEN @Privacidad = @ACTIVO
				THEN @PrivacidadDescripcion
				ELSE rp.ClaveEvaluador
			END AS [CLAVE EVALUADOR],
		--rp.Evaluador AS [EVALUADOR],
		CASE 
			WHEN @Privacidad = @ACTIVO
				THEN @PrivacidadDescripcion
				ELSE rp.Evaluador
			END AS [EVALUADOR],
		rp.Relacion AS [RELACION],
		cast( sum(rp.Porcentaje) / cast(count(*) as decimal(10,2)) as decimal(10,2)) as  [PORCENTAJE],
		cast( sum(rp.Promedio) / cast(count(*)  as decimal(10,2)) as decimal(10,2)) as [PROMEDIO]
	from #tempGrupos rp
	group by rp.IDEmpleado,
		rp.ClaveEmpleado,
		rp.Colaborador,
		rp.ClaveEvaluador,
		rp.Evaluador,
		rp.Relacion
GO
