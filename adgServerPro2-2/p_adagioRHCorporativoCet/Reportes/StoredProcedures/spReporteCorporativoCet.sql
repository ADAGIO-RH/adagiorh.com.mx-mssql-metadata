USE [p_adagioRHCorporativoCet]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [Reportes].[spReporteCorporativoCet] (            
	 @dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario   int 
)            
as   

DECLARE
	@FechaIni date,
	@FechaFin date,
	@cols AS VARCHAR(MAX),
	@query1  AS VARCHAR(MAX),
	@query2  AS VARCHAR(MAX),
	@colsAlone AS VARCHAR(MAX)

	--Seleccion de periodos

	select @FechaIni = Value from @dtFiltros where Catalogo = 'FechaIni'
	select @FechaFin = Value from @dtFiltros where Catalogo = 'FechaFin'

	if OBJECT_ID('tempdb..#periodos') is not null
		drop table #periodos
	
	if object_id('tempdb..#tempConceptos')	is not null 
		drop table #tempConceptos 

	if object_id('tempdb..#tempData')		is not null 
		drop table #tempData

	select * from RH.tblEmpleados

	----Periodos que si van a ir dentro del Reporte
	--SELECT IDPeriodo INTO #periodos
	--		FROM Nomina.tblCatPeriodos WHERE FechaInicioPago BETWEEN @FechaIni AND @FechaFin
	--select distinct 
	--	c.IdConcepto,
	--	c.Descripcion,
	--	c.Codigo,
	--	replace(replace(replace(replace(replace(c.Descripcion+'_'+c.Codigo,' ','_'),'-',''),'.',''),'(',''),')','') as Concepto,
	--	tc.IDTipoConcepto as IDTipoConcepto,
	--	tc.Descripcion as TipoConcepto,
	--	c.OrdenCalculo as OrdenCalculo,
	--	case when  tc.IDTipoConcepto in (1,4) then 1
	--		 when  tc.IDTipoConcepto = 2 then 2
	--		 when  tc.IDTipoConcepto = 3 then 3
	--		 when  tc.IDTipoConcepto = 6 then 4
	--		 when  tc.IDTipoConcepto = 5 then 5
	--		 else 0
	--		 end as OrdenColumn,
	--	1 as Origen
	--into #tempConceptos
	--from Reportes.tblConfigReporteRayas dp
	--		inner join Nomina.tblCatConceptos c with(nolock)
	--		on C.IDConcepto = dp.IDConcepto
	--		Inner join Nomina.tblCatTipoConcepto tc with(nolock)
	--		on tc.IDTipoConcepto = c.IDTipoConcepto
	--where dp.Impresion = 1
	--and c.Codigo > '899'
	--order by OrdenColumn,OrdenCalculo asc



	--SELECT empleados.Cliente,empleados.Empresa,FORMAT (catPeriodos.FechaInicioPago ,'dd-MM-yyyy' ) as FechaInicioPago,
	--	replace(replace(replace(replace(replace(c.Descripcion+'_'+c.Codigo,' ','_'),'-',''),'.',''),'(',''),')','') as Concepto,
	--	SUM(isnull(detallePeriodo.ImporteTotal1,0)) as ImporteTotal1,
	--	c.IDConcepto
	--	INTO #tempData
	--		FROM Nomina.tblDetallePeriodo detallePeriodo
	--			INNER JOIN RH.tblEmpleadosMaster empleados on detallePeriodo.IDEmpleado = empleados.IDEmpleado
	--			INNER JOIN Nomina.tblCatPeriodos catPeriodos on detallePeriodo.IDPeriodo = catPeriodos.IDPeriodo
	--			inner join #tempConceptos c	on C.IDConcepto = detallePeriodo.IDConcepto and c.Origen = 1
	--	WHERE detallePeriodo.IDPeriodo in (select IDPeriodo from #periodos)  and Codigo > '899'
	--			GROUP BY empleados.Cliente,empleados.Empresa,catPeriodos.FechaInicioPago, c.Descripcion, c.Codigo, c.IDConcepto

				


	--delete from #tempConceptos where IDConcepto not in (select IDConcepto from #tempData)


			--SET @cols = STUFF((SELECT ',' +' ISNULL('+ QUOTENAME(c.Concepto)+',0) AS '+ QUOTENAME(c.Concepto)
			--	FROM #tempConceptos c
			--	GROUP BY c.Concepto,c.OrdenColumn,c.OrdenCalculo
			--	ORDER BY c.OrdenColumn,c.OrdenCalculo
			--	FOR XML PATH(''), TYPE
			--	).value('.', 'VARCHAR(MAX)') 
			--,1,1,'');

			--SET @colsAlone = STUFF((SELECT ','+ QUOTENAME(c.Concepto)
			--	FROM #tempConceptos c
			--	GROUP BY c.Concepto,c.OrdenColumn,c.OrdenCalculo
			--	ORDER BY c.OrdenColumn,c.OrdenCalculo
			--	FOR XML PATH(''), TYPE
			--	).value('.', 'VARCHAR(MAX)') 
			--,1,1,'');

			--set @query1 = '
			--		SELECT
			--		Cliente,
			--		Empresa,
			--		FechaInicioPago,' + @cols + ' from 

			--	(   
			--		SELECT
			--		Cliente,
			--		Empresa,
			--		FechaInicioPago,
			--		Concepto,
			--		isnull(ImporteTotal1,0) as ImporteTotal1
			--	from #tempData
					
			--   ) x'
			--set @query2 = '
			--	pivot 
			--	(
			--		SUM(ImporteTotal1)
			--		for Concepto in (' + @colsAlone + ')
			--	) p 
			--	order by Cliente'
			
			--exec( @query1 + @query2)
GO
