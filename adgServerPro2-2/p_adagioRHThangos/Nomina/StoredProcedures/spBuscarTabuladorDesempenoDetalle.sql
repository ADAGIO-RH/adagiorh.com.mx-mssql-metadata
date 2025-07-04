USE [p_adagioRHThangos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [Nomina].[spBuscarTabuladorDesempenoDetalle]
(
    @IDTabuladorDesempeno INT
   ,@IDUsuario INT 
) AS
BEGIN
    SET NOCOUNT ON;

    IF @IDTabuladorDesempeno IS NULL
    BEGIN
        RAISERROR('El parámetro @IDTabuladorDesempeno no puede ser NULL.', 16, 1);
        RETURN;
    END;

    SELECT 
        IDTabuladorDesempenoDetalle,
        IDTabuladorDesempeno,
        Minimo,
        Maximo,
        Porcentaje
    FROM [Nomina].[tblTabuladorDesempenoDetalle]
    WHERE IDTabuladorDesempeno = @IDTabuladorDesempeno
    ORDER BY Minimo ASC;
END;
GO
