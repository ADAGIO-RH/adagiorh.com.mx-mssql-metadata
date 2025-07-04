USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reportes].[spReporteBasicoPagoDeNominaImpreso](
	@CatalogoConceptos		varchar(max)
	,@ClaveEmpleadoInicial	varchar(20) = '0'
	,@ClaveEmpleadoFinal	varchar(20) ='zzzzzzzzzzzzzzzzzzzzzzzzzzzzz'
	,@IDPeriodoInicial		int
	,@TipoNomina			int 
	,@Departamentos			varchar(max) = ''
	,@Sucursales			varchar(max) = ''
	,@Puestos				varchar(max) = ''
	,@RazonesSociales		varchar(max) = ''
	,@Divisiones			varchar(max) = ''
	,@IDUsuario				int
)as
	--declare 
	--	@dtFiltros Nomina.dtFiltrosRH
	--	,@IDUsuario int = 1

	--insert into @dtFiltros(Catalogo,Value)
	--values('IDPeriodoInicial','98')
	--	--,('CatalogoConceptos','219')

	declare 
		@empleados [RH].[dtEmpleados]      
		,@empleadosTemp [RH].[dtEmpleados]  
		,@dtFiltros Nomina.dtFiltrosRH  
		 
		,@Periodo varchar(max)
		,@ClavePeriodo varchar(max)
		--,@CatalogoConceptos nvarchar(max)   
		,@FechaIniPeriodo  date        
		,@FechaFinPeriodo  date  
		,@Cerrado bit = 1
	    ,@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	select @ClaveEmpleadoInicial = case when @ClaveEmpleadoInicial is null or @ClaveEmpleadoInicial = '' then '0' else @ClaveEmpleadoInicial end
		,@ClaveEmpleadoFinal = case when @ClaveEmpleadoFinal is null or @ClaveEmpleadoFinal = '' then 'zzzzzzzzzzzzzzzzzzzzzzzzzzzzz' else @ClaveEmpleadoFinal end

	insert into @dtFiltros(Catalogo,Value)
	values
		('Departamentos',@Departamentos)
		,('RazonesSociales',@RazonesSociales)
		,('Divisiones',@Divisiones)
		,('Sucursales',@Sucursales)
		,('Puestos',@Puestos)

	select 
		@FechaIniPeriodo = p.FechaInicioPago
		,@FechaFinPeriodo = p.FechaFinPago	
		,@ClavePeriodo = p.ClavePeriodo
		,@Periodo = p.Descripcion
		,@Cerrado = isnull(Cerrado,0)
	from Nomina.tblCatPeriodos p with (nolock)
	where p.IDPeriodo = @IDPeriodoInicial

		/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */                  
    insert into @empleadosTemp       
	select e.*
	from RH.tblEmpleadosMaster e with (nolock)
		join ( select distinct dp.IDEmpleado
				from Nomina.tblDetallePeriodo dp with (nolock)
				where dp.IDPeriodo = @IDPeriodoInicial
		) detallePeriodo on e.IDEmpleado = detallePeriodo.IDEmpleado

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
					where hep.IDPeriodo = @IDPeriodoInicial
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
		@IDTipoNomina	= @TipoNomina,
		@dtFiltros		= @dtFiltros,
		@IDUsuario		= @IDUsuario

	--insert into @empleados        
 --   exec [RH].[spBuscarEmpleadosMaster] 
	--	@IDTipoNomina	= @TipoNomina
	--	,@EmpleadoIni	= @ClaveEmpleadoInicial
	--	,@EmpleadoFin	= @ClaveEmpleadoFinal
	--	,@FechaIni		= @fechaIniPeriodo
	--	,@Fechafin		= @fechaFinPeriodo 
	--	,@dtFiltros		= @dtFiltros
	--	,@IDUsuario		= @IDUsuario     
    
	select         
		e.ClaveEmpleado as Clave,        
		e.NOMBRECOMPLETO as Nombre,        
		ISNULL(e.Departamento,'NO ASIGNADO') as Departamento,
		ISNULL(e.Puesto,'NO ASIGNADO') as Puesto,		
		ISNULL(lp.Descripcion,'Sin Tipo de pago') as TipoPago,
		ISNULL(pe.Cuenta,'') as CuentaDePago,
		ISNULL(pe.Interbancaria,'') as ClabeInterbancaria,
		ISNULL(pe.Tarjeta,'') as Tarjeta,
		ISNULL(Banco.Descripcion,'NO ASIGNADO') Banco,        
		ISNULL(c.Codigo,'000') as CodigoConcepto,        
		ISNULL(c.Descripcion,'NO ASIGNADO') as Concepto, 
		ISNULL(dpPagado.ImporteTotal1,0.00) as ImporteTotal1,        
		ISNULL(e.RazonSocial,'NO ASIGNADA') as RazonSocial,		
		ISNULL(e.Sucursal,'NO ASIGNADA') as Sucursal,		
		CASE WHEN ISNULL(LDE.IDControlLayoutDispersionEmpleado,0) = 0 THEN 'NO' ELSE 'SI'	END as Pagado      
		,'PERIODO '+@ClavePeriodo+' -'+@Periodo as Periodo
		,Titulo = 'REPORTE DE PAGO DE NÓMINA' 
	FROM Nomina.tblDetallePeriodo dpPagado with(nolock)     
		inner JOIN @empleados e     
			on dpPagado.IDPeriodo = @IDPeriodoInicial        
				and dpPagado.IDEmpleado = e.IDEmpleado        
		INNER join Nomina.tblCatPeriodos p with(nolock)        
			on p.IDPeriodo = @IDPeriodoInicial       
				and (dpPagado.ImporteTotal1 > 0 OR dpPagado.ImporteTotal2 >0)   
		inner JOIN Nomina.tblLayoutPago lp with(nolock)        
			on (lp.IDConcepto = dpPagado.IDConcepto or lp.IDConceptoFiniquito = dpPagado.IDConcepto)
		inner JOIN RH.tblPagoEmpleado pe with(nolock)        
			on pe.IDEmpleado = e.IDEmpleado and pe.IDLayoutPago = lp.IDLayoutPago
		left JOIN Nomina.tblCatConceptos c with(nolock)        
			on dpPagado.IDConcepto = c.IDConcepto    
		
		left join Nomina.tblControlLayoutDispersionEmpleado LDE with(nolock)
			on LDE.IDEmpleado = E.IDEmpleado
				and LDE.IDLayoutPago = lp.IDLayoutPago
				and LDE.IDPeriodo = @IDPeriodoInicial        
		LEFT JOIN Sat.tblCatBancos Banco with(nolock)        
			on Banco.IDBanco = pe.IDBanco        
		left join RH.tblCatTiposPrestaciones tp with(nolock)
			on tp.IDTipoPrestacion = e.IDTipoPrestacion    
		 --where  (dpPagado.IDConcepto in (Select IDConcepto from Nomina.tblCatConceptos where IDTipoConcepto = (Select IDTipoConcepto from Nomina.tblCatTipoConcepto where Descripcion = 'CONCEPTOS DE PAGO' ))) 
		 order by e.ClaveEmpleado
GO
