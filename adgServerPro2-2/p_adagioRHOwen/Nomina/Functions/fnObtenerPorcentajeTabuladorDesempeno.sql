USE [p_adagioRHOwen]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    FUNCTION [Nomina].[fnObtenerPorcentajeTabuladorDesempeno]
(
    @PorcentajeDesempeno DECIMAL(18,4),
    @IDControlAumentosDesempeno INT
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @PorcentajeTabulador DECIMAL(5,2) = 0;
    
    SET @PorcentajeDesempeno = @PorcentajeDesempeno * 100;


    SELECT TOP 1 
        @PorcentajeTabulador = TD.Porcentaje
    FROM Nomina.tblControlAumentosDesempeno C
        INNER JOIN Nomina.tblTabuladorDesempeno T 
            ON T.IDTabuladorDesempeno = C.IDTabuladorDesempeno
        INNER JOIN Nomina.tblTabuladorDesempenoDetalle TD 
            ON TD.IDTabuladorDesempeno = T.IDTabuladorDesempeno
    WHERE C.IDControlAumentosDesempeno = @IDControlAumentosDesempeno
        AND @PorcentajeDesempeno >= TD.Minimo 
        AND @PorcentajeDesempeno <= TD.Maximo;

    RETURN ISNULL(@PorcentajeTabulador, 0)/100;
    
END
GO
