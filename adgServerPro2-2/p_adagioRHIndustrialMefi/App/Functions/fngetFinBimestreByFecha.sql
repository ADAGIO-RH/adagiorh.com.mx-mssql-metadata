USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function app.fngetFinBimestreByFecha(
	@Fecha Date
)
returns date
AS
BEGIN
Declare @fechaFinBimestre date
	select   
		@fechaFinBimestre=MAX(DATEADD(day,-1,DATEADD(month,IDMes,DATEADD(year,datepart(year,@Fecha)-1900,0))))   
	from Nomina.tblCatMeses with (nolock)  
	where cast(IDMes as varchar) in (select item from app.Split( (select top 1 meses from Nomina.tblCatBimestres with (nolock) where MONTH(@Fecha) in (select item from app.Split(meses,','))
  ),','))  

   return @fechaFinBimestre

END
GO
