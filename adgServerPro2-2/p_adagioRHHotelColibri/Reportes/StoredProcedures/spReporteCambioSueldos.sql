USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reportes].[spReporteCambioSueldos](
	 @IDEmpleados VARCHAR(MAX)
	,@IDUsuario int
) as
BEGIN
SET NOCOUNT ON;
IF 1=0 BEGIN
       SET FMTONLY OFF
END

declare 
@IDIdioma VARCHAR(5)

select @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

IF OBJECT_ID('TEMPDB..#tempHistPuestos') IS NOT NULL DROP TABLE #tempHistPuestos
IF OBJECT_ID('TEMPDB..#tempHistSalarios') IS NOT NULL DROP TABLE #tempHistSalarios


Select   
 IDEmpleado,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion,ROW_NUMBER() OVER(PARTITION by idempleado order by FechaIni desc) as RN
    into #tempHistPuestos 
from rh.tblPuestoEmpleado e inner join rh.tblCatPuestos cp on cp.IDPuesto = e.IDPuesto
where IDEmpleado in (select item from  app.Split(@IDEmpleados,',')) 



select IDEmpleado,SalarioDiario , ROW_NUMBER()OVER(PARTITION BY IDEmpleado order by Fecha desc) as RN 
into #tempHistSalarios
from IMSS.tblMovAfiliatorios
where IDEmpleado in (select item from  app.Split(@IDEmpleados,',')) and IDTipoMovimiento <> 2

Select *,
(Select SalarioDiario from #tempHistSalarios where RN = 2) as SalarioDiarioAnterior,
(Select Descripcion from #tempHistPuestos where RN = 2) as PuestoAnterior
from rh.tblEmpleadosMaster em 
where IDEmpleado in(select item from  app.Split(@IDEmpleados,','))
    
END
GO
