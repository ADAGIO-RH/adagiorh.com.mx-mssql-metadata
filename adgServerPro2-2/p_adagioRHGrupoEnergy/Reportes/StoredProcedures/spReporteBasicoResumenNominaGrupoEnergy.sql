USE [p_adagioRHGrupoEnergy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteBasicoResumenNominaGrupoEnergy](    
	 @Cliente int,  
	 @TipoNomina int,   
	 @IDPeriodoInicial Varchar(max),   
	 @Ejercicio Varchar(max),   
	 @Departamentos varchar(max) = '',    
	 @Sucursales  varchar(max) = '',       
	 @RazonesSociales  varchar(max) = '',
	 @Puestos varchar(max) = '',   
	 @Clientes varchar(max) = '', 
	 @RegPatronales varchar(max) = '', 
	 @Divisiones varchar(max) = '',  
	 @CentrosCostos varchar(max) = '',  
	 @ClasificacionesCorporativas varchar(max) = '',   
	 @IDUsuario int
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
  
	if(isnull(@Departamentos,'')<>'')      
	BEGIN      
		insert into @dtFiltros(Catalogo,Value)      
		values('Departamentos',case when @Departamentos is null then '' else @Departamentos end)      
	END;    
	
	if(isnull(@Sucursales,'')<>'')      
	BEGIN      
		insert into @dtFiltros(Catalogo,Value)      
		values('Sucursales',case when @Sucursales is null then '' else @Sucursales end)      
	END;  
	
	if(isnull(@Puestos,'')<>'')      
	BEGIN      
		insert into @dtFiltros(Catalogo,Value)      
		values('Puestos',case when @Puestos is null then '' else @Puestos end)      
	END;  
	

	
	if(isnull(@Clientes,'')<>'')      
	BEGIN      
		insert into @dtFiltros(Catalogo,Value)      
		values('Clientes',case when @Clientes is null then '' else @Clientes end)      
	END; 
  
	if(isnull(@RazonesSociales,'')<>'')      
	BEGIN      
		insert into @dtFiltros(Catalogo,Value)      
		values('RazonesSociales',case when @RazonesSociales is null then '' else @RazonesSociales end)      
	END;  
    
	if(isnull(@RegPatronales,'')<>'')      
	BEGIN      
		insert into @dtFiltros(Catalogo,Value)      
		values('RegPatronales',case when @RegPatronales is null then '' else @RegPatronales end)      
	END;   

	if(isnull(@Divisiones,'')<>'')      
	BEGIN      
		insert into @dtFiltros(Catalogo,Value)      
		values('Divisiones',case when @Divisiones is null then '' else @Divisiones end)      
	END; 

	if(isnull(@ClasificacionesCorporativas,'')<>'')      
	BEGIN      
		insert into @dtFiltros(Catalogo,Value)      
		values('ClasificacionesCorporativas',case when @ClasificacionesCorporativas is null then '' else @ClasificacionesCorporativas end)      
	END;

	if(isnull(@CentrosCostos,'')<>'')      
	BEGIN      
		insert into @dtFiltros(Catalogo,Value)      
		values('CentrosCostos',case when @CentrosCostos is null then '' else @CentrosCostos end)      
	END;

	set @IDTipoNomina = (Select top 1 cast(item as int) from App.Split(@TipoNomina,''))
  
	/* Se buscan el periodo seleccionado */    
	insert into @periodo  
	select   
		IDPeriodo  
		,IDTipoNomina  
		,Ejercicio  
		,ClavePeriodo  
		,Descripcion  
		,FechaInicioPago  
		,FechaFinPago  
		,FechaInicioIncidencia  
		,FechaFinIncidencia  
		,Dias  
		,AnioInicio  
		,AnioFin  
		,MesInicio  
		,MesFin  
		,IDMes  
		,BimestreInicio  
		,BimestreFin  
		,Cerrado  
		,General  
		,Finiquito  
		,isnull(Especial,0)  
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
				where dp.IDPeriodo = @IDPeriodoInicial
		) detallePeriodo on e.IDEmpleado = detallePeriodo.IDEmpleado
    --exec [RH].[spBuscarEmpleadosMaster] @IDTipoNomina = @IDTipoNomina,@FechaIni=@fechaIniPeriodo, @Fechafin = @fechaFinPeriodo ,@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario     
    
	--delete @empleados
	--where IDEmpleado not in (Select IDEmpleado from Nomina.tblDetallePeriodo where IDPeriodo = @IDPeriodoInicial )  
	
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
	
	insert @Empleados
	exec [RH].[spFiltrarEmpleadosDesdeLista]              
		@dtEmpleados	= @empleadosTemp,
		@dtFiltros		= @dtFiltros,
		@IDUsuario		= @IDUsuario

	if object_id('tempdb..#tempConceptos') is not null drop table #tempConceptos 
	if object_id('tempdb..#tempData') is not null drop table #tempData

	select
		e.IDEmpleado,
		e.ClaveEmpleado,
		e.NOMBRECOMPLETO as Nombre,
		e.IDRegPatronal,
		e.RegPatronal,
		e.IDDepartamento,
		e.Departamento,
		e.IDEmpresa,
		e.Empresa,
		e.IDCliente,
		e.Cliente,
		cp.ClavePeriodo,
		cp.Descripcion as Periodo,
		cc.IDConcepto,
		cc.Codigo as CodigoConcepto,
		cc.Descripcion as DescripcionConcepto,
		crr.Orden,
		crr.Impresion,
		isnull(dp.ImporteTotal1,0.00) as ImporteTotal1
		into #tempData
    from reportes.tblConfigReporteRayas crr with(nolock)
    INNER JOIN nomina.tblCatConceptos cc with(nolock) ON CRR.IDConcepto = cc.IDConcepto
		and CRR.Impresion = 1
    INNER JOIN nomina.tblCatPeriodos cp with(nolock) ON cp.IDPeriodo = @IDPeriodoInicial
    CROSS Apply @empleados e 
	left join nomina.tblDetallePeriodo dp with(nolock)
		on cc.IDConcepto = dp.IDConcepto
		and dp.IDEmpleado = e.IDEmpleado
		and dp.IDPeriodo = cp.IDPeriodo
    --where dp.IDPeriodo = @IDPeriodoInicial 
	order by e.ClaveEmpleado asc, cc.OrdenCalculo asc

	--delete #tempData
	--where --ImporteTotal1 = 0
	-- CodigoConcepto  in ('304','305')

	select * from #tempData

    
GO
