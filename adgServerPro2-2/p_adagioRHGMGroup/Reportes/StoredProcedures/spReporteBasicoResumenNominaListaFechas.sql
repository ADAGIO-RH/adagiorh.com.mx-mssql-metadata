USE [p_adagioRHGMGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteBasicoResumenNominaListaFechas](    
	 @Cliente int,  
	 @IDClientes varchar(max) = '', 
	 @FechaIni date,
	 @FechaFin date,
	 @IDUsuario int
) as    
	SET FMTONLY OFF 
	declare 
		@empleados [RH].[dtEmpleados]        
		,@empleadosTemp [RH].[dtEmpleados]        
		,@IDPeriodoSeleccionado int=0        
		,@periodos [Nomina].[dtPeriodos]        
		,@configs [Nomina].[dtConfiguracionNomina]        
		,@Conceptos [Nomina].[dtConceptos]        
		,@fechaIniPeriodo  date        
		,@fechaFinPeriodo  date 
		,@IDTipoNomina   int    
		,@dtFiltros Nomina.dtFiltrosRH   
		,@Cerrado bit = 1
	;    
  
	if(isnull(@FechaIni,'')<>'')      
	BEGIN      
		insert into @dtFiltros(Catalogo,Value)      
		values('FechaIni',case when @FechaIni is null then '1900-01-01' else @FechaIni end)      
	END; 

	if(isnull(@FechaFin,'')<>'')      
	BEGIN      
		insert into @dtFiltros(Catalogo,Value)      
		values('FechaFin',case when @FechaIni is null then '2999-01-01' else @FechaIni end)      
	END; 
	
	if(isnull(@IDClientes,'')<>'')      
	BEGIN      
		insert into @dtFiltros(Catalogo,Value)      
		values('Clientes',case when @IDClientes is null then '' else @IDClientes end)      
	END; 
	if(isnull(@Cliente,'')<>'')      
	BEGIN      
		insert into @dtFiltros(Catalogo,Value)      
		values('Clientes',case when @Cliente is null then '' else @Cliente end)      
	END; 
  
    
	/* Se buscan el periodo seleccionado */    
	insert into @periodos  
	select   
		P.IDPeriodo  
		,P.IDTipoNomina  
		,Ejercicio  
		,ClavePeriodo  
		,P.Descripcion  
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
	from Nomina.tblCatPeriodos p with (nolock)
	inner join Nomina.tblcattiponomina tn
		on tn.IDTipoNomina = p.IDTipoNomina
	inner join rh.tblCatclientes c
		on tn.Idcliente = c.Idcliente
	where C.Idcliente = @IDClientes and p.FechaFinPago BETWEEN @FechaIni and @FechaFin     	

	-- Guardamos en la variable @Cerrado el estatus del período para determinar si actualizamos o no los historiales de los colaboradres de la tabla Nomina.tblHistorialesEmpleadosPeriodos
	--select top 1 @Cerrado = ISNULL(Cerrado,0) from @periodo

	--select top 1 @fechaIniPeriodo = FechaInicioPago,  @fechaFinPeriodo = FechaFinPago from @periodo  
  
	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */        
    insert into @empleadosTemp       
	select e.*
	from RH.tblEmpleadosMaster e with (nolock)
		join ( select distinct dp.IDEmpleado
				from Nomina.tblDetallePeriodo dp
				where dp.IDPeriodo in (select IDPeriodo from @periodos)
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
						join @periodos p on hep.IDPeriodo = p.IDPeriodo
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

	Select E.*,
		P.*,
		CASE WHEN EXISTS(Select 1 from Nomina.tblDetallePeriodo with (nolock) where IDPeriodo = p.IDPeriodo and IDEmpleado = E.IDEmpleado and isnull(ImporteTotal1,0)>0 and IDConcepto in (select IDConcepto from Nomina.tblCatConceptos with (nolock) where Codigo in ('601','604'))) THEN 1 ELSE 0 END as EmpleadosTransferencia,
		CASE WHEN EXISTS(Select 1 from Nomina.tblDetallePeriodo with (nolock) where IDPeriodo = p.IDPeriodo and IDEmpleado = E.IDEmpleado and isnull(ImporteTotal1,0)>0 and IDConcepto in (select IDConcepto from Nomina.tblCatConceptos with (nolock) where Codigo in ('602','605'))) THEN 1 ELSE 0 END as EmpleadosCheque,
		CASE WHEN EXISTS(Select 1 from Nomina.tblDetallePeriodo with (nolock) where IDPeriodo = p.IDPeriodo and IDEmpleado = E.IDEmpleado and isnull(ImporteTotal1,0)>0 and IDConcepto in (select IDConcepto from Nomina.tblCatConceptos with (nolock) where Codigo in ('603','606'))) THEN 1 ELSE 0 END as EmpleadosEfectivo,
		CASE WHEN EXISTS(Select 1 from Nomina.tblDetallePeriodo with (nolock) where IDPeriodo = p.IDPeriodo and IDEmpleado = E.IDEmpleado and isnull(ImporteTotal1,0)>0 and IDConcepto in (select IDConcepto from Nomina.tblCatConceptos with (nolock) where Codigo in ('607'))) THEN 1 ELSE 0 END as EmpleadosOtro,
		CASE WHEN isnull((Select SUM(ImporteTotal1)  from Nomina.tblDetallePeriodo with (nolock) where IDPeriodo = p.IDPeriodo and IDEmpleado = E.IDEmpleado  and IDConcepto  in (select IDConcepto from Nomina.tblCatConceptos with (nolock) where IDTipoConcepto = 5)),0) <= 0 THEN 1 ELSE 0 END as EmpleadosCero
	from @empleados E
		,@periodos p
	Where E.IDEmpleado in (Select distinct IDEmpleado from Nomina.tblDetallePeriodo with (nolock) where IDPeriodo in (select IDPeriodo from @periodos))
GO
