USE [p_adagioRHArcos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
        
CREATE proc [Reportes].[spReporteAcumuladosPorTrabajadoresTipoPercepciones](        
	@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
) as
	declare @empleados [RH].[dtEmpleados]      
			,@IDPeriodoSeleccionado int=0            
			,@periodo [Nomina].[dtPeriodos]            
			,@configs [Nomina].[dtConfiguracionNomina]            
			,@Conceptos [Nomina].[dtConceptos]            
			,@IDTipoNomina int                 
			,@IDCliente int
			,@fechaIniPeriodo date
			,@fechaFinPeriodo date
	;   
 ;        
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
			select  @fechaIniPeriodo = MIN(FechaInicioPago),  @fechaFinPeriodo = MAX(FechaFinPago) from @periodo  

		insert into @empleados      
		exec [RH].[spBuscarEmpleadosMaster] @IDTipoNomina = @IDTipoNomina,@FechaIni=@fechaIniPeriodo, @Fechafin = @fechaFinPeriodo ,@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario   
	
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
			where c.Impresion = 1
			 and tc.IDTipoConcepto in (1,4) -- solo percepciones
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

-----exento cierra



--------------------------------
	Select
		e.ClaveEmpleado as CLAVE,
		e.RFC as RFC,
		e.IMSS as IMSS, 
		e.NOMBRECOMPLETO as NOMBRE,
		tp.Descripcion as TIPO_PRESTACION,
		FORMAT(e.FechaAntiguedad,'dd/MM/yyyy') as ANTIGUEDAD,
		CASE WHEN E.Vigente = 'True' THEN 'Vigente' ELSE 'Baja'
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
		inner join #tempConceptos c
			on C.IDConcepto = dp.IDConcepto
				and c.Origen = 1
		Inner join Nomina.tblCatTipoConcepto tc with(nolock)
			on tc.IDTipoConcepto = c.IDTipoConcepto
		inner join @empleados e
			on dp.IDEmpleado = e.IDEmpleado
		left join RH.tblCatTiposPrestaciones tp
			on tp.IDTipoPrestacion = e.IDTipoPrestacion
Group by    e.ClaveEmpleado,
			e.RFC,
			e.IMSS,
			e.NOMBRECOMPLETO,
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
			e.Sucursal
	ORDER BY e.ClaveEmpleado ASC
--------------------------------


--ex inicia--------------------------------
	
	insert into #tempData
	Select
		e.ClaveEmpleado as CLAVE,
		e.RFC as RFC,
		e.IMSS as IMSS, 
		e.NOMBRECOMPLETO as NOMBRE,
		tp.Descripcion as TIPO_PRESTACION,
		FORMAT(e.FechaAntiguedad,'dd/MM/yyyy') as ANTIGUEDAD,
		CASE WHEN E.Vigente = 'True' THEN 'Vigente' ELSE 'Baja'
			 END AS ESTATUS,
		e.Sucursal as SUCURSAL,
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
		left join RH.tblCatTiposPrestaciones tp
			on tp.IDTipoPrestacion = e.IDTipoPrestacion
Group by    e.ClaveEmpleado,
			e.RFC,
			e.IMSS,
			e.NOMBRECOMPLETO,
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
			e.Sucursal
	ORDER BY e.ClaveEmpleado ASC
--ex final--------------------------------



	DECLARE @cols AS NVARCHAR(MAX),
		@query1  AS NVARCHAR(MAX),
		@query2  AS NVARCHAR(MAX),
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
					RFC AS [RFC ],
					IMSS,
					NOMBRE, 
					TIPO_PRESTACION,
					ANTIGUEDAD,
					ESTATUS,
					SUCURSAL,
					SALARIO_DIARIO,
					SALARIO_INTEGRADO,
					 ' + @cols + ' from 

				(select 
					CLAVE,
					RFC,
					IMSS,
					NOMBRE, 
					TIPO_PRESTACION, 
					ANTIGUEDAD,
					ESTATUS,
					SUCURSAL,
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
