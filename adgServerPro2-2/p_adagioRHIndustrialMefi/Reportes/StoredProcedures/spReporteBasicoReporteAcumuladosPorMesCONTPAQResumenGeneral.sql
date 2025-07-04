USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteBasicoReporteAcumuladosPorMesCONTPAQResumenGeneral](    
	 @Cliente int,  
	 @TipoNomina int,   
	 @Ejercicio Varchar(max),  
	 @IDMesInicio int = 0,
	 @IDMesFin int = 0,
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
		,@dtDetallePeriodo [Nomina].[dtDetallePeriodo]
		,@fechaIniPeriodo  date        
		,@fechaFinPeriodo  date 
		,@IDTipoNomina   int    
		,@dtFiltros Nomina.dtFiltrosRH   
		,@Cerrado bit = 1
		,@IDIdioma varchar(20)
	;    

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

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
	from Nomina.tblCatPeriodos with (nolock)  
	where 
		IDMes between CASE WHEN isnull(@IDMesInicio,0) = 0 THEN 1 ELSE isnull(@IDMesInicio,0) END and CASE WHEN isnull(@IDMesFin,0) = 0 THEN 12 ELSE isnull(@IDMesFin,0) END
		and IDTipoNomina = @IDTipoNomina
		and Ejercicio = @Ejercicio
		and Cerrado = 1

	insert into @Conceptos
	select c.* from Nomina.tblCatConceptos c with(nolock)
	where
	 c.Codigo not like '0%'
	and c.Codigo not like '6%'
	and c.Codigo not in ('550','560')
	

	-- Guardamos en la variable @Cerrado el estatus del período para determinar si actualizamos o no los historiales de los colaboradres de la tabla Nomina.tblHistorialesEmpleadosPeriodos
	select top 1 @Cerrado = ISNULL(Cerrado,0) from @periodo

	select top 1 @fechaIniPeriodo = FechaInicioPago,  @fechaFinPeriodo = FechaFinPago from @periodo  
  
  
	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */        
    insert into @empleadosTemp       
	select e.*
	from RH.tblEmpleadosMaster e with (nolock)
		join ( select distinct dp.IDEmpleado
				from Nomina.tblDetallePeriodo dp
				where dp.IDPeriodo in(select IDPeriodo from @periodo)
		) detallePeriodo on e.IDEmpleado = detallePeriodo.IDEmpleado
    --exec [RH].[spBuscarEmpleadosMaster] @IDTipoNomina = @IDTipoNomina,@FechaIni=@fechaIniPeriodo, @Fechafin = @fechaFinPeriodo ,@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario     
    
	--delete @empleados
	--where IDEmpleado not in (Select IDEmpleado from Nomina.tblDetallePeriodo where IDPeriodo = @IDPeriodoInicial )  
	
	if (@Cerrado = 1)
	begin
		update e
			set 
				e.IDCentroCosto		= isnull(cc.IDCentroCosto	,e.IDCentroCosto)
				,e.CentroCosto		= isnull(JSON_VALUE(cc.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))		,e.CentroCosto)
				,e.IDDepartamento	= isnull(d.IDDepartamento	,e.IDDepartamento)
				,e.Departamento		= isnull(JSON_VALUE(d.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))		,e.Departamento	)
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
				,e.Area				= isnull(JSON_VALUE(a.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))	,e.Area	)
				,e.IDDivision		= isnull(div.IDDivision		,e.IDDivision	)
				,e.Division			= isnull(JSON_VALUE(div.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))	,e.Division		)
				,e.IDRegion			= isnull(r.IDRegion			,e.IDRegion		)
				,e.Region			=  isnull(JSON_VALUE(r.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))	,e.Region		)
				,e.IDRazonSocial	= isnull(rs.IDRazonSocial	,e.IDRazonSocial)
				,e.RazonSocial		= isnull(rs.RazonSocial		,e.RazonSocial	)

				,e.IDClasificacionCorporativa	= isnull(clasificacionC.IDClasificacionCorporativa,e.IDClasificacionCorporativa)
				--,e.ClasificacionCorporativa		= isnull(clasificacionC.Descripcion, e.ClasificacionCorporativa)
				,e.ClasificacionCorporativa		= isnull(JSON_VALUE(clasificacionC.Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE(@IDIdioma, '-', '')), 'Descripcion')), e.ClasificacionCorporativa)

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

	


	Insert into @dtDetallePeriodo
	SELECT 
		IDDetallePeriodo
		,IDEmpleado
		,IDPeriodo
		,IDConcepto
		,CantidadMonto
		,CantidadDias
		,CantidadVeces
		,CantidadOtro1
		,CantidadOtro2
		,ImporteGravado
		,ImporteExcento
		,ImporteOtro
		,ImporteTotal1
		,ImporteTotal2
		,Descripcion
		,IDReferencia
	FROM Nomina.tblDetallePeriodo 
	where IDPeriodo in (SELECT IDPeriodo FROM @periodo)


	Select
		  C.Codigo as CodigoConcepto
		, C.Descripcion as Concepto
		, C.OrdenCalculo
		, Percepcion = CASE WHEN C.IDTipoConcepto = 1 THEN SUM(isnull(dp.ImporteTotal1,0)) ELSE 0 END
		, PercepcionGravada = CASE WHEN C.IDTipoConcepto = 1 THEN SUM(isnull(dp.ImporteGravado,0)) ELSE 0 END
		, Percepcionexento = CASE WHEN C.IDTipoConcepto = 1 THEN SUM(isnull(dp.ImporteExcento,0)) ELSE 0 END
		, OtrosTiposPago = CASE WHEN C.IDTipoConcepto = 4 THEN SUM(isnull(dp.ImporteTotal1,0)) ELSE 0 END
		, Deducciones = CASE WHEN C.IDTipoConcepto = 2 THEN SUM(isnull(dp.ImporteTotal1,0)) ELSE 0 END
		, Obligaciones = CASE WHEN C.IDTipoConcepto = 3 THEN SUM(isnull(dp.ImporteTotal1,0)) ELSE 0 END
	from @empleados E
		inner join RH.tblCatDepartamentos depto with(nolock)
			on e.IDDepartamento = depto.IDDepartamento
		inner join Nomina.tblDetallePeriodo dp WITH(NOLOCK)
			on dp.IDEmpleado = E.IDEmpleado
		INNER JOIN @periodo p
			on p.IDPeriodo = dp.IDPeriodo
		INNER JOIN Nomina.tblCatMeses M
			on P.IDMes = M.IDMes
		inner join @Conceptos c
			on c.IDConcepto = dp.IDConcepto
		inner join Nomina.tblCatTipoConcepto tc with(nolock)
		on c.IDTipoConcepto = tc.IDTipoConcepto
	where isnull(dp.ImporteTotal1,0) > 0

	GROUP BY 
		  C.Codigo
		, C.Descripcion
		, C.OrdenCalculo
		,C.IDTipoConcepto
	ORDER BY C.OrdenCalculo
GO
