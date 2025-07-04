USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select  [Facturacion].[fnAntiguedadSAT]('2013-07-16','2020-01-15')

--select dateadd(day,1,dateadd(MONTH,6,dateadd(Year,6,cast('2013-07-16' as date))))

CREATE FUNCTION [Facturacion].[fnAntiguedadSAT](
--Declare
	@FechaInicio date,
	@FechaFin date 
)
RETURNS Varchar(20)
AS
BEGIN
  DECLARE @Years INT
  , @Months INT
  , @Days INT
  , @tmpFromDate DATE
    SET @Years = DATEDIFF(YEAR, @FechaInicio, @FechaFin) - (CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, @FechaInicio, @FechaFin), @FechaInicio) > @FechaFin THEN 1 ELSE 0 END) 
    
    SET @tmpFromDate = DATEADD(YEAR, @Years , @FechaInicio)
    SET @Months =  DATEDIFF(MONTH, @tmpFromDate, @FechaFin) - (CASE WHEN DATEADD(MONTH,DATEDIFF(MONTH, @tmpFromDate, @FechaFin), @tmpFromDate) > @FechaFin THEN 1 ELSE 0 END) 
    
    SET @tmpFromDate = DATEADD(MONTH, @Months , @tmpFromDate)
    SET @Days =  DATEDIFF(DAY, @tmpFromDate, @FechaFin) - (CASE WHEN DATEADD(DAY, DATEDIFF(DAY, @tmpFromDate, @FechaFin),@tmpFromDate) > @FechaFin THEN 1 ELSE 0 END) 
    
    --INSERT INTO @DateDifference
    --select @Years, @Months, @Days

	
	RETURN  'P'+ CASE WHEN @Years> 0 then cast( @Years as varchar(3))+'Y' ELSE '' END + 
			  CASE WHEN	@Months> 0 THEN CAST( @Months as varchar(3))+'M' ELSE '' END+
			  CAST(  @Days as varchar(5))+'D'
END
GO
