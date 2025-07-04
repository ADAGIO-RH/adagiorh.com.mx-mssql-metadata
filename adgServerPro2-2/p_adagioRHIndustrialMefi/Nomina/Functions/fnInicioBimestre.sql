USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION Nomina.fnInicioBimestre
(
	@FechaInicio DATE,
	@FechaFin DATE
)
RETURNS bit
AS
BEGIN

	DECLARE @BimestreInicio bit

	set @BimestreInicio = CASE WHEN DATEADD(month,1-1,DATEADD(year,DATEPART(YEAR,@FechaFin)-1900,0)) BETWEEN @FechaInicio and @FechaFin then 1
							   WHEN DATEADD(month,3-1,DATEADD(year,DATEPART(YEAR,@FechaFin)-1900,0)) BETWEEN @FechaInicio and @FechaFin then 1
							   WHEN DATEADD(month,5-1,DATEADD(year,DATEPART(YEAR,@FechaFin)-1900,0)) BETWEEN @FechaInicio and @FechaFin then 1
							   WHEN DATEADD(month,7-1,DATEADD(year,DATEPART(YEAR,@FechaFin)-1900,0)) BETWEEN @FechaInicio and @FechaFin then 1
							   WHEN DATEADD(month,9-1,DATEADD(year,DATEPART(YEAR,@FechaFin)-1900,0)) BETWEEN @FechaInicio and @FechaFin then 1
							   WHEN DATEADD(month,11-1,DATEADD(year,DATEPART(YEAR,@FechaFin)-1900,0)) BETWEEN @FechaInicio and @FechaFin then 1
							 ELSE 0
							 END
		RETURN @BimestreInicio

END
GO
