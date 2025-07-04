USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE procedure [Reportes].[spReporteBasicaGeneralTarjetadeSalud] 
(    
  @dtFiltros [Nomina].[dtFiltrosRH] readonly,
  @IDUsuario int  
 )  
AS    
BEGIN    

	Declare  @empleados [RH].[dtEmpleados]    
		   --@Titulo VARCHAR(MAX)= 'REPORTE DE GENERAL DE TARJETAS DE SALUD DEL '    
				 --+ App.fnAddString(2,cast(DATEPART(DAY,@FechaIni) as varchar(2)),'0',1)    
				 --+'/'+substring(UPPER(cast(FORMAT(@FechaIni,'MMMM') as varchar)),1,3)                       --UPPER(DATENAME(month,@FechaIni))    
				 --+'/'+CAST(DATEPART(YEAR,@FechaIni) as varchar)    
				 --+' AL '    
				 --+ App.fnAddString(2,cast(DATEPART(DAY,@FechaFin) as varchar(2)),'0',1)    
				 --+'/'+substring(UPPER(cast(FORMAT(@FechaFin,'MMMM') as varchar)),1,3)                                  --UPPER(DATENAME(month,@FechaFin))    
				 --+'/'+CAST(DATEPART(YEAR,@FechaFin) as varchar) --{FECHA INICIAL CON FORMATO DD / Mes con Letra Completo / AÑO (4 dígitos)} AL FECHA FINAL     
  
	insert into @empleados    
	Exec [RH].[spBuscarEmpleadosMaster] @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario    
    
	select e.ClaveEmpleado,    
		e.NOMBRECOMPLETO as NombreCompleto,    
		cast(e.FechaAntiguedad as varchar(10)) AS FechaAntiguedad,    
		cast(dateadd(month,-6,se.VencimientoTarjeta) as varchar(10)) as FechaExpedicion,    
		cast(se.VencimientoTarjeta as varchar(10)) AS VencimientoTarjeta,   
		e.Departamento,    
		e.Puesto,    
		e.Sucursal,    
		e.RegPatronal,    
		e.TipoContrato,
		e.Division
		--@Titulo AS Titulo  
	from rh.tblSaludEmpleado se with (nolock)
		inner join @empleados e
			on e.IDEmpleado = se.IDEmpleado    
	where e.Vigente = 1 and se.RequiereTarjetaSalud = 1
END
GO
