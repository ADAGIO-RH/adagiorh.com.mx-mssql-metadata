USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION Nomina.fnMesMayorEntreFechas
(
	--@FechaGeneraPeriodo DATE,
	@FechaInicio DATE,
	@FechaFin DATE
)
RETURNS int
AS
BEGIN
	
	Declare @DateCounter Date,
			@Mes int
			--@FechaGeneraPeriodo DATE,
			--@FechaInicio DATE,
			--@FechaFin DATE

			--set @FechaGeneraPeriodo = '2016-12-26'
			--set @FechaInicio = '2017-02-28'
			--set @FechaFin = '2017-03-07'

	set @DateCounter =  @FechaInicio
	IF(DATEPART(MONTH,@FechaInicio) = DATEPART(MONTH,@FechaFin))
	BEGIN
		set @Mes = DATEPART(MONTH,@FechaInicio);
	END
	ELSE
	BEGIN
		IF((DATEPART(DAY,EOMONTH(@FechaInicio))-DATEPART(DAY,@FechaInicio))>=DATEPART(DAY,@FechaFin))
		BEGIN
			set @Mes = DATEPART(MONTH,@FechaInicio);
		END
		ELSE
		BEGIN
			set @Mes = DATEPART(MONTH,@FechaFin);
		END
	END


		 

	RETURN @Mes;
END


--select Nomina.fnMesMayorEntreFechas('2016-12-26','2017-02-28','2017-03-07')
GO
