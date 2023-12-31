USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteDetalleMensualNomina](        
	@dtFiltros Nomina.dtFiltrosRH readonly        
	,@IDUsuario int        
) as        
    
	--declare    
	--  @dtFiltros Nomina.dtFiltrosRH     
	--  ,@IDUsuario int = 1    
    
    
	--  insert @dtFiltros    
	--  Values    
	--  --('Departamentos','5')    
	--  --,    
	--  ('IDTipoNomina','4')    
	--  ,('IDPeriodoInicial','76')    
        
	declare 
		 @empleados RH.dtEmpleados           
		,@periodo [Nomina].[dtPeriodos]            
		,@configs [Nomina].[dtConfiguracionNomina]            
		,@Conceptos [Nomina].[dtConceptos]  
		,@EmpleadoIni Varchar(20)  
		,@EmpleadoFin Varchar(20) 
		,@IDRazonSocial VARCHAR (20)
		,@Ejercicio int
		,@dtFechas app.dtFechas
		,@FechaInicial date
		,@FechaFinal date
	;        

	--set @IDmesIni = (Select top 1 Value from @dtFiltros where Catalogo = 'IDMes')
	--set @IDmesFin = (Select top 1 Value from @dtFiltros where Catalogo = 'IDMesFin')
	select @IDRazonSocial = CASE WHEN ISNULL(Value,'') = '' THEN '1,2,3,4,5,6,7,8,9,10' ELSE  Value END
		from @dtFiltros where Catalogo = 'RazonesSociales'
	set @Ejercicio = (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ejercicio'),',')) 
	SET @EmpleadoIni	= ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')    
	SET @EmpleadoFin	= ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZ')  

		
	set @FechaInicial = Cast(Cast(@Ejercicio as Varchar(4)) +'-01-01' as date)
	set	@FechaFinal	=	Cast(Cast(@Ejercicio as Varchar(4)) +'-12-31' as date)

	if object_id('tempdb..#Empleados') is not null drop table #Empleados
	create Table #Empleados (  
		IDEmpleado int null,  
		Fecha Date null,  
		Vigente bit null  
	) 
	IF object_ID('TEMPDB..#TempEmitidos') IS NOT NULL DROP TABLE #TempEmitidos
	IF object_ID('TEMPDB..#TempNominaGeneral') IS NOT NULL DROP TABLE #TempNominaGeneral
	IF object_ID('TEMPDB..#TempTotalTrabajadores') IS NOT NULL DROP TABLE #TempTotalTrabajadores

	--insert into @dtFechas  
	--exec [App].[spListaFechas] @FechaIni = @FechaInicial, @FechaFin = @FechaFinal  

	insert @empleados
	exec RH.spBuscarEmpleados @EmpleadoIni=@EmpleadoIni,@EmpleadoFin=@EmpleadoFin,@FechaIni = @FechaInicial, @FechaFin = @FechaFinal, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario

	insert into @periodo
	select * from Nomina.tblCatPeriodos where Ejercicio = @Ejercicio

	insert into @Conceptos
	select c.* from Nomina.tblCatConceptos c
		inner join Reportes.tblConfigReporteRayas ry
			on c.idconcepto = ry.idconcepto
	where c.Estatus = 1 and c.Impresion = 1


	select 'Comprobantes Emitidos' as Titulo, periodos.IDMes, Estatustimbrado.Descripcion as Emitidos, Historial.IDEmpleado as IDEmpleado
	into #TempEmitidos
	FROM 
	Facturacion.tblTimbrado timbrado with (nolock)
		inner join Nomina.tblHistorialesEmpleadosPeriodos Historial with (nolock)       
				on Historial.IDHistorialEmpleadoPeriodo = Timbrado.IDHistorialEmpleadoPeriodo 
		left JOIN Facturacion.tblCatEstatusTimbrado Estatustimbrado  with (nolock)       
			on Timbrado.IDEstatusTimbrado = Estatustimbrado.IDEstatusTimbrado  
		inner join @periodo periodos 
			on periodos.IDPeriodo = Historial.IDPeriodo
	where periodos.Ejercicio = @Ejercicio 
		and Estatustimbrado.Descripcion = 'TIMBRADO' 
		and Historial.IDEmpleado in (select IDEmpleado from @empleados)



	select dp.idperiodo, periodo.IDMes, c.IDConcepto, c.Codigo, c.Descripcion, dp.ImporteTotal1, dp.ImporteExcento, dp.ImporteGravado, dp.IDEmpleado, c.IDTipoConcepto, c.idCalculo, c.OrdenCalculo
	into #TempNominaGeneral
	from Facturacion.tblTimbrado timbrado with (nolock)
		inner join Nomina.tblHistorialesEmpleadosPeriodos Historial  with (nolock)	
				on Historial.IDHistorialEmpleadoPeriodo = Timbrado.IDHistorialEmpleadoPeriodo 
		inner join Nomina.tblDetallePeriodo dp with (nolock) on
			dp.IDPeriodo = Historial.IDPeriodo and Historial.IDEmpleado = dp.IDEmpleado
		inner join @periodo periodo
				on periodo.idPeriodo = Historial.Idperiodo
		inner join @Conceptos c
				on c.IDConcepto = dp.IDConcepto			
	where timbrado.IDEstatusTimbrado = 2 
	and Historial.IDEmpleado in (select IDEmpleado from @empleados)
	order by c.OrdenCalculo desc


	select distinct ' ' as 'IMPORTE', 'Numero de trabajadores' as concepto, mes.Nombre as Mes, '1' as Total, ('0') as CODIGO, TempNomina.IDEmpleado
	into #TempTotalTrabajadores
	from  #TempNominaGeneral  TempNomina
	inner join Utilerias.tblMeses mes
			on TempNomina.IDMes = mes.IDMes
				


	DECLARE  
		@DinamicColumns nvarchar(max)
		,@DinamicColumnsISNULL nvarchar(max)
		,@DinamicColumnsTotal nvarchar(max)
		,@query  AS NVARCHAR(MAX)

	select @DinamicColumns='[ENERO],[FEBRERO],[MARZO],[ABRIL],[MAYO],[JUNIO],[JULIO],[AGOSTO],[SEPTIEMBRE],[OCTUBRE],[NOVIEMBRE],[DICIEMBRE]'
		  ,@DinamicColumnsISNULL= 'isnull([ENERO],0) as ENERO,isnull([FEBRERO],0) as FEBRERO,isnull([MARZO],0) as MARZO,isnull([ABRIL],0) as ABRIL,isnull([MAYO],0) as MAYO,isnull([JUNIO],0) as JUNIO,isnull([JULIO],0) as JULIO,isnull([AGOSTO],0) as AGOSTO,isnull([SEPTIEMBRE],0) as SEPTIEMBRE,isnull([OCTUBRE],0) as OCTUBRE,isnull([NOVIEMBRE],0) as NOVIEMBRE,isnull([DICIEMBRE],0) as DICIEMBRE'
		  ,@DinamicColumnsTotal = ',isnull([ENERO],0) + isnull([FEBRERO],0) + isnull([MARZO],0) + isnull([ABRIL],0) + isnull([MAYO],0) + isnull([JUNIO],0) + isnull([JULIO],0) + isnull([AGOSTO],0) + isnull([SEPTIEMBRE],0) + isnull([OCTUBRE],0) + isnull([NOVIEMBRE],0) + isnull([DICIEMBRE],0) as TOTAL'

		SELECT 
			CONCAT(CAST(CODIGO as VARCHAR(10)),' - ',UPPER( Concepto)) as CONCEPTO,
			IMPORTE
			,CASE WHEN Concepto = 'Numero de trabajadores' THEN null else
			isnull([ENERO],0) + isnull([FEBRERO],0) + isnull([MARZO],0)  + isnull([ABRIL],0)		+ isnull([MAYO],0)    + 
			 isnull([JUNIO],0) + isnull([JULIO],0)	 + isnull([AGOSTO],0) + isnull([SEPTIEMBRE],0)  + isnull([OCTUBRE],0) + 
			 isnull([NOVIEMBRE],0) + isnull([DICIEMBRE],0)
			 end as TOTAL 
			,isnull([ENERO],0) as ENERO
			,isnull([FEBRERO],0) as FEBRERO
			,isnull([MARZO],0) as MARZO
			,isnull([ABRIL],0) as ABRIL
			,isnull([MAYO],0) as MAYO
			,isnull([JUNIO],0) as JUNIO
			,isnull([JULIO],0) as JULIO
			,isnull([AGOSTO],0) as AGOSTO
			,isnull([SEPTIEMBRE],0) as SEPTIEMBRE
			,isnull([OCTUBRE],0) as OCTUBRE
			,isnull([NOVIEMBRE],0) as NOVIEMBRE
			,isnull([DICIEMBRE],0) as DICIEMBRE
			
		from (
				select ' ' as 'IMPORTE', emitidos.Titulo as Concepto, mes.Nombre as Mes, COUNT(emitidos.Emitidos) as Total, (' ') as 'CODIGO'
				from #TempEmitidos emitidos
					inner join Utilerias.tblMeses mes
						on emitidos.IDMes = mes.IDMes
				group by mes.Nombre, mes.IDMes, emitidos.Titulo
				union all
				select ' ' as 'IMPORTE', 'Numero de trabajadores' as concepto, tra.mes as Mes, SUM(CAST(tra.Total as int)) as Total, (' ') as CODIGO
				from #TempTotalTrabajadores tra
				group by  tra.Total, tra.Mes
				union all
				select 'EXCENTO' as 'IMPORTE',ng.Descripcion as concepto, mes.Nombre as Mes, SUM(ng.ImporteExcento) as Total, ng.Codigo as CODIGO
				from #TempNominaGeneral ng
					inner join Utilerias.tblMeses mes
						on ng.IDMes = mes.IDMes
				group by  ng.Descripcion , mes.Nombre, ng.Codigo
				union all
				select 'IMPORTE TOTAL' as 'IMPORTE',ng.Descripcion as concepto, mes.Nombre as Mes, SUM(NG.ImporteTotal1) as Total, ng.Codigo as CODIGO
				from #TempNominaGeneral ng
					inner join Utilerias.tblMeses mes
						on ng.IDMes = mes.IDMes
				group by  ng.Descripcion , mes.Nombre, ng.Codigo

            ) x
            pivot 
            (
               SUM( Total )
                for Mes in ([ENERO],[FEBRERO],[MARZO],[ABRIL],[MAYO],[JUNIO],[JULIO],[AGOSTO],[SEPTIEMBRE],[OCTUBRE],[NOVIEMBRE],[DICIEMBRE])
            ) p 
			WHERE (isnull([ENERO],0) + isnull([FEBRERO],0) + isnull([MARZO],0)  + isnull([ABRIL],0)		+ isnull([MAYO],0)    + 
			isnull([JUNIO],0) + isnull([JULIO],0)	 + isnull([AGOSTO],0) + isnull([SEPTIEMBRE],0)  + isnull([OCTUBRE],0) + 
			isnull([NOVIEMBRE],0) + isnull([DICIEMBRE],0)) <> 0
			order by CODIGO, IMPORTE 

	--SELECT Codigo
	--		,Concepto
	--		,TipoConcepto
	--		,isnull([ENERO],0) as ENERO
	--		,isnull([FEBRERO],0) as FEBRERO
	--		,isnull([MARZO],0) as MARZO
	--		,isnull([ABRIL],0) as ABRIL
	--		,isnull([MAYO],0) as MAYO
	--		,isnull([JUNIO],0) as JUNIO
	--		,isnull([JULIO],0) as JULIO
	--		,isnull([AGOSTO],0) as AGOSTO
	--		,isnull([SEPTIEMBRE],0) as SEPTIEMBRE
	--		,isnull([OCTUBRE],0) as OCTUBRE
	--		,isnull([NOVIEMBRE],0) as NOVIEMBRE
	--		,isnull([DICIEMBRE],0) as DICIEMBRE
	--		,isnull([ENERO],0) + isnull([FEBRERO],0) + isnull([MARZO],0)  + isnull([ABRIL],0)		+ isnull([MAYO],0)    + 
	--		 isnull([JUNIO],0) + isnull([JULIO],0)	 + isnull([AGOSTO],0) + isnull([SEPTIEMBRE],0)  + isnull([OCTUBRE],0) + 
	--		 isnull([NOVIEMBRE],0) + isnull([DICIEMBRE],0) as TOTAL 
	--	from (
	--			select 
	--				c.Codigo
	--				,c.DESCRIPCION as Concepto
	--				,c.TipoConcepto
	--				,m.Nombre as Mes
	--				,SUM(isnull(dp.ImporteTotal1,0)) as Total
	--				,c.Orden as OrdenCalculo
	--				,case when c.IDTipoConcepto = 1 then 1 
	--					   WHEN c.IDTipoConcepto = 4 then 2
	--					   WHEN c.IDTipoConcepto = 2 then 3
	--					   WHEN c.IDTipoConcepto = 3 then 4
	--					   WHEN c.IDTipoConcepto = 6 then 5
	--					   WHEN c.IDTipoConcepto = 5 then 6
	--					else 0
	--					end as ordenshow
	--			from Nomina.tblDetallePeriodo dp with (nolock) 
	--				inner join @periodo P on dp.IDPeriodo = P.IDPeriodo
	--				inner join (select 
	--								ccc.*
	--								,tc.Descripcion as TipoConcepto
	--								,crr.Orden
	--							from Nomina.tblCatConceptos ccc with (nolock) 
	--								inner join Nomina.tblCatTipoConcepto tc with (nolock) on tc.IDTipoConcepto = ccc.IDTipoConcepto
	--								inner join Reportes.tblConfigReporteRayas crr with (nolock)  on crr.IDConcepto = ccc.IDConcepto and crr.Impresion = 1
	--							) c on c.IDConcepto = dp.IDConcepto
	--				inner join Utilerias.tblMeses m with (nolock) on P.IDMes = m.IDMes
	--				inner join @empleados e on dp.IDEmpleado = e.IDEmpleado
	--			Group by c.Codigo,c.IDTipoConcepto,c.DESCRIPCION,m.Nombre, c.Orden,c.TipoConcepto
 --           ) x
 --           pivot 
 --           (
 --              SUM( Total )
 --               for Mes in ([ENERO],[FEBRERO],[MARZO],[ABRIL],[MAYO],[JUNIO],[JULIO],[AGOSTO],[SEPTIEMBRE],[OCTUBRE],[NOVIEMBRE],[DICIEMBRE])
 --           ) p order by ordenshow,OrdenCalculo asc
GO
