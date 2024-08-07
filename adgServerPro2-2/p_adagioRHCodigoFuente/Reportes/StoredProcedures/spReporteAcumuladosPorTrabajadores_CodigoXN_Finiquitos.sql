USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
        
CREATE proc [Reportes].[spReporteAcumuladosPorTrabajadores_CodigoXN_Finiquitos](        
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
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
       
	set @IDTipoNomina = case when exists (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) 
								THEN (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))
						else 0 END

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
			and Finiquito=1

			select  @fechaIniPeriodo = MIN(FechaInicioPago),  @fechaFinPeriodo = MAX(FechaFinPago) from @periodo  

		insert into @empleados     
		exec [RH].[spBuscarEmpleadosEnIntervalos] @IDTipoNomina = @IDTipoNomina,@FechaIni=@fechaIniPeriodo, @Fechafin = @fechaFinPeriodo ,@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario   

		
	
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


-----exento abre

	insert into #tempConceptos
	select distinct 
		c.IdConcepto,
		c.Descripcion,
		c.Codigo,
		replace(replace(replace(replace(replace('EX'+'_'+c.Descripcion+'_'+c.Codigo,' ','_'),'-',''),'.',''),'(',''),')','') as Concepto,
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
		where CCC.IDConcepto in (select distinct IDConcepto from Nomina.tblDetallePeriodo with (nolock) where IDPeriodo IN ( select idperiodo from  @periodo ) and isnull(ImporteExcento,0)>0  )
		and tc.IDTipoConcepto = 1
		) c 

	if object_id('tempdb..#tempBaja')		is not null drop table #tempBaja


	select IDEmpleado,FechaAlta, FechaBaja,            
     case when ((FechaBaja is not null and FechaReingreso is not null) and FechaReingreso > FechaBaja) then FechaReingreso else null end as FechaReingreso 
      ,IDMovAfiliatorio
	  into #tempBaja
    from (
	
	
	select distinct tm.IDEmpleado,            
    case when(tm.IDEmpleado is not null) then (select top 1 Fecha             
                from [IMSS].[tblMovAfiliatorios]  mAlta WITH(NOLOCK)            
					join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mAlta.IDTipoMovimiento=c.IDTipoMovimiento            
                where mAlta.IDEmpleado=tm.IDEmpleado and c.Codigo='A'              
                Order By mAlta.Fecha Desc , c.Prioridad DESC ) end as FechaAlta,            
    case when (tm.IDEmpleado is not null) then (select top 1 Fecha             
                from [IMSS].[tblMovAfiliatorios]  mBaja WITH(NOLOCK)            
					join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mBaja.IDTipoMovimiento=c.IDTipoMovimiento            
                where mBaja.IDEmpleado=tm.IDEmpleado and c.Codigo='B' and mBaja.Fecha <= @fechaFinPeriodo            
    order by mBaja.Fecha desc, C.Prioridad desc) end as FechaBaja,            
    case when (tm.IDEmpleado is not null) then (select top 1 Fecha             
                from [IMSS].[tblMovAfiliatorios]  mReingreso WITH(NOLOCK)            
            join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mReingreso.IDTipoMovimiento=c.IDTipoMovimiento            
                where mReingreso.IDEmpleado=tm.IDEmpleado and c.Codigo='R'              
            and mReingreso.Fecha <= @fechaFinPeriodo            
            order by mReingreso.Fecha desc, C.Prioridad desc) end as FechaReingreso              
    ,(Select top 1 mSalario.IDMovAfiliatorio from [IMSS].[tblMovAfiliatorios]  mSalario WITH(NOLOCK)            
            join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mSalario.IDTipoMovimiento=c.IDTipoMovimiento            
                where mSalario.IDEmpleado=tm.IDEmpleado and c.Codigo in ('A','M','R')             
                order by mSalario.Fecha desc ) as IDMovAfiliatorio                                       
    from [IMSS].[tblMovAfiliatorios]  tm 
		inner join @empleados e on tm.IDEmpleado = e.IDEmpleado

	
	
	) mm  
	


-----exento cierra



--------------------------------
	Select
		e.ClaveEmpleado as CLAVE,
		e.RFC as RFC,
		e.IMSS as IMSS, 
		e.NOMBRECOMPLETO as NOMBRE,
		E.CURP AS CURP,
		tp.Descripcion as TIPO_PRESTACION,
		mas.Departamento as DEPARTAMENTO,
		mas.PUESTO as PUESTO,
		FORMAT(e.FechaAntiguedad,'dd/MM/yyyy') as ANTIGUEDAD,
		FORMAT(bb.fechabaja,'dd/MM/yyyy') as baja,
		CASE WHEN mas.Vigente = 1 THEN 'Vigente' ELSE 'Baja'
			 END AS ESTATUS,
		P.Descripcion AS PERIODO,
		mas.Sucursal as SUCURSAL,
		e.SalarioDiario as SALARIO_DIARIO,
		e.SalarioIntegrado AS SALARIO_INTEGRADO,
		replace(replace(replace(replace(replace(c.Descripcion+'_'+c.Codigo,' ','_'),'-',''),'.',''),'(',''),')','') as Concepto,
		SUM(isnull(dp.ImporteTotal1,0)) as ImporteTotal1
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
        inner join rh.tblEmpleadosMaster mas with(nolock)
            on mas.IDEmpleado = e.IDEmpleado
		left join RH.tblCatTiposPrestaciones tp with(nolock)
			on tp.IDTipoPrestacion = e.IDTipoPrestacion
        inner join Nomina.tblHistorialesEmpleadosPeriodos hep  with(nolock)
			on hep.IDPeriodo = P.IDPeriodo and e.IDEmpleado = hep.IDEmpleado
		inner join #tempBaja bb 
			on bb.idempleado=mas.idempleado
        where ( hep.IDArea = (Select top 1 cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Areas'),','))  
                or  (Select top 1 cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Areas'),',')) IS NULL )
        AND ( hep.IDCentroCosto = (Select top 1 cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'CentrosCostos'),','))  
                or  (Select top 1 cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'CentrosCostos'),',')) IS NULL )
        AND ( hep.IDDepartamento = (Select top 1 cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Departamentos'),','))  
                or  (Select top 1 cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Departamentos'),',')) IS NULL )
        AND ( hep.IDSucursal = (Select top 1 cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),','))  
                or  (Select top 1 cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),',')) IS NULL )  
        AND ( hep.IDPuesto = (Select top 1 cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),','))  
                or  (Select top 1 cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),',')) IS NULL )   
        AND ( hep.IDRegPatronal = (Select top 1 cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),','))  
                or  (Select top 1 cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')) IS NULL )
        AND ( hep.IDCliente = (Select top 1 cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Cliente'),','))  
                or  (Select top 1 cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Cliente'),',')) IS NULL )
        AND ( hep.IDEmpresa = (Select top 1 cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),','))  
                or  (Select top 1 cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),',')) IS NULL )  
        AND ( hep.IDDivision = (Select top 1 cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),','))  
                or  (Select top 1 cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')) IS NULL )  
        AND ( hep.IDClasificacionCorporativa = (Select top 1 cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClasificacionesCorporativas'),','))  
                or  (Select top 1 cast(item as int) 
                                from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClasificacionesCorporativas'),',')) IS NULL ) 
        AND ( hep.IDRegion = (Select top 1 cast(item as int) 
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
			mas.Sucursal,
			mas.Departamento,
			mas.Puesto,
			p.descripcion,
			bb.fechabaja
	ORDER BY e.ClaveEmpleado ASC
--------------------------------


--ex inicia--------------------------------
	
	insert into #tempData
	Select
		e.ClaveEmpleado as CLAVE,
		e.RFC as RFC,
		e.IMSS as IMSS, 
		e.NOMBRECOMPLETO as NOMBRE,
		e.CURP AS CURP,
		tp.Descripcion as TIPO_PRESTACION,
		mas.Departamento as DEPARTAMENTO,
		mas.Puesto as PUESTO,
		FORMAT(e.FechaAntiguedad,'dd/MM/yyyy') as ANTIGUEDAD,
		FORMAT(bb.fechabaja,'dd/MM/yyyy') as baja,
		CASE WHEN mas.Vigente = 1 THEN 'Vigente' ELSE 'Baja'
			 END AS ESTATUS,
		p.Descripcion as PERIODO,
		mas.Sucursal as SUCURSAL,
		
		e.SalarioDiario as SALARIO_DIARIO,
		e.SalarioIntegrado AS SALARIO_INTEGRADO,
		replace(replace(replace(replace(replace('EX'+'_'+c.Descripcion+'_'+c.Codigo,' ','_'),'-',''),'.',''),'(',''),')','') as Concepto,
		SUM(isnull(dp.ImporteExcento,0)) as ImporteTotal1
	from @periodo P
		inner join Nomina.tblDetallePeriodo dp with(nolock)
			on p.IDPeriodo = dp.IDPeriodo
		inner join #tempConceptos c
			on C.IDConcepto = dp.IDConcepto
				and c.Origen = 2
		Inner join Nomina.tblCatTipoConcepto tc with(nolock)
			on tc.IDTipoConcepto = c.IDTipoConcepto
		inner join @empleados e
			on dp.IDEmpleado = e.IDEmpleado
        inner join rh.tblEmpleadosMaster mas 
            on mas.IDEmpleado = e.IDEmpleado
		left join RH.tblCatTiposPrestaciones tp
			on tp.IDTipoPrestacion = e.IDTipoPrestacion
        inner join Nomina.tblHistorialesEmpleadosPeriodos hep on hep.IDPeriodo = P.IDPeriodo and e.IDEmpleado = hep.IDEmpleado
		inner join #tempBaja bb 
			on bb.idempleado=mas.idempleado
    where ( hep.IDArea = (Select top 1 cast(item as int) 
                            from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Areas'),','))  
            or  (Select top 1 cast(item as int) 
                            from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Areas'),',')) IS NULL )
    AND ( hep.IDCentroCosto = (Select top 1 cast(item as int) 
                            from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'CentrosCostos'),','))  
            or  (Select top 1 cast(item as int) 
                            from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'CentrosCostos'),',')) IS NULL )
    AND ( hep.IDDepartamento = (Select top 1 cast(item as int) 
                            from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Departamentos'),','))  
            or  (Select top 1 cast(item as int) 
                            from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Departamentos'),',')) IS NULL )
    AND ( hep.IDSucursal = (Select top 1 cast(item as int) 
                            from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),','))  
            or  (Select top 1 cast(item as int) 
                            from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),',')) IS NULL )  
    AND ( hep.IDPuesto = (Select top 1 cast(item as int) 
                            from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),','))  
            or  (Select top 1 cast(item as int) 
                            from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),',')) IS NULL )   
    AND ( hep.IDRegPatronal = (Select top 1 cast(item as int) 
                            from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),','))  
            or  (Select top 1 cast(item as int) 
                            from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')) IS NULL )
    AND ( hep.IDCliente = (Select top 1 cast(item as int) 
                            from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Cliente'),','))  
            or  (Select top 1 cast(item as int) 
                            from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Cliente'),',')) IS NULL )
    AND ( hep.IDEmpresa = (Select top 1 cast(item as int) 
                            from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),','))  
            or  (Select top 1 cast(item as int) 
                            from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),',')) IS NULL )  
    AND ( hep.IDDivision = (Select top 1 cast(item as int) 
                            from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),','))  
            or  (Select top 1 cast(item as int) 
                            from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')) IS NULL )  
    AND ( hep.IDClasificacionCorporativa = (Select top 1 cast(item as int) 
                            from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClasificacionesCorporativas'),','))  
            or  (Select top 1 cast(item as int) 
                            from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClasificacionesCorporativas'),',')) IS NULL ) 
    AND ( hep.IDRegion = (Select top 1 cast(item as int) 
                            from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Regiones'),','))  
            or  (Select top 1 cast(item as int) 
                            from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Regiones'),',')) IS NULL )
Group by    e.ClaveEmpleado,
			e.RFC,
			e.IMSS,
			e.NOMBRECOMPLETO,
			e.CURP,
			tp.Descripcion,
			e.TipoContrato,
			e.FechaAntiguedad,
			mas.Vigente,
			mas.Sucursal,
			e.SalarioDiario,
			e.SalarioIntegrado,
			c.Descripcion,
			c.Codigo,
			mas.departamento,
			mas.puesto,
			p.Descripcion,
			bb.fechabaja
	ORDER BY e.ClaveEmpleado ASC
--ex final--------------------------------



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
					baja as [ULTIMA BAJA],
					ESTATUS,
					PERIODO,
					SUCURSAL,
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
					baja,
					ESTATUS,
					PERIODO,
					SUCURSAL,
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
