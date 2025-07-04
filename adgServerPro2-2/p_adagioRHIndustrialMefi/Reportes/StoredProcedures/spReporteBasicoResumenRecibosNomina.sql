USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
CREATE proc [Reportes].[spReporteBasicoResumenRecibosNomina](    
	 @Cliente int,  
	 @TipoNomina int,   
	 @IDPeriodoInicial Varchar(max),   
	 @Ejercicio Varchar(max),   
	 @IDDepartamento varchar(max) = '',    
	 @IDSucursal  varchar(max) = '',       
	 @IDRazonSocial  varchar(max) = '',
	 @IDPuesto varchar(max) = '',   
	 @IDPrestaciones varchar(max) = '', 
	 @IDClientes varchar(max) = '', 
	 @IDRegPatronales varchar(max) = '', 
	 @IDDivisiones varchar(max) = '',  
	 @IDCentrosCosto varchar(max) = '',  
	 @IDClasificacionesCorporativas varchar(max) = '',  
	 @ConceptosPago varchar(max) = '',
	 @ClaveEmpleadoInicial VARCHAR(MAX) = '',
	 @ClaveEmpleadoFinal VARCHAR(MAX) = '',
	 @Timbrado bit = 0, 
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
		,@EmpleadoIni Varchar(20)  
		,@EmpleadoFin Varchar(20)  
	;    


	SET @EmpleadoIni	= ISNULL(@ClaveEmpleadoInicial,'0')    
	SET @EmpleadoFin	= ISNULL(@ClaveEmpleadoFinal,'ZZZZZZZZZZZZZZZZZZZZ')     
	

	if Object_ID('tempdb..#tempestatus') is not null drop table #tempestatus

	CREATE TABLE #tempestatus(
		IDEstatusTimbrado int
	)

	IF(@Timbrado = 1)
	BEGIN
		insert into #tempestatus
		Select IDEstatusTimbrado  from Facturacion.tblCatEstatusTimbrado where IDEstatusTimbrado = 2
	END
	ELSE
	BEGIN
		insert into #tempestatus
		Select IDEstatusTimbrado  from Facturacion.tblCatEstatusTimbrado where IDEstatusTimbrado <> 2
	END
  
	if(isnull(@IDDepartamento,'')<>'')      
	BEGIN      
	  insert into @dtFiltros(Catalogo,Value)      
	  values('Departamentos',case when @IDDepartamento is null then '' else @IDDepartamento end)      
	END;      
	if(isnull(@IDSucursal,'')<>'')      
	BEGIN      
	  insert into @dtFiltros(Catalogo,Value)      
	  values('Sucursales',case when @IDSucursal is null then '' else @IDSucursal end)      
	END;  
	
	if(isnull(@IDPuesto,'')<>'')      
	BEGIN      
	  insert into @dtFiltros(Catalogo,Value)      
	  values('Puestos',case when @IDPuesto is null then '' else @IDPuesto end)      
	END;  
	
	if(isnull(@IDPrestaciones,'')<>'')      
	BEGIN      
	  insert into @dtFiltros(Catalogo,Value)      
	  values('Prestaciones',case when @IDPrestaciones is null then '' else @IDPrestaciones end)      
	END;   

	
	if(isnull(@IDClientes,'')<>'')      
	BEGIN      
	  insert into @dtFiltros(Catalogo,Value)      
	  values('Clientes',case when @IDClientes is null then '' else @IDClientes end)      
	END; 
 
  
	if(isnull(@IDRazonSocial,'')<>'')      
	BEGIN      
	  insert into @dtFiltros(Catalogo,Value)      
	  values('RazonesSociales',case when @IDRazonSocial is null then '' else @IDRazonSocial end)      
	END;  
    
	if(isnull(@IDRegPatronales,'')<>'')      
	BEGIN      
	  insert into @dtFiltros(Catalogo,Value)      
	  values('RegPatronales',case when @IDRegPatronales is null then '' else @IDRegPatronales end)      
	END;   
	if(isnull(@IDDivisiones,'')<>'')      
	BEGIN      
	  insert into @dtFiltros(Catalogo,Value)      
	  values('Divisiones',case when @IDDivisiones is null then '' else @IDDivisiones end)      
	END; 
	if(isnull(@IDClasificacionesCorporativas,'')<>'')      
	BEGIN      
	  insert into @dtFiltros(Catalogo,Value)      
	  values('ClasificacionesCorporativas',case when @IDClasificacionesCorporativas is null then '' else @IDClasificacionesCorporativas end)      
	END;
  if(isnull(@IDCentrosCosto,'')<>'')      
	BEGIN      
	  insert into @dtFiltros(Catalogo,Value)      
	  values('CentrosCostos',case when @IDCentrosCosto is null then '' else @IDCentrosCosto end)      
	END;

	if(isnull(@ConceptosPago,'')<>'')      
	BEGIN      
	  insert into @dtFiltros(Catalogo,Value)      
	  values('ConceptosPago',case when @ConceptosPago is null then '' else @ConceptosPago end)      
	END;
  


   set @IDTipoNomina = (Select top 1 cast(item as int) from App.Split(@TipoNomina,''))
  
	/* Se buscan el periodo seleccionado */    
	insert into @periodo  
	select   *
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
    exec [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina
	,@FechaIni=@fechaIniPeriodo
	,@Fechafin = @fechaFinPeriodo 
	,@dtFiltros = @dtFiltros
	,@IDUsuario = @IDUsuario     
	,@EmpleadoIni = @EmpleadoIni  
	,@EmpleadoFin = @EmpleadoFin  
    
	--delete @empleados
	--where IDEmpleado not in (Select IDEmpleado from Nomina.tblDetallePeriodo where IDPeriodo = @IDPeriodoInicial )  
	--select * from @empleados
	
	Select E.*,
		Empresa.RFC RFCEmpresa,        
		RF.Descripcion as EmpresaRegimenFiscal,        
		estados.NombreEstado as EmpresaEstado,        
		municipios.Descripcion as EmpresaMunicipio, 
		regpatronal.RegistroPatronal as NumRegPatronal,   
		P.*,
		CASE WHEN EXISTS(Select 1 from Nomina.tblDetallePeriodo where IDPeriodo = p.IDPeriodo and IDEmpleado = E.IDEmpleado and isnull(ImporteTotal1,0)>0 and IDConcepto in (select IDConcepto from Nomina.tblCatConceptos where Codigo in ('601','604'))) THEN 1 ELSE 0 END as EmpleadosTransferencia,
		CASE WHEN EXISTS(Select 1 from Nomina.tblDetallePeriodo where IDPeriodo = p.IDPeriodo and IDEmpleado = E.IDEmpleado and isnull(ImporteTotal1,0)>0 and IDConcepto in (select IDConcepto from Nomina.tblCatConceptos where Codigo in ('602','605'))) THEN 1 ELSE 0 END as EmpleadosCheque,
		CASE WHEN EXISTS(Select 1 from Nomina.tblDetallePeriodo where IDPeriodo = p.IDPeriodo and IDEmpleado = E.IDEmpleado and isnull(ImporteTotal1,0)>0 and IDConcepto in (select IDConcepto from Nomina.tblCatConceptos where Codigo in ('603','606'))) THEN 1 ELSE 0 END as EmpleadosEfectivo,
		CASE WHEN EXISTS(Select 1 from Nomina.tblDetallePeriodo where IDPeriodo = p.IDPeriodo and IDEmpleado = E.IDEmpleado and isnull(ImporteTotal1,0)>0 and IDConcepto in (select IDConcepto from Nomina.tblCatConceptos where Codigo in ('607'))) THEN 1 ELSE 0 END as EmpleadosOtro,
		CASE WHEN isnull((Select SUM(ImporteTotal1)  from Nomina.tblDetallePeriodo where IDPeriodo = p.IDPeriodo and IDEmpleado = E.IDEmpleado  and IDConcepto  in (select IDConcepto from Nomina.tblCatConceptos where IDTipoConcepto = 5)),0) <= 0 THEN 1 ELSE 0 END as EmpleadosCero
		,t.ACUSE       
		,t.CadenaOriginal       
		,t.NoCertificadoSat       
		,t.SelloCFDI       
		,t.SelloSAT       
		,t.UUID 
        ,t.Fecha as FechaTimbrado
		,(
			select Valor + 'RecibosNomina/' + cast(e.IDTipoNomina as varchar(10)) + '/' + p.ClavePeriodo + '/XML/' + Empresa.RFC + '_' + p.ClavePeriodo + '_' +e.ClaveEmpleado + '_' + RH.fnFormatNombreCompleto(e.nombre,e.segundoNombre,e.Paterno,e.Materno)+ '.jpeg'
			from App.tblConfiguracionesGenerales with (nolock)
			where IDConfiguracion = 'Url'
		) as QR
	from @empleados E
		left join Nomina.tblHistorialesEmpleadosPeriodos hep with (nolock) on hep.IDEmpleado = E.IDEmpleado
			and hep.IDPeriodo = @IDPeriodoInicial
		left join RH.tblEmpresa					Empresa with (nolock) on Empresa.IdEmpresa = E.IDEmpresa
		left join Sat.tblCatRegimenesFiscales	RF with (nolock) on RF.IDRegimenFiscal = Empresa.IDRegimenFiscal        
		left join Sat.tblCatEstados				estados with (nolock) on estados.IDEstado = Empresa.IDEstado        
		left join Sat.tblCatMunicipios			municipios with (nolock) on municipios.IDMunicipio = Empresa.IDMunicipio 
		left join RH.tblCatRegPatronal			regpatronal with (nolock) on regpatronal.IDRegPatronal = E.IDRegPatronal   
		left join @periodo						p on p.IDPeriodo = @IDPeriodoInicial
		left join Facturacion.TblTimbrado		T with (nolock) on T.IDHistorialEmpleadoPeriodo = hep.IDHistorialEmpleadoPeriodo       
	 
	Where E.IDEmpleado in (Select distinct IDEmpleado from Nomina.tblDetallePeriodo where  IDPeriodo = @IDPeriodoInicial and ((IDConcepto in (select ITEM from App.Split(isnull(@ConceptosPago,''),','))) OR isnull(@ConceptosPago,'') = ''))
		AND (
			(@Timbrado = 1 AND t.IDEstatusTimbrado IN (SELECT IDEstatusTimbrado FROM #tempestatus))
			OR
			(@Timbrado = 0 AND (t.IDEstatusTimbrado IN (SELECT IDEstatusTimbrado FROM #tempestatus) OR t.IDEstatusTimbrado IS NULL))
		  )
		and (t.Actual = 1 OR t.Actual is null)
	order by e.ClaveEmpleado
GO
