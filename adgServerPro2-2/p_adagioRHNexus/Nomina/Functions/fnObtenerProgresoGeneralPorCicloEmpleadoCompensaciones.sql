USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Nomina].[fnObtenerProgresoGeneralPorCicloEmpleadoCompensaciones](
    @IDEmpleado int,
    @CiclosMedicionStr varchar(max),
    @TopeCumplimientoObjetivo decimal(18, 2)
) 
RETURNS decimal(18, 4)
AS
BEGIN
    DECLARE @Porcentaje decimal(18, 4) = 0.00;

    -- Convertir el string de ciclos en una tabla temporal
    DECLARE @CiclosMedicion TABLE (IDCicloMedicionObjetivo int);
    INSERT INTO @CiclosMedicion
    SELECT value FROM STRING_SPLIT(@CiclosMedicionStr, ',');

    -- Declarar constantes para los estatus que se excluyen
    DECLARE 
        @ID_ESTATUS_OBJETIVO_CANCELADO int = 7,
        @ID_ESTATUS_OBJETIVO_EMPLEADO_PENDIENTE_AUTORIZAR INT = 8,                   
        @ID_ESTATUS_OBJETIVO_EMPLEADO_SIN_AUTORIZAR INT = 9;

    -- Calcular el promedio de los objetivos
    SELECT @Porcentaje = AVG(Porcentaje)
    FROM (
        SELECT 
            CAST(SUM(
                (CASE 
                    WHEN PorcentajeAlcanzado > @TopeCumplimientoObjetivo 
                    THEN @TopeCumplimientoObjetivo 
                    ELSE PorcentajeAlcanzado 
                END * (CASE 
                    WHEN ISNULL(Peso, 0) = 0 
                    THEN 100 
                    ELSE Peso 
                END))
            ) / SUM(
                CASE 
                    WHEN ISNULL(Peso, 0) = 0 
                    THEN 100 
                    ELSE Peso 
                END
            ) AS decimal(18, 2)) AS Porcentaje
        FROM Evaluacion360.tblObjetivosEmpleados oe
        WHERE oe.IDCicloMedicionObjetivo IN (SELECT IDCicloMedicionObjetivo FROM @CiclosMedicion)
          AND oe.IDEmpleado = @IDEmpleado 
          AND IDEstatusObjetivoEmpleado NOT IN (
              @ID_ESTATUS_OBJETIVO_CANCELADO, 
              @ID_ESTATUS_OBJETIVO_EMPLEADO_PENDIENTE_AUTORIZAR, 
              @ID_ESTATUS_OBJETIVO_EMPLEADO_SIN_AUTORIZAR
          )
        GROUP BY oe.IDEmpleado, oe.IDCicloMedicionObjetivo
    ) AS Resultados;

    RETURN ISNULL(@Porcentaje/100, 0);
END
GO
