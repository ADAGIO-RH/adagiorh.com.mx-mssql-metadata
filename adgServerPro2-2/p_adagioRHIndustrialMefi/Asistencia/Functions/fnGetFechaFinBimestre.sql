USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Asistencia].[fnGetFechaFinBimestre]
(
	@Fecha DATE
)
RETURNS DATE
AS
BEGIN
	DECLARE 
		--@Fecha  DATE = '2019-05-03',
		@FinBimentre Date

		select @FinBimentre= 
			EOMONTH(CAST(DATEADD(MONTH,(select MAX(cast(item as int)) from app.Split(b.meses,','))-1,CAST(YEAR(@Fecha) as Varchar))  as date))		
			
			from Nomina.tblcatBimestres b
		WHERE DATEPART(MONTH,@Fecha) in (select item from app.Split(b.meses,','))
		--select @FinBimentre
		return @FinBimentre
		

END
GO
