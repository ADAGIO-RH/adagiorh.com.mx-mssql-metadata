USE [p_adagioRHGMGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteTotalesGeneralesSucursal](
	@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
) as
--select * from Nomina.tblCatPeriodos
	--declare	
	--	@dtFiltros Nomina.dtFiltrosRH
	--	,@IDUsuario int
	--insert @dtFiltros
	--values ('TipoNomina',4)
	--	  ,('IDPeriodoInicial',29)

	declare 
		@empleados [RH].[dtEmpleados]      
		,@empleadosTemp [RH].[dtEmpleados]        
		,@IDPeriodoSeleccionado int=0      
		,@periodo [Nomina].[dtPeriodos]      
		,@configs [Nomina].[dtConfiguracionNomina]      
		,@Conceptos [Nomina].[dtConceptos]      
		,@IDTipoNomina int   
		,@IDPais int   
		,@fechaIniPeriodo  date      
		,@fechaFinPeriodo  date     
		,@IDPeriodoInicial int
		,@IDCliente int
		,@Cerrado bit = 1
		,@IDIdioma varchar(20)
		,@dtFiltrosFinal Nomina.dtFiltrosRH

	;  

			insert into @dtFiltrosFinal
	select * from  @dtFiltros where Catalogo <> 'TipoNomina'

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	set @IDTipoNomina = case when exists (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) 
								THEN (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))
						else 0 END
	

	Select @IDPeriodoInicial= cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),',')
	Select @IDCliente	= cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Cliente'),',')
	
	select @IDPais = isnull(IDPais,0) from Nomina.tblCatTipoNomina where IDTipoNomina = @IDTipoNomina

	

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
	where IDTipoNomina = @IDTipoNomina and IDPeriodo = @IDPeriodoInicial


	select 
		@fechaIniPeriodo = FechaInicioPago
		,@fechaFinPeriodo = FechaFinPago 
		,@IDTipoNomina = IDTipoNomina 
		,@Cerrado = Cerrado 
	from @periodo
	where IDPeriodo = @IDPeriodoInicial

	

	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */   
	--insert into @empleados
	--Exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina,@FechaIni = @fechaIniPeriodo, @FechaFin = @fechaFinPeriodo, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario

	----return

	--delete from @empleados where idempleado not in (select distinct idempleado from Nomina.tblDetallePeriodo where idperiodo = @IDPeriodoInicial)

	

	--update e set e.IDSucursal = sucursal.IDSucursal, e.Sucursal = NSucursal.Descripcion
	--from @empleados e
	--inner join rh.tblSucursalEmpleado sucursal
	--	on sucursal.idempleado = e.idempleado
	--inner join rh.tblCatSucursales NSucursal
	--	on NSucursal.IDSucursal = sucursal.IDSucursal
	--where sucursal.Fechaini <= @fechaFinPeriodo and sucursal.FechaFin >= @fechaFinPeriodo
	
		/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */      
	insert into @empleadosTemp       
	select e.*
	from RH.tblEmpleadosMaster e with (nolock)
		join ( select distinct dp.IDEmpleado
				from Nomina.tblDetallePeriodo dp with (nolock)
				where dp.IDPeriodo = @IDPeriodoInicial
		) detallePeriodo on e.IDEmpleado = detallePeriodo.IDEmpleado
order by IDEmpleado

if (@Cerrado = 1)
	begin
		update e
			set 
				e.IDCentroCosto		= isnull(cc.IDCentroCosto	,e.IDCentroCosto)
				,e.CentroCosto		= isnull(JSON_VALUE(cc.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))		,e.CentroCosto		)
				,e.IDDepartamento	= isnull(d.IDDepartamento	,e.IDDepartamento)
				,e.Departamento		= isnull(JSON_VALUE(d.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))		,e.Departamento	)
				,e.IDSucursal		= isnull(s.IDSucursal		,e.IDSucursal	)
				,e.Sucursal			= isnull(s.Descripcion		,e.Sucursal		)
				,e.IDPuesto			= isnull(p.IDPuesto			,e.IDPuesto		)
				,e.Puesto			= isnull(JSON_VALUE(p.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))		,e.Puesto		)
				,e.IDRegPatronal	= isnull(rp.IDRegPatronal	,e.IDRegPatronal)
				,e.RegPatronal		= isnull(rp.RazonSocial		,e.RegPatronal	)
				,e.IDCliente		= isnull(c.IDCliente		,e.IDCliente	)
				,e.Cliente			= isnull(JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial'))	,e.Cliente		)
				,e.IDEmpresa		= isnull(emp.IdEmpresa		,e.IdEmpresa	)
				,e.Empresa			= isnull(substring(emp.NombreComercial,1,50),substring(e.Empresa,1,50))
				,e.IDArea			= isnull(a.IDArea			,e.IDArea		)
				,e.Area				= isnull(JSON_VALUE(a.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))		,e.Area	)
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
		--@IDTipoNomina	= @IDTipoNomina,
		@dtFiltros		= @dtFiltrosFinal,
		@IDUsuario		= @IDUsuario

	if object_id('tempdb..#tempConceptos') is not null drop table #tempConceptos 
	if object_id('tempdb..#tempData') is not null drop table #tempData

		-- CONCEPTOS
	select distinct 
		c.IDConcepto,
		c.Descripcion as Concepto,--replace(replace(replace(replace(replace(c.Descripcion+'_'+c.Codigo,' ','_'),'-',''),'.',''),'(',''),')','') as Concepto,
		c.IDTipoConcepto as IDTipoConcepto,
		c.TipoConcepto,
		c.Orden as OrdenCalculo,
		case when c.IDTipoConcepto in (1,4) then 1
			 when c.IDTipoConcepto = 2 then 2
			 when c.IDTipoConcepto = 3 then 3
			 when c.IDTipoConcepto = 6 then 4
			 when c.IDTipoConcepto = 5 then 5
			 else 0
			 end as OrdenColumn,
		c.codigo
	into #tempConceptos
	from (select 
			ccc.*
			,tc.Descripcion as TipoConcepto
			,crr.Orden
		from Nomina.tblCatConceptos ccc with (nolock) 
			inner join Nomina.tblCatTipoConcepto tc with (nolock) on tc.IDTipoConcepto = ccc.IDTipoConcepto
			inner join Reportes.tblConfigReporteRayas crr with (nolock)  on crr.IDConcepto = ccc.IDConcepto and crr.Impresion = 1
		where ccc.IDPais = isnull(@IDPais,0) OR ISNULL(@IDPais,0) = 0
		) c 
	where c.Codigo in ('550','560','899','903','904','902')

	Select
		e.ClaveEmpleado		as CLAVE
		,e.NOMBRECOMPLETO	as NOMBRE
		,e.Empresa			as RAZON_SOCIAL
		,e.Sucursal			as SUCURSAL
		,e.Departamento		as DEPARTAMENTO
		,e.Puesto			as PUESTO
		,e.Division			as DIVISION
		,e.CentroCosto		as CENTRO_COSTO
		,c.Concepto
		,c.OrdenCalculo
		,SUM(isnull(dp.ImporteTotal1,0)) as ImporteTotal1
	into #tempData
	from @periodo P
		inner join Nomina.tblDetallePeriodo dp with (nolock) 
			on p.IDPeriodo = dp.IDPeriodo
		inner join #tempConceptos c
			on C.IDConcepto = dp.IDConcepto
		inner join @empleados e
			on dp.IDEmpleado = e.IDEmpleado
	Group by 
		e.ClaveEmpleado
		,e.NOMBRECOMPLETO
		,c.Concepto
		,c.OrdenCalculo
		,e.Empresa
		,e.Sucursal 
		,e.Departamento
		,e.Puesto
		,e.Division
		,e.CentroCosto
	ORDER BY e.ClaveEmpleado ASC

	--select * from #tempData return

	-- EMPLEADOS TOTALES POR RAZÓN SOCIAL
	if object_id('tempdb..#tempCantEmpleados') is not null drop table #tempCantEmpleados
	select e.Sucursal as SUCURSAL, count(distinct e.ClaveEmpleado) as EMPLEADOS --CANTIDAD DE EMPLEADOS 
	into #tempCantEmpleados
	from @empleados e
	group by  e.Sucursal

	if object_id('tempdb..#tempCantPagos') is not null drop table #tempCantPagos
	if object_id('tempdb..#tempEmpleadosPago') is not null drop table #tempEmpleadosPago

	

	Select distinct
		e.Sucursal as SUCURSAL
		,COUNT (cTrans.Codigo) as TRANS
		,COUNT (cCheque.Codigo) as CHEQUE
		,COUNT (cOtro.Codigo) as OTRO
	into #tempCantPagos
	from @empleados e
		inner join Nomina.tblDetallePeriodo dp with (nolock) 
			on dp.IDEmpleado = e.IDEmpleado
		left join Nomina.tblCatConceptos cTrans
			on cTrans.IDConcepto = dp.IDConcepto and cTrans.Codigo = '601' -- TRANSFERENCIAS
		left join Nomina.tblCatConceptos cCheque
			on cCheque.IDConcepto = dp.IDConcepto and cCheque.Codigo = '602' -- CHEQUE
		left join Nomina.tblCatConceptos cOtro
			on cOtro.IDConcepto = dp.IDConcepto and cOtro.Codigo = '607' --OTRO
	where dp.IDPeriodo = @IDPeriodoInicial and dp.ImporteTotal1 <> 0
	group by e.Sucursal

	select e.ClaveEmpleado,e.Sucursal as SUCURSAL, dp.IDEmpleado 
	into #tempEmpleadosPago
	from Nomina.tblDetallePeriodo dp
		inner join @empleados e on e.IDEmpleado = dp.IDEmpleado
	where IDPeriodo =@IDPeriodoInicial and dp.IDConcepto in (52,51,57) and dp.ImporteTotal1 <> 0
	order by e.ClaveEmpleado

	if object_id('tempdb..#tempCantEfectivo') is not null drop table #tempCantEfectivo
	Select distinct
		e.Sucursal as SUCURSAL
		,isnull(COUNT(cEfectivo.Codigo),0) as EFECTIVO
	into #tempCantEfectivo
	from @periodo P
		inner join Nomina.tblDetallePeriodo dp with (nolock) 
			on p.IDPeriodo = dp.IDPeriodo
		left join Nomina.tblCatConceptos cEfectivo
			on cEfectivo.IDConcepto = dp.IDConcepto and cEfectivo.Codigo = '903' --OTRO
		inner join @empleados e
			on dp.IDEmpleado = e.IDEmpleado
	WHERE dp.IDEmpleado not IN (SELECT IDEmpleado from #tempEmpleadosPago )
	group by e.Sucursal

	if object_id('tempdb..#tempSinPago') is not null drop table #tempSinPago
	if object_id('tempdb..#tempSinPago2') is not null drop table #tempSinPago2
	if object_id('tempdb..#tempdetalleSinPago') is not null drop table #tempdetalleSinPago

	select * 
	into #tempdetalleSinPago
	from Nomina.tblDetallePeriodo dp
	where dp.IDPeriodo = @IDPeriodoInicial and dp.IDConcepto in (select IDConcepto from Nomina.tblCatConceptos where (IDTipoConcepto = 5) or Codigo = '903' )
	--and dp.idempleado = 3601

	--return

	Select distinct
		e.Sucursal as SUCURSAL
		,e.claveempleado
		,e.IDEmpleado
		,CASE WHEN SUM(isnull(dp.ImporteTotal1,0)) < 1 then 1 else 0 END as SinPago
	into #tempSinPago
	from @empleados e
		left join #tempdetalleSinPago dp
			on dp.IDEmpleado = e.IDEmpleado
	group by e.Sucursal, e.ClaveEmpleado, e.IDEmpleado

	--select * from #tempSinPago return

	Select 
		SUCURSAL as SUCURSAL
		,ISNULL( SUM(SinPago),0)  as SinPago
	into #tempSinPago2
	from #tempSinPago
	Group by SUCURSAL

	--select * from #tempData return

	if object_id('tempdb..#temptotales') is not null drop table #temptotales

	select * 
	INTO #temptotales 
	from
	(
		select SUCURSAL,concepto, importetotal1 from #tempData
	) S
	pivot
	(
		sum(Importetotal1)
		for Concepto in ([TOTAL PERCEPCIONES],[TOTAL DEDUCCIONES],[(NF) DEDUCCIONES],[TOTAL PAGADO EFECTIVO],[TOTAL A PAGAR], [VALES DE DESPENSA])
	) P

	
	(
		select ce.SUCURSAL
				,ISNULL(ce.EMPLEADOS,0) AS [EMPLEADOS]
				,ISNULL(cp.TRANS,0) AS [TRANSFERENCIA]
				,ISNULL(cp.CHEQUE,0) AS [CHEQUE]
				--,ISNULL(CP.OTRO,0) AS[EMPLEADO OTRO]
				,ISNULL(cefect.EFECTIVO,0) AS [NF   ]
				,ISNULL(sp.SinPago,0) as [SIN PAGO] 
				,floor(ISNULL(tt.[TOTAL PERCEPCIONES],0)) AS [PERCEPCIONES]
				,floor(ISNULL(tt.[TOTAL DEDUCCIONES],0)) AS [DEDUCCIONES]
				,(isnull(tt.[TOTAL PERCEPCIONES],0)-isnull(tt.[TOTAL DEDUCCIONES],0)) AS [TRANSFERENCIA ]
				,floor(ISNULL(tt.[VALES DE DESPENSA],0)) AS [VALES DE DESPENSA]
				--,floor(ISNULL(tt.[(NF) DEDUCCIONES],0)) AS [NF DEDUCCIONES]
				,floor(ISNULL(tt.[TOTAL PAGADO EFECTIVO],0)) AS [NF    ]
				,floor(ISNULL(tt.[TOTAL A PAGAR],0)) AS [TOTAL]
			from #tempCantEmpleados ce
				LEFT join #tempCantPagos cp on cp.SUCURSAL = ce.SUCURSAL
				LEFT join #tempCantEfectivo cefect on cefect.SUCURSAL = ce.SUCURSAL
				LEFT join #tempSinPago2 sp on sp.SUCURSAL = ce.SUCURSAL
				LEFT join #temptotales tt on tt.SUCURSAL = ce.SUCURSAL
	) 
	UNION ALL
	(
		select 'Totales' AS RAZON_SOCIAL
				,ISNULL(SUM(ce.EMPLEADOS),0) AS [EMPLEADOS]
				,ISNULL(SUM(cp.TRANS),0) AS [TRANSFERENCIA]
				,ISNULL(SUM(cp.CHEQUE),0) AS [CHEQUE]
				--,ISNULL(SUM(CP.OTRO),0) AS[EMPLEADO OTRO]
				,ISNULL(SUM(cefect.EFECTIVO),0) AS [NF]
				,ISNULL(SUM(sp.SinPago),0) as [EMPLEADOS SIN PAGO] 
				,floor(ISNULL(SUM(tt.[TOTAL PERCEPCIONES]),0)) AS [PERCEPCIONES]
				,floor(ISNULL(SUM(tt.[TOTAL DEDUCCIONES]),0)) AS [DEDUCCIONES]
				,(sum(tt.[TOTAL PERCEPCIONES])-SUM(tt.[TOTAL DEDUCCIONES])) as [TRANSFERENCIA]
				,floor(ISNULL(SUM(tt.[VALES DE DESPENSA]),0)) AS [VALES DE DESPENSA]
				--,floor(ISNULL(SUM(tt.[(NF) DEDUCCIONES]),0)) AS [NF DEDUCCIONES]
				,floor(ISNULL(SUM(tt.[TOTAL PAGADO EFECTIVO]),0)) AS [NF]
				,floor(ISNULL(SUM(tt.[TOTAL A PAGAR]),0)) AS [TOTAL]
			from #tempCantEmpleados ce
				LEFT join #tempCantPagos cp on cp.SUCURSAL = ce.SUCURSAL
				LEFT join #tempCantEfectivo cefect on cefect.SUCURSAL = ce.SUCURSAL
				LEFT join #tempSinPago2 sp on sp.SUCURSAL = ce.SUCURSAL
				LEFT join #temptotales tt on tt.SUCURSAL = ce.SUCURSAL	
	)


	

GO
