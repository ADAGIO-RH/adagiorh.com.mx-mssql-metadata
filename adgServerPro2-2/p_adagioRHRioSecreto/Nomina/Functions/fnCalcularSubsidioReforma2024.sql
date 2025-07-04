USE [p_adagioRHRioSecreto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [Nomina].[fnCalcularSubsidioReforma2024]
(
    @MesFin BIT,
    @Dias INT,
    @ValorDiarioUMA DECIMAL(18,4),
    @TopeSalarialPorPeriodo DECIMAL(18,2),
    @TopeMensualSubsidioSalario DECIMAL(18,2),
    @SumImporteGravado DECIMAL(18,2),
    @AcumGravPeriodosAnteriores DECIMAL(18,2),
    @AcumuladoSubsidio DECIMAL(18,2),
    @ISRCausado DECIMAL(18,2)
    
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @SubsidioFinal DECIMAL(18,2),
    @SUBSIDIOREFORMA2024_DEVOLUCION BIT

    select @SUBSIDIOREFORMA2024_DEVOLUCION = CAST(isnull((Valor),'0') as bit) 
	from Nomina.tblConfiguracionNomina 
	where Configuracion = 'SUBSIDIOREFORMA2024_DEVOLUCION'
    
    -- Step 1: Calculate initial subsidy value
    SET @SubsidioFinal = CASE 
        WHEN @MesFin = 0 THEN
            CASE WHEN @SumImporteGravado <= @TopeSalarialPorPeriodo 
                THEN (@Dias * @ValorDiarioUMA)
                ELSE 0
            END
        ELSE
            CASE WHEN (@SumImporteGravado + @AcumGravPeriodosAnteriores) <= @TopeMensualSubsidioSalario
                THEN (30.4 * @ValorDiarioUMA) - @AcumuladoSubsidio
                ELSE 0
            END
        END

    -- Step 2: Apply monthly subsidy cap
    SET @SubsidioFinal = CASE 
        WHEN @AcumuladoSubsidio >= @TopeMensualSubsidioSalario THEN 0
        WHEN (@AcumuladoSubsidio + @SubsidioFinal) <= @TopeMensualSubsidioSalario THEN @SubsidioFinal
        WHEN (@AcumuladoSubsidio + @SubsidioFinal) > @TopeMensualSubsidioSalario THEN
            CASE WHEN (@TopeMensualSubsidioSalario - @AcumuladoSubsidio) >= @SubsidioFinal 
                THEN @SubsidioFinal
                ELSE (@TopeMensualSubsidioSalario - @AcumuladoSubsidio)
            END
        END

    -- Step 3: Apply ISR limitation
    
    RETURN CASE 
        WHEN @MesFin = 0 THEN 
            CASE WHEN @ISRCausado <= @SubsidioFinal THEN @ISRCausado ELSE @SubsidioFinal END
        WHEN @MesFin = 1 AND @SUBSIDIOREFORMA2024_DEVOLUCION = 1 THEN @SubsidioFinal
        WHEN @MesFin = 1 AND @SUBSIDIOREFORMA2024_DEVOLUCION = 0 THEN 
            CASE WHEN @ISRCausado <= @SubsidioFinal THEN @ISRCausado ELSE @SubsidioFinal END
        ELSE 
            CASE WHEN @ISRCausado <= @SubsidioFinal THEN @ISRCausado ELSE @SubsidioFinal END
        END
END
GO
