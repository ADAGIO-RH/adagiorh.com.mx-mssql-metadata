USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteBasicoPagoDeNomina](
	@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int  
) as
BEGIN        
       
	--declare	
	--	@dtFiltros Nomina.dtFiltrosRH  
	--	,@IDUsuario int = 1

	--;

	--insert @dtFiltros(Catalogo,[Value])
	--values('IDPeriodoInicial','126')

	declare         
		@empleados [RH].[dtEmpleados]        
		,@empleadosTemp [RH].[dtEmpleados]  
		,@ListaEmpleados Nvarchar(max) 
		,@periodo [Nomina].[dtPeriodos]  
		,@fechaIniPeriodo  date                  
		,@fechaFinPeriodo  date
		,@IDTipoNomina int                    
		,@IDPeriodo int
		,@ClaveEmpleadoInicial varchar(max)
		,@ClaveEmpleadoFinal   varchar(max)
		,@Cerrado bit = 1
		,@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	SET @ClaveEmpleadoInicial	= ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')    
	SET @ClaveEmpleadoFinal		= ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZ')     

	set @IDPeriodo = 
		case when exists (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),',')) THEN (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),','))  
		else 0  
		END 

	Insert into @periodo(IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,Cerrado,General,Finiquito,Especial)                  
	select IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,Cerrado,General,Finiquito,isnull(Especial,0)
	from Nomina.TblCatPeriodos with(nolock)                 
	where IDPeriodo = @IDPeriodo                  
                  
	select top 1 @IDTipoNomina = IDTipoNomina ,@fechaIniPeriodo = FechaInicioPago, @fechaFinPeriodo =FechaFinPago ,@Cerrado = isnull(Cerrado,0)
	from @periodo                  
	              
	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */                  
    insert into @empleadosTemp       
	select e.*
	from RH.tblEmpleadosMaster e
		join ( select distinct dp.IDEmpleado
				from Nomina.tblDetallePeriodo dp with (nolock)
				where dp.IDPeriodo = @IDPeriodo
		) detallePeriodo on e.IDEmpleado = detallePeriodo.IDEmpleado
	--insert into @empleados                  
	--exec [RH].[spBuscarEmpleadosMaster] 
	--	 @IDTipoNomina	= @IDTipoNomina
	--	,@EmpleadoIni	= @ClaveEmpleadoInicial
	--	,@EmpleadoFin	= @ClaveEmpleadoFinal
	--	,@FechaIni		= @fechaIniPeriodo
	--	,@Fechafin		= @fechaFinPeriodo
	--	,@dtFiltros		= @dtFiltros 
	--	,@IDUsuario		= @IDUsuario   

	if (@Cerrado = 1)
	begin
		update e
			set 
				e.IDCentroCosto		= isnull(cc.IDCentroCosto	,e.IDCentroCosto)
				,e.CentroCosto		= isnull(JSON_VALUE(cc.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))		,e.CentroCosto		)
				,e.IDDepartamento	= isnull(d.IDDepartamento	,e.IDDepartamento)
				,e.Departamento		= isnull(JSON_VALUE(d.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))	,e.Departamento	)
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
				,e.Area				= isnull(JSON_VALUE(a.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))	,e.Area			)
				,e.IDDivision		= isnull(div.IDDivision		,e.IDDivision	)
				,e.Division			= isnull(JSON_VALUE(div.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))	,e.Division		)
				,e.IDRegion			= isnull(r.IDRegion			,e.IDRegion		)
				,e.Region			= isnull(JSON_VALUE(r.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))	,e.Region		)
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
		@IDTipoNomina	= @IDTipoNomina,
		@dtFiltros		= @dtFiltros,
		@IDUsuario		= @IDUsuario
     
	select         
		e.ClaveEmpleado as Clave,        
		e.NOMBRECOMPLETO as Nombre,        
		
		ISNULL(Depto.Codigo,'NO ASIGNADO') as DEPTO,
		ISNULL(e.Departamento,'NO ASIGNADO') as [DEPARTAMENTO DESCRIPCION],
		
		ISNULL(Puesto.Codigo,'NO ASIGNADO') as PUESTO,		
		ISNULL(e.Puesto,'NO ASIGNADO') as [PUESTO DESCRIPCION],		
		
		ISNULL(Empresa.RFC,'NO ASIGNADA') as [RFC RAZON SOCIAL],	
		ISNULL(e.Empresa,'NO ASIGNADA') as [RAZON SOCIAL],	
		
		ISNULL(Suc.Codigo,'NO ASIGNADA') as SUCURSAL,	
		ISNULL(e.Sucursal,'NO ASIGNADA') as [SUCURSAL DESCRIPCION],	

		ISNULL(lp.Descripcion,'Sin Tipo de pago') as TipoPago,
		ISNULL(pe.Cuenta,'') as CuentaDePago,
		ISNULL(pe.Interbancaria,'') as ClabeInterbancaria,
		ISNULL(pe.Tarjeta,'') as Tarjeta,
		ISNULL(Banco.Descripcion,'NO ASIGNADO') Banco,        
		ISNULL(c.Codigo,'000') as CodigoConcepto,        
		ISNULL(c.Descripcion,'NO ASIGNADO') as Concepto, 
		ISNULL(dpPagado.ImporteTotal1,0.00) as ImporteTotal1,        
		CASE WHEN ISNULL(LDE.IDControlLayoutDispersionEmpleado,0) = 0 THEN 'NO' ELSE 'SI'	END as Pagado        
	FROM Nomina.tblDetallePeriodo dpPagado with(nolock)     
		inner JOIN @empleados e     
			on dpPagado.IDPeriodo = @IDPeriodo and dpPagado.IDEmpleado = e.IDEmpleado 
		left join RH.tblCatDepartamentos Depto
			on Depto.IDDepartamento = e.IDDepartamento
		left join RH.tblCatPuestos Puesto
			on Puesto.IDPuesto = e.IDPuesto
		left join RH.tblEmpresa Empresa
			on Empresa.IdEmpresa = E.IDEmpresa
		left join RH.tblCatSucursales Suc
			on Suc.IDSucursal = E.IDSucursal
		INNER join Nomina.tblCatPeriodos p with(nolock)        
			on p.IDPeriodo = @IDPeriodo and (dpPagado.ImporteTotal1 > 0 OR dpPagado.ImporteTotal2 >0)   
		inner JOIN Nomina.tblLayoutPago lp with(nolock)        
			on (lp.IDConcepto = dpPagado.IDConcepto or lp.IDConceptoFiniquito = dpPagado.IDConcepto)
		inner JOIN RH.tblPagoEmpleado pe with(nolock)        
			on pe.IDEmpleado = e.IDEmpleado and pe.IDLayoutPago = lp.IDLayoutPago
		left JOIN Nomina.tblCatConceptos c with(nolock)        
			on dpPagado.IDConcepto = c.IDConcepto    
		left join Nomina.tblControlLayoutDispersionEmpleado LDE with(nolock)
			on LDE.IDEmpleado = E.IDEmpleado
				and LDE.IDLayoutPago = lp.IDLayoutPago
				and LDE.IDPeriodo = @IDPeriodo        
		LEFT JOIN Sat.tblCatBancos Banco with(nolock)        
			on Banco.IDBanco = pe.IDBanco        
		left join RH.tblCatTiposPrestaciones tp with(nolock)
			on tp.IDTipoPrestacion = e.IDTipoPrestacion    
		 --where  (dpPagado.IDConcepto in (Select IDConcepto from Nomina.tblCatConceptos where IDTipoConcepto = (Select IDTipoConcepto from Nomina.tblCatTipoConcepto where Descripcion = 'CONCEPTOS DE PAGO' ))) 
		 order by e.ClaveEmpleado
END
GO
