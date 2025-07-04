USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION Nomina.fnFinBimestre
(
	@FechaInicio DATE,
	@FechaFin DATE
)
RETURNS bit
AS
BEGIN
	DECLARE @isFinBimentre bit

		IF((EOMONTH(DATEADD(MONTH,2,CAST(YEAR(@FechaInicio) as Varchar))) BETWEEN @FechaInicio and @FechaFin)
			OR (EOMONTH(DATEADD(MONTH,4,CAST(YEAR(@FechaInicio) as Varchar))) BETWEEN @FechaInicio and @FechaFin)
			OR (EOMONTH(DATEADD(MONTH,6,CAST(YEAR(@FechaInicio) as Varchar))) BETWEEN @FechaInicio and @FechaFin)
			OR (EOMONTH(DATEADD(MONTH,8,CAST(YEAR(@FechaInicio) as Varchar))) BETWEEN @FechaInicio and @FechaFin)
			OR (EOMONTH(DATEADD(MONTH,10,CAST(YEAR(@FechaInicio) as Varchar))) BETWEEN @FechaInicio and @FechaFin)
			OR (EOMONTH(DATEADD(MONTH,12,CAST(YEAR(@FechaInicio) as Varchar))) BETWEEN @FechaInicio and @FechaFin)
		)BEGIN
			set @isFinBimentre = 1;
		END
		ELSE
		BEGIN
			set @isFinBimentre = 0;
		END
		return @isFinBimentre;
		

END
GO
