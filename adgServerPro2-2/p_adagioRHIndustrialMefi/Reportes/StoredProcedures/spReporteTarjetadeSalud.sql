USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE procedure [Reportes].[spReporteTarjetadeSalud] --@IDPeriodo = 1    
(    
	  @dtFiltros [Nomina].[dtFiltrosRH] readonly,
	  @IDUsuario int  
 )  
AS    
BEGIN    

	Declare  @empleados [RH].[dtEmpleados]   
			,@FechaIni Date = '1900-01-01'  
			,@FechaFin Date = '9999-12-31'

	SET @FechaIni		= cast((Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),',')) as date)    
	SET @FechaFin		= cast((Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),',')) as date)  
	
		    
	insert into @empleados    
	Exec [RH].[spBuscarEmpleadosMaster] @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario    
    
	select 
			e.ClaveEmpleado CLAVE
			,e.NOMBRECOMPLETO as [NOMBRE EMPLEADO]   
			,cast(dateadd(month,-6,se.VencimientoTarjeta) as varchar(10)) as [EXPEDICION TARJETA]    
			,cast(se.VencimientoTarjeta as varchar(10)) AS [VENCIMIENTO TARJETA] 
			,FORMAT(GETDATE(),'dd/MM/yyyy')  as [FECHA HOY]
			,CASE WHEN se.VencimientoTarjeta > GETDATE() then (DATEDIFF(d, se.VencimientoTarjeta, GETDATE()) * -1)
				else
				DATEDIFF(d, se.VencimientoTarjeta, GETDATE())
				end as [DIAS PARA VENCIMIENTO]
	
			,case when (se.VencimientoTarjeta >= getdate()) then 'SI' else 'NO' end as [TARJETA VIGENTE]

			,e.Departamento AS DEPARTAMENTO 
			,e.Puesto AS PUESTO
			,e.Sucursal AS SUCURSAL
			,e.RegPatronal AS [REGISTRO PATRONAL]
			--e.TipoContrato,
			,e.Division AS DIVISION
			
			,case when e.Vigente=1 then 'Si' else 'No' end as [VIGENTE HOY]
	from  rh.tblSaludEmpleado se  
		inner join @empleados e 
			on e.IDEmpleado = se.IDEmpleado  
				and isnull(se.VencimientoTarjeta,'9999-12-31') Between @FechaIni and @FechaFin
				    
		   --where e.Vigente = 1

		order by e.ClaveEmpleado asc, se.VencimientoTarjeta asc   
END
GO
