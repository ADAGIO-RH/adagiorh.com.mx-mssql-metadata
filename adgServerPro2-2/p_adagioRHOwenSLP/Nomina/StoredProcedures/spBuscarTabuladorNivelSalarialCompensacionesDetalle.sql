USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [Nomina].[spBuscarTabuladorNivelSalarialCompensacionesDetalle]
(
    @IDTabuladorNivelSalarialCompensaciones INT
   ,@IDUsuario  INT
)
AS
BEGIN
    SET NOCOUNT ON;

    
    IF @IDTabuladorNivelSalarialCompensaciones IS NULL
    BEGIN
        RAISERROR('El parámetro @IDTabuladorNivelSalarialCompensaciones no puede ser NULL.', 16, 1);
        RETURN;
    END;

    
    SELECT 
        IDTabuladorNivelSalarialCompensacionesDetalle,
        IDTabuladorNivelSalarialCompensaciones,
        Nivel,
        Minimo,
        Maximo,
        PorcentajeResultadoUtilidad,
        PorcentajeDesempenoEvaluacionPersonal,
        PorcentajeBonoAnual
    FROM [Nomina].[tblTabuladorNivelSalarialCompensacionesDetalle]
    WHERE IDTabuladorNivelSalarialCompensaciones = @IDTabuladorNivelSalarialCompensaciones
    ORDER BY Nivel ASC;

END;
GO
