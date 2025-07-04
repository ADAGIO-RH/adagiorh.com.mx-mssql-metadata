USE [p_adagioRHGMGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteBasicoResumenNominaListaEmpleadosP](    
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
	 @IDUsuario int,
	 @ConceptosPago varchar(max) = ''
) as    
	SET FMTONLY OFF 
	declare 
		@empleados [RH].[dtEmpleados]        
		,@empleadosTemp [RH].[dtEmpleados]        
		,@IDPeriodoSeleccionado int=0        
		,@periodo [Nomina].[dtPeriodos]        
		,@configs [Nomina].[dtConfiguracionNomina]        
		,@Conceptos [Nomina].[dtConceptos]        
		,@fechaIniPeriodo  date        
		,@fechaFinPeriodo  date 
		,@IDTipoNomina   int    
		,@dtFiltros Nomina.dtFiltrosRH   
		,@Cerrado bit = 1
	;    
  
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
	from Nomina.tblCatPeriodos with (nolock)  
	where IDPeriodo = @IDPeriodoInicial     	

	-- Guardamos en la variable @Cerrado el estatus del período para determinar si actualizamos o no los historiales de los colaboradres de la tabla Nomina.tblHistorialesEmpleadosPeriodos
	select top 1 @Cerrado = ISNULL(Cerrado,0) from @periodo

	select top 1 @fechaIniPeriodo = FechaInicioPago,  @fechaFinPeriodo = FechaFinPago from @periodo  
  
	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */        
 
	insert into @empleadosTemp   
	select e.*
	from RH.tblEmpleadosMaster e with (nolock)
		join ( select distinct dp.IDEmpleado
				from Nomina.tblDetallePeriodo dp
				where dp.IDPeriodo = @IDPeriodoInicial and dp.ImporteTotal1<>0
		) detallePeriodo on e.IDEmpleado = detallePeriodo.IDEmpleado
		where e.tipotrabajadorempleado<>'eventual'


	if (@Cerrado = 1)
	begin

		update e
			set 
				e.IDCentroCosto		= isnull(cc.IDCentroCosto	,e.IDCentroCosto)
				,e.CentroCosto		= isnull(cc.Descripcion		,e.CentroCosto	)
				,e.IDDepartamento	= isnull(d.IDDepartamento	,e.IDDepartamento)
				,e.Departamento		= isnull(d.Descripcion		,e.Departamento	)
				,e.IDSucursal		= isnull(s.IDSucursal		,e.IDSucursal	)
				,e.Sucursal			= isnull(s.Descripcion		,e.Sucursal		)
				,e.IDPuesto			= isnull(p.IDPuesto			,e.IDPuesto		)
				,e.Puesto			= isnull(p.Descripcion		,e.Puesto		)
				,e.IDRegPatronal	= isnull(rp.IDRegPatronal	,e.IDRegPatronal)
				,e.RegPatronal		= isnull(rp.RazonSocial		,e.RegPatronal	)
				,e.IDCliente		= isnull(c.IDCliente		,e.IDCliente	)
				,e.Cliente			= isnull(c.NombreComercial	,e.Cliente		)
				,e.IDEmpresa		= isnull(emp.IdEmpresa		,e.IdEmpresa	)
				,e.Empresa			= isnull(substring(emp.NombreComercial,1,50),substring(e.Empresa,1,50))
				,e.IDArea			= isnull(a.IDArea			,e.IDArea		)
				,e.Area				= isnull(a.Descripcion		,e.Area			)
				,e.IDDivision		= isnull(div.IDDivision		,e.IDDivision	)
				,e.Division			= isnull(div.Descripcion	,e.Division		)
				,e.IDRegion			= isnull(r.IDRegion			,e.IDRegion		)
				,e.Region			= isnull(r.Descripcion		,e.Region		)
				,e.IDRazonSocial	= isnull(rs.IDRazonSocial	,e.IDRazonSocial)
				,e.RazonSocial		= isnull(rs.RazonSocial		,e.RazonSocial	)

				,e.IDClasificacionCorporativa	= isnull(clasificacionC.IDClasificacionCorporativa,e.IDClasificacionCorporativa)
				,e.ClasificacionCorporativa		= isnull(clasificacionC.Descripcion, e.ClasificacionCorporativa)

		from @empleadosTemp e
			join ( select hep.*
					from Nomina.tblHistorialesEmpleadosPeriodos hep with (nolock)
						join @periodo p on hep.IDPeriodo = p.IDPeriodo
				) historiales on e.IDEmpleado = historiales.IDEmpleado
			left join RH.tblCatCentroCosto cc		with(nolock) on cc.IDCentroCosto = historiales.IDCentroCosto
		 	left join RH.tblCatDepartamentos d		with(nolock) on d.IDDepartamento = historiales.IDDepartamento
			left join RH.tblCatSucursales s			with(nolock) on s.IDSucursal		= historiales.IDSucursal
			left join RH.tblCatPuestos p			with(nolock) on p.IDPuesto			= historiales.IDPuesto
			left join RH.tblCatRegPatronal rp		with(nolock) on rp.IDRegPatronal	= historiales.IDRegPatronal
			left join RH.tblCatClientes c			with(nolock) on c.IDCliente		= historiales.IDCliente
			left join RH.tblEmpresa emp				with(nolock) on emp.IDEmpresa	= historiales.IDEmpresa
			left join RH.tblCatArea a				with(nolock) on a.IDArea		= historiales.IDArea
			left join RH.tblCatDivisiones div		with(nolock) on div.IDDivision	= historiales.IDDivision
			left join RH.tblCatRegiones r			with(nolock) on r.IDRegion		= historiales.IDRegion
			left join RH.tblCatRazonesSociales rs	with(nolock) on rs.IDRazonSocial = historiales.IDRazonSocial
			left join RH.tblCatClasificacionesCorporativas clasificacionC with(nolock)	on clasificacionC.IDClasificacionCorporativa = historiales.IDClasificacionCorporativa

	end;


		--update e set e.idEmpresa = empresa.idempresa, e.empresa = Nempresa.NombreComercial
		--from @empleadosTemp e
		--inner join rh.tblempresaempleado empresa
		--	on empresa.idempleado = e.idempleado
		--inner join rh.tblempresa Nempresa
		--	on Nempresa.idEmpresa = empresa.idempresa
		--where empresa.Fechaini <= @fechaFinPeriodo and empresa.FechaFin > @fechaIniPeriodo

	insert @Empleados
	exec [RH].[spFiltrarEmpleadosDesdeLista]              
		@dtEmpleados	= @empleadosTemp,
		@dtFiltros		= @dtFiltros,
		@IDUsuario		= @IDUsuario


	Select E.*,
		P.*,
		CASE WHEN EXISTS(Select 1 from Nomina.tblDetallePeriodo with (nolock) where IDPeriodo = p.IDPeriodo and IDEmpleado = E.IDEmpleado and isnull(ImporteTotal1,0)>0 and IDConcepto in (select IDConcepto from Nomina.tblCatConceptos with (nolock) where Codigo in ('601','604'))) THEN 1 ELSE 0 END as EmpleadosTransferencia,
		CASE WHEN EXISTS(Select 1 from Nomina.tblDetallePeriodo with (nolock) where IDPeriodo = p.IDPeriodo and IDEmpleado = E.IDEmpleado and isnull(ImporteTotal1,0)>0 and IDConcepto in (select IDConcepto from Nomina.tblCatConceptos with (nolock) where Codigo in ('602','605'))) THEN 1 ELSE 0 END as EmpleadosCheque,
		CASE WHEN EXISTS(Select 1 from Nomina.tblDetallePeriodo with (nolock) where IDPeriodo = p.IDPeriodo and IDEmpleado = E.IDEmpleado and isnull(ImporteTotal1,0)>0 and IDConcepto in (select IDConcepto from Nomina.tblCatConceptos with (nolock) where Codigo in ('603','606'))) THEN 1 ELSE 0 END as EmpleadosEfectivo,
		CASE WHEN EXISTS(Select 1 from Nomina.tblDetallePeriodo with (nolock) where IDPeriodo = p.IDPeriodo and IDEmpleado = E.IDEmpleado and isnull(ImporteTotal1,0)>0 and IDConcepto in (select IDConcepto from Nomina.tblCatConceptos with (nolock) where Codigo in ('607'))) THEN 1 ELSE 0 END as EmpleadosOtro,
		CASE WHEN isnull((Select SUM(ImporteTotal1)  from Nomina.tblDetallePeriodo with (nolock) where IDPeriodo = p.IDPeriodo and IDEmpleado = E.IDEmpleado  and IDConcepto  in (select IDConcepto from Nomina.tblCatConceptos with (nolock) where IDTipoConcepto = 5)),0) <= 0 THEN 0 ELSE 0 END as EmpleadosCero
	from @empleados E
		,@periodo p
	Where E.IDEmpleado in (Select distinct IDEmpleado from Nomina.tblDetallePeriodo with (nolock) where IDPeriodo = @IDPeriodoInicial)
	and E.IDEmpleado in 
	(Select IDEmpleado 
	from Nomina.tblDetallePeriodo 
	where  IDPeriodo = @IDPeriodoInicial 
		and ((IDConcepto in (select ITEM from App.Split(isnull(@ConceptosPago,''),','))) OR isnull(@ConceptosPago,'') = ''))
		AND (E.IDSucursal IN (SELECT item FROM App.Split(@IDSucursal, ',')) OR @IDSucursal = '')
GO
