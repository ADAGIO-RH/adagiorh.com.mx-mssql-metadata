USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: ?
** Autor			: ?
** Email			: ?
** FechaCreacion	: ?
** Paremetros		:  
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2024-01-11		    Jose Vargas		Se añade el sp [IMSS].[spCalcularFechaAntiguedadMovAfiliatorios], despues de realizar modificaciones a la tabla de "IMSS.tblMovAfiliatorios" 
                                    para realizar el calculo de "FechaAntiguedad" y "IDTipoPrestacion"
 ***************************************************************************************************/
CREATE PROCEDURE [Reportes].[spReporteVariablesDetallado_Excel](        
	@dtFiltros Nomina.dtFiltrosRH readonly        
	,@IDUsuario int        
) as        

DECLARE @Ejercicio int,
		@IDBimestre int,
		@Aplicar bit = 0,
		@IDRegPatronales int

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
	select top 1 @Aplicar = CASE WHEN item = 'true' then 1 else 0 end from app.Split((select top 1 value from @dtFiltros where Catalogo = 'Afectar'),',')

	
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

	if OBJECT_ID('tempdb..#tempData') is not null drop table #tempData  
	if OBJECT_ID('tempdb..#tempcalc') is not null drop table #tempcalc  
	if OBJECT_ID('tempdb..#tempDone') is not null drop table #tempDone  
	if OBJECT_ID('tempdb..#temp') is not null drop table #temp
	if OBJECT_ID('tempdb..#tempMovPrevios') is not null drop table #tempMovPrevios

	if OBJECT_ID('tempdb..#temp2') is not null drop table #temp2



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
	


	--select * from @dtEmpleados order by ClaveEmpleado

	insert into @dtEmpleadosTrabajables  
	select ev.*   
	from @dtEmpleadosVigentes ev  
		left join IMSS.tblMovAfiliatorios mov with (nolock)  
			on ev.IDEmpleado = mov.IDEmpleado  
		and mov.Fecha = DATEADD(Day,1,@fechaFinBimestre)  
		left join Asistencia.tblIncidenciaEmpleado IE
			on Ev.idEmpleado = IE.idempleado
			and IE.IDIncidencia = 'I'
			and IE.fecha = DATEADD(Day,1,@fechaFinBimestre)
	where mov.IDMovAfiliatorio is null   
	and ie.IDIncidenciaEmpleado is null

 --select * from @dtEmpleadosTrabajables
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
		,(select top 1 Factor   
			from [RH].[tblCatTiposPrestacionesDetalle] with (nolock)  
			where IDTipoPrestacion = e.IDTipoPrestacion   
			and Antiguedad >= CASE WHEN DATEDIFF(YEAR, e.FechaAntiguedad,@FechaIni) = 0 THEN 1 else DATEDIFF(YEAR, e.FechaAntiguedad,@FechaIni)+1 end) Factor 
		, CAST(isnull(e.SalarioIntegrado,0)/ isnull(e.SalarioDiario,0) as decimal(18,5)) FactorAntiguo	
		,(select top 1 Antiguedad   
			from [RH].[tblCatTiposPrestacionesDetalle] with (nolock)  
			where IDTipoPrestacion = e.IDTipoPrestacion   
			and Antiguedad >= CASE WHEN DATEDIFF(YEAR, e.FechaAntiguedad,@FechaIni) = 0 THEN 1 else DATEDIFF(YEAR, e.FechaAntiguedad,@FechaIni)+1 end) aniosPrestacion
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
		,isnull((select CAST(SUM(ImporteGravado) as decimal(18,2))     
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
				where dp.IDEmpleado = e.IDEmpleado and dp.IDConcepto in (select item from app.Split(vb.ConceptosHorasExtrasDobles,',')) ),0) as HorasExtrasDobles  
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
				where dp.IDEmpleado = e.IDEmpleado and dp.IDConcepto in (select item from app.Split(vb.ConceptosDias,',')) ),0) as Dias  
	into #tempData  
	from @dtEmpleadosTrabajables e  
	cross join Nomina.tblConfigReporteVariablesBimestrales vb with (nolock)   
  
  --select * from #tempData order by ClaveEmpleado


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
		,aniosPrestacion
		,SalarioDiario  
		,FechaAntiguedad
		,case when Vales > ((@UMA * case when CriterioDias = 0 then @diasBimestre else @diasBimestre end)*0.40) then Vales - ((@UMA * case when CriterioDias = 0 then @diasBimestre else @diasBimestre end)*0.40)  
			else 0 end as ConceptosValesDespensa  
  
		,case when PremioPuntualidad > (( SalarioIntegrado * case when CriterioDias = 0 then Dias else @diasBimestre end)*0.10) then PremioPuntualidad - (( SalarioIntegrado * case when CriterioDias = 0 then Dias else @diasBimestre end)*0.10)  
			else 0 end as ConceptosPremioPuntualidad  
    
		,case when PremioAsistencia > (( SalarioIntegrado * case when CriterioDias = 0 then Dias else @diasBimestre end)*0.10) then PremioAsistencia - (( SalarioIntegrado * case when CriterioDias = 0 then Dias else @diasBimestre end)*0.10)  
			else 0 end as ConceptosPremioAsistencia  
  
		,HorasExtrasDobles  
		,IntegrablesVariables  
		,ConceptosDias  
		,IDRazonMovimiento  
		,CriterioDias  
		,Dias  
	into #tempcalc  
	from #tempData  
  
-- select * from #tempcalc  order by ClaveEmpleado
  
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
			)) = 0  then 0 else 1 END
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
  

  update  #tempDone  
	set AFECTAR = CASE WHEN FactorCambio = 1 or VariableCambio = 1 THEN 1 else 0 end
    
  --SELECT * FROM #tempDone WHERE ClaveEmpleado IN ('02800','03276')
  --RETURN
  
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
			,d.CantidadValesDespensa
		into #temp
		from #tempDone d  
			left join #tempMovPrevios p
			 on p.IDEmpleado = d.IDEmpleado
		where not exists(select 1 from IMSS.tblMovAfiliatorios where IDEmpleado = d.IDEmpleado and Fecha = d.DiaAplicacion and IDTipoMovimiento = (Select top 1 IDTipoMovimiento from IMSS.tblCatTipoMovimientos where Codigo = 'M') )  
			  and ((cast(d.SalarioDiario as decimal(10,2)) <> cast(ISNULL(p.SalarioDiario, 0) as decimal(10,2)) ) 
					or (CAST(d.SalarioVariable as decimal(10,2)) <> CAST(ISNULL( p.SalarioVariable , 0 ) as decimal(10,2)) ) 
					or (CAST(d.SalarioIntegrado as decimal(10,2)) <> CAST(ISNULL(p.SalarioIntegrado,0) as decimal(10,2))))
			 and
            (d.AFECTAR = 1)

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
			,d.CantidadValesDespensa
		into #temp2
		from #tempDone d  
			left join #tempMovPrevios p
			 on p.IDEmpleado = d.IDEmpleado
		where not exists(select 1 from IMSS.tblMovAfiliatorios where IDEmpleado = d.IDEmpleado and Fecha = d.DiaAplicacion and IDTipoMovimiento = (Select top 1 IDTipoMovimiento from IMSS.tblCatTipoMovimientos where Codigo = 'M') )  
			  --and ((cast(d.SalarioDiario as decimal(10,2)) <> cast(ISNULL(p.SalarioDiario, 0) as decimal(10,2)) ) 
					--or (CAST(d.SalarioVariable as decimal(10,2)) <> CAST(ISNULL( p.SalarioVariable , 0 ) as decimal(10,2)) ) 
					--or (CAST(d.SalarioIntegrado as decimal(10,2)) <> CAST(ISNULL(p.SalarioIntegrado,0) as decimal(10,2))))

		delete #temp
		where RN > 1

		delete #temp2
		where RN > 1

		--select * from #temp where ClaveEmpleado in ('02800','03276')
        --RETURN

	if(@Aplicar = 1)  
	BEGIN  

	
        CREATE TABLE #IdentityMovAfiliatorios (IDMovAfiliatorio INT);
		--select 0
		insert into IMSS.tblMovAfiliatorios(  
			Fecha  
			,IDEmpleado  
			,IDTipoMovimiento  
			,IDRazonMovimiento  
			,SalarioDiario  
			,SalarioIntegrado  
			,SalarioVariable  
			,SalarioDiarioReal
			,IDRegPatronal)  
        output inserted.IDMovAfiliatorio into #IdentityMovAfiliatorios
		select 
			DiaAplicacion  
			,IDEmpleado  
			--,d.ClaveEmpleado
			--,d.Afecta
			,IDTipoMovimiento 
			,IDRazonMovimiento  
			,CAST(SalarioDiario AS DECIMAL(10,2)) SalarioDiario
			,CAST(SalarioIntegrado AS DECIMAL(10,2))  SalarioIntegrado 
			,CAST(SalarioVariable AS DECIMAL(10,2)) SalarioVariable
			,CAST(SalarioDiarioReal AS DECIMAL(10,2)) SalarioDiarioReal
			,IDRegPatronal 
		    --, d.Afecta
		from #temp d 
		WHERE
		NOT EXISTS( SELECT 1
			FROM IMSS.tblMovAfiliatorios t2
			WHERE     d.DiaAplicacion = t2.Fecha
				  AND d.IDEmpleado = t2.IDEmpleado
				  AND d.IDTipoMovimiento = t2.IDTipoMovimiento
				  AND d.IDRazonMovimiento = t2.IDRazonMovimiento
				  AND (CAST(d.SalarioDiario AS DECIMAL(10,2))     = CAST(t2.SalarioDiario AS DECIMAL(10,2)))
				  AND (CAST(d.SalarioIntegrado AS DECIMAL(10,2))  = CAST(t2.SalarioIntegrado AS DECIMAL(10,2)))
				  AND (CAST(d.SalarioVariable AS DECIMAL(10,2))   = CAST(t2.SalarioVariable AS DECIMAL(10,2)))
				  AND (CAST(d.SalarioDiarioReal AS DECIMAL(10,2)) = CAST(t2.SalarioDiarioReal AS DECIMAL(10,2)))
				  AND d.IDRegPatronal = t2.IDRegPatronal) 
		 
		group by IDEmpleado
			,DiaAplicacion  
			,IDEmpleado  
			,IDTipoMovimiento 
			,IDRazonMovimiento  
			,SalarioDiario  
			,SalarioIntegrado  
			,SalarioVariable 
			,SalarioDiarioReal 
			,IDRegPatronal
			,viejoSalarioDiario
			,viejoSalariovariable
			,viejoSalariointegrado
			,d.ClaveEmpleado
			
        DECLARE @CurrentIdentity INT;                
        SELECT TOP 1 @CurrentIdentity = IDMovAfiliatorio
        FROM #IdentityMovAfiliatorios;                
        WHILE @CurrentIdentity IS NOT NULL
        BEGIN
            exec [IMSS].[spCalcularFechaAntiguedadMovAfiliatorios] @IDMovAfiliatorio=@CurrentIdentity;
            SELECT TOP 1 @CurrentIdentity = IDMovAfiliatorio
            FROM #IdentityMovAfiliatorios
            WHERE IDMovAfiliatorio > @CurrentIdentity;
        END;
		--order by d.ClaveEmpleado
	 --Where evita la duplicidad.
	END
	
	if object_id('tempdb..#tempConceptos')	is not null drop table #tempConceptos 
	if object_id('tempdb..#tempDataArmada')		is not null drop table #tempDataArmada
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
			ccc.*,
			tc.Descripcion as TipoConcepto,
			ccc.OrdenCalculo as orden
		from Nomina.tblCatConceptos ccc with (nolock) 
			inner join Nomina.tblCatTipoConcepto tc with (nolock) on tc.IDTipoConcepto = ccc.IDTipoConcepto
			inner join Nomina.tblConfigReporteVariablesBimestrales crr with (nolock)  on ccc.IDConcepto in (select item from app.Split(isnull(crr.ConceptosValesDespensa,'') +','+isnull(crr.ConceptosPremioPuntualidad,'')+','+isnull(crr.ConceptosPremioAsistencia,'')+','+isnull(crr.ConceptosIntegrablesVariables,'')+','+isnull(crr.ConceptosHorasExtrasDobles,''),','))
		) c 

		

	Select
		e.ClaveEmpleado as CLAVE,
		e.NOMBRECOMPLETO as NOMBRE,
		c.IDConcepto,
		c.Concepto,
		e.dias,
		e.SalarioVariable,
		e.SalarioDiario,
		e.SalarioIntegrado,
		SUM(isnull(dp.ImporteTotal1,0)) as ImporteTotal1,
		CAST(0.0 as decimal(18,2)) as BASE,
		e.NewFactor,
		e.CantidadValesDespensa
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
		inner join #temp2 e
			on dp.IDEmpleado = e.IDEmpleado
	Group by e.ClaveEmpleado,e.NOMBRECOMPLETO,c.Concepto,e.dias,e.SalarioVariable,e.SalarioVariable,e.NewFactor,e.SalarioDiario,c.IDConcepto,e.CantidadValesDespensa,e.SalarioIntegrado
	ORDER BY e.ClaveEmpleado ASC
	
	UPDATE t 
	 set t.BASE = (SELECT SUM(isnull(ImporteTotal1,0)) from #tempDataArmada a where a.Clave = t.Clave)
	from #tempDataArmada t
	--select * from #tempDataArmada


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

	

	
	set @query1 = 'SELECT CLAVE,NOMBRE, ' + @cols + ',BASE,CantidadValesDespensa as [VALES INTEGRABLES],Dias as [DIAS], SalarioDiario as [S.D.],SalarioVariable as [S.V.],NewFactor as FACTOR, SalarioIntegrado as [S.I.] from 
				(
					select CLAVE
						, Nombre
						, Concepto
						, Dias
						, BASE
						, CantidadValesDespensa
						, SalarioDiario
						, SalarioVariable
						, SalarioIntegrado
						, NewFactor
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
