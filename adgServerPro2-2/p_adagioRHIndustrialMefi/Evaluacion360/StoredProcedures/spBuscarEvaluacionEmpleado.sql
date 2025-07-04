USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spBuscarEvaluacionEmpleado] (
	@IDEvaluacionEmpleado int 
) as

    SET NOCOUNT ON;
     IF 1=0 BEGIN
       SET FMTONLY OFF
     END

	 DECLARE @Resultado VARCHAR(250)
			, @Privacidad BIT = 0
			, @PrivacidadDescripcion VARCHAR(25)
			, @ACTIVO BIT = 1
			;
--declare @IDEvaluacionEmpleado int = 105657
DECLARE
@IDIdioma VARCHAR(max);
        
select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')

	if object_id('tempdb..#tempHistorialEstatusEvaluacion') is not null
		drop table #tempHistorialEstatusEvaluacion;

	
		-- VALIDACION PRUEBAS ANONIMAS
	EXEC [Evaluacion360].[spValidarPruebasAnonimas] 
		@IDEvaluacionEmpleado = @IDEvaluacionEmpleado
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

	select ee.*,eee.IDEstatusEvaluacionEmpleado
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
	where ee.IDEvaluacionEmpleado = @IDEvaluacionEmpleado 

	--select * from #tempHistorialEstatusEvaluacion
	select 
		 ee.IDEvaluacionEmpleado
		,ee.IDEmpleadoProyecto
		,ee.IDTipoRelacion
		,ee.IDEvaluador
		--,evaluador.NOMBRECOMPLETO as NombreEvaluador
		,CASE 
			WHEN @Privacidad = @ACTIVO
				THEN @PrivacidadDescripcion
				ELSE evaluador.NOMBRECOMPLETO
			END AS NombreEvaluador
		,evaluador.Puesto as PuestoEvaluador
		,ep.IDProyecto
		,ep.IDEmpleado
		,empleado.NOMBRECOMPLETO as NombreColaborador
		,empleado.Puesto as PuestoColaborador
		,estatus.IDEstatusEvaluacionEmpleado
		,estatus.IDEstatus
		,estatus.Estatus
		,estatus.IDUsuario
		,estatus.FechaCreacion 
		--,ROW_NUMBER()over(partition by eee.IDEvaluacionEmpleado 
		--					ORDER by eee.IDEvaluacionEmpleado, eee.FechaCreacion  desc) as [ROW]
	
	from [Evaluacion360].[tblEvaluacionesEmpleados] ee with (nolock)
		join [Evaluacion360].[tblEmpleadosProyectos] ep with (nolock) on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		join #tempHistorialEstatusEvaluacion estatus on ee.IDEvaluacionEmpleado = estatus.IDEvaluacionEmpleado and estatus.[ROW]  = 1
		left join [RH].[tblEmpleadosMaster] empleado with (nolock) on ep.IDEmpleado = empleado.IDEmpleado
		left join [RH].[tblEmpleadosMaster] evaluador with (nolock) on ee.IDEvaluador = evaluador.IDEmpleado
	where ee.IDEvaluacionEmpleado = @IDEvaluacionEmpleado 

--	select * from #tempHistorialEstatusEvaluacion


--select *
--from [Evaluacion360].[tblEvaluacionesEmpleados]
--where IDEvaluacionEmpleado = @IDEvaluacionEmpleado
GO
