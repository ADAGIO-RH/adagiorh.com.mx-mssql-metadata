USE [q_adagioRHTuning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spSubReporteBasicoNHT](    
	 @ClaveEmpleadoInicial VARCHAR(max), 
     @FechaIni Date
) as    
	SET FMTONLY OFF 

DECLARE
@IDEmpleado int,
@Ejercicio INT,
@dtFechas app.dtFechas,
@fechaAntiguedad date,
@fechaVigencia date

if object_id('tempdb..#tempMovAfil') is not null    
    drop table #tempMovAfil   

SELECT @IDEmpleado=IDEmpleado FROM RH.tblEmpleados WHERE ClaveEmpleado=@ClaveEmpleadoInicial
Select @Ejercicio = DATEPART(YEAR,GETDATE())
select @fechaAntiguedad = fechaAntiguedad from rh.tblEmpleadosMaster where ClaveEmpleado = @ClaveEmpleadoInicial
--select @fechaVigencia = @FechaIni


insert @dtFechas
exec [App].[spListaFechas]  @fechaAntiguedad, @FechaIni





if object_id('tempdb..#tempFechas') is not null    
    drop table #tempFechas   


select
DATEPART(YEAR,Fecha) AS ejercicio,
semana 
into #tempFechas
from  @dtFechas

-- select 
--         ejercicio,
--         COUNT(distinct Semana)-1 
--         as weeks from #tempFechas
--         group by ejercicio 

--         RETURN


SELECT
ACUMULADO.*,
WEEKS.Weeks 
FROM
    (SELECT
    Ejercicio,
    cc.Descripcion, 
    SUM(ImporteTotal1) as GrossPay
    from nomina.tblCatConceptos cc
            JOIN nomina.tblDetallePeriodo dp On dp.IDConcepto = cc.IDConcepto
            JOIN nomina.tblCatPeriodos cp ON cp.IDPeriodo = dp.IDPeriodo
            JOIN RH.tblEmpleados M ON M.IDEmpleado=DP.IDEmpleado
    Where M.ClaveEmpleado = @ClaveEmpleadoInicial and cc.Descripcion IN ('GROSS PAY', 'NHT')  
    group by Ejercicio,cc.Descripcion) as ACUMULADO
INNER JOIN
        (select 
        ejercicio,
        COUNT(distinct Semana)-1 
        as weeks from #tempFechas
        group by ejercicio) AS WEEKS  ON ACUMULADO.Ejercicio = WEEKS.Ejercicio


GO
