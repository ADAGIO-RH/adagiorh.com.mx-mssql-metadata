USE [p_adagioRHGMGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	    
CREATE proc [Reportes].[spReporteBasicoReporteISNImpreso](        
		@Cliente	varchar(max) = '',      
	@TipoNomina varchar(max) = '',      
	@Ejercicio	varchar(max),       
	@IDMes		varchar(max),       
	@RazonesSociales	varchar(max),      
	@RegPatronales		varchar(max),      
	@Sucursales			varchar(max),   
	@IDUsuario			int        
) as        
	SET FMTONLY OFF     
	declare 
		@empleados [RH].[dtEmpleados]            
		,@IDPeriodoSeleccionado int=0            
		,@periodo [Nomina].[dtPeriodos]            
		,@configs [Nomina].[dtConfiguracionNomina]            
		,@Conceptos [Nomina].[dtConceptos]            
		,@fechaIniPeriodo  date            
		,@fechaFinPeriodo  date         
		,@dtFiltros Nomina.dtFiltrosRH         
		,@IDConcepto540 int  
		,@IDIdioma varchar(10)
		--,@dtFechas app.dtFechas
		--,@IDEmpresa int
	;        

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
   
	select @IDConcepto540 = IDConcepto from Nomina.tblCatConceptos where Codigo = '540'
	
	insert into @dtFiltros(Catalogo,Value)      
	values('RazonesSociales',@RazonesSociales)      
		,('RegPatronales',@RegPatronales)      
		,('Sucursales',@Sucursales)      
      
	/* Se buscan el periodo seleccionado */        
	insert into @periodo      
	select *         
	from Nomina.tblCatPeriodos      
	where (
			(
				IDTipoNomina in (select item from App.Split(isnull(@TipoNomina,''),',')) or (isnull(@TipoNomina,'') = '')
			)  
		)                       
		and IDMes in (Select item from App.Split(@IDMes,','))   
		and Ejercicio in (Select item from App.Split(@Ejercicio,','))
    
	select @fechaIniPeriodo = min(FechaInicioPago), @fechaFinPeriodo = max(FechaFinPago) from @periodo         


	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */
    insert into @empleados            
    exec [RH].[spBuscarEmpleados]
		@FechaIni = @fechaIniPeriodo, 
		@Fechafin = @fechaFinPeriodo,  
		--@dtFiltros = @dtFiltros, 
		@IDUsuario = @IDUsuario          
	





	if object_id('tempdb..#tempData') is not null drop table #tempData;           
      
	select    
		E.ClaveEmpleado as ClaveEmpleado,  
		E.NOMBRECOMPLETO as NombreCompleto,  
		isnull(e.Departamento  ,'SIN DEPARTAMENTO') as Departamento,    
		isnull(e.Sucursal,'SIN SUCURSAL') as Sucursal,    
		isnull(e.Puesto,'SIN PUESTO') as Puesto,      
		isnull(em.NombreComercial  ,'SIN RAZÓN SOCIAL') as RazonSocial,    
		isnull(crp.RazonSocial,'SIN REGISTRO PATRONAL') as Registro_Patronal,    
		c.OrdenCalculo,  
		c.Codigo+' - '+c.Descripcion as Concepto,      
		SUM(isnull(dp.ImporteTotal1,0)) as Importe_ISN,  
		ISNULL(ISN.Porcentaje,0) as Porcentaje,  
		--ISNULL(m.Descripcion,'') as Mes,  
		JSON_VALUE(m.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Mes,
		c.Codigo
	into #tempData
	from @periodo P      
		inner join Nomina.tblDetallePeriodo dp	
			on p.IDPeriodo= dp.IDPeriodo      
		inner join rh.tblEmpleadosMaster e				
			on dp.IDEmpleado= e.IDEmpleado  
		inner join Nomina.tblHistorialesEmpleadosPeriodos he
			on he.IDPeriodo=p.IDPeriodo and he.IDEmpleado=e.IDEmpleado
		inner join Nomina.tblCatMeses m		
			on m.IDMes= p.IDMes  
		left join RH.tblCatSucursales s		
			on e.IDSucursal= s.IDSucursal  
		left join Nomina.tblConfigISN ISN	
			on s.IDEstadoSTPS= ISN.IDEstado  
		left join Nomina.tblCatConceptos c	
			on C.IDConcepto= dp.IDConcepto 
		left join rh.tblEmpresa em
			on em.IdEmpresa=he.IDEmpresa
		left join rh.tblCatRegPatronal crp
			on crp.IDRegPatronal=he.IDRegPatronal
	where  ((c.IDConcepto =  104) OR (c.IDConcepto not in (select item from app.Split(isn.IDConceptos,',')) and c.IDTipoConcepto = 1))  
		and he.idempresa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),','))
		and e.SalarioDiario>1
	group by 
		c.Descripcion, 
		c.Codigo,  
		em.NombreComercial,    
		crp.RazonSocial,    
		e.Sucursal,    
		E.ClaveEmpleado,  
		E.NOMBRECOMPLETO,  
		e.Departamento,  
		e.Puesto,  
		c.OrdenCalculo,  
		ISN.Porcentaje,
		m.Traduccion,
		he.IDRegPatronal,
		he.IDEmpresa
	ORDER BY e.Sucursal, e.ClaveEmpleado, c.OrdenCalculo
  
	insert into #tempData
	select  
		ClaveEmpleado,  
		NombreCompleto,  
		Departamento,    
		Sucursal,    
		Puesto,      
		RazonSocial,    
		Registro_Patronal,    
		0 as OrdenCalculo,  
		'000'+' - '+'TOTAL BASE' as Concepto,      
		SUM(Importe_ISN) as Importe_ISN,  
		Porcentaje,  
		Mes,  
		'000'Codigo
	from #tempData
	where codigo <> '540'
	group by
		ClaveEmpleado,  
		NombreCompleto,  
		Departamento,    
		Sucursal,    
		Puesto,      
		RazonSocial,    
		Registro_Patronal,    
		Porcentaje,
		Mes
    
   select * from #tempData order by ClaveEmpleado
GO
