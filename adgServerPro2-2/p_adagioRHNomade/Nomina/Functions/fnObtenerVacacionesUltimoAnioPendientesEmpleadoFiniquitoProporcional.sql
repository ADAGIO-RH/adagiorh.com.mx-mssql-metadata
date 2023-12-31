USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Nomina].[fnObtenerVacacionesUltimoAnioPendientesEmpleadoFiniquitoProporcional]
(
 @IDEmpleado int,    
 @FechaIni Date = null,  
 @FechaBaja Date = null  
)
RETURNS @tblProporcional TABLE 
(
    -- Columns returned by the function
    IDEmpleado int PRIMARY KEY NOT NULL, 
    Dias decimal (18,2) NULL,
    fecha  date

    

)
AS 
BEGIN
DECLARE @DiasPendientes DECIMAL(10, 2),
        @DiasVacaciones DECIMAL(18, 2),
        @AniosAntiguedad FLOAT = 0,
        @FechaAntiguedad DATE,
        @AniosAntiguedadReal  DECIMAL(10, 2),
        @IDTipoPrestacion INT;

----------------------------------------------------Calculo------------------------------------------------------------------
SELECT @FechaAntiguedad = ISNULL(e.FechaAntiguedad, GETDATE()),
       @IDTipoPrestacion = pe.IDTipoPrestacion
FROM [RH].[tblEmpleadosMaster] e WITH (nolock)
    LEFT JOIN [RH].[tblPrestacionesEmpleado] pe WITH (nolock)
        ON pe.IDEmpleado = e.IDEmpleado
           AND pe.FechaIni <= @FechaBaja
           AND pe.FechaFin >= @FechaBaja
    LEFT JOIN [RH].tblClienteEmpleado ce WITH (nolock)
        ON ce.IDEmpleado = e.IDEmpleado
           AND ce.FechaIni <= @FechaBaja
           AND ce.FechaFin >= @FechaBaja
WHERE e.IDEmpleado = @IDEmpleado

SELECT @AniosAntiguedad = CEILING(DATEDIFF(day, @FechaAntiguedad, GETDATE()) / 365.2425)

SELECT @DiasVacaciones = DiasVacaciones
FROM RH.tblCatTiposPrestacionesDetalle
WHERE IDTipoPrestacion = @IDTipoPrestacion
      AND Antiguedad = @AniosAntiguedad

SET @AniosAntiguedadReal=DATEDIFF(day, @FechaAntiguedad, GETDATE()) / 365.2425


IF(@AniosAntiguedadReal>=1)
BEGIN
    SET @FechaIni= CONVERT(VARCHAR, DATEPART(YEAR, @FechaBaja)) + '-' + CONVERT(VARCHAR, DATEPART(MONTH, @FechaIni)) + '-'+ CONVERT(VARCHAR, DATEPART(DAY, @FechaIni))
END
ELSE
BEGIN
    SET @FechaIni=@FechaAntiguedad
END


SET @DiasPendientes = (((DATEDIFF(day, @FechaIni, @FechaBaja) + 1) / 365.4) * @DiasVacaciones)

----------------------------------------------------------Fin-------------------------------------------------------------------------------
INSERT INTO @tblProporcional(IDEmpleado,Dias,fecha)
    SELECT @IDEmpleado AS IDEmpleado,
        @DiasPendientes AS Dias,
        @FechaIni as fecha
RETURN;
END
GO
