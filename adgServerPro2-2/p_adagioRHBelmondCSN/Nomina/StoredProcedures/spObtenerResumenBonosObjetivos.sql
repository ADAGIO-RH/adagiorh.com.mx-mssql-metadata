USE [p_adagioRHBelmondCSN]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spObtenerResumenBonosObjetivos]
    @IDControlBonosObjetivos INT,
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TotalEmpleados INT,
            @EmpleadosConBono INT,
            @EmpleadosConComplemento INT,
            @TotalBonos DECIMAL(18,2),
            @TotalComplementos DECIMAL(18,2)

    -- Obtener totales principales
    SELECT 
        @TotalEmpleados = ISNULL(COUNT(*),0),
        @EmpleadosConBono = ISNULL(SUM(
                            CASE 
                                WHEN ExcluirColaborador = -1     THEN 0
                                WHEN CalibracionBonoFinal = -1 THEN 0
                                WHEN CalibracionBonoFinal > 0   THEN 1
                            ELSE IIF(BonoFinal>0,1,0) END
        ),0),
        @EmpleadosConComplemento = ISNULL(SUM(
                            CASE             
                                WHEN ExcluirColaborador = -1     THEN 0
                                WHEN CalibracionComplemento = -1 THEN 0
                                WHEN CalibracionComplemento > 0   THEN 1
                            ELSE IIF(Complemento>0,1,0) END
        ),0),
        @TotalBonos = ISNULL(SUM(
                            CASE 
                                WHEN ExcluirColaborador = -1     THEN 0
                                WHEN CalibracionBonoFinal = -1 THEN 0
                                WHEN CalibracionBonoFinal > 0   THEN CalibracionBonoFinal
                            ELSE IIF(BonoFinal>0,BonoFinal,0) END
        ),0),
        @TotalComplementos = ISNULL(SUM(
                             CASE             
                                WHEN ExcluirColaborador = -1     THEN 0
                                WHEN CalibracionComplemento = -1 THEN 0
                                WHEN CalibracionComplemento > 0   THEN CalibracionComplemento
                            ELSE IIF(Complemento>0,Complemento,0) END
        ),0)
    FROM Nomina.tblControlBonosObjetivosDetalle 
    WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos

    -- Retornar resultados
    SELECT 
        @TotalEmpleados as TotalEmpleados,
        @EmpleadosConBono as EmpleadosConBono,
        @EmpleadosConComplemento as EmpleadosConComplemento,
        ISNULL(@TotalEmpleados - CASE 
            WHEN @EmpleadosConBono > @EmpleadosConComplemento 
            THEN @EmpleadosConBono 
            ELSE @EmpleadosConComplemento 
        END,0) as EmpleadosSinBeneficios,
        ISNULL(CAST((@EmpleadosConBono * 100.0 / NULLIF(@TotalEmpleados, 0)) AS DECIMAL(18,2)),0) as PorcentajeEmpleadosConBono,
        ISNULL(CAST((@EmpleadosConComplemento * 100.0 / NULLIF(@TotalEmpleados, 0)) AS DECIMAL(18,2)),0) as PorcentajeEmpleadosConComplemento,
        ISNULL(FORMAT(@TotalBonos, 'C', 'es-MX'),0) as TotalBonosFormateado,
        ISNULL(FORMAT(@TotalComplementos, 'C', 'es-MX'),0) as TotalComplementosFormateado,
        ISNULL(FORMAT(@TotalBonos + @TotalComplementos, 'C', 'es-MX'),0) as TotalGeneralFormateado,
        ISNULL(FORMAT(CASE 
            WHEN @EmpleadosConBono > 0 
            THEN CAST((@TotalBonos / NULLIF(@EmpleadosConBono, 0)) AS DECIMAL(18,2))
            ELSE 0 
        END, 'C', 'es-MX'),0) as PromedioBonoIndividual,
        ISNULL(FORMAT(CASE 
            WHEN @EmpleadosConComplemento > 0 
            THEN CAST((@TotalComplementos / NULLIF(@EmpleadosConComplemento, 0)) AS DECIMAL(18,2))
            ELSE 0 
        END, 'C', 'es-MX'),0) as PromedioComplementoIndividual
END
GO
