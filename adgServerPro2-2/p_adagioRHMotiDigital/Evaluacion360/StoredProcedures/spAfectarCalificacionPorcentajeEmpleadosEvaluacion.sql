USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Evaluacion360].[spAfectarCalificacionPorcentajeEmpleadosEvaluacion] (
    @dtFiltros Nomina.dtFiltrosRH readonly,
	@IDUsuario int
	
) as
	
DECLARE
@Afectar Varchar(10) = 'FALSE',
@IDPeriodoInicial int,
@IDProyecto int,
@IDConceptoOP001 int -- PORCENTAJE DE EVALUACION


if object_id('tempdb..#TempDatosAfectarPeriodo') is not null drop table #TempDatosAfectarPeriodo


SELECT TOP 1 @IDConceptoOP001 = IDConcepto from nomina.tblCatConceptos where Codigo = 'OP001'; 
SELECT @IDPeriodoInicial = cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),',')
SELECT @IDProyecto = cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDProyecto'),',')
SET @Afectar =  CASE WHEN EXISTS (Select top 1 cast(item as varchar(10)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Afectar'),',')) 
                                 THEN (Select top 1 cast(item as Varchar(10)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Afectar'),','))  
					             ELSE 'FALSE' 
				END 


SELECT EM.IDEmpleado,EM.ClaveEmpleado AS CLAVE,EM.NOMBRECOMPLETO AS NOMBRE,CP.Nombre as ENCUESTA,CP.Descripcion AS DESCRIPCION, 
	CASE WHEN ( ISNULL( EP.TotalGeneral,0) - ROUND ( ISNULL( EP.TotalGeneral,0) ,0, 1 ) ) > 0.49 THEN
		CEILING ( ISNULL( EP.TotalGeneral,0) ) 
	ELSE
		FLOOR ( ISNULL( EP.TotalGeneral,0) )
	END AS PORCENTAJE

INTO #TempDatosAfectarPeriodo
    FROM Evaluacion360.tblEmpleadosProyectos EP
        INNER JOIN Evaluacion360.tblCatProyectos CP ON CP.IDProyecto = EP.IDProyecto
        INNER JOIN RH.tblEmpleadosMaster EM ON em.IDEmpleado = ep.IDEmpleado
        INNER JOIN NOMINA.tblCatPeriodos CAP ON CAP.IDTipoNomina = EM.IDTipoNomina
    WHERE EP.IDProyecto = @IDProyecto  
        AND CAP.IDPeriodo = @IDPeriodoInicial
       -- AND EP.TotalGeneral <>0
	   AND EP.TipoFiltro != 'Excluir Empleado'



SELECT CLAVE,t.NOMBRE,ENCUESTA,t.DESCRIPCION,PORCENTAJE as [TOTAL GENERAL] , t.PORCENTAJE, isnull ( t.PORCENTAJE, 0.00 ) * isnull ( Dee.Valor , 0.00 ) as Monto 
    FROM #TempDatosAfectarPeriodo t
			LEFT JOIN RH.tblDatosExtraEmpleados DEE
							ON DEE.IDEmpleado = t.IDEmpleado
						LEFT JOIN RH.tblCatDatosExtra DE 
							on DE.IDDatoExtra = DEE.IDDatoExtra
						WHERE ((DE.Nombre = 'BONO_KPI'))
ORDER BY PORCENTAJE DESC



IF(@Afectar = 'true' AND (Select top 1 1 from #TempDatosAfectarPeriodo) = 1 )
BEGIN
    MERGE Nomina.tblDetallePeriodo AS TARGET
        USING #TempDatosAfectarPeriodo AS SOURCE
            ON TARGET.IDPeriodo = @IDPeriodoInicial
            and TARGET.IDConcepto = @IDConceptoOP001
			and TARGET.IDEmpleado = SOURCE.IDEmpleado
		WHEN MATCHED Then
			update
				Set 
					TARGET.CantidadMonto  = isnull(SOURCE.PORCENTAJE ,0) , 
					TARGET.CantidadVeces  = isnull(SOURCE.PORCENTAJE ,0)  

		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(IDEmpleado,IDPeriodo,IDConcepto,CantidadMonto, CantidadVeces)  
			VALUES(SOURCE.IDEmpleado,@IDPeriodoInicial,@IDConceptoOP001, isnull(SOURCE.PORCENTAJE ,0), isnull(SOURCE.PORCENTAJE ,0)
			);
    END
    
GO
