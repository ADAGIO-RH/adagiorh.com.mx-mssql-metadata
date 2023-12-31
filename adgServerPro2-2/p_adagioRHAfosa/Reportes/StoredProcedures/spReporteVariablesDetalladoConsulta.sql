USE [p_adagioRHAfosa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spReporteVariablesDetalladoConsulta](        
	@dtFiltros Nomina.dtFiltrosRH readonly        
	,@IDUsuario int        
) as        

DECLARE @Ejercicio int,
		@IDBimestre int,
		--@Aplicar bit = 0,
		@IDRegPatronales int,
		@Mesini int,
		@MesFin int,
		@dtFechas app.dtFechas

	SET FMTONLY OFF  
	DECLARE 
		@dtEmpleadosVigentes RH.dtEmpleados,  
		@dtEmpleadosTrabajables RH.dtEmpleados,  
		@dtEmpleados RH.dtEmpleados,
		@FechaIni Date = getdate(),  
		@Fechafin Date = getdate(),  
		@SalarioMinimo decimal(18,2),  
		@UMA Decimal(18,2),  
		@fechaInicioBimestre date,  
		@fechaFinBimestre date,  
		@diasBimestre int,  
		--@Filtros Nomina.dtFiltrosRH,  
		@DescripcionBimestre Varchar(MAX),
		@IDRegPatronal int

	select top 1 @IDRegPatronal = item from app.Split((select top 1 value from @dtFiltros where Catalogo = 'RegPatronales'),',')
	select top 1 @IDBimestre = item from app.Split((select top 1 value from @dtFiltros where Catalogo = 'Bimestre'),',')
	select top 1 @Ejercicio = item from app.Split((select top 1 value from @dtFiltros where Catalogo = 'Ejercicio'),',')
	--select top 1 @Aplicar = CASE WHEN item = 'true' then 1 else 0 end from app.Split((select top 1 value from @dtFiltros where Catalogo = 'Afectar'),',')
	select top 1 @Mesini = item from app.Split((select top 1 value from @dtFiltros where Catalogo = 'IDMes'),',')
	select top 1 @MesFin = item from app.Split((select top 1 value from @dtFiltros where Catalogo = 'IDMesFin'),',')

	select @IDBimestre = IdBimestre FROM Nomina.tblCatBimestres where meses = CONCAT(@Mesini, ',', @MesFin)

	
	select @fechaInicioBimestre = min(DATEADD(month,IDMes-1,DATEADD(year,@Ejercicio-1900,0)))   
		, @fechaFinBimestre=MAX(DATEADD(day,-1,DATEADD(month,IDMes,DATEADD(year,@Ejercicio-1900,0))))   
	from Nomina.tblCatMeses with (nolock)  
	where cast(IDMes as varchar) in (select item from app.Split( (select top 1 meses from Nomina.tblCatBimestres with (nolock) where IDBimestre = @IDBimestre),','))  
   
	set @diasBimestre = DATEDIFF(DAY, @fechaInicioBimestre, @fechaFinBimestre) + 1 
  
	select @DescripcionBimestre = Descripcion from Nomina.tblCatBimestres with (nolock) where IDBimestre = @IDBimestre  
  
	select top 1 
		@SalarioMinimo = SalarioMinimo,  
		@UMA = UMA   
	from Nomina.tblSalariosMinimos with (nolock)  
	where Year(Fecha) = @Ejercicio  
	order by Fecha desc  
	
	 insert @dtFechas
   exec [App].[spListaFechas]  @fechaInicioBimestre, @fechaFinBimestre

	if OBJECT_ID('tempdb..#tempData') is not null drop table #tempData  
	if OBJECT_ID('tempdb..#tempcalc') is not null drop table #tempcalc  
	if OBJECT_ID('tempdb..#tempDone') is not null drop table #tempDone  
	if OBJECT_ID('tempdb..#temp') is not null drop table #temp
	if OBJECT_ID('tempdb..#tempMovPrevios') is not null drop table #tempMovPrevios
	if OBJECT_ID('tempdb..#tempMovAlta') is not null drop table #tempMovAlta


	if not exists( select top 1 1 from @dtFiltros where Catalogo = 'RegPatronales')  
	BEGIN  
		RAISERROR('Debe seleccionar un Registro Patronal',16,1);  
		RETURN;  
	END  

	if exists( select top 1 1 from @dtFiltros where Catalogo = 'RegPatronales' and Value = '')  
	BEGIN  
		RAISERROR('Debe seleccionar un Registro Patronal',16,1);  
		RETURN;  
	END  


	Insert into @dtEmpleadosVigentes  
	Exec RH.spBuscarEmpleados 
		@FechaIni = @fechaFinBimestre  
		,@Fechafin = @fechaFinBimestre  
		,@dtFiltros= @dtFiltros   
		,@IDUsuario = @IDUsuario

		
	

	insert into @dtEmpleadosTrabajables  
	select DISTINCT ev.*   
	from @dtEmpleadosVigentes ev  
		left join IMSS.tblMovAfiliatorios mov with (nolock)  
			on ev.IDEmpleado = mov.IDEmpleado  
		--and mov.Fecha = DATEADD(Day,1,@fechaFinBimestre)  
		left join Asistencia.tblIncidenciaEmpleado IE
			on Ev.idEmpleado = IE.idempleado
			and IE.IDIncidencia = 'I'
			and IE.fecha = DATEADD(Day,1,@fechaFinBimestre)
	where  ie.IDIncidenciaEmpleado is null
	
	 select m.* ,ROW_NUMBER()OVER(partition by m.idempleado order by m.fecha desc) RN
	  into #tempMovAlta 
	  from @dtEmpleadosTrabajables E
		inner join IMSS.tblMovAfiliatorios M
		 on E.IDEmpleado = M.IDEmpleado
		 and M.IDTipoMovimiento in (1,3) --Alta o Reingreso
		 and m.Fecha <= @fechaFinBimestre
		 and m.IDRegPatronal = @IDRegPatronal
	
		 delete #tempMovAlta
		 where RN > 1

		-- select * from #tempMovAlta where IDEmpleado = 251 --return

		 update  e  set e.FechaAntiguedad = CASE WHEN e.FechaAntiguedad <= @fechaFinBimestre then e.FechaAntiguedad ELSE  alta.Fecha END
		 from @dtEmpleadosTrabajables e
			inner join #tempMovAlta alta
			on alta.IDEmpleado = e.IDEmpleado
		--where ISNULL(alta.respetarAntiguedad,0) = 0 

		--select FechaAntiguedad from @dtEmpleadosTrabajables where IDEmpleado = 251 return
 
	  select m.* ,ROW_NUMBER()OVER(partition by m.idempleado order by m.fecha desc) RN
	   into #tempMovPrevios 
	  from @dtEmpleadosTrabajables E
		inner join IMSS.tblMovAfiliatorios M
		 on E.IDEmpleado = M.IDEmpleado
		 and M.IDTipoMovimiento in (Select  IDTipoMovimiento from IMSS.tblCatTipoMovimientos where Codigo <> 'B')
		and m.Fecha >= e.FechaAntiguedad
		 and m.Fecha <= @fechaFinBimestre
		 and m.IDRegPatronal = @IDRegPatronal
	
		 delete #tempMovPrevios
		 where RN > 1

		 
		-- select *
		-- from @dtEmpleadosTrabajables e  
		--cross join Nomina.tblConfigReporteVariablesBimestrales vb with (nolock)
		--left join #tempMovPrevios temp
		--		  on temp.IDEmpleado=e.IDEmpleado
		--left join RH.tblCatTiposPrestacionesDetalle ctpd 
		--			on e.IDTipoPrestacion = ctpd.IDTipoPrestacion	
		--				--and ctpd.Antiguedad =cast( Asistencia.fnBuscarAniosDiferencia(Empleados.FechaAntiguedad,@FechaFinPago) as int)
		--				and ctpd.Antiguedad =CEILING([Asistencia].[fnBuscarAniosDiferencia](e.FechaAntiguedad,temp.Fecha)) 
		--return
	--select * from @dtEmpleadosTrabajables return
     --SELECT * FROM #tempMovPrevios where IDEmpleado = 251
     --return
	
	select e.IDEmpleado  
		,e.ClaveEmpleado  
		,e.NOMBRECOMPLETO  
		,e.Departamento  
		,e.Sucursal  
		,e.Puesto  
		,e.IDRegPatronal  
		,e.RegPatronal  
		,CAST(e.SalarioDiario as decimal(10,2))  SalarioDiario
		,CAST(e.SalarioVariable  as decimal(10,2)) SalarioVariable
		,CAST(e.SalarioIntegrado as decimal(10,2))  SalarioIntegrado
		,CAST(temp.SalarioVariable as decimal(10,2)) SalarioVariableAntiguo
		,(select min(Factor)   
			from [RH].[tblCatTiposPrestacionesDetalle] with (nolock)  
			where IDTipoPrestacion = e.IDTipoPrestacion   
			and Antiguedad > CASE WHEN (DATEDIFF(day, e.FechaAntiguedad,@FechaIni)/365.00) = 0 THEN 1 else (DATEDIFF(day, e.FechaAntiguedad,@FechaIni)/365.00) end) Factor 
		--, CAST(isnull(e.SalarioIntegrado,0)/ isnull(e.SalarioDiario,0) as decimal(18,4)) FactorAntiguo	
		,ctpd.Factor AS FactorAntiguo
		,(select min(Antiguedad)   
			from [RH].[tblCatTiposPrestacionesDetalle] with (nolock)  
			where IDTipoPrestacion = e.IDTipoPrestacion   
			and Antiguedad > CASE WHEN (DATEDIFF(day, e.FechaAntiguedad,@FechaIni)/365.00) = 0 THEN 1 else (DATEDIFF(day, e.FechaAntiguedad,@FechaIni)/365.00) end) aniosPrestacion
		,e.FechaAntiguedad
		,vb.*  
		,isnull((select CAST(SUM(Importetotal1) as decimal(18,2))   
				from Nomina.tblDetallePeriodo dp with (nolock)    
					inner join Nomina.tblCatPeriodos p with (nolock)    
					on dp.IDPeriodo = p.IDPeriodo  
						and p.Ejercicio = @Ejercicio  
						and p.IDMes in (select item from app.Split( (select top 1 meses from Nomina.tblCatBimestres with (nolock)   where IDBimestre = @IDBimestre),','))  
						and p.Cerrado = 1  
						and (p.General = 1 or p.Finiquito = 1)
					inner join Nomina.tblHistorialesEmpleadosPeriodos HEP with(Nolock)
						on hep.IDEmpleado = e.IDEmpleado
						and hep.IDPeriodo = p.IDPeriodo
						and hep.IDRegPatronal = @IDRegPatronal
				where dp.IDEmpleado = e.IDEmpleado and dp.IDConcepto in (select item from app.Split(vb.ConceptosValesDespensa,','))),0) as Vales  
		,isnull((select CAST( SUM(Importetotal1)as decimal(18,2))      
				from Nomina.tblDetallePeriodo dp with (nolock)  
					inner join Nomina.tblCatPeriodos p with (nolock)   
					on dp.IDPeriodo = p.IDPeriodo  
					and p.Ejercicio = @Ejercicio  
					and p.IDMes in (select item from app.Split( (select top 1 meses from Nomina.tblCatBimestres with (nolock) where IDBimestre = @IDBimestre),','))  
					and p.Cerrado = 1  
					and (p.General = 1 or p.Finiquito = 1)
					inner join Nomina.tblHistorialesEmpleadosPeriodos HEP with(Nolock)
						on hep.IDEmpleado = e.IDEmpleado
						and hep.IDPeriodo = p.IDPeriodo
						and hep.IDRegPatronal = @IDRegPatronal
				where dp.IDEmpleado = e.IDEmpleado and dp.IDConcepto in (select item from app.Split(vb.ConceptosPremioPuntualidad,',')) ),0) as PremioPuntualidad  
		,isnull((select CAST(SUM(Importetotal1) as decimal(18,2))     
				from Nomina.tblDetallePeriodo dp with (nolock)  
					inner join Nomina.tblCatPeriodos p with (nolock)   
						on dp.IDPeriodo = p.IDPeriodo  
							and p.Ejercicio = @Ejercicio  
							and p.IDMes in (select item from app.Split( (select top 1 meses from Nomina.tblCatBimestres with (nolock) where IDBimestre = @IDBimestre),','))  
							and p.Cerrado = 1 
							and (p.General = 1 or p.Finiquito = 1)
						inner join Nomina.tblHistorialesEmpleadosPeriodos HEP with(Nolock)
						on hep.IDEmpleado = e.IDEmpleado
						and hep.IDPeriodo = p.IDPeriodo
						and hep.IDRegPatronal = @IDRegPatronal
				where dp.IDEmpleado = e.IDEmpleado and dp.IDConcepto in (select item from app.Split(vb.ConceptosPremioAsistencia,',')) ),0) as PremioAsistencia  
		,CASE WHEN isnull((select CAST(SUM(dp.ImporteTotal1) as decimal(18,2))     
				from Nomina.tblDetallePeriodo dp with (nolock)  
					inner join Nomina.tblCatPeriodos p with (nolock)   
						on dp.IDPeriodo = p.IDPeriodo  
							and p.Ejercicio = @Ejercicio  
							and p.IDMes in (select item from app.Split( (select top 1 meses from Nomina.tblCatBimestres with (nolock) where IDBimestre = @IDBimestre),','))  
							and p.Cerrado = 1 
							and (p.General = 1 or p.Finiquito = 1)
						inner join Nomina.tblHistorialesEmpleadosPeriodos HEP with(Nolock)
						on hep.IDEmpleado = e.IDEmpleado
						and hep.IDPeriodo = p.IDPeriodo
						and hep.IDRegPatronal = @IDRegPatronal
				where dp.IDEmpleado = e.IDEmpleado and dp.IDConcepto in (select item from app.Split(vb.ConceptosHorasExtrasDobles,',')) ),0) <= ((e.SalarioDiario /  8.0)*2.0)*72.0
				THEN 0.00
				ELSE isnull((select CAST(SUM(ImporteTotal1) as decimal(18,2))     
				from Nomina.tblDetallePeriodo dp with (nolock)  
					inner join Nomina.tblCatPeriodos p with (nolock)   
						on dp.IDPeriodo = p.IDPeriodo  
							and p.Ejercicio = @Ejercicio  
							and p.IDMes in (select item from app.Split( (select top 1 meses from Nomina.tblCatBimestres with (nolock) where IDBimestre = @IDBimestre),','))  
							and p.Cerrado = 1 
							and (p.General = 1 or p.Finiquito = 1)
						inner join Nomina.tblHistorialesEmpleadosPeriodos HEP with(Nolock)
						on hep.IDEmpleado = e.IDEmpleado
						and hep.IDPeriodo = p.IDPeriodo
						and hep.IDRegPatronal = @IDRegPatronal
				where dp.IDEmpleado = e.IDEmpleado and dp.IDConcepto in (select item from app.Split(vb.ConceptosHorasExtrasDobles,',')) ),0) - ((e.SalarioDiario /  8.0)*2.0)*72.0
				END
				as HorasExtrasDobles  
		,isnull((select CAST(SUM(Importetotal1) as decimal(18,2))     
				from Nomina.tblDetallePeriodo dp with (nolock)  
					inner join Nomina.tblCatPeriodos p with (nolock)   
						on dp.IDPeriodo = p.IDPeriodo  
							and p.Ejercicio = @Ejercicio  
							and p.IDMes in (select item from app.Split( (select top 1 meses from Nomina.tblCatBimestres with (nolock) where IDBimestre = @IDBimestre),','))  
							and p.Cerrado = 1  
							and (p.General = 1 or p.Finiquito = 1)
						inner join Nomina.tblHistorialesEmpleadosPeriodos HEP with(Nolock)
						on hep.IDEmpleado = e.IDEmpleado
						and hep.IDPeriodo = p.IDPeriodo
						and hep.IDRegPatronal = @IDRegPatronal
				where dp.IDEmpleado = e.IDEmpleado and dp.IDConcepto in (select item from app.Split(vb.ConceptosIntegrablesVariables,',')) ),0) as IntegrablesVariables  
		,isnull((select CAST(SUM(Importetotal1)as decimal(18,2))      
				from Nomina.tblDetallePeriodo dp with (nolock)  
				inner join Nomina.tblCatPeriodos p with (nolock)   
					on dp.IDPeriodo = p.IDPeriodo  
						and p.Ejercicio = @Ejercicio  
						and p.IDMes in (select item from app.Split( (select top 1 meses from Nomina.tblCatBimestres with (nolock) where IDBimestre = @IDBimestre),','))  
						and p.Cerrado = 1 
						and (p.General = 1 or p.Finiquito = 1)
					inner join Nomina.tblHistorialesEmpleadosPeriodos HEP with(Nolock)
						on hep.IDEmpleado = e.IDEmpleado
						and hep.IDPeriodo = p.IDPeriodo
						and hep.IDRegPatronal = @IDRegPatronal
				where dp.IDEmpleado = e.IDEmpleado and dp.IDConcepto in (select item from app.Split(vb.ConceptosDias,',')) ),1) as Dias  
	into #tempData  
	from @dtEmpleadosTrabajables e  
	cross join Nomina.tblConfigReporteVariablesBimestrales vb with (nolock)
    left join #tempMovPrevios temp
              on temp.IDEmpleado=e.IDEmpleado
    left join RH.tblCatTiposPrestacionesDetalle ctpd 
				on e.IDTipoPrestacion = ctpd.IDTipoPrestacion	
					--and ctpd.Antiguedad =cast( Asistencia.fnBuscarAniosDiferencia(Empleados.FechaAntiguedad,@FechaFinPago) as int)
                    and ctpd.Antiguedad =CEILING([Asistencia].[fnBuscarAniosDiferencia](e.FechaAntiguedad,temp.Fecha)) 

	--select * from #tempData return
	--return

	select 
		IDEmpleado  
		,ClaveEmpleado  
		,NOMBRECOMPLETO  
		,Departamento  
		,Sucursal  
		,Puesto  
		,IDRegPatronal  
		,RegPatronal  
		,Factor 
		,FactorAntiguo
		,SalarioVariableAntiguo
		,aniosPrestacion
		,SalarioDiario  
		,FechaAntiguedad
		,case when Vales > ((@UMA * case when CriterioDias = 0 then @diasBimestre else @diasBimestre end)*0.40) then Vales - ((@UMA * case when CriterioDias = 0 then @diasBimestre else @diasBimestre end)*0.40)  
			else 0 end as ConceptosValesDespensa  
  
		,case when PremioPuntualidad > (( SalarioDiario * case when CriterioDias = 0 then Dias else @diasBimestre end)*0.10) then PremioPuntualidad - (( SalarioDiario * case when CriterioDias = 0 then Dias else @diasBimestre end)*0.10)  
			else 0 end as ConceptosPremioPuntualidad  
    
		,case when PremioAsistencia > (( SalarioDiario * case when CriterioDias = 0 then Dias else @diasBimestre end)*0.10) then PremioAsistencia - (( SalarioDiario * case when CriterioDias = 0 then Dias else @diasBimestre end)*0.10)  
			else 0 end as ConceptosPremioAsistencia  
  
		,HorasExtrasDobles  
		,IntegrablesVariables  
		,ConceptosDias  
		,IDRazonMovimiento  
		,CriterioDias  
		,Dias  
	into #tempcalc  
	from #tempData  
  
         --select * from #tempcalc 
         --RETURN
  
	select   
		c.IDEmpleado  
		,c.ClaveEmpleado  
		,c.NOMBRECOMPLETO 
		,m.IMSS
		,c.Departamento  
		,c.Sucursal  
		,c.Puesto  
		,c.IDRegPatronal  
		,c.RegPatronal 
		,c.FechaAntiguedad
		,CASE WHEN (((isnull(c.ConceptosValesDespensa,0)+ isnull(c.ConceptosPremioPuntualidad,0)+   
			isnull(c.ConceptosPremioAsistencia,0)+ isnull(c.HorasExtrasDobles,0)+ isnull(c.IntegrablesVariables,0))  
			)) = 0  then 'NO INTEGRA PARA VARIABLE' else cast(c.Factor as varchar) END Factor  
        ,VariableCambio = CASE WHEN (((isnull(c.ConceptosValesDespensa,0)+ isnull(c.ConceptosPremioPuntualidad,0)+   
			isnull(c.ConceptosPremioAsistencia,0)+ isnull(c.HorasExtrasDobles,0)+ isnull(c.IntegrablesVariables,0))  
			))/CASE WHEN CriterioDias=0 THEN Dias ELSE @diasBimestre END = isnull(C.SalarioVariableAntiguo,0)  then 0 else 1 END
        ,c.Factor as NewFactor
		,c.FactorAntiguo
		,FactorCambio = CASE WHEN c.Factor <>c.FactorAntiguo THEN 1 ELSE 0 END
		,c.aniosPrestacion
		,c.SalarioDiario  
		,0 as AFECTAR
		, case when ((isnull(c.ConceptosValesDespensa,0)+ isnull(c.ConceptosPremioPuntualidad,0)+   
			isnull(c.ConceptosPremioAsistencia,0)+ isnull(c.HorasExtrasDobles,0)+ isnull(c.IntegrablesVariables,0))) = 0 then 0 else  
    
			((isnull(c.ConceptosValesDespensa,0)+ isnull(c.ConceptosPremioPuntualidad,0)+   
			isnull(c.ConceptosPremioAsistencia,0)+ isnull(c.HorasExtrasDobles,0)+ isnull(c.IntegrablesVariables,0))  
			/ case when c.CriterioDias = 0 and c.Dias > 0 then c.Dias else @diasBimestre end) END SalarioVariable  
  
		,case when c.CriterioDias = 0 then c.Dias else @diasBimestre end as Dias  
   
		,case when ((c.SalarioDiario*c.Factor) + 
			case when ((isnull(c.ConceptosValesDespensa,0)+ isnull(c.ConceptosPremioPuntualidad,0)+isnull(c.ConceptosPremioAsistencia,0)+ isnull(c.HorasExtrasDobles,0)+ isnull(c.IntegrablesVariables,0))) = 0 then 0 
			else  
    
			((isnull(c.ConceptosValesDespensa,0)+ isnull(c.ConceptosPremioPuntualidad,0)+   
			isnull(c.ConceptosPremioAsistencia,0)+ isnull(c.HorasExtrasDobles,0)+ isnull(c.IntegrablesVariables,0))  
			/case when c.CriterioDias = 0 and c.Dias > 0 then c.Dias else @diasBimestre end) 
   
		END ) >= @UMA * 25 then (@UMA * 25)
		ELSE
			(c.SalarioDiario*c.Factor) + 
			case when ((isnull(c.ConceptosValesDespensa,0)+ isnull(c.ConceptosPremioPuntualidad,0)+isnull(c.ConceptosPremioAsistencia,0)+ isnull(c.HorasExtrasDobles,0)+ isnull(c.IntegrablesVariables,0))) = 0 then 0 
			else  
    
			((isnull(c.ConceptosValesDespensa,0)+ isnull(c.ConceptosPremioPuntualidad,0)+   
			isnull(c.ConceptosPremioAsistencia,0)+ isnull(c.HorasExtrasDobles,0)+ isnull(c.IntegrablesVariables,0))  
			/case when c.CriterioDias = 0 and c.Dias > 0 then c.Dias else @diasBimestre end) 
   
		END 
		END SalarioIntegrado  
  
		,(Select top 1 isnull(SalarioDiarioReal,0.00) from IMSS.tblMovAfiliatorios m inner join IMSS.tblCatTipoMovimientos tm on tm.IDTipoMovimiento = m.IDTipoMovimiento where IDEmpleado = c.IDEmpleado and tm.Codigo <> 'B' order by Fecha desc ) as SalarioDiarioReal
		,c.IDRazonMovimiento  
		,(Select top 1 Descripcion from IMSS.tblCatRazonesMovAfiliatorios where IDRazonMovimiento = c.IDRazonMovimiento) RazonMovimiento  
		, DATEADD(Day,1,@fechaFinBimestre) as DiaAplicacion  
		,c.ConceptosPremioAsistencia as CantidadPremioAsistencia
		,c.ConceptosPremioPuntualidad as CantidadPremioPuntualidad
		,c.ConceptosValesDespensa as CantidadValesDespensa
		,c.IntegrablesVariables as CantidadIntegrablesVariables
		,c.HorasExtrasDobles as CantidadHorasExtrasDobles
	into #tempDone  
	from #tempcalc c  
	inner join RH.tblEmpleadosMaster m with(nolock)
		on c.IDEmpleado = m.IDEmpleado

	--select * from #tempDone where IDEmpleado = 23575 return
  
  update  #tempDone  
	set AFECTAR = CASE WHEN FactorCambio = 1 or VariableCambio = 1 THEN 1 else 0 end

	 --select * from #tempDone
	 --return
  
  
  select distinct
			d.DiaAplicacion  
			,d.IDEmpleado 
			,d.ClaveEmpleado
			,d.NOMBRECOMPLETO as NombreCompleto
			,(Select top 1 IDTipoMovimiento from IMSS.tblCatTipoMovimientos where Codigo = 'M') IDTipoMovimiento 
			,d.IDRazonMovimiento  
			,CAST(d.SalarioDiario as decimal(10,2))  SalarioDiario
			,CAST(d.SalarioIntegrado as decimal(10,2)) SalarioIntegrado  
			,CAST(d.SalarioVariable as decimal(10,2))   SalarioVariable
			,CAST(d.SalarioDiarioReal as decimal(10,2))  SalarioDiarioReal
			,d.IDRegPatronal  
			,ROW_NUMBER()OVER(Partition by d.DiaAplicacion,d.IDEmpleado order by d.IDEmpleado asc)RN
			,CAST(p.SalarioDiario as decimal(10,2)) viejoSalarioDiario
			,CAST(p.SalarioVariable as decimal(10,2)) viejoSalariovariable
			,CAST(p.SalarioIntegrado as decimal(10,2)) viejoSalariointegrado
			,d.AFECTAR 
			,d.VariableCambio
			,d.FactorCambio
			,d.NewFactor
			,d.FactorAntiguo
			,p.Fecha FechaUltimoMovimiento
			,d.Dias
			,d.CantidadValesDespensa as VALESDEDESPENSA_135_Integrable
			,d.CantidadPremioAsistencia as PREMIODEASISTENCIA_141_Integrable
			,d.CantidadPremioPuntualidad as PREMIODEPUNTUALIDA_140_Integrable
			,d.CantidadIntegrablesVariables
			,d.CantidadHorasExtrasDobles as TIEMPOEXTRA_110_Integrable
		into #temp
		from #tempDone d  
			left join #tempMovPrevios p
			 on p.IDEmpleado = d.IDEmpleado
		where ((cast(d.SalarioDiario as decimal(10,2)) <> cast(ISNULL(p.SalarioDiario, 0) as decimal(10,2)) ) 
					or (CAST(d.SalarioVariable as decimal(10,2)) <> CAST(ISNULL( p.SalarioVariable , 0 ) as decimal(10,2)) ) 
					or (CAST(d.SalarioIntegrado as decimal(10,2)) <> CAST(ISNULL(p.SalarioIntegrado,0) as decimal(10,2))))
			 and (d.AFECTAR = 1)

		--select * from #temp where IDEmpleado = 23575 return
		delete #temp
		where RN > 1

		
	
	if object_id('tempdb..#tempConceptos')	is not null drop table #tempConceptos 
	if object_id('tempdb..#tempDataArmada')		is not null drop table #tempDataArmada
	if object_id('tempdb..#tempDetallePeriodo')		is not null drop table #tempDetallePeriodo

	

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
			ccc.*,
			tc.Descripcion as TipoConcepto,
			ccc.OrdenCalculo as orden
		from Nomina.tblCatConceptos ccc with (nolock) 
			inner join Nomina.tblCatTipoConcepto tc with (nolock) on tc.IDTipoConcepto = ccc.IDTipoConcepto
			inner join Nomina.tblConfigReporteVariablesBimestrales crr with (nolock)  on ccc.IDConcepto in (select item from app.Split(isnull(crr.ConceptosValesDespensa,'') +','+isnull(crr.ConceptosPremioPuntualidad,'')+','+isnull(crr.ConceptosPremioAsistencia,'')+','+isnull(crr.ConceptosIntegrablesVariables,'')+','+isnull(crr.ConceptosHorasExtrasDobles,''),','))
		) c 

		--insert into #tempConceptos (idconcepto, Concepto, OrdenColumn, OrdenCalculo,IDTipoConcepto,TipoConcepto) values (3000,'VALESDEDESPENSA_135_Integrable',1,36,1,'PERCEPCION')
		--insert into #tempConceptos (idconcepto, Concepto, OrdenColumn, OrdenCalculo,IDTipoConcepto,TipoConcepto) values (3001,'PREMIODEASISTENCIA_141_Integrable',1,38,1,'PERCEPCION')
		--insert into #tempConceptos (idconcepto, Concepto, OrdenColumn, OrdenCalculo,IDTipoConcepto,TipoConcepto) values (3002,'PREMIODEPUNTUALIDA_140_Integrable',1,37,1,'PERCEPCION')
		--insert into #tempConceptos (idconcepto, Concepto, OrdenColumn, OrdenCalculo,IDTipoConcepto,TipoConcepto) values (3003,'TIEMPOEXTRA_110_Integrable',1,18,1,'PERCEPCION')



	Select
		e.ClaveEmpleado as CLAVE,
		e.NOMBRECOMPLETO as NOMBRE,
		c.IDConcepto,
		c.Concepto,
		e.dias,
		e.viejoSalariovariable as 'Viejo S.V.',
		e.SalarioVariable as 'Nuevo S.V.',
		e.viejoSalarioDiario as 'Viejo S.D',
		e.SalarioDiario as 'Nuevo S.D.',
		e.viejoSalariointegrado as 'Viejo S.I.',
		e.SalarioIntegrado as 'Nuevo S.I.',
		SUM(isnull(dp.ImporteTotal1,0)) as ImporteTotal1,
		CAST(0.0 as decimal(18,2)) as BASE,
		e.FactorAntiguo as 'Ultimo Factor',
		e.NewFactor as 'Nuevo Factor'
		,e.VALESDEDESPENSA_135_Integrable
		,e.PREMIODEASISTENCIA_141_Integrable
		,e.PREMIODEPUNTUALIDA_140_Integrable
		,e.TIEMPOEXTRA_110_Integrable
	into #tempDataArmada
	from Nomina.tblDetallePeriodo dp with (nolock)  
	inner join Nomina.tblCatPeriodos p with (nolock) 
		on dp.IDPeriodo = p.IDPeriodo 
			and p.Ejercicio = @Ejercicio 
			and p.IDMes in (select item from app.Split( (select top 1 meses from Nomina.tblCatBimestres with (nolock) where IDBimestre = @IDBimestre),','))
			and p.Cerrado = 1  
			and (p.General = 1 or p.Finiquito = 1)
		inner join Nomina.tblHistorialesEmpleadosPeriodos HEP with(Nolock)
						on hep.IDEmpleado = dp.IDEmpleado
						and hep.IDPeriodo = p.IDPeriodo
						and hep.IDRegPatronal = @IDRegPatronal
		inner join #tempConceptos c with(nolock)
			on c.IDConcepto = dp.IDConcepto
		RIGHT join #temp e
			on dp.IDEmpleado = e.IDEmpleado
	 Group by e.ClaveEmpleado,e.NOMBRECOMPLETO,c.Concepto,e.dias,e.SalarioVariable,e.SalarioVariable,e.NewFactor,e.SalarioDiario,c.IDConcepto,e.SalarioIntegrado, e.viejoSalarioDiario, e.viejoSalariointegrado, e.viejoSalariovariable, e.FactorAntiguo, VALESDEDESPENSA_135_Integrable,e.PREMIODEASISTENCIA_141_Integrable,e.PREMIODEPUNTUALIDA_140_Integrable,e.TIEMPOEXTRA_110_Integrable

	 --select * from #tempDataArmada order by CLAVE return

	UPDATE t 
	 set t.BASE = (SELECT SUM(isnull(ImporteTotal1,0)) from #tempDataArmada a where a.Clave = t.Clave)
	from #tempDataArmada t


	

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

	

	
	set @query1 = 'SELECT CLAVE,NOMBRE, ' + @cols + ', VALESDEDESPENSA_135_Integrable
						, PREMIODEASISTENCIA_141_Integrable
						, PREMIODEPUNTUALIDA_140_Integrable
						, TIEMPOEXTRA_110_Integrable
						, BASE
						, Dias as [DIAS]
						, [Viejo S.V.] 
						, [Nuevo S.V.]
						, [Viejo S.D]
						, [Nuevo S.D.]
						, [Viejo S.I.]
						, [Nuevo S.I.]
						, [Ultimo Factor]
						, [Nuevo Factor] from 
				(
					select CLAVE
						, Nombre
						, Concepto
						, Dias
						, VALESDEDESPENSA_135_Integrable
						, PREMIODEASISTENCIA_141_Integrable
						, PREMIODEPUNTUALIDA_140_Integrable
						, TIEMPOEXTRA_110_Integrable
						, BASE
						, [Viejo S.V.] 
						, [Nuevo S.V.]
						, [Viejo S.D]
						, [Nuevo S.D.]
						, [Viejo S.I.]
						, [Nuevo S.I.]
						, [Ultimo Factor]
						, [Nuevo Factor]
						, isnull(ImporteTotal1,0) as ImporteTotal1
					from #tempDataArmada
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
GO
