USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Nomina].[fnDeterminarBonoEmpleado]
(
    @ResultadoEvaluaciones DECIMAL(18,4),
    @ResultadoObjetivos DECIMAL(18,4),
    @IDTabuladorRelacionEvaluacionesObjetivos INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @EsElegible BIT = 0;
        
    IF EXISTS (
        SELECT TOP 1 1
            FROM Nomina.tblTabuladorRelacionEvaluacionesObjetivosDetalle
            WHERE IDTabuladorRelacionEvaluacionesObjetivos = @IDTabuladorRelacionEvaluacionesObjetivos
            AND @ResultadoEvaluaciones BETWEEN 
                (MinimoEvaluaciones/100.0) AND 
                ((MaximoEvaluaciones/100.0))
             AND @ResultadoObjetivos >= (MinimoObjetivos/100)
    )
    BEGIN
        SET @EsElegible = 1;
    END

    RETURN @EsElegible;
END
GO
