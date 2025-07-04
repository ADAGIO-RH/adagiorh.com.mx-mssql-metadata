USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
CREATE proc [Reportes].[spReporteBasicoResumenNominaSucursalImpreso](    
	 @Cliente int,  
	 @TipoNomina int,   
	 @Sucursales varchar(max),  
	 @Ejercicio Varchar(max),   
	 @IDPeriodoInicial Varchar(max),   
	 @IDUsuario int    
) as    
	SET FMTONLY OFF 
	declare @empleados [RH].[dtEmpleados]        
		,@IDPeriodoSeleccionado int=0        
		,@periodo [Nomina].[dtPeriodos]        
		,@configs [Nomina].[dtConfiguracionNomina]        
		,@Conceptos [Nomina].[dtConceptos]        
		,@fechaIniPeriodo  date        
		,@fechaFinPeriodo  date 
		,@IDTipoNomina   int    
		,@dtFiltros Nomina.dtFiltrosRH     
	;    
  
	 insert into @dtFiltros(Catalogo,Value)  
	 values('Sucursales',@Sucursales)  
  
   set @IDTipoNomina = (Select top 1 cast(item as int) from App.Split(@TipoNomina,''))
  
	/* Se buscan el periodo seleccionado */    
	insert into @periodo  
	select *  
		--IDPeriodo  
		--,IDTipoNomina  
		--,Ejercicio  
		--,ClavePeriodo  
		--,Descripcion  
		--,FechaInicioPago  
		--,FechaFinPago  
		--,FechaInicioIncidencia  
		--,FechaFinIncidencia  
		--,Dias  
		--,AnioInicio  
		--,AnioFin  
		--,MesInicio  
		--,MesFin  
		--,IDMes  
		--,BimestreInicio  
		--,BimestreFin  
		--,Cerrado  
		--,General  
		--,Finiquito  
		--,isnull(Especial,0)  
	from Nomina.tblCatPeriodos  
	where IDPeriodo = @IDPeriodoInicial  
    
	select top 1 @fechaIniPeriodo = FechaInicioPago,  @fechaFinPeriodo = FechaFinPago from @periodo  
  
	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */        
    insert into @empleados        
    exec [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina,@FechaIni=@fechaIniPeriodo, @Fechafin = @fechaFinPeriodo ,@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario     
    
	--delete @empleados
	--where IDEmpleado not in (Select IDEmpleado from Nomina.tblDetallePeriodo where IDPeriodo = @IDPeriodoInicial )  
	
	if object_id('tempdb..#tempResults') is not null        
		drop table #tempResults  
  
	Select  
		E.Sucursal,  
		E.RegPatronal as RegPatronal,   
		c.Codigo as CodigoConcepto,  
		c.Descripcion as Concepto,  
		tc.IDTipoConcepto as IDTipoConcepto,  
		tc.Descripcion as TipoConcepto,  
		c.OrdenCalculo as OrdenCalculo,  
		SUM(dp.ImporteTotal1) as ImporteTotal1
	into #tempResults
	from @periodo P  
		inner join Nomina.tblDetallePeriodo dp  
			on p.IDPeriodo = dp.IDPeriodo  
		inner join Nomina.tblCatConceptos c  
			on C.IDConcepto = dp.IDConcepto  
		inner join Nomina.tblCatTipoConcepto tc  
			on tc.IDTipoConcepto = c.IDTipoConcepto  
		inner join @empleados e  
			on dp.IDEmpleado = e.IDEmpleado  
	GROUP BY E.Sucursal   
		,c.Codigo   
		,c.Descripcion  
		,tc.IDTipoConcepto  
		,tc.Descripcion  
		,c.OrdenCalculo  
		,E.RegPatronal  

	  Select t.*,
	  (Select count(*) from @empleados where Sucursal = t.Sucursal and IDEmpleado  in (Select IDEmpleado from Nomina.tblDetallePeriodo where IDPeriodo = @IDPeriodoInicial )) as Empleados, 
	  (Select count(*) from @empleados where IDEmpleado  in (Select IDEmpleado from Nomina.tblDetallePeriodo where IDPeriodo = @IDPeriodoInicial )  ) as TotalEmpleados 
	  from #tempResults t
GO
