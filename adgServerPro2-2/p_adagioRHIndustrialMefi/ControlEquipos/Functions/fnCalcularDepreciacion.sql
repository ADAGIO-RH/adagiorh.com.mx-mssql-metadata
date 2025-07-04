USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- SELECT 154.25 as CostoOriginal,[ControlEquipos].[fnCalcularDepreciacion](154.25, '2020-10-15',0.5, 0.5), 77.115 CostoDepreciadoCorrecto
CREATE FUNCTION [ControlEquipos].[fnCalcularDepreciacion](
	@Costo DECIMAL(10, 2), 
	@FechaAlta DATE, 
	@FactorDepreciacion DECIMAL(10, 2), 
	@PorcentajeMinimo DECIMAL(10, 2)
)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @FechaActual DATE = GETDATE();
    DECLARE @AniosTranscurridos INT;
    DECLARE @Depreciacion DECIMAL(10, 2);
    DECLARE @DepreciacionAnual DECIMAL(10, 2);
    DECLARE @ValorMinimo DECIMAL(10, 2);

    SET @AniosTranscurridos = DATEDIFF(YEAR, @FechaAlta, @FechaActual);
    SET @DepreciacionAnual = @Costo * @FactorDepreciacion;
    SET @ValorMinimo = @Costo * @PorcentajeMinimo;

    -- Verificar si el artículo está en el mismo año de creación o menos de un año
    IF @AniosTranscurridos = 0
    BEGIN
        SET @Depreciacion = @Costo;
    END
    ELSE
    BEGIN
        SET @Depreciacion = @Costo - (@DepreciacionAnual * @AniosTranscurridos);
    END;

    -- Verificar si la depreciación es menor al valor mínimo
    IF @Depreciacion < @ValorMinimo
    BEGIN
        SET @Depreciacion = @ValorMinimo;
    END;

    -- Devolver el resultado
    RETURN ISNULL(@Depreciacion, 0.00);
END;
GO
