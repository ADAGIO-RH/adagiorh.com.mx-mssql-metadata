USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
        
CREATE proc [Reportes].[spReporteAcumuladosPorTrabajadoresPersonalizado](        
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
			,@IDIdioma varchar(20)
			,@IdiomaSQL varchar(100) = null
			,@Ejercicio int
			,@ID_RUBRO_BONOS	int
			,@ID_RUBRO_CONCEPTOS_DE_PAGO	int
			,@ID_RUBRO_CONCEPTOS_TOTALES	int
			,@ID_RUBRO_DEDUCCION	int
			,@ID_RUBRO_INFORMATIVO	int
			,@ID_RUBRO_PERCEPCION	int
			,@ID_RUBRO_PROVISIONES	int
			,@ID_RUBRO_RELATIVOS	int	
	;

	select top 1 @ID_RUBRO_BONOS = IDCatDatoExtraCliente from RH.tblCatDatosExtraClientes where Nombre = 'RUBRO_BONOS'
	select top 1 @ID_RUBRO_CONCEPTOS_DE_PAGO = IDCatDatoExtraCliente from RH.tblCatDatosExtraClientes where Nombre = 'RUBRO_CONCEPTOS_DE_PAGO'
	select top 1 @ID_RUBRO_CONCEPTOS_TOTALES = IDCatDatoExtraCliente from RH.tblCatDatosExtraClientes where Nombre = 'RUBRO_CONCEPTOS_TOTALES'
	select top 1 @ID_RUBRO_DEDUCCION = IDCatDatoExtraCliente from RH.tblCatDatosExtraClientes where Nombre = 'RUBRO_DEDUCCION'
	select top 1 @ID_RUBRO_INFORMATIVO = IDCatDatoExtraCliente from RH.tblCatDatosExtraClientes where Nombre = 'RUBRO_INFORMATIVO'
	select top 1 @ID_RUBRO_PERCEPCION = IDCatDatoExtraCliente from RH.tblCatDatosExtraClientes where Nombre = 'RUBRO_PERCEPCION'
	select top 1 @ID_RUBRO_PROVISIONES = IDCatDatoExtraCliente from RH.tblCatDatosExtraClientes where Nombre = 'RUBRO_PROVISIONES'
	select top 1 @ID_RUBRO_RELATIVOS = IDCatDatoExtraCliente from RH.tblCatDatosExtraClientes where Nombre = 'RUBRO_RELATIVOS'

	set @IDCliente = case when exists (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Cliente'),',')) 
								THEN (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Cliente'),','))
						else 0 END 

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	select @IdiomaSQL = [SQL]
		from app.tblIdiomas with (nolock)
		where IDIdioma = @IDIdioma

	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
	begin
		set @IdiomaSQL = 'Spanish' ;
	end
  
	SET LANGUAGE @IdiomaSQL

	set @IDTipoNomina = case when exists (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) 
								THEN (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))
						else 0 END

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
	Select top 1 @Ejercicio = Value from @dtFiltros where Catalogo = 'Ejercicio'

	insert into @empleados     
	exec [RH].[spBuscarEmpleadosEnIntervalos] @IDTipoNomina = @IDTipoNomina,@FechaIni=@fechaIniPeriodo, @Fechafin = @fechaFinPeriodo ,@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario   
	
	if object_id('tempdb..#tempConceptos')	is not null drop table #tempConceptos 
	if object_id('tempdb..#tempData')		is not null drop table #tempData
	if object_id('tempdb..#tempRubros')	is not null drop table #tempRubros

	Select *
		into #tempRubros
		from (
			Select 
				cast(item as varchar(20)) Codigo,'BONOS' Rubro 
				from App.Split((select top 1 Valor from RH.tblDatosExtraClientes where IDCliente = @IDCliente and IDDatoExtraCliente = @ID_RUBRO_BONOS) ,',')
			UNION
			Select 
				cast(item as varchar(20)) Codigo ,'CONCEPTOS DE PAGO' Rubro
				from App.Split((select top 1 Valor from RH.tblDatosExtraClientes where IDCliente = @IDCliente and IDDatoExtraCliente = @ID_RUBRO_CONCEPTOS_DE_PAGO) ,',')

			UNION

			Select 
				cast(item as varchar(20)) Codigo ,'CONCEPTOS TOTALES' Rubro
				from App.Split((select top 1 Valor from RH.tblDatosExtraClientes where IDCliente = @IDCliente and IDDatoExtraCliente = @ID_RUBRO_CONCEPTOS_TOTALES) ,',')

			UNION

			Select 
				cast(item as varchar(20)) Codigo ,'DEDUCCION' Rubro
				from App.Split((select top 1 Valor from RH.tblDatosExtraClientes where IDCliente = @IDCliente and IDDatoExtraCliente = @ID_RUBRO_DEDUCCION) ,',')

			UNION

			Select 
				cast(item as varchar(20)) Codigo,'INFORMATIVO' Rubro 
				from App.Split((select top 1 Valor from RH.tblDatosExtraClientes where IDCliente = @IDCliente and IDDatoExtraCliente = @ID_RUBRO_INFORMATIVO) ,',')

			UNION

			Select 
				cast(item as varchar(20)) Codigo ,'PERCEPCION' Rubro
				from App.Split((select top 1 Valor from RH.tblDatosExtraClientes where IDCliente = @IDCliente and IDDatoExtraCliente = @ID_RUBRO_PERCEPCION) ,',')

			UNION

			Select 
				cast(item as varchar(20)) Codigo ,'PROVISIONES' Rubro
				from App.Split((select top 1 Valor from RH.tblDatosExtraClientes where IDCliente = @IDCliente and IDDatoExtraCliente = @ID_RUBRO_PROVISIONES) ,',')

			UNION

			Select 
				cast(item as varchar(20)) Codigo ,'RELATIVOS' Rubro
				from App.Split((select top 1 Valor from RH.tblDatosExtraClientes where IDCliente = @IDCliente and IDDatoExtraCliente = @ID_RUBRO_RELATIVOS) ,',')
		) Rubros
		
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
		,Rubro.Rubro
	into #tempConceptos
	from Reportes.tblConfigReporteRayas dp
		inner join Nomina.tblCatConceptos c with(nolock)
			on C.IDConcepto = dp.IDConcepto
		Inner join Nomina.tblCatTipoConcepto tc with(nolock)
			on tc.IDTipoConcepto = c.IDTipoConcepto
		left join #tempRubros Rubro
			on Rubro.Codigo = c.Codigo
	where dp.Impresion = 1
	order by OrdenColumn,OrdenCalculo asc

	Select
		e.ClaveEmpleado as CLAVE,
		e.RFC as RFC,
		e.IMSS as IMSS, 
		e.NOMBRECOMPLETO as NOMBRE,
		E.CURP AS CURP,
		tp.Descripcion as TIPO_PRESTACION,
		e.Departamento as DEPARTAMENTO,
		e.PUESTO as PUESTO,
		FORMAT(e.FechaAntiguedad,'dd/MM/yyyy') as ANTIGUEDAD,
		CASE WHEN mas.Vigente = 1 THEN 'Vigente' ELSE 'Baja'
			 END AS ESTATUS,
		mas.Sucursal as SUCURSAL,
		e.SalarioDiario as SALARIO_DIARIO,
		e.SalarioIntegrado AS SALARIO_INTEGRADO,
		c.Codigo +' - ' +c.Descripcion as Concepto,
		c.Rubro,
		TC.Descripcion AS TipoConcepto
		,SUM(isnull(dp.ImporteTotal1,0)) as ImporteTotal1
		,DATENAME(Month, DATEFROMPARTS(@Ejercicio,P.IDmes,1)) as Mes
		,e.Empresa
		,e.CentroCosto
	into #tempData
	from @periodo P
		inner join Nomina.tblDetallePeriodo dp with(nolock)
			on p.IDPeriodo = dp.IDPeriodo
		inner join #tempConceptos c
			on C.IDConcepto = dp.IDConcepto
				and c.Origen = 1
		Inner join Nomina.tblCatTipoConcepto tc with(nolock)
			on tc.IDTipoConcepto = c.IDTipoConcepto
		inner join @empleados e
			on dp.IDEmpleado = e.IDEmpleado
        inner join rh.tblEmpleadosMaster mas 
            on mas.IDEmpleado = e.IDEmpleado
		left join RH.tblCatTiposPrestaciones tp
			on tp.IDTipoPrestacion = e.IDTipoPrestacion
        inner join Nomina.tblHistorialesEmpleadosPeriodos hep on hep.IDPeriodo = P.IDPeriodo and e.IDEmpleado = hep.IDEmpleado
        where 
			--( hep.IDArea = (Select top 1 cast(item as int) 
			( hep.IDArea in (Select  cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Areas'),','))  
                or  (Select top 1 cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Areas'),',')) IS NULL )
       -- AND ( hep.IDCentroCosto = (Select top 1 cast(item as int) 
		AND ( hep.IDCentroCosto in (Select cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'CentrosCostos'),','))  
                or  (Select top 1 cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'CentrosCostos'),',')) IS NULL )
        --AND ( hep.IDDepartamento = (Select top 1 cast(item as int) 
		AND ( hep.IDDepartamento in (Select cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Departamentos'),','))  
                or  (Select top 1 cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Departamentos'),',')) IS NULL )
        --AND ( hep.IDSucursal = (Select top 1 cast(item as int) 
		AND ( hep.IDSucursal in (Select cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),','))  
                or  (Select top 1 cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),',')) IS NULL )  
        --AND ( hep.IDPuesto = (Select top 1 cast(item as int) 
		AND ( hep.IDPuesto in (Select cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),','))  
                or  (Select top 1 cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),',')) IS NULL )   
        --AND ( hep.IDRegPatronal = (Select top 1 cast(item as int) 
		AND ( hep.IDRegPatronal in (Select cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),','))  
                or  (Select top 1 cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')) IS NULL )
        --AND ( hep.IDCliente = (Select top 1 cast(item as int) 
		AND ( hep.IDCliente in (Select cast(item as int)
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Cliente'),','))  
                or  (Select top 1 cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Cliente'),',')) IS NULL )
       -- AND ( hep.IDEmpresa = (Select top 1 cast(item as int)
		AND ( hep.IDEmpresa in (Select cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),','))  
                or  (Select top 1 cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),',')) IS NULL )  
       -- AND ( hep.IDDivision = (Select top 1 cast(item as int) 
		AND ( hep.IDDivision in (Select cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),','))  
                or  (Select top 1 cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')) IS NULL )  
        --AND ( hep.IDClasificacionCorporativa = (Select top 1 cast(item as int) 
		AND ( hep.IDClasificacionCorporativa in (Select cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClasificacionesCorporativas'),','))  
                or  (Select top 1 cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClasificacionesCorporativas'),',')) IS NULL ) 
        --AND ( hep.IDRegion = (Select top 1 cast(item as int) 
		AND ( hep.IDRegion in (Select cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Regiones'),','))  
                or  (Select top 1 cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Regiones'),',')) IS NULL )
Group by    e.ClaveEmpleado,
			e.RFC,
			e.IMSS,
			e.NOMBRECOMPLETO,
			E.CURP,
			tp.Descripcion,
			e.TipoContrato,
			e.FechaAntiguedad,
			mas.Vigente,
			e.SalarioDiario,
			e.SalarioIntegrado,
			c.Descripcion,
			c.Codigo,
			c.Rubro,
			mas.Sucursal,
			e.Departamento,
			e.Puesto,
			P.IDmes
			,e.Empresa
			,e.CentroCosto
			,tc.Descripcion
	ORDER BY e.ClaveEmpleado, c.Codigo ASC

	Select 
		@Ejercicio		as [AÑO ]
		,UPPER(Mes)		as [MES ]
		,Empresa		as [EMPRESA]
		,CentroCosto	as [CENTRO COSTO]
		,DEPARTAMENTO	as [DEPARTAMENTO]
		,CLAVE			AS [NO DE EMPLEADO]
		,NOMBRE			AS [NOMBRE]
		,PUESTO			AS [PUESTO]
		,Rubro			AS [RUBRO]
		,Concepto		AS [CONCEPTO]
		,ImporteTotal1	AS [IMPORTE]
		,ImporteTotal1/1000.0 AS [MILES]
		,''			AS [CUENTA]
		from #tempData
		order by CLAVE, Concepto
GO
