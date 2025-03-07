USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE proc [Evaluacion360].[spAfectarKPIPorcentajeEmpleadosEvaluacion] (
    @dtFiltros Nomina.dtFiltrosRH readonly,
	@IDUsuario int
) as

DECLARE
	@Afectar Varchar(10) = 'FALSE',
	@IDPeriodoInicial int,
	@IDProyecto int,
	@IDConceptoOP112 int -- PORCENTAJE DE EVALUACION

	if object_id('tempdb..#TempDatosAfectarPeriodo') is not null drop table #TempDatosAfectarPeriodo
	if object_id('tempdb..#TempRespuesta') is not null drop table #TempRespuesta

	select top 1 @IDConceptoOP112 = IDConcepto from nomina.tblCatConceptos where Codigo = 'OP112'
	select @IDPeriodoInicial = cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),',')
	SELECT @IDProyecto = cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDProyecto'),',')


	SET @Afectar =  CASE WHEN EXISTS (Select top 1 cast(item as varchar(10)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Afectar'),',')) 
		THEN (Select top 1 cast(item as Varchar(10)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Afectar'),','))  
			ELSE 'FALSE' 
		END

	SELECT EM.IDEmpleado,EM.ClaveEmpleado AS CLAVE,EM.NOMBRECOMPLETO AS NOMBRE,CP.Nombre as ENCUESTA,CP.Descripcion AS DESCRIPCION, IDEvaluador as evaluador,
				EE.IDEvaluacionEmpleado
	INTO #TempDatosAfectarPeriodo
	FROM Evaluacion360.tblEmpleadosProyectos EP
		INNER JOIN Evaluacion360.tblCatProyectos CP ON CP.IDProyecto = EP.IDProyecto
		INNER JOIN RH.tblEmpleadosMaster EM ON em.IDEmpleado = ep.IDEmpleado
		INNER JOIN NOMINA.tblCatPeriodos CAP ON CAP.IDTipoNomina = EM.IDTipoNomina
		LEFT JOIN Evaluacion360.tblEvaluacionesEmpleados EE ON EP.IDEmpleadoProyecto = EE.IDEmpleadoProyecto
	WHERE EP.IDProyecto = @IDProyecto  
		AND CAP.IDPeriodo = @IDPeriodoInicial
		-- AND EP.TotalGeneral <>0
		AND EP.TipoFiltro != 'Excluir Empleado'

	select af.IDEmpleado,af.CLAVE, e.NOMBRECOMPLETO as Evaluador , af.NOMBRE as Evaluado, af.ENCUESTA, p.Respuesta
		into #TempRespuesta
	from Evaluacion360.tblRespuestasPreguntas p
			inner join #TempDatosAfectarPeriodo af on p.IDEvaluacionEmpleado = af.IDEvaluacionEmpleado
				inner join RH.tblEmpleadosMaster e on af.evaluador = e.IDEmpleado
		where p.IDEvaluacionEmpleado in (  af.IDEvaluacionEmpleado )


	select af.CLAVE, e.NOMBRECOMPLETO as Evaluador , af.NOMBRE as Evaluado, af.ENCUESTA, p.Respuesta as Calificacion, isnull ( cast ( dee.Valor as decimal(18,2) ) / 100 , 0.00 ) * isnull ( cast ( p.Respuesta as decimal(18,2) ) , 0.00 ) as Monto --* isnull ( dee.Valor, 0.00)
	from Evaluacion360.tblRespuestasPreguntas p
			inner join #TempDatosAfectarPeriodo af on p.IDEvaluacionEmpleado = af.IDEvaluacionEmpleado
				inner join RH.tblEmpleadosMaster e on af.evaluador = e.IDEmpleado

			LEFT JOIN RH.tblDatosExtraEmpleados DEE
							ON DEE.IDEmpleado = af.IDEmpleado and dee.IDDatoExtra = 15
		where p.IDEvaluacionEmpleado in (  af.IDEvaluacionEmpleado )	


IF(@Afectar = 'true' AND (Select top 1 1 from #TempDatosAfectarPeriodo) = 1 )
BEGIN
    MERGE Nomina.tblDetallePeriodo AS TARGET
        USING #TempRespuesta AS SOURCE
            ON TARGET.IDPeriodo = @IDPeriodoInicial
            and TARGET.IDConcepto = @IDConceptoOP112
			and TARGET.IDEmpleado = SOURCE.IDEmpleado
		WHEN MATCHED Then
			update
				Set 
					TARGET.CantidadVeces  = isnull(SOURCE.Respuesta ,0)  

		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(IDEmpleado,IDPeriodo,IDConcepto,CantidadVeces)  
			VALUES(SOURCE.IDEmpleado,@IDPeriodoInicial,@IDConceptoOP112, isnull(SOURCE.Respuesta ,0)
			);
    END
GO
