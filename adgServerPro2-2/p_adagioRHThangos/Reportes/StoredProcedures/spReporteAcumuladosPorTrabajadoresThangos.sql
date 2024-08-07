USE [p_adagioRHThangos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
        
CREATE proc [Reportes].[spReporteAcumuladosPorTrabajadoresThangos](       
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
			,@IDMesInicio int
			,@IDMesFin int
	;   
 ;        
	set @IDTipoNomina = case when exists (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) 
								THEN (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))
						else 0 END


	set @IDMesInicio = isnull((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDMes'),',')),0)
	set @IDMesFin = isnull((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDMesFin'),',')),0)

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
		and (IDMes between @IDMesInicio and @IDMesFin)   
		and Ejercicio in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ejercicio'),','))   
		))                      
		and ISNULL(Cerrado,0) = 1	
		--	select * from @periodo

		select  @fechaIniPeriodo = MIN(FechaInicioPago),  @fechaFinPeriodo = MAX(FechaFinPago) from @periodo  

		insert into @empleados      
		exec [RH].[spBuscarEmpleadosMaster] @IDTipoNomina = @IDTipoNomina,@FechaIni=@fechaIniPeriodo, @Fechafin = @fechaFinPeriodo ,@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario   
	
		if object_id('tempdb..#tempConceptos')	is not null drop table #tempConceptos 
		if object_id('tempdb..#tempData')		is not null drop table #tempData

	select distinct 
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
			 end as OrdenColumn
	into #tempConceptos
	from Reportes.tblConfigReporteRayas dp
			inner join Nomina.tblCatConceptos c with(nolock)
			on C.IDConcepto = dp.IDConcepto
			Inner join Nomina.tblCatTipoConcepto tc with(nolock)
			on tc.IDTipoConcepto = c.IDTipoConcepto
	where dp.Impresion = 1
	order by OrdenColumn,OrdenCalculo asc

	Select
		e.ClaveEmpleado as CLAVE,
		e.RFC as [RFC],
		e.IMSS as IMSS, 
		e.Cliente as [CLIENTE],
		e.NOMBRECOMPLETO as NOMBRE,
		tp.Descripcion as [TIPO_PRESTACION],
		format(e.FechaAntiguedad,'dd/MM/yyyy') as ANTIGUEDAD,
		CASE WHEN isnull(E.Vigente,0) = 'True' THEN 'SI' ELSE 'NO'
			 END AS [VIGENTE HOY],
		e.Sucursal as SUCURSAL,
		e.SalarioDiario as SALARIO_DIARIO,
		e.SalarioIntegrado AS SALARIO_INTEGRADO,
		replace(replace(replace(replace(replace(c.Descripcion+'_'+c.Codigo,' ','_'),'-',''),'.',''),'(',''),')','') as Concepto,
		SUM(isnull(dp.ImporteTotal1,0)) as ImporteTotal1
	into #tempData
	from @periodo P
		inner join Nomina.tblDetallePeriodo dp with(nolock)
			on p.IDPeriodo = dp.IDPeriodo
		inner join Nomina.tblCatConceptos c with(nolock)
			on C.IDConcepto = dp.IDConcepto
		Inner join Nomina.tblCatTipoConcepto tc with(nolock)
			on tc.IDTipoConcepto = c.IDTipoConcepto
		inner join @empleados e
			on dp.IDEmpleado = e.IDEmpleado
		left join RH.tblCatTiposPrestaciones tp with(nolock)
			on tp.IDTipoPrestacion = e.IDTipoPrestacion
	Group by    e.ClaveEmpleado,
			e.RFC,
			e.IMSS,
			e.NOMBRECOMPLETO,
			e.Cliente,
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
					CLIENTE,
					NOMBRE, 
					TIPO_PRESTACION as [TIPO PRESTACION],
					ANTIGUEDAD,
					[VIGENTE HOY],
					SUCURSAL,
					SALARIO_DIARIO as [SALARIO DIARIO],
					SALARIO_INTEGRADO as [SALARIO INTEGRADO],
					 ' + @cols + ' from 

				(select 
					CLAVE,
					RFC,
					IMSS,
					CLIENTE,
					NOMBRE, 
					TIPO_PRESTACION, 
					ANTIGUEDAD,
					[VIGENTE HOY],
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
