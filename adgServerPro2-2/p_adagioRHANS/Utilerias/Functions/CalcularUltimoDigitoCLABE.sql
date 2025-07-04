USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Utilerias].[CalcularUltimoDigitoCLABE] (@ClabeBase VARCHAR(18))
RETURNS BIT
AS
BEGIN
    DECLARE @Pesos TABLE (Posicion INT, Peso INT);
    DECLARE @Suma INT = 0, @Residuo INT, @DigitoControl INT;
    DECLARE @i INT = 1, @Digito INT;
    Declare @Resultado BIT = 0;
    DECLARE @CodigoBanco VARCHAR(10) = SUBSTRING(@ClabeBase, 1, 3);

    IF NOT EXISTS(SELECT 1 FROM SAT.tblCatBancos WHERE Codigo = @CodigoBanco) RETURN 0;

    
    
    -- Insertamos la secuencia de pesos (3, 7, 1) repetidos
    INSERT INTO @Pesos VALUES (1, 3), (2, 7), (3, 1),
                              (4, 3), (5, 7), (6, 1),
                              (7, 3), (8, 7), (9, 1),
                              (10, 3), (11, 7), (12, 1),
                              (13, 3), (14, 7), (15, 1),
                              (16, 3), (17, 7);
    
    -- Recorremos cada dígito y aplicamos la multiplicación por su peso correspondiente
    WHILE @i <= 17
    BEGIN
        SET @Digito = CAST(SUBSTRING(@ClabeBase, @i, 1) AS INT);
        SET @Suma = @Suma + (@Digito * (SELECT Peso FROM @Pesos WHERE Posicion = @i));
        SET @i = @i + 1;
    END

    -- Cálculo del dígito de control
    SET @Residuo = @Suma % 10;
    SET @DigitoControl = CASE WHEN @Residuo = 0 THEN 0 ELSE 10 - @Residuo END;


    IF @DigitoControl = cast(substring(@ClabeBase, 18, 1) as int)
        SET @Resultado = 1  
    ELSE
        SET @Resultado = 0

    RETURN @Resultado
END;
GO
