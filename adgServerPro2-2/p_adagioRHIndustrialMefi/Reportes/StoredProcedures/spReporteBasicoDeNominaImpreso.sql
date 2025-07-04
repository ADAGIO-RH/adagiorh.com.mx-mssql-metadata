USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reportes].[spReporteBasicoDeNominaImpreso](
	 @Cliente  varchar(max) = null
	,@TipoNomina  varchar(max) = null
	,@IDPeriodoInicial int
	,@IDPeriodoFinal int
    ,@Departamentos				  varchar(max) = ''
	,@Sucursales				  varchar(max) = ''
	,@Puestos					  varchar(max) = ''
	,@Prestaciones				  varchar(max) = ''
	,@TiposContratacion			  varchar(max) = ''
	,@RazonesSociales			  varchar(max) = ''
	,@RegPatronales				  varchar(max) = ''
	,@Divisiones				  varchar(max) = ''
	,@ClasificacionesCorporativas varchar(max) = ''
	,@CentrosCostos				  varchar(max) = ''
	,@Regiones					  varchar(max) = ''
	,@IDUsuario int
) as
	SET FMTONLY OFF;
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
		,@fechaIniPeriodo  date      
		,@fechaFinPeriodo  date      
		,@IDTipoNomina int
		,@dtFiltros Nomina.dtFiltrosRH   
	;  


	insert into @dtFiltros(Catalogo,Value)
	values
		('Departamentos',@Departamentos)
		,('RazonesSociales',@RazonesSociales)
		,('RegistrosPatronales',@RegPatronales)
		,('Regiones',@Regiones)
		,('Divisiones',@Divisiones)
		,('ClasificacionesCorporativas',@ClasificacionesCorporativas)
		,('CentrosCostos',@CentrosCostos)
		,('Sucursales',@Sucursales)
		,('Puestos',@Puestos)
		,('Cliente',@Cliente)

	select @fechaIniPeriodo = FechaInicioPago, @IDTipoNomina = IDTipoNomina from Nomina.tblCatPeriodos where IDPeriodo = @IDPeriodoInicial
	select @fechaFinPeriodo = FechaFinPago from Nomina.tblCatPeriodos where IDPeriodo = @IDPeriodoFinal

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
	from Nomina.tblCatPeriodos
	where IDTipoNomina = @IDTipoNomina and FechaInicioPago >= @fechaIniPeriodo and FechaFinPago <= @fechaFinPeriodo

	 /* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */      
    insert into @empleados      
    exec [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina,@FechaIni=@fechaIniPeriodo, @Fechafin = @fechaFinPeriodo ,@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario   

	if object_id('tempdb..#tempConceptos') is not null drop table #tempConceptos 
	if object_id('tempdb..#tempData') is not null drop table #tempData

	select distinct 
		replace(replace(replace(c.Descripcion+'_'+c.Codigo,' ','_'),'-',''),'.','') as Concepto,
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
	from @periodo P
	inner join Nomina.tblDetallePeriodo dp
		on p.IDPeriodo = dp.IDPeriodo
	inner join Nomina.tblCatConceptos c
		on C.IDConcepto = dp.IDConcepto
	Inner join Nomina.tblCatTipoConcepto tc
		on tc.IDTipoConcepto = c.IDTipoConcepto
	inner join @empleados e
		on dp.IDEmpleado = e.IDEmpleado

	Select
		e.IDEmpleado,
		e.ClaveEmpleado as CLAVE,
		e.NOMBRECOMPLETO as NOMBRE,
		c.IDConcepto,
		replace(replace(replace(c.Descripcion+'_'+c.Codigo,' ','_'),'-',''),'.','') as Concepto,
		SUM(isnull(dp.ImporteTotal1,0)) as ImporteTotal1
	into #tempData
	from @periodo P
	inner join Nomina.tblDetallePeriodo dp
		on p.IDPeriodo = dp.IDPeriodo
	inner join Nomina.tblCatConceptos c
		on C.IDConcepto = dp.IDConcepto	
	inner join @empleados e
		on dp.IDEmpleado = e.IDEmpleado
	Group by e.IDEmpleado,e.ClaveEmpleado,e.NOMBRECOMPLETO,c.Descripcion,c.IDConcepto,c.Codigo

	select 
		t.CLAVE
		,t.NOMBRE
		,e.Puesto
		,e.Departamento
		,e.Sucursal
		,e.CentroCosto
		,e.Division
		,e.ClasificacionCorporativa
		,e.SalarioDiario
		,e.SalarioIntegrado
		,t.Concepto
		,t.ImporteTotal1
		,crr.Orden
	from #tempData t
	inner join Nomina.tblCatConceptos c
		on C.IDConcepto = t.IDConcepto
	Inner join Nomina.tblCatTipoConcepto tc
		on tc.IDTipoConcepto = c.IDTipoConcepto
	inner join @empleados e
		on t.IDEmpleado = e.IDEmpleado
	left join Reportes.tblConfigReporteRayas crr
		on c.IDConcepto = crr.IDConcepto
	where crr.Impresion = 1
	order by CLAVE, 
	crr.Orden asc
	--case when tc.IDTipoConcepto in (1,4) then 1
	--		 when tc.IDTipoConcepto = 2 then 2
	--		 when tc.IDTipoConcepto = 3 then 3
	--		 when tc.IDTipoConcepto = 6 then 4
	--		 when tc.IDTipoConcepto = 5 then 5
	--		 else 0
	--		 end

	--DECLARE @cols AS NVARCHAR(MAX),
	--	@query1  AS NVARCHAR(MAX),
	--	@query2  AS NVARCHAR(MAX),
	--	@colsAlone AS VARCHAR(MAX)
	--;

	--SET @cols = STUFF((SELECT ',' +' ISNULL('+ QUOTENAME(c.Concepto)+',0) AS '+ QUOTENAME(c.Concepto)
	--			FROM #tempConceptos c
	--			GROUP BY c.Concepto,c.OrdenColumn,c.OrdenCalculo
	--			ORDER BY c.OrdenColumn,c.OrdenCalculo
	--			FOR XML PATH(''), TYPE
	--			).value('.', 'VARCHAR(MAX)') 
	--		,1,1,'');

	--SET @colsAlone = STUFF((SELECT ','+ QUOTENAME(c.Concepto)
	--			FROM #tempConceptos c
	--			GROUP BY c.Concepto,c.OrdenColumn,c.OrdenCalculo
	--			ORDER BY c.OrdenColumn,c.OrdenCalculo
	--			FOR XML PATH(''), TYPE
	--			).value('.', 'VARCHAR(MAX)') 
	--		,1,1,'');


	--set @query1 = 'SELECT CLAVE,NOMBRE, ' + @cols + ' from 
	--			(
	--				select CLAVE
	--					,Nombre
	--					, Concepto
	--					, isnull(ImporteTotal1,0) as ImporteTotal1
	--				from #tempData
	--		   ) x'

	--set @query2 = '
	--			pivot 
	--			(
	--				 SUM(ImporteTotal1)
	--				for Concepto in (' + @colsAlone + ')
	--			) p '

	--exec( @query1 + @query2)
GO
