USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reportes].[spReporteAcumuladosPorTrabajadoresMes](        
	@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
) as
	declare @empleados [RH].[dtEmpleados]  
			,@empleadosTemp [RH].[dtEmpleados]  
			,@IDPeriodoSeleccionado int=0            
			,@periodo [Nomina].[dtPeriodos]            
			,@configs [Nomina].[dtConfiguracionNomina]            
			,@Conceptos [Nomina].[dtConceptos]            
			,@IDTipoNomina int                 
			,@IDCliente int
			,@fechaIniPeriodo date
			,@fechaFinPeriodo date			
			,@EmpleadoIn Varchar(20)  
			,@EmpleadoFi Varchar(20) 
	;   
 ;        
	set @IDTipoNomina = case when exists (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) 
								THEN (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))
						else 0 END
	SET @EmpleadoIn	= ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')    
	SET @EmpleadoFi	= ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZ')

	insert into @periodo
		select *
			from Nomina.tblCatPeriodos with (nolock)
			where      
			(((IDTipoNomina in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))  
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TipoNomina' and isnull(Value,'')<>''))  
			)
			--antes
			--and (IDMes in (Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDMes'),','))
			--despues
			and (         IDMes >= (Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDMes'),','))
                      and IDMes <= (Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDMesFin'),','))
			)   
			and Ejercicio in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ejercicio'),','))   
			))
			and isnull(Cerrado,0) = 1

			select  @fechaIniPeriodo = MIN(FechaInicioPago),  @fechaFinPeriodo = MAX(FechaFinPago) from @periodo  

		insert into @empleadosTemp      
		exec [RH].[spBuscarEmpleadosMaster] @IDTipoNomina = @IDTipoNomina,@FechaIni=@fechaIniPeriodo, @Fechafin = @fechaFinPeriodo
		--,@dtFiltros = @dtFiltros
		, @IDUsuario = @IDUsuario , @EmpleadoIni =@EmpleadoIn , @EmpleadoFin = @EmpleadoFi



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


		insert into @empleados
		exec [RH].[spFiltrarEmpleadosDesdeLista] @dtEmpleados=	@empleadosTemp, @dtFiltros= @dtFiltros, @IDTipoNomina =  @IDTipoNomina, @IDUsuario = @IDUsuario

		--select * from @empleados
	
		if object_id('tempdb..#tempConceptos')	is not null drop table #tempConceptos 
		if object_id('tempdb..#tempData')		is not null drop table #tempData

	select distinct 
		c.IdConcepto,
		c.Descripcion,
		c.Codigo,
		replace(replace(replace(replace(replace(c.Descripcion+'_'+c.Codigo,' ','_'),'-',''),'.',''),'(',''),')','') as Concepto,
		tc.IDTipoConcepto as IDTipoConcepto,
		tc.Descripcion as TipoConcepto,
		c.OrdenCalculo as OrdenCalculo,
		case when  tc.IDTipoConcepto in (1,4) then 1
			 when  tc.IDTipoConcepto = 2 then 2
			 when  tc.IDTipoConcepto = 3 then 3
			 when  tc.IDTipoConcepto = 6 then 4
			 when  tc.IDTipoConcepto = 5 then 5
			 else 0
			 end as OrdenColumn,
		1 as Origen
	into #tempConceptos
	from Reportes.tblConfigReporteRayas dp
			inner join Nomina.tblCatConceptos c with(nolock)
			on C.IDConcepto = dp.IDConcepto
			Inner join Nomina.tblCatTipoConcepto tc with(nolock)
			on tc.IDTipoConcepto = c.IDTipoConcepto
			where dp.Impresion = 1
				order by OrdenColumn,OrdenCalculo asc


-----GRAVADO abre

	insert into #tempConceptos
	select distinct 
		c.IdConcepto,
		c.Descripcion,
		c.Codigo,
		replace(replace(replace(replace(replace('GRAV'+'_'+c.Descripcion+'_'+c.Codigo,' ','_'),'-',''),'.',''),'(',''),')','') as Concepto,
		c.IDTipoConcepto as IDTipoConcepto,
		c.TipoConcepto as TipoConcepto,
		c.OrdenCalculo as OrdenCalculo,
		case when  c.IDTipoConcepto in (1,4) then 1
			 when  c.IDTipoConcepto = 2 then 2
			 when  c.IDTipoConcepto = 3 then 3
			 when  c.IDTipoConcepto = 6 then 4
			 when  c.IDTipoConcepto = 5 then 5
			 else 0
			 end as OrdenColumn,
		2 as Origen
	from (select 
			ccc.*
			,tc.Descripcion as TipoConcepto
			,crr.Orden
		from Nomina.tblCatConceptos ccc with (nolock) 
			inner join Nomina.tblCatTipoConcepto tc with (nolock) on tc.IDTipoConcepto = ccc.IDTipoConcepto
			inner join Reportes.tblConfigReporteRayas crr with (nolock)  on crr.IDConcepto = ccc.IDConcepto and crr.Impresion = 1
		where tc.IDTipoConcepto = 1 /*CCC.IDConcepto in (select distinct IDConcepto from Nomina.tblDetallePeriodo with (nolock) where IDPeriodo IN ( select idperiodo from  @periodo ) and isnull(ImporteExcento,0)>0  )
		and*/ 
		) c 

-----GRAVADO cierra



--------------------------------
	Select
		e.ClaveEmpleado as CLAVE,
		e.RFC as RFC,
		e.IMSS as IMSS, 
		e.NOMBRECOMPLETO as NOMBRE,
		E.CURP AS CURP,
		tp.Descripcion as TIPO_PRESTACION,
		dep.codigo as CODIGO_DEPARTAMENTO,
		e.Departamento as DEPARTAMENTO,
		E.PUESTO as PUESTO,
		FORMAT(e.FechaAntiguedad,'dd/MM/yyyy') as ANTIGUEDAD,
		CASE WHEN E.Vigente = 1 THEN 'Vigente' ELSE 'Baja'
			 END AS ESTATUS,
		e.Sucursal as SUCURSAL,
		e.SalarioDiario as SALARIO_DIARIO,
		e.SalarioIntegrado AS SALARIO_INTEGRADO,
		replace(replace(replace(replace(replace(c.Descripcion+'_'+c.Codigo,' ','_'),'-',''),'.',''),'(',''),')','') as Concepto,
		SUM(isnull(dp.ImporteTotal1,0)) as ImporteTotal1
	into #tempData
	from @periodo P
		inner join Nomina.tblDetallePeriodo dp with(nolock)
			on p.IDPeriodo = dp.IDPeriodo
		left join #tempConceptos c
			on C.IDConcepto = dp.IDConcepto
				and c.Origen = 1
		Inner join Nomina.tblCatTipoConcepto tc with(nolock)
			on tc.IDTipoConcepto = c.IDTipoConcepto
		inner join @empleados e
			on dp.IDEmpleado = e.IDEmpleado
		left join RH.tblCatTiposPrestaciones tp
			on tp.IDTipoPrestacion = e.IDTipoPrestacion
		inner join rh.tblempleadosMaster emaster on emaster.idempleado = e.idempleado
		inner join rh.tblCatdepartamentos dep on dep.iddepartamento = emaster.iddepartamento 
Group by    e.ClaveEmpleado,
			e.RFC,
			e.IMSS,
			e.NOMBRECOMPLETO,
			E.CURP,
			tp.Descripcion,
			e.TipoContrato,
			e.FechaAntiguedad,
			e.Vigente,
			e.Sucursal,
			e.SalarioDiario,
			e.SalarioIntegrado,
			c.Descripcion,
			c.Codigo,
			e.Empresa,
			e.Sucursal,
			e.Departamento,
			e.Puesto,
			dep.codigo
	ORDER BY e.ClaveEmpleado ASC
--------------------------------


--GRAV inicia--------------------------------
	
	insert into #tempData
	Select
		e.ClaveEmpleado as CLAVE,
		e.RFC as RFC,
		e.IMSS as IMSS, 
		e.NOMBRECOMPLETO as NOMBRE,
		e.CURP AS CURP,
		tp.Descripcion as TIPO_PRESTACION,
		dep.codigo as CODIGO_DEPARTAMENTO,
		e.Departamento as DEPARTAMENTO,
		e.Puesto as PUESTO,
		FORMAT(e.FechaAntiguedad,'dd/MM/yyyy') as ANTIGUEDAD,
		CASE WHEN E.Vigente = 1 THEN 'Vigente' ELSE 'Baja'
			 END AS ESTATUS,
		e.Sucursal as SUCURSAL,		
		e.SalarioDiario as SALARIO_DIARIO,
		e.SalarioIntegrado AS SALARIO_INTEGRADO,
		replace(replace(replace(replace(replace('GRAV'+'_'+c.Descripcion+'_'+c.Codigo,' ','_'),'-',''),'.',''),'(',''),')','') as Concepto,
		SUM(isnull(dp.ImporteGravado,0)) as ImporteTotal1
	from @periodo P
		inner join Nomina.tblDetallePeriodo dp with(nolock)
			on p.IDPeriodo = dp.IDPeriodo
		left join #tempConceptos c
			on C.IDConcepto = dp.IDConcepto
				and c.Origen = 2
		Inner join Nomina.tblCatTipoConcepto tc with(nolock)
			on tc.IDTipoConcepto = c.IDTipoConcepto
		inner join @empleados e
			on dp.IDEmpleado = e.IDEmpleado
		left join RH.tblCatTiposPrestaciones tp
			on tp.IDTipoPrestacion = e.IDTipoPrestacion		
		inner join rh.tblempleadosMaster emaster on emaster.idempleado = e.idempleado
		inner join rh.tblCatdepartamentos dep on dep.iddepartamento = emaster.iddepartamento 
Group by    e.ClaveEmpleado,
			e.RFC,
			e.IMSS,
			e.NOMBRECOMPLETO,
			e.CURP,
			tp.Descripcion,
			e.TipoContrato,
			e.FechaAntiguedad,
			e.Vigente,
			e.Sucursal,
			e.SalarioDiario,
			e.SalarioIntegrado,
			c.Descripcion,
			c.Codigo,
			e.Empresa,
			e.Sucursal,
			E.departamento,
			E.puesto,
			dep.codigo
	ORDER BY e.ClaveEmpleado ASC
--GRAV final--------------------------------



	DECLARE @cols AS VARCHAR(MAX),
		@query1  AS VARCHAR(MAX),
		@query2  AS VARCHAR(MAX),
		@colsAlone AS VARCHAR(MAX)
	;

	SET @cols = STUFF((SELECT ',' +' ISNULL('+ QUOTENAME(c.Concepto)+',0) AS '+ QUOTENAME(c.Concepto)
				FROM #tempConceptos c
				GROUP BY c.Concepto,c.OrdenColumn,c.OrdenCalculo
				ORDER BY c.OrdenColumn,c.OrdenCalculo
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');

	SET @colsAlone = STUFF((SELECT ','+ QUOTENAME(c.Concepto)
				FROM #tempConceptos c
				GROUP BY c.Concepto,c.OrdenColumn,c.OrdenCalculo
				ORDER BY c.OrdenColumn,c.OrdenCalculo
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');



	set @query1 = 'SELECT 
					CLAVE,
					RFC as [RFC ],
					IMSS,
					NOMBRE, 
					CURP,
					TIPO_PRESTACION,
					ANTIGUEDAD,
					ESTATUS,
					SUCURSAL,
					CODIGO_DEPARTAMENTO,
					DEPARTAMENTO,
					PUESTO,
					SALARIO_DIARIO,
					SALARIO_INTEGRADO,
					 ' + @cols + ' from 

				(select 
					CLAVE,
					RFC,
					IMSS,
					NOMBRE, 
					CURP,
					TIPO_PRESTACION, 
					ANTIGUEDAD,
					ESTATUS,
					SUCURSAL,
					CODIGO_DEPARTAMENTO,
					DEPARTAMENTO,
					PUESTO,
					SALARIO_DIARIO,
					SALARIO_INTEGRADO,
					Concepto,
					isnull(ImporteTotal1,0) as ImporteTotal1
				from #tempData
					
			   ) x'

	set @query2 = '
				pivot 
				(
					 SUM(ImporteTotal1)
					for Concepto in (' + @colsAlone + ')
				) p 
				order by CLAVE
				'
 
	exec( @query1 + @query2)
GO
