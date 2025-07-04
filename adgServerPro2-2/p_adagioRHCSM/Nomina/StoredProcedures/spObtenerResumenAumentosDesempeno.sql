USE [p_adagioRHCSM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spObtenerResumenAumentosDesempeno]
    @IDControlAumentosDesempeno INT,
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        TotalEmpleados,
        EmpleadosConAumento,
        EmpleadosSinAumento,
        ROUND(CAST(EmpleadosConAumento AS FLOAT) / NULLIF(TotalEmpleados, 0) * 100, 2) as PorcentajeEmpleadosConAumento,
        FORMAT(NominaAnterior, 'C', 'es-MX') as NominaAnteriorFormateada,
        FORMAT(NominaNueva, 'C', 'es-MX') as NominaNuevaFormateada,
        FORMAT(NominaNueva - NominaAnterior, 'C', 'es-MX') as IncrementoNominaPesos,
        PorcentajeIncrementoTotal,
        PromedioIncrementoIndividual,
        MetaIncrementoSalarialGeneral,
        CASE 
            WHEN PorcentajeIncrementoTotal > MetaIncrementoSalarialGeneral THEN 
                'Por encima de la meta en ' + 
                FORMAT(ROUND(PorcentajeIncrementoTotal - MetaIncrementoSalarialGeneral, 4), 'N4') + '%'
            WHEN PorcentajeIncrementoTotal < MetaIncrementoSalarialGeneral THEN 
                'Por debajo de la meta en ' + 
                FORMAT(ROUND(MetaIncrementoSalarialGeneral - PorcentajeIncrementoTotal, 4), 'N4') + '%'
            ELSE 'Igual a la meta'
        END as ComparacionConMeta,
        CASE 
            WHEN PorcentajeIncrementoTotal >= MetaIncrementoSalarialGeneral THEN 1
            ELSE 0
        END as MetaCumplida,
        ROUND((NominaNueva - NominaAnterior) / 12, 2) as ImpactoMensualPromedio
    FROM (
        SELECT 
            ISNULL(C.MetaIncrementoSalarialGeneral,0) as MetaIncrementoSalarialGeneral,
            ISNULL(COUNT(D.IDEmpleado),0) as TotalEmpleados,
            ISNULL(COUNT(CASE 
                WHEN C.AfectarSalarioDiarioReal = 1 AND ISNULL(D.SalarioDiarioRealMovimiento, 0) > 0 THEN 1
                WHEN C.AfectarSalarioDiarioReal = 0 AND ISNULL(D.SalarioDiarioMovimiento, 0) > 0 THEN 1
                ELSE NULL 
            END),0) as EmpleadosConAumento,
            ISNULL(COUNT(CASE 
                WHEN C.AfectarSalarioDiarioReal = 1 AND ISNULL(D.SalarioDiarioRealMovimiento, 0) = 0 THEN 1
                WHEN C.AfectarSalarioDiarioReal = 0 AND ISNULL(D.SalarioDiarioMovimiento, 0) = 0 THEN 1
                ELSE NULL 
            END),0) as EmpleadosSinAumento,
            ISNULL(SUM(D.SueldoActualMensual),0) as NominaAnterior,
            ISNULL(SUM(CASE 
                WHEN C.AfectarSalarioDiarioReal = 1 
                    THEN CASE WHEN ISNULL(D.SalarioDiarioRealMovimiento, 0) > 0 THEN ISNULL(D.SalarioDiarioRealMovimiento,0) ELSE ISNULL(D.SueldoActual,0) END * ISNULL(C.DiasSueldoMensual, 30.4)
                ELSE CASE WHEN ISNULL(D.SalarioDiarioMovimiento, 0) > 0 THEN ISNULL(D.SalarioDiarioMovimiento,0) ELSE ISNULL(D.SueldoActual,0) END * ISNULL(C.DiasSueldoMensual, 30.4)
            END),0) as NominaNueva,
            ISNULL(ROUND(
                (
                    (SUM(CASE 
                        WHEN C.AfectarSalarioDiarioReal = 1 
                            THEN CASE WHEN ISNULL(D.SalarioDiarioRealMovimiento, 0) > 0 THEN ISNULL(D.SalarioDiarioRealMovimiento,0) ELSE ISNULL(D.SueldoActual,0) END * ISNULL(C.DiasSueldoMensual, 30.4)
                        ELSE CASE WHEN ISNULL(D.SalarioDiarioMovimiento, 0) > 0 THEN ISNULL(D.SalarioDiarioMovimiento,0) ELSE ISNULL(D.SueldoActual,0) END * ISNULL(C.DiasSueldoMensual, 30.4)
                    END) / NULLIF(SUM(D.SueldoActualMensual), 0) - 1) * 100
                ), 2
            ),0) as PorcentajeIncrementoTotal,
            ISNULL(ROUND(
                AVG(CASE 
                    WHEN C.AfectarSalarioDiarioReal = 1 AND D.SalarioDiarioRealMovimiento > 0
                        THEN ((D.SalarioDiarioRealMovimiento / ISNULL(D.SueldoActual,0)) - 1) * 100
                    WHEN C.AfectarSalarioDiarioReal = 0 AND D.SalarioDiarioMovimiento > 0
                        THEN ((D.SalarioDiarioMovimiento / ISNULL(D.SueldoActual,0)) - 1) * 100
                    ELSE 0 
                END), 2
            ),0) as PromedioIncrementoIndividual
        FROM Nomina.TblControlAumentosDesempenoDetalle D
        INNER JOIN Nomina.tblControlAumentosDesempeno C 
            ON C.IDControlAumentosDesempeno = D.IDControlAumentosDesempeno
        WHERE D.IDControlAumentosDesempeno = @IDControlAumentosDesempeno
        GROUP BY C.MetaIncrementoSalarialGeneral, C.DiasSueldoMensual
    ) AS ResumenAumentos;
END
GO
