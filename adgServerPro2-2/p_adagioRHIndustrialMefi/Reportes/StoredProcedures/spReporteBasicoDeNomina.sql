USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteBasicoDeNomina](
	@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
) as
	--declare	
	--	@dtFiltros Nomina.dtFiltrosRH
	--	,@IDUsuario int
	--insert @dtFiltros
	--values ('IDTipoNomina',4)
	--	  ,('IDPeriodoInicial',75)
	--	  ,('IDPeriodoFinal',98)

	declare @empleados [RH].[dtEmpleados]      
		,@IDPeriodoSeleccionado int=0      
		,@periodo [Nomina].[dtPeriodos]      
		,@configs [Nomina].[dtConfiguracionNomina]      
		,@Conceptos [Nomina].[dtConceptos]      
		,@IDTipoNomina int   
		,@fechaIniPeriodo  date      
		,@fechaFinPeriodo  date     
		,@IDPeriodoInicial int
		,@IDPeriodoFinal int 
		,@IDCliente int
	;  

	set @IDTipoNomina = case when exists (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) 
								THEN (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))
						else 0 END

	Select @IDPeriodoInicial= cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),',')
	Select @IDPeriodoFinal	= cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoFinal'),',')
	Select @IDCliente		= cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Cliente'),',')

	select 
		@fechaIniPeriodo = FechaInicioPago
		, @IDTipoNomina = IDTipoNomina 
	from Nomina.tblCatPeriodos with (nolock) 
	where IDPeriodo = @IDPeriodoInicial
	
	select 
		@fechaFinPeriodo = FechaFinPago 
	from Nomina.tblCatPeriodos with (nolock) 
	where IDPeriodo = @IDPeriodoFinal

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
	where IDTipoNomina = @IDTipoNomina and FechaInicioPago >= @fechaIniPeriodo and FechaFinPago <= @fechaFinPeriodo

	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */      
    insert into @empleados      
    exec [RH].[spBuscarEmpleadosMaster] @IDTipoNomina = @IDTipoNomina,@FechaIni=@fechaIniPeriodo, @Fechafin = @fechaFinPeriodo ,@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario   

	if object_id('tempdb..#tempConceptos')	is not null drop table #tempConceptos 
	if object_id('tempdb..#tempData')		is not null drop table #tempData
	if object_id('tempdb..#tempSalida')		is not null drop table #tempSalida

	select distinct 
		c.IDConcepto,
		replace(replace(replace(replace(replace(Substring(c.Descripcion,0,21)+'_'+c.Codigo,' ',''),'-',''),'.',''),'(',''),')','') as Concepto,
		c.IDTipoConcepto as IDTipoConcepto,
		c.TipoConcepto,
		c.Orden as OrdenCalculo,
		case when c.IDTipoConcepto in (1,4) then 1
			 when c.IDTipoConcepto = 2 then 2
			 when c.IDTipoConcepto = 3 then 3
			 when c.IDTipoConcepto = 6 then 4
			 when c.IDTipoConcepto = 5 then 5
			 else 0
			 end as OrdenColumn
	into #tempConceptos
	from (select 
			ccc.*
			,tc.Descripcion as TipoConcepto
			,crr.Orden
		from Nomina.tblCatConceptos ccc with (nolock) 
			inner join Nomina.tblCatTipoConcepto tc with (nolock) on tc.IDTipoConcepto = ccc.IDTipoConcepto
			inner join Reportes.tblConfigReporteRayas crr with (nolock)  on crr.IDConcepto = ccc.IDConcepto and crr.Impresion = 1
		) c 

	Select
		e.ClaveEmpleado as CLAVE,
		e.NOMBRECOMPLETO as NOMBRE,
		e.Empresa as RAZON_SOCIAL,
		e.Sucursal as SUCURSAL,
		e.Departamento as DEPARTAMENTO,
		e.Puesto as PUESTO,
		e.Division as DIVISION,
		e.CentroCosto as CENTRO_COSTO,
		c.Concepto,
		SUM(isnull(dp.ImporteTotal1,0)) as ImporteTotal1
	into #tempData
	from @periodo P
		inner join Nomina.tblDetallePeriodo dp with(nolock)
			on p.IDPeriodo = dp.IDPeriodo
		inner join #tempConceptos c with(nolock)
			on c.IDConcepto = dp.IDConcepto
		inner join @empleados e
			on dp.IDEmpleado = e.IDEmpleado
	Group by e.ClaveEmpleado,e.NOMBRECOMPLETO,c.Concepto,
		e.Empresa,
		e.Sucursal ,
		e.Departamento,
		e.Puesto,
		e.Division,
		e.CentroCosto
	ORDER BY e.ClaveEmpleado ASC

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


	set @query1 = 'SELECT CLAVE,NOMBRE, SUCURSAL, DEPARTAMENTO, PUESTO, ' + @cols + ' from 
				(
					select CLAVE
						,Nombre
						, Concepto
						, SUCURSAL
						, DEPARTAMENTO
						, PUESTO
						, isnull(ImporteTotal1,0) as ImporteTotal1
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

	--select len(@query1) +len( @query2) 
	exec( @query1 + @query2) 

	--select *from #tempSalida
GO
