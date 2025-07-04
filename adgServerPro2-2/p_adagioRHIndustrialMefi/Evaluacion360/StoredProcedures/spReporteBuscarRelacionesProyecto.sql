USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [Evaluacion360].[spReporteBuscarRelacionesProyecto] (
	@IDUsuario		INT,
	@IDProyecto		INT
) AS
Declare 
@IDIdioma VARCHAR(max)
select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	SET NOCOUNT ON;
    IF 1=0 BEGIN
		SET FMTONLY OFF
    END

	DECLARE @Resultado VARCHAR(250)
			, @Privacidad BIT = 0
			, @PrivacidadDescripcion VARCHAR(25)
			, @ACTIVO BIT = 1
			;


	-- VALIDACION PRUEBAS ANONIMAS
	EXEC [Evaluacion360].[spValidarPruebasAnonimas] 
		@IDProyecto = @IDProyecto
		, @EsRptBasico = 1
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


	if object_id('tempdb..#tempHistorialEstatusEvaluacion') is not NULL drop table #tempHistorialEstatusEvaluacion;
	
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
	
	INSERT @RelacionesProyecto
	EXEC [Evaluacion360].[spBuscarRelacionesProyecto]
		@IDProyecto = @IDProyecto,
		@IDUsuario = @IDUsuario

	DELETE @RelacionesProyecto 
	WHERE isnull(IDEvaluador, 0) = 0

	select 
		rp.IDEmpleadoProyecto,
		rp.IDProyecto,
		rp.IDEmpleado,
		rp.ClaveEmpleado,
		rp.Colaborador,
		rp.IDEvaluacionEmpleado,
		rp.IDTipoRelacion,
		rp.Relacion,
		rp.IDEvaluador,		
		--rp.ClaveEvaluador,
		CASE 
			WHEN @Privacidad = @ACTIVO
				THEN @PrivacidadDescripcion
				ELSE rp.ClaveEvaluador
			END AS ClaveEvaluador,
		--rp.Evaluador,
		CASE 
			WHEN @Privacidad = @ACTIVO
				THEN @PrivacidadDescripcion
				ELSE rp.Evaluador
			END AS Evaluador,
		rp.Minimo,
		rp.Maximo,
		rp.Requerido,
		rp.Evaluar,
		rp.TotalPaginas,
		rp.TotalRows,
		h.*
	from @RelacionesProyecto rp
		left join #tempHistorialEstatusEvaluacion h on h.IDEvaluacionEmpleado = rp.IDEvaluacionEmpleado and h.[ROW] = 1
	order by h.IDEstatus, rp.IDEmpleado
GO
