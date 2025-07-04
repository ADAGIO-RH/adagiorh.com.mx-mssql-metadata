USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spCostoGeneral] (
	@FechaInicioPago date	-- = '2019-03-01'
	,@FechaFinPago date		-- = '2019-04-15'
	,@IDTipoNomina int		-- = 4
	,@IDUsuario int
)
as
	SET NOCOUNT ON;
    IF 1=0 
	BEGIN
		SET FMTONLY OFF
    END

	declare
		@dtTiemposExtras [Asistencia].[dtDetalleTiemposExtras] 
		,@dtFiltros [Nomina].[dtFiltrosRH] 
		,@dtEmpleados [RH].[dtEmpleados]
		--,@IDUsuario int
		,@Homologa varchar(10)
		,@UMA decimal(18,4)        
		,@Tope25UMA decimal(18,4)        
		,@Tope3UMA decimal(18,4) 

		,@Ejercicio int 
		,@IDMes int    

		,@IDConceptoDiasVigencia	varchar(20) = 'DVIG'       
		,@IDConceptoIncapacidades	varchar(20) = 'I'       
		,@IDConceptoAusentismos		varchar(20) = 'AUSENTISMOS'       
		,@IDConceptoDiasCotizados	varchar(20) = 'DVIG'
    
	
		,@IDConceptoIMSSP	varchar(20) = '512'

		,@IDConceptosCostoTotal varchar(max) = 'TOTAL_SUELDOS,TOTAL_INCIDENCIAS,IMPUESTO_NOMINA,%5_INFONAVIT,IMSS_PATRONAL'
	;

	select @Ejercicio = datepart(YEAR,@FechaFinPago)   
			,@IDMes = datepart(MONTH,@FechaFinPago)   

	--select @IDUsuario = cast(Valor as Int) from App.tblConfiguracionesGenerales where IDConfiguracion = 'IDUsuarioAdmin'

    if object_id('tempdb..#tempIMSS') is not null drop table #tempIMSS;         
    if object_id('tempdb..#tempIMSSDetalleTotales') is not null drop table #tempIMSSDetalleTotales;       
    if object_id('tempdb..#tempIMSSFinal') is not null drop table #tempIMSSFinal;         
    if object_id('tempdb..#tempTodosConceptos') is not null drop table #tempTodosConceptos;     

	if exists( select top 1 1 from [Nomina].[tblConfiguracionNomina] with (nolock) where Configuracion = 'HomologarIMSS')      
	BEGIN      
		select top 1 @Homologa = ISNULL(valor,'0') 
		from [Nomina].[tblConfiguracionNomina] with (nolock)      
		where Configuracion = 'HomologarIMSS'      
	END      
	ELSE      
	BEGIN      
		set @Homologa = '0'      
	END;
         
    select top 1         
		 @UMA  = UMA        
		,@Tope25UMA = UMA * 25        
		,@Tope3UMA  = UMA *3        
    from Nomina.TblSalariosMinimos with (nolock)        
    where Fecha <= @FechaFinPago        
    order by Fecha desc   

	--select @Tope25UMA,@Tope3UMA

--	if object_id('tempdb..#tempEmpleados') is not null drop table #tempEmpleados;
	if object_id('tempdb..#tempCatConceptos') is not null drop table #tempCatConceptos;

	create table #tempCatConceptos (
		 IDConcepto varchar(20)
		,Concepto varchar(100) 
		,EsPercepcion bit default 0
		,EsIncidencia bit default 0
		,Orden int
	);
	insert #tempCatConceptos(IDConcepto,Concepto, EsPercepcion,EsIncidencia,Orden)
	values
	 ('DVIG','DÍAS DE VIGENCIA',0,0,1)
	,('I','INCAPACIDAD',0,1,2)
	,('F','FALTAS',0,1,3)
	,('DIAS_PAGADOS','DIAS PAGADOS',0,0,4)
	,('V','VACACIONES',0,1,5)
	,('EX','TIEMPO EXTRA',0,1,6)
	,('SUELDO','SUELDO',1,0,7)
	,('TIEMPO_EXTRA','TIEMPO EXTRA PAGADO',1,1,8)
	--,('DF','DIAS FESTIVOS TRABAJADO',0,1,14)
	,('FESTIVOS_TRABAJADO','FESTIVOS TRABAJADO',0,1,9)
	--,('DL','DESCANSO LABORADO',0,1,4)
	,('DESCANSO_LABORADO','DESCANSO LABORADO',0,1,10)
	,('PRIMA_DOMINICAL','PRIMA DOMINICAL',1,1,11)
	--,('PD','PRIMA DOMINICAL TRABAJADA',0,1,9)
	,('VACACIONES','VACACIONES PAGADAS',1,1,12)
	,('PRIMA_VACACIONAL','PRIMA VACACIONAL',1,1,13)
	,('PREMIO_PUNTUALIDAD','PREMIO DE PUNTUALIDAD',1,0,14)
	,('PREMIO_ASISTENCIA','PREMIO DE ASISTENCIA',1,0,15)
	,('VALES_DESPENSA','VALES DE DESPENSA',1,0,17)
	,('TOTAL_PERCEPCIONES','TOTAL DE PERCEPCIONES',0,0,18)
	,('TOTAL_SUELDOS','TOTAL SUELDOS',0,0,19)
	,('TOTAL_INCIDENCIAS','TOTAL INCIDENCIAS',0,0,20)
	,('IMPUESTO_NOMINA','IMPUESTO SOBRE NOMINA',0,0,21)
	,('%5_INFONAVIT','%5 INFONAVIT',0,0,22)
	--,('AUSENTISMOS','AUSENTISMOS',0,0,23)
	,('IMSS_PATRONAL','IMSS PATRONAL',0,0,24)
	,('COSTO_TOTAL','COSTO TOTAL',0,0,25)
	--select * from #tempCatConceptos

	if object_id('tempdb..#tempEmpleadosFinal') is not null drop table #tempEmpleadosFinal;
	if object_id('tempdb..#tempDiasVigencia') is not null drop table #tempDiasVigencia;
	IF object_ID('tempdb..#TempMovimientos') IS NOT NULL  DROP TABLE #TempMovimientos;  

	create table #tempEmpleadosFinal(
		 IDEmpleado	int
		--,ClaveEmpleado varchar(20)
		--,NombreCompleto varchar(max)
		--,FechaIngreso  date
		--,Sucursal varchar(255)
		--,Departamento	 varchar(255)
		--,Puesto			 varchar(255)
		--,TipoContratacion varchar(255)
		,SalarioDiario money
		,SalarioIntegrado money
		,IDConcepto varchar(20)
		,Concepto varchar(100) 
		,Valor money
	);
	
	insert @dtEmpleados
	exec [RH].[spBuscarEmpleados] @FechaIni = @FechaInicioPago,@FechaFin = @FechaFinPago,@IDTipoNomina = @IDTipoNomina,@IDUsuario=@IDUsuario
	
	--Select top 1 hpr.*         
	--   from [RH].[tblHistorialPrimaRiesgo] hpr
	--	join @dtEmpleados e on e.IDRegPatronal = hpr.IDRegPatronal         
	--  -- where IDRegPatronal= e.IDRegPatronal        
	--   and Anio = @Ejercicio        
	--   and Mes <= @IDMes        
	--   order by Mes desc

	--select top 1 *        
	--	from [IMSS].[tblCatPorcentajesPago]        
	--	where Fecha <= @FechaFinPago        
	--	order by Fecha desc


	IF EXISTS (SELECT pd.* 
				FROM @dtEmpleados Empleados
					Left Join RH.tblCatTiposPrestacionesDetalle PD with (nolock)  on Empleados.IDTipoPrestacion = PD.IDTipoPrestacion  
						and PD.Antiguedad = CASE WHEN DATEDIFF(YEAR,Empleados.FechaAntiguedad,@FechaFinPago) < 1 THEN 1  
												ELSE DATEDIFF(YEAR,Empleados.FechaAntiguedad,@FechaFinPago)  END
				WHERE PD.PrimaVacacional IS NULL
		)
	BEGIN
		exec app.spObtenerError  @IDUsuario= @IDUsuario,@CodigoError='0410002'
		return
	END
	--select e.IDEmpleado
	--	,e.ClaveEmpleado
	--	,e.NOMBRECOMPLETO as NombreCompleto
	--	,e.FechaIngreso 
	--	,e.Sucursal
	--	,e.Departamento
	--	,e.Puesto
	--	,'' TipoContratacion
	--	,e.SalarioDiario
	--	,e.SalarioIntegrado
	--INTO #tempEmpleados
	--from [RH].[tblEmpleadosMaster] e with (nolock)
	--where e.IDTipoNomina = @IDTipoNomina
	--order by e.NOMBRECOMPLETO asc
	
	--select * from #tempEmpleados order by NombreCompleto
      
    select m.*, ROW_NUMBER()over(partition by m.IDEmpleado order by  m.Fecha desc) as [Row]  
    into #TempMovimientos  
    from @dtEmpleados e  
    join IMSS.tblMovAfiliatorios m on e.IDEmpleado = m.IDEmpleado  
	
	BEGIN-- Días de vigencia
		SELECT  
			Empleados.IDEmpleado,  
			DiasVigencia =  CASE  WHEN ( Movimientos.Fecha between @FechaInicioPago and @FechaFinPago) AND (TipoMovimiento.Codigo = 'A' OR TipoMovimiento.Codigo = 'R') THEN DATEDIFF(DAY,Movimientos.Fecha, @FechaFinPago)+1  
								 WHEN ( Movimientos.Fecha between @FechaInicioPago and @FechaFinPago) AND (TipoMovimiento.Codigo = 'B') THEN DATEDIFF(DAY,@FechaInicioPago,Movimientos.Fecha)+1  
								 WHEN ( Movimientos.Fecha <= @FechaInicioPago) AND (TipoMovimiento.Codigo = 'A' OR TipoMovimiento.Codigo = 'R') THEN DATEDIFF(DAY,@FechaInicioPago, @FechaFinPago) +1 
								 ELSE DATEDIFF(DAY,@FechaInicioPago, @FechaFinPago)  +1
							 END  
		INTO #tempDiasVigencia  
		FROM @dtEmpleados Empleados  
			Left join (select *  
					from #TempMovimientos  
					where [Row] = 1) Movimientos  
				on Empleados.IDEmpleado = Movimientos.IDEmpleado  
			left join IMSS.tblCatTipoMovimientos TipoMovimiento with (nolock) 
				on Movimientos.IDTipoMovimiento = TipoMovimiento.IDTipoMovimiento  
					and TipoMovimiento.Codigo <>'M'   
					and Movimientos.Fecha <= @FechaFinPago  

		insert into #tempEmpleadosFinal
		select   e.IDEmpleado			
				--,e.ClaveEmpleado		
				--,e.NombreCompleto		
				--,e.FechaIngreso		
				--,e.Sucursal			
				--,e.Departamento		
				--,e.Puesto				
				--,'' TipoContratacion	
				,e.SalarioDiario		
				,e.SalarioIntegrado
				,'DVIG'
				,'DÍAS DE VIGENCIA'
				,isnull(edvig.DiasVigencia,0)
		from @dtEmpleados e	
			join #tempDiasVigencia edvig on  e.IDEmpleado = edvig.IDEmpleado
	END;
	BEGIN -- INCIDENCIAS
		insert into #tempEmpleadosFinal
		select e.IDEmpleado			
				--,e.ClaveEmpleado		
				--,e.NombreCompleto		
				--,e.FechaIngreso		
				--,e.Sucursal			
				--,e.Departamento		
				--,e.Puesto				
				--,'' TipoContratacion	
				,e.SalarioDiario		
				,e.SalarioIntegrado
				,ee.IDIncidencia
				,ee.Descripcion
				,isnull(ee.Total,0)
		from (
			select emp.IDEmpleado,i.IDIncidencia,i.Descripcion,count(ie.IDIncidencia) as Total
			from @dtEmpleados emp
				join Asistencia.tblIncidenciaEmpleado ie with (nolock) on emp.IDEmpleado = ie.IDEmpleado and ie.Fecha between @FechaInicioPago and @FechaFinPago
				join Asistencia.tblCatIncidencias i with (nolock) on ie.IDIncidencia = i.IDIncidencia
			where ie.Autorizado = 1
			group by emp.IDEmpleado,i.IDIncidencia,i.Descripcion
		) ee join @dtEmpleados e on ee.IDEmpleado = e.IDEmpleado

		--select e.IDEmpleado			
		--		--,e.ClaveEmpleado		
		--		--,e.NombreCompleto		
		--		--,e.FechaIngreso		
		--		--,e.Sucursal			
		--		--,e.Departamento		
		--		--,e.Puesto				
		--		--,'' TipoContratacion	
		--		,e.SalarioDiario		
		--		,e.SalarioIntegrado
		--		,ee.IDIncidencia
		--		,ee.Descripcion
		--		,isnull(ee.Total,0)
		--from (
		--	select emp.IDEmpleado,i.IDIncidencia,i.Descripcion,count(ie.IDIncidencia) as Total
		--	from @dtEmpleados emp
		--		join Asistencia.tblIncidenciaEmpleado ie on emp.IDEmpleado = ie.IDEmpleado and ie.Fecha between @FechaInicioPago and @FechaFinPago
		--		join Asistencia.tblCatIncidencias i on ie.IDIncidencia = i.IDIncidencia
		--	where ie.Autorizado = 1
		--	group by emp.IDEmpleado,i.IDIncidencia,i.Descripcion
		--) ee join @dtEmpleados e on ee.IDEmpleado = e.IDEmpleado

	END;
	BEGIN -- AUSENTISMOS
		insert into #tempEmpleadosFinal
		select e.IDEmpleado			
				--,e.ClaveEmpleado		
				--,e.NombreCompleto		
				--,e.FechaIngreso		
				--,e.Sucursal			
				--,e.Departamento		
				--,e.Puesto				
				--,'' TipoContratacion	
				,e.SalarioDiario		
				,e.SalarioIntegrado
				,'AUSENTISMOS'
				,'AUSENTISMOS'
				,isnull(ee.Total,0)
		from (
			select emp.IDEmpleado,count(ie.IDIncidencia) as Total
			from @dtEmpleados emp
				join Asistencia.tblIncidenciaEmpleado ie with (nolock) on emp.IDEmpleado = ie.IDEmpleado and ie.Fecha between @FechaInicioPago and @FechaFinPago
				join Asistencia.tblCatIncidencias i with (nolock) on ie.IDIncidencia = i.IDIncidencia
			where ie.Autorizado = 1 and  i.EsAusentismo = 1
									   AND i.GoceSueldo = 0
			group by emp.IDEmpleado
		) ee join @dtEmpleados e on ee.IDEmpleado = e.IDEmpleado
	END;
	BEGIN -- DIAS PAGADOS
		insert into #tempEmpleadosFinal
		select e.IDEmpleado			
				--,e.ClaveEmpleado		
				--,e.NombreCompleto		
				--,e.FechaIngreso		
				--,e.Sucursal			
				--,e.Departamento		
				--,e.Puesto				
				--,'' TipoContratacion	
				,e.SalarioDiario		
				,e.SalarioIntegrado
				,'DIAS_PAGADOS'
				,'DIAS PAGADOS'
				,isnull(DVIG.Valor,0) - (isnull(Incapacidades.Valor,0) + isnull(Faltas.Valor,0) + isnull(Vacaciones.Valor,0))
		from @dtEmpleados e
			join (
				select * 
				from #tempEmpleadosFinal 
				where IDConcepto = 'DVIG'
				) DVIG on e.IDEmpleado = DVIG.IDEmpleado 
			left join (
				select * 
				from #tempEmpleadosFinal 
				where IDConcepto = 'I'
				) Incapacidades on e.IDEmpleado = Incapacidades.IDEmpleado 		
			left join (
				select * 
				from #tempEmpleadosFinal 
				where IDConcepto = 'F'
				) Faltas on e.IDEmpleado = Faltas.IDEmpleado 			
			left join (
				select * 
				from #tempEmpleadosFinal 
				where IDConcepto = 'V'
				) Vacaciones on e.IDEmpleado = Vacaciones.IDEmpleado 	--  DIAS_DE_VIGENCIA  - (TOTAL_INCAPACIDADES + _faltas + _vacaciones)
	END;
	BEGIN -- TiemposExtras

		insert @dtTiemposExtras
		exec [Asistencia].[spBuscarDetalleTiemposExtras] @FechaIni = @FechaInicioPago         
														,@Fechafin = @FechaFinPago         
														,@dtEmpleados = @dtEmpleados
		
		insert into #tempEmpleadosFinal
		select   e.IDEmpleado			
				--,e.ClaveEmpleado		
				--,e.NombreCompleto		
				--,e.FechaIngreso		
				--,e.Sucursal			
				--,e.Departamento		
				--,e.Puesto				
				--,'' TipoContratacion	
				,e.SalarioDiario		
				,e.SalarioIntegrado
				,'TIEMPO_EXTRA'
				,'TIEMPO EXTRA'
				,((e.SalarioDiario / 8) * tiemposExtras.TiempoTotal) * 2
		from @dtEmpleados e	
			join @dtTiemposExtras tiemposExtras on  e.IDEmpleado = tiemposExtras.IDEmpleado
	END;
	BEGIN -- SUELDO
		insert into #tempEmpleadosFinal
		select   e.IDEmpleado			
				--,e.ClaveEmpleado		
				--,e.NombreCompleto		
				--,e.FechaIngreso		
				--,e.Sucursal			
				--,e.Departamento		
				--,e.Puesto				
				--,'' TipoContratacion	
				,e.SalarioDiario		
				,e.SalarioIntegrado
				,'SUELDO'
				,'SUELDO'
				,e.SalarioDiario * DIAS_PAGADOS.Valor
		from @dtEmpleados e	
			join (
				select * 
				from #tempEmpleadosFinal 
				where IDConcepto = 'DIAS_PAGADOS'
				) DIAS_PAGADOS on e.IDEmpleado = DIAS_PAGADOS.IDEmpleado 

	END;
	BEGIN -- FESTIVOS TRABAJADO
		insert into #tempEmpleadosFinal
		select   e.IDEmpleado			
				--,e.ClaveEmpleado		
				--,e.NombreCompleto		
				--,e.FechaIngreso		
				--,e.Sucursal			
				--,e.Departamento		
				--,e.Puesto				
				--,'' TipoContratacion	
				,e.SalarioDiario		
				,e.SalarioIntegrado
				,'FESTIVOS_TRABAJADO'
				,'FESTIVOS TRABAJADO'
				,(e.SalarioDiario * df.Valor) * 2
		from @dtEmpleados e	
			join (
				select * 
				from #tempEmpleadosFinal 
				where IDConcepto = 'DF'
				) df on e.IDEmpleado = df.IDEmpleado 

	END;
	BEGIN -- DESCANSO LABORADO
		insert into #tempEmpleadosFinal
		select   e.IDEmpleado			
				--,e.ClaveEmpleado		
				--,e.NombreCompleto		
				--,e.FechaIngreso		
				--,e.Sucursal			
				--,e.Departamento		
				--,e.Puesto				
				--,'' TipoContratacion	
				,e.SalarioDiario		
				,e.SalarioIntegrado
				,'DESCANSO_LABORADO'
				,'DESCANSO LABORADO'
				,(e.SalarioDiario * dl.Valor) * 2
		from @dtEmpleados e	
			join (
				select * 
				from #tempEmpleadosFinal 
				where IDConcepto = 'DL'
				) dl on e.IDEmpleado = dl.IDEmpleado 

	END;
	BEGIN -- PRIMA DOMINICAL TRABAJADA
		insert into #tempEmpleadosFinal
		select   e.IDEmpleado			
				--,e.ClaveEmpleado		
				--,e.NombreCompleto		
				--,e.FechaIngreso		
				--,e.Sucursal			
				--,e.Departamento		
				--,e.Puesto				
				--,'' TipoContratacion	
				,e.SalarioDiario		
				,e.SalarioIntegrado
				,'PRIMA_DOMINICAL'
				,'PRIMA DOMINICAL'
				,(e.SalarioDiario * dl.Valor) * 0.25
		from @dtEmpleados e	
			join (
				select * 
				from #tempEmpleadosFinal 
				where IDConcepto = 'PD'
				) dl on e.IDEmpleado = dl.IDEmpleado 

	END;
	BEGIN -- VACACIONES PAGADAS
		insert into #tempEmpleadosFinal
		select   e.IDEmpleado			
				--,e.ClaveEmpleado		
				--,e.NombreCompleto		
				--,e.FechaIngreso		
				--,e.Sucursal			
				--,e.Departamento		
				--,e.Puesto				
				--,'' TipoContratacion	
				,e.SalarioDiario		
				,e.SalarioIntegrado
				,'VACACIONES'
				,'VACACIONES PAGADAS'
				,(e.SalarioDiario * 1.20) * dl.Valor
		from @dtEmpleados e	
			join (
				select * 
				from #tempEmpleadosFinal 
				where IDConcepto = 'V'
				) dl on e.IDEmpleado = dl.IDEmpleado 

	END; --  (SalarioDiario * 1.20) * totalVacaciones 
	BEGIN -- PRIMA VACACIONAL
		insert into #tempEmpleadosFinal
		select   e.IDEmpleado			
				--,e.ClaveEmpleado		
				--,e.NombreCompleto		
				--,e.FechaIngreso		
				--,e.Sucursal			
				--,e.Departamento		
				--,e.Puesto				
				--,'' TipoContratacion	
				,e.SalarioDiario		
				,e.SalarioIntegrado
				,'PRIMA_VACACIONAL'
				,'PRIMA VACACIONAL'
				,(e.SalarioDiario *  dl.Valor) * PrimaVacacional -- ( SUELDO * VACACIONES ) * ( PRIMA_VACACIONAL / 100 )
		from @dtEmpleados e	
			join (
				select * 
				from #tempEmpleadosFinal 
				where IDConcepto = 'V'
				) dl on e.IDEmpleado = dl.IDEmpleado 
			 Left Join RH.tblCatTiposPrestacionesDetalle PD  on e.IDTipoPrestacion = PD.IDTipoPrestacion  
					and PD.Antiguedad = CASE WHEN DATEDIFF(YEAR,e.FechaAntiguedad,@FechaFinPago) < 1 THEN 1  
              ELSE DATEDIFF(YEAR,e.FechaAntiguedad,@FechaFinPago)  END


	END;  
	BEGIN -- PREMIO DE PUNTUALIDAD
		insert into #tempEmpleadosFinal
		select   e.IDEmpleado			
				--,e.ClaveEmpleado		
				--,e.NombreCompleto		
				--,e.FechaIngreso		
				--,e.Sucursal			
				--,e.Departamento		
				--,e.Puesto				
				--,'' TipoContratacion	
				,e.SalarioDiario		
				,e.SalarioIntegrado
				,'PREMIO_PUNTUALIDAD'
				,'PREMIO DE PUNTUALIDAD'
				,(e.SalarioDiario *  0.10)
		from @dtEmpleados e	

	END;  
	BEGIN -- PREMIO DE ASISTENCIA
		insert into #tempEmpleadosFinal
		select   e.IDEmpleado			
				--,e.ClaveEmpleado		
				--,e.NombreCompleto		
				--,e.FechaIngreso		
				--,e.Sucursal			
				--,e.Departamento		
				--,e.Puesto				
				--,'' TipoContratacion	
				,e.SalarioDiario		
				,e.SalarioIntegrado
				,'PREMIO_ASISTENCIA'
				,'PREMIO DE ASISTENCIA'
				,(e.SalarioDiario *  0.10)
		from @dtEmpleados e	

	END; 
	BEGIN -- VALES DE DESPENSA
		insert into #tempEmpleadosFinal
		select   e.IDEmpleado			
				--,e.ClaveEmpleado		
				--,e.NombreCompleto		
				--,e.FechaIngreso		
				--,e.Sucursal			
				--,e.Departamento		
				--,e.Puesto				
				--,'' TipoContratacion	
				,e.SalarioDiario		
				,e.SalarioIntegrado
				,'VALES_DESPENSA'
				,'VALES DE DESPENSA'
				,CASE when '' = 'SA' then (isnull(diasPagados.Valor,0) + isnull(diasVacaciones.Valor,0)) * 18.33  
					else (isnull(diasPagados.Valor,0) + isnull(diasVacaciones.Valor,0)) * 20 end
		from @dtEmpleados e	
			LEFT join (
				select * 
				from #tempEmpleadosFinal 
				where IDConcepto = 'DIAS_PAGADOS'
				) diasPagados on e.IDEmpleado = diasPagados.IDEmpleado 
			LEFT join (
				select * 
				from #tempEmpleadosFinal 
				where IDConcepto = 'V'
				) diasVacaciones on e.IDEmpleado = diasVacaciones.IDEmpleado 

			--SI TipoContratacion = 'SA' ENTONCES
   --            _vales_despensa := ( _dias + _vacaciones ) * 18.33
   --         SI_NO
   --            _vales_despensa := ( _dias + _vacaciones ) * 20
   --         FIN_SI

	END;
	BEGIN -- TOTAL_PERCEPCIONES
		insert into #tempEmpleadosFinal
		select   e.IDEmpleado			
				--,e.ClaveEmpleado		
				--,e.NombreCompleto		
				--,e.FechaIngreso		
				--,e.Sucursal			
				--,e.Departamento		
				--,e.Puesto				
				--,'' TipoContratacion	
				,e.SalarioDiario		
				,e.SalarioIntegrado
				,'TOTAL_PERCEPCIONES'
				,'TOTAL DE PERCEPCIONES'
				,SUM(ef.Valor)
		from @dtEmpleados e	
			join #tempEmpleadosFinal ef on e.IDEmpleado = ef.IDEmpleado 
			join #tempCatConceptos c on ef.IDConcepto = c.IDConcepto
		where c.EsPercepcion = 1
 		group by 	  e.IDEmpleado			
				,e.ClaveEmpleado		
				,e.NombreCompleto		
				,e.FechaIngreso		
				,e.Sucursal			
				,e.Departamento		
				,e.Puesto				
				,e.SalarioDiario		
				,e.SalarioIntegrado	 

	END;
	BEGIN -- TOTAL_SUELDOS
		insert into #tempEmpleadosFinal
		select   e.IDEmpleado			
				--,e.ClaveEmpleado		
				--,e.NombreCompleto		
				--,e.FechaIngreso		
				--,e.Sucursal			
				--,e.Departamento		
				--,e.Puesto				
				--,'' TipoContratacion	
				,e.SalarioDiario		
				,e.SalarioIntegrado
				,'TOTAL_SUELDOS'
				,'TOTAL SUELDOS'
				,isnull(sueldo.Valor,0) + isnull(otrasPerc.Valor,0)
		from @dtEmpleados e	
			left join (
				select * 
				from #tempEmpleadosFinal 
				where IDConcepto = 'SUELDO'
				) sueldo on e.IDEmpleado = sueldo.IDEmpleado 
			left join (
				select IDEmpleado,sum(Valor) as Valor
				from #tempEmpleadosFinal 
				where IDConcepto in ('VACACIONES','PREMIO_PUNTUALIDAD','PREMIO_ASISTENCIA','VALES_DESPENSA')
				GROUP BY IDEmpleado
				) otrasPerc on e.IDEmpleado = otrasPerc.IDEmpleado 				
	END;
	BEGIN -- TOTAL_INCIDENCIAS
		insert into #tempEmpleadosFinal
		select   e.IDEmpleado			
				--,e.ClaveEmpleado		
				--,e.NombreCompleto		
				--,e.FechaIngreso		
				--,e.Sucursal			
				--,e.Departamento		
				--,e.Puesto				
				--,'' TipoContratacion	
				,e.SalarioDiario		
				,e.SalarioIntegrado
				,'TOTAL_INCIDENCIAS'
				,'TOTAL INCIDENCIAS'
				,isnull(totalPerc.Valor,0) - isnull(otrasPerc.Valor,0)
		from @dtEmpleados e	
			left join (
				select * 
				from #tempEmpleadosFinal 
				where IDConcepto = 'TOTAL_PERCEPCIONES'
				) totalPerc on e.IDEmpleado = totalPerc.IDEmpleado 
			left join (
				select IDEmpleado,sum(Valor) as Valor
				from #tempEmpleadosFinal 
				where IDConcepto in ('VACACIONES','PREMIO_PUNTUALIDAD','PREMIO_ASISTENCIA','VALES_DESPENSA','SUELDO')
				GROUP BY IDEmpleado
				) otrasPerc on e.IDEmpleado = otrasPerc.IDEmpleado 				
	END;
	BEGIN -- IMPUESTO_NOMINA
		insert into #tempEmpleadosFinal
		select   e.IDEmpleado			
				--,e.ClaveEmpleado		
				--,e.NombreCompleto		
				--,e.FechaIngreso		
				--,e.Sucursal			
				--,e.Departamento		
				--,e.Puesto				
				--,'' TipoContratacion	
				,e.SalarioDiario		
				,e.SalarioIntegrado
				,'IMPUESTO_NOMINA'
				,'IMPUESTO SOBRE NOMINA'
				,isnull(totalPerc.Valor,0) * 0.03
		from @dtEmpleados e	
			left join (
				select * 
				from #tempEmpleadosFinal 
				where IDConcepto = 'TOTAL_PERCEPCIONES'
				) totalPerc on e.IDEmpleado = totalPerc.IDEmpleado 
		
	END;
	BEGIN -- %5_INFONAVIT
		insert into #tempEmpleadosFinal
		select   e.IDEmpleado			
				--,e.ClaveEmpleado		
				--,e.NombreCompleto		
				--,e.FechaIngreso		
				--,e.Sucursal			
				--,e.Departamento		
				--,e.Puesto				
				--,'' TipoContratacion	
				,e.SalarioDiario		
				,e.SalarioIntegrado
				,'%5_INFONAVIT'
				,'%5 INFONAVIT'
				,case when isnull(faltas.Valor,0) > 14 then ( (isnull(DVIG.Valor,0) -14) * e.SalarioIntegrado )* 0.05
					 else  ( (isnull(DVIG.Valor,0) - isnull(faltas.Valor,0)) * e.SalarioIntegrado )* 0.05 end
		from @dtEmpleados e	
			left join (
				select * 
				from #tempEmpleadosFinal 
				where IDConcepto = 'DVIG'
				) DVIG on e.IDEmpleado = DVIG.IDEmpleado 
			left join (
				select * 
				from #tempEmpleadosFinal 
				where IDConcepto = 'F'
				) faltas on e.IDEmpleado = faltas.IDEmpleado 
	END;
	BEGIN -- IMSS PATRONAL
		select e.*, Antiguedad = case when DATEDIFF(YEAR,e.FechaAntiguedad,@FechaFinPago) = 0 then 1         
			else DATEDIFF(YEAR,e.FechaAntiguedad,@FechaFinPago)         
			end        
		, e.SalarioDiario * 30.4  as SalarioMensual        
		, DiasCotizados = isnull(DC.Valor,0)         
		, DiasVigencia = isnull(dp.Valor,0)     
		,DiasAusentismo = CASE WHEN (ISNULL(Ausentismos.Valor,0)) >= 14 THEN 14
															 ELSE  ISNULL(Ausentismos.Valor,0)
															   END
		--, DiasAusentismo =  case when  ISNULL(AcumAusentismos.ImporteTotal1,0) >= 7 then 0 
		--						 when  ISNULL(AcumAusentismos.ImporteTotal1,0) < 7 then  
		--												CASE WHEN (ISNULL(AcumAusentismos.ImporteTotal1,0) + ISNULL(Ausentismos.Valor,0)) >= 7 THEN  7 - ISNULL(AcumAusentismos.ImporteTotal1,0)
		--													 ELSE 7 - (ISNULL(AcumAusentismos.ImporteTotal1,0) + ISNULL(Ausentismos.Valor,0))
		--													   END

							
		--						else 0
		--						end       
		, DiasIncapacidad = isnull(inca.Valor,0)        
		,dp.Valor   
		,AcumAusentismos = CASE WHEN (ISNULL(Ausentismos.Valor,0)) >= 14 THEN 14
									ELSE  ISNULL(Ausentismos.Valor,0)
									END		--,AcumAusentismos.ImporteTotal1   as  AcumAusentismos 
		, (Select top 1 Prima         
			from [RH].[tblHistorialPrimaRiesgo] with (nolock)        
			where IDRegPatronal= e.IDRegPatronal        
			and Anio = @Ejercicio        
			and Mes <= @IDMes        
			order by Mes desc) as PrimaRiesgo        
		,PorcentajesPago.*        
		INTO #tempIMSS        
		from @dtempleados E        
		left join #tempEmpleadosFinal dp on e.IDEmpleado = dp.IDEmpleado and dp.IDConcepto = @IDConceptoDiasVigencia        
		left join #tempEmpleadosFinal inca on e.IDEmpleado = inca.IDEmpleado and inca.IDConcepto = @IDConceptoIncapacidades        
		left join #tempEmpleadosFinal Ausentismos on e.IDEmpleado = Ausentismos.IDEmpleado and Ausentismos.IDConcepto = @IDConceptoAusentismos        
		left join #tempEmpleadosFinal DC on e.IDEmpleado = DC.IDEmpleado and DC.IDConcepto = @IDConceptoDiasCotizados
	--	Cross Apply [Nomina].[fnObtenerAcumuladoPorConceptoPorMes](e.IDEmpleado,@IDConceptoAusentismos,@IDMes,@Ejercicio) AcumAusentismos       
		,(select top 1 *        
		 from [IMSS].[tblCatPorcentajesPago] with (nolock)        
		 where Fecha <= @FechaFinPago        
		 order by Fecha desc) as PorcentajesPago        

		select         
		imss.IDEmpleado        
		,imss.Antiguedad        
		,imss.SalarioMensual        
		,imss.DiasCotizados        
		,isnull(imss.PrimaRiesgo,0.0) PrimaRiesgo        
        
			/* CUOTA FIJA 20.4% */        
		,'500' as IDCuotaFija_1          
		,CuotaFija_1 = case when isnull(Valor,0) > 0 then isnull(Valor,0)         
		else (@UMA*imss.CuotaFija)*(imss.DiasCotizados) end        
        
		/* EXCEDENTE PATRONAL */          
		,'501' as IDExcedentePatronal_2          
		,ExcedentePatronal_2 = case when isnull(Valor,0) > 0 then isnull(Valor,0)         
				when imss.SalarioIntegrado > @Tope3UMA then ((imss.SalarioIntegrado-@Tope3UMA) * imss.ExcedentePatronal) * (imss.DiasCotizados) else 0 end        
        
		/* PRESTACIONES EN DINERO PATRONAL*/        
		,'502' as IDPrestacionesDineroPatronal_3          
		,PrestacionesDineroPatronal_3 = case when isnull(Valor,0) > 0 then isnull(Valor,0)         
		else (imss.SalarioIntegrado * imss.PrestacionesDineroPatronal) * (imss.DiasCotizados) end          
		/* GUARDERIAS */        
		,'503' as IDGuarderia_4          
			,Guarderia_4 =  case when isnull(Valor,0) > 0 then isnull(Valor,0)         
		else (imss.SalarioIntegrado * imss.GuarderiasPrestacionesSociales) * (imss.DiasCotizados - (isnull(case when imss.DiasAusentismo > 7 then 7 else imss.DiasAusentismo end,0) + isnull(imss.DiasIncapacidad,0)) ) end        
          
		/*RIESGO DE TRABAJO*/        
		,'504' as IDPrimaRiesgoTrabajo_5          
			,PrimaRiesgoTrabajo_5 =  case when isnull(Valor,0) > 0 then isnull(Valor,0)         
		else (imss.SalarioIntegrado * imss.RiesgosTrabajo) *  (imss.DiasCotizados - (isnull(case when imss.DiasAusentismo > 7 then 7 else imss.DiasAusentismo end,0) ) ) end        
          
		/*RESERVA PENSIONADO*/        
		,'505' as IDReservaPensionado_6          
			,ReservaPensionado_6 =  case when isnull(Valor,0) > 0 then isnull(Valor,0)         
		else (imss.SalarioIntegrado * imss.ReservaPensionado) * (imss.DiasCotizados- isnull(imss.DiasIncapacidad,0)) end        
        
		/*  INVALIDEZ Y VIDA  */        
		,'506' as IDInvalidezVidaPatronal_7         
			,InvalidezVidaPatronal_7 =  case when isnull(Valor,0) > 0 then isnull(Valor,0)         
		else (imss.SalarioIntegrado * imss.InvalidezVidaPatronal) * (imss.DiasCotizados - (isnull(case when imss.DiasAusentismo > 7 then 7 else imss.DiasAusentismo end,0) )) end        
        
		-- 507 Total Imss Patronal        
        
		/*  CESANTIA Y VEJEZ PATRON  */        
		,'508' as IDCesantiaVejezPatron_8        
			,CesantiaVejezPatron_8 =  case when isnull(Valor,0) > 0 then isnull(Valor,0)         
		else (imss.SalarioIntegrado * imss.CesantiaVejezPatron) * (imss.DiasCotizados - (isnull(case when imss.DiasAusentismo > 7 then 7 else imss.DiasAusentismo end,0) + isnull(imss.DiasIncapacidad,0)) ) end        
        
		/*  Seguro de Retiro  */        
		,'509' as IDSeguroRetiro_9        
			,SeguroRetiro_9 =  case when isnull(Valor,0) > 0 then isnull(Valor,0)         
		else (imss.SalarioIntegrado * imss.SeguroRetiro) * (imss.DiasCotizados - isnull(case when imss.DiasAusentismo > 7 then 7 else imss.DiasAusentismo end,0) ) end        
        
		/*  Infonavit  */        
		,'510' as IDInfonavit_10        
			,Infonavit_10 =  case when isnull(Valor,0) > 0 then isnull(Valor,0)         
		else (imss.SalarioIntegrado * imss.Infonavit) * (imss.DiasCotizados - isnull(case when imss.DiasAusentismo > 7 then 7 else imss.DiasAusentismo end,0) ) end        
        
		--  511 TOTAL PRESTACIONES PATRON        
		--  512 TOTAL PATRON MENSUAL        
        
		/* CUOTA PROPORCIONAL */        
			,'513' as IDCuotaPatrolObrera_11        
		,CuotaPatrolObrera_11 = case  when isnull(Valor,0) > 0 then isnull(Valor,0)          
			when imss.SalarioIntegrado > @Tope3UMA then ((imss.SalarioIntegrado-@Tope3UMA) * imss.CuotaProporcionalObrera) * (imss.DiasCotizados - isnull(imss.DiasIncapacidad,0))  else 0 end        
        
		/* PRESTACIONES EN DINERO OBRERA*/        
		,'514' as IDPrestacionesDineroObrera_12        
		,PrestacionesDineroObrera_12 =   case when isnull(Valor,0) > 0 then isnull(Valor,0)         
		else (imss.SalarioIntegrado * imss.PrestacionesDineroObrera) * (imss.DiasCotizados - isnull(imss.DiasIncapacidad,0)) end        
          
		/* GMPensionados Obrera */        
		,'515' as IDGMPensionadosObrera_13        
		,GMPensionadosObrera_13 =   case when isnull(Valor,0) > 0 then isnull(Valor,0)         
		else (imss.SalarioIntegrado * imss.GMPensionadosObrera) * (imss.DiasCotizados - isnull(imss.DiasIncapacidad,0))end        
        
		/* Invalidez Vida Obrera */        
		,'516' as IDInvalidezVidaObrera_14        
		,InvalidezVidaObrera_14 =   case when isnull(Valor,0) > 0 then isnull(Valor,0)         
		else (imss.SalarioIntegrado * imss.InvalidezVidaObrera) * (imss.DiasCotizados- (isnull(case when imss.DiasAusentismo > 7 then 7 else imss.DiasAusentismo end,0) +isnull(imss.DiasIncapacidad,0))) end        
          
		--  517 IMSS - TOTAL IMSS TRABAJADOR        
        
		/* CesantiaVejezObrera */        
		,'303' as IDCesantiaVejezObrera_15        
		,CesantiaVejezObrera_15 =  case when isnull(Valor,0) > 0 then isnull(Valor,0)         
		else (imss.SalarioIntegrado * imss.CesantiaVejezObrera) * (imss.DiasCotizados- (isnull(case when imss.DiasAusentismo > 7 then 7 else imss.DiasAusentismo end,0) +isnull(imss.DiasIncapacidad,0))) end        
        
		-- 519 TOTAL IMSS MENSUAL        
        
		/* EXCEDENTE OBRERA */          
		,'520' as IDExcedenteObrera_16          
		,ExcedenteObrera_16 = case when isnull(Valor,0) > 0 then isnull(Valor,0)         
				when imss.SalarioIntegrado > @Tope3UMA then ((imss.SalarioIntegrado-@Tope3UMA) * imss.ExcedenteObrera) * (imss.DiasCotizados- isnull(imss.DiasIncapacidad,0)) else 0 end        
		INTO #tempIMSSDetalleTotales        
		from #tempIMSS imss        
              
		--select * from #tempIMSSDetalleTotales
		
		create table #tempIMSSFinal(
			IDEmpleado int
			,IDConcepto varchar(20) collate database_default
			,Total decimal(18,4)
		);      
     
		Insert into #tempIMSSFinal        
			Select IDEmpleado, IDConcepto,Total           
			from        
			(        
			select         
			IDEmpleado        
			,IDCuotaFija_1        
			,CuotaFija_1        
        
			,IDExcedentePatronal_2          
			,ExcedentePatronal_2         
        
			,IDPrestacionesDineroPatronal_3          
			,PrestacionesDineroPatronal_3        
        
			,IDGuarderia_4          
			,Guarderia_4         
        
			,IDPrimaRiesgoTrabajo_5          
			,PrimaRiesgoTrabajo_5        
        
			,IDReservaPensionado_6          
			,ReservaPensionado_6        
        
			,IDInvalidezVidaPatronal_7         
			,InvalidezVidaPatronal_7        
        
			,IDCesantiaVejezPatron_8        
			,CesantiaVejezPatron_8        
        
			,IDSeguroRetiro_9        
			,SeguroRetiro_9        
        
			,IDInfonavit_10        
			,Infonavit_10         
        
			,IDCuotaPatrolObrera_11        
			,CuotaPatrolObrera_11        
        
			,IDPrestacionesDineroObrera_12        
			,PrestacionesDineroObrera_12        
        
			,IDGMPensionadosObrera_13        
			,GMPensionadosObrera_13        
        
			,IDInvalidezVidaObrera_14        
			,InvalidezVidaObrera_14        
        
			,IDCesantiaVejezObrera_15        
			,CesantiaVejezObrera_15        
        
			,IDExcedenteObrera_16        
			,ExcedenteObrera_16        
        
		From  #tempIMSSDetalleTotales        
			) as dt        
			UNPIVOT        
			(        
			IDConcepto FOR IDConceptos in (IDCuotaFija_1,IDExcedentePatronal_2,IDPrestacionesDineroPatronal_3,IDGuarderia_4,IDPrimaRiesgoTrabajo_5        
			,IDReservaPensionado_6,IDInvalidezVidaPatronal_7,IDCesantiaVejezPatron_8,IDSeguroRetiro_9,IDInfonavit_10,IDCuotaPatrolObrera_11        
			,IDPrestacionesDineroObrera_12,IDGMPensionadosObrera_13,IDInvalidezVidaObrera_14,IDCesantiaVejezObrera_15,IDExcedenteObrera_16)        
			) as ids        
			UNPIVOT        
			(        
			Total FOR Totales in (CuotaFija_1,ExcedentePatronal_2,PrestacionesDineroPatronal_3,Guarderia_4,PrimaRiesgoTrabajo_5        
			,ReservaPensionado_6,InvalidezVidaPatronal_7,CesantiaVejezPatron_8,SeguroRetiro_9,Infonavit_10,CuotaPatrolObrera_11        
			,PrestacionesDineroObrera_12,GMPensionadosObrera_13,InvalidezVidaObrera_14,CesantiaVejezObrera_15,ExcedenteObrera_16        
			)        
			) as totals        
			WHERE SUBSTRING(IDConceptos,CHARINDEX('_',IDConceptos) +1,LEN(IDConceptos)) = SUBSTRING(Totales,CHARINDEX('_',Totales) +1,LEN(Totales))        
		
		--select * from #tempIMSSFinal        
		
		Insert into #tempIMSSFinal        
		select IDEmpleado,'507' IDConcepto        
		,Sum(Total) as total        
		 from #tempIMSSFinal      
			where IDConcepto in ('500','501','502','503','504','505','506')        
		group by IDEmpleado        
        
		Insert into #tempIMSSFinal        
		select IDEmpleado,'511' IDConcepto        
		,Sum(Total) as total        
		 from #tempIMSSFinal        
			where IDConcepto in ('508','509','510')        
		group by IDEmpleado        
        
		Insert into #tempIMSSFinal        
		select IDEmpleado,'512' IDConcepto        
		,Sum(Total) as total        
		 from #tempIMSSFinal        
			where IDConcepto in ('507','511')        
		group by IDEmpleado        
      
		IF(@Homologa = '0')      
		BEGIN      
			Insert into #tempIMSSFinal        
			select IDEmpleado,'517' IDConcepto        
			,Sum(Total) as total        
				from #tempIMSSFinal        
				where IDConcepto in ('513','514','515','516') --,'303'        
			group by IDEmpleado        
      
			Insert into #tempIMSSFinal        
			select IDEmpleado,'302' IDConcepto        
			,Sum(Total) as total        
				from #tempIMSSFinal        
				where  IDConcepto in ('517','520') --,        
			group by IDEmpleado        
		END ELSE      
		BEGIN      
			Insert into #tempIMSSFinal        
			select IDEmpleado,'517' IDConcepto        
			,Sum(Total) as total        
				from #tempIMSSFinal        
			where IDConcepto in ('513','514','515','516','303') --,'303'        
			group by IDEmpleado        
      
			Insert into #tempIMSSFinal        
			select IDEmpleado,'302' IDConcepto        
			,Sum(Total) as total        
				from #tempIMSSFinal        
				where       
				IDConcepto in ('517','520') --,        
				group by IDEmpleado        
		END      
      
		Insert into #tempIMSSFinal        
		select IDEmpleado,'519' IDConcepto        
			,Sum(Total) as total        
		from #tempIMSSFinal        
		where IDConcepto in ('302','512')        
		group by IDEmpleado        
        
		--select * from #tempIMSSFinal        
        
		select imf.IDEmpleado,c.IDConcepto,imf.Total,c.Codigo,c.Descripcion        
		into #tempTodosConceptos        
		from #tempIMSSFinal imf        
		join [Nomina].[tblCatConceptos] c with (nolock) on imf.IDConcepto = c.Codigo        
		order by imf.IDEmpleado, imf.IDConcepto        
		

		-- IMSS_PATRONAL
		insert into #tempEmpleadosFinal
		select   e.IDEmpleado			
				--,e.ClaveEmpleado		
				--,e.NombreCompleto		
				--,e.FechaIngreso		
				--,e.Sucursal			
				--,e.Departamento		
				--,e.Puesto				
				--,'' TipoContratacion	
				,e.SalarioDiario		
				,e.SalarioIntegrado
				,'IMSS_PATRONAL'
				,'IMSS PATRONAL'
				,isnull(tc.Total,0) 
		from @dtEmpleados e	
			left join #tempTodosConceptos tc on e.IDEmpleado = tc.IDEmpleado
			
			where tc.Codigo = @IDConceptoIMSSP
	END; -- FIN IMSS PATRONAL
	BEGIN -- COSTO_TOTAL
		insert into #tempEmpleadosFinal
		select   e.IDEmpleado			
				--,e.ClaveEmpleado		
				--,e.NombreCompleto		
				--,e.FechaIngreso		
				--,e.Sucursal			
				--,e.Departamento		
				--,e.Puesto				
				--,'' TipoContratacion	
				,e.SalarioDiario		
				,e.SalarioIntegrado
				,'COSTO_TOTAL'
				,'COSTO TOTAL'
				,isnull(totalPerc.Valor,0)
		from @dtEmpleados e	
			left join (
				select IDEmpleado,Sum(Valor) as Valor
				from #tempEmpleadosFinal 
				where IDConcepto in (select IDConcepto from app.Split(@IDConceptosCostoTotal,','))
				group by IDEmpleado
				) totalPerc on e.IDEmpleado = totalPerc.IDEmpleado 
		
	END;


	--delete ef 
	-- from   #tempEmpleadosFinal  ef 
	--left join #tempCatConceptos c on ef.IDConcepto = c.IDConcepto
	--where c.IDConcepto is null

	select   c.IDEmpleado		
		    ,c.ClaveEmpleado	
		    ,c.NombreCompleto	
		    ,c.FechaIngreso	
		    ,c.Sucursal		
		    ,c.Departamento	
		    ,c.Puesto	
			,'CONFIANZA' TipoContratacion			
			,c.SalarioDiario
			,c.SalarioIntegrado
			,c.IDConcepto
			,c.Concepto
			,dt.Valor
			,c.Orden
	from  (select *
			from  @dtEmpleados
				,#tempCatConceptos) c 
		left join #tempEmpleadosFinal dt on dt.IDConcepto = c.IDConcepto  and c.IDEmpleado = dt.IDEmpleado
	order by c.IDEmpleado,c.Orden
	--select *
	-- from   #tempEmpleadosFinal  ef 
	--right join #tempCatConceptos c on ef.IDConcepto = c.IDConcepto
	--where ef.IDConcepto is null
	
	--select e.ClaveEmpleado,e.NombreCompleto,cc.IDConcepto,cc.Valor,cc.Orden--,  ef.Valor,c.*
	--from @dtEmpleados e
	--	 left join (select c.IDConcepto,ef.Valor,ef.IDEmpleado,c.Orden
	--				from #tempCatConceptos c
	--					left join #tempEmpleadosFinal ef on ef.IDConcepto = c.IDConcepto)
	--					cc on e.IDEmpleado = cc.IDEmpleado
	--order by e.ClaveEmpleado, cc.Orden		

	-- #tempCatConceptos c
	--	cross apply  #tempEmpleadosFinal ef-- on ef.IDConcepto = c.IDConcepto
	--order by ef.ClaveEmpleado, c.Orden

	--select  e.ClaveEmpleado,e.NombreCompleto,c.*-- ef.ClaveEmpleado,ef.NombreCompleto,ef.Valor,c.*
	--from @dtEmpleados e 
	--	left join  #tempEmpleadosFinal  ef  on e.IDEmpleado = ef.IDEmpleado
	--	left join #tempCatConceptos c on ef.IDConcepto = c.IDConcepto
	--order by e.ClaveEmpleado,c.Orden

	-- exec Reportes.spCostoGeneral

	--select * from #tempDiasVigencia
	--select * from #tempEmpleados

	--select * from rh.tblTipoTrabajadorEmpleado	
	--select * from rh.tblEmpleados

	--select *
	--from rh.tblCatClientes c
	--	join nomina.tblCatTipoNomina tno on c.IDCliente = tno.IDCliente


	--select Cliente,count(*)
	--from rh.tblEmpleadosMaster
	--group by Cliente
GO
