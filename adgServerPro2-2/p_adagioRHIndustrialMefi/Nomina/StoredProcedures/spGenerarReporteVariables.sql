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
CREATE PROCEDURE [Nomina].[spGenerarReporteVariables]  
(  
	@Ejercicio int,  
	@IDBimestre int,  
	@EmpleadoIni Varchar(20) = '0',                
	@EmpleadoFin Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ',   
	@dtDepartamentos Varchar(max) = '',  
	@dtSucursales Varchar(max) = '',  
	@dtPuestos Varchar(max) = '',  
	@dtClasificacionesCorporativas Varchar(max) = '',  
	@dtRegPatronales Varchar(max) = '',  
	@dtDivisiones Varchar(max) = '',  
	@Aplicar bit ,
	@IDUsuario int
)  
AS  
BEGIN  
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
		@Filtros Nomina.dtFiltrosRH,  
		@DescripcionBimestre Varchar(MAX),
		@IDRegPatronal int,
		@dtFechas app.dtFechas
  
	insert into @Filtros(Catalogo,Value)  
	values('Departamentos',@dtDepartamentos)  
	      ,('Sucursales',@dtSucursales)  
	      ,('Puestos',@dtPuestos)  
	      ,('ClasificacionesCorporativas',@dtClasificacionesCorporativas)  
	      ,('RegPatronales',@dtRegPatronales)  
	      ,('Divisiones',@dtDivisiones)  



	select top 1 @IDRegPatronal = item from app.Split((select top 1 value from @Filtros where Catalogo = 'RegPatronales'),',')
	--select @IDRegPatronal = (select top 1 item from app.Split( @dtRegPatronales,',')) 
  
	select @fechaInicioBimestre = min(DATEADD(month,IDMes-1,DATEADD(year,@Ejercicio-1900,0)))   
		, @fechaFinBimestre=MAX(DATEADD(day,-1,DATEADD(month,IDMes,DATEADD(year,@Ejercicio-1900,0))))   
	from Nomina.tblCatMeses with (nolock)  
	where cast(IDMes as varchar) in (select item from app.Split( (select top 1 meses from Nomina.tblCatBimestres with (nolock) where IDBimestre = @IDBimestre),','))  
   
	set @diasBimestre = DATEDIFF(DAY, @fechaInicioBimestre, @fechaFinBimestre) + 1 
  
	select @DescripcionBimestre = Descripcion from Nomina.tblCatBimestres with (nolock) where IDBimestre = @IDBimestre  
  
	set @EmpleadoIni = case when isnull(@EmpleadoIni,'') = '' then '0' else @EmpleadoIni end  
	set @EmpleadoFin = case when isnull(@EmpleadoFin,'') = '' then 'ZZZZZZZZZZZZZZZZZZ' else @EmpleadoFin end  
  
  
    -----------------------------------------------------------------Sacar promedio de UMA en enero y febrero-------------------------------------------------------------------------------

   insert @dtFechas
   exec [App].[spListaFechas]  @fechaInicioBimestre, @fechaFinBimestre

   select @UMA = case 
   when @IDBimestre = 1 then (select AVG(UMA) UMA from (
        select f.Fecha,
                (select top 1 UMA from  Nomina.tblSalariosMinimos with (nolock) where Fecha <= f.Fecha order by Fecha desc) UMA
        from @dtFechas f
    ) info)

    else (
    select top 1 
        UMA 	 
	from Nomina.tblSalariosMinimos with (nolock)  
	where Year(Fecha) = @Ejercicio  
	order by Fecha desc )
    end

	select top 1 
		@SalarioMinimo = SalarioMinimo
		--@UMA = UMA   
	from Nomina.tblSalariosMinimos with (nolock)  
	where Year(Fecha) = @Ejercicio  
	order by Fecha desc  
  
	if OBJECT_ID('tempdb..#tempData') is not null drop table #tempData  
	if OBJECT_ID('tempdb..#tempcalc') is not null drop table #tempcalc  
	if OBJECT_ID('tempdb..#tempDone') is not null drop table #tempDone  
	if OBJECT_ID('tempdb..#temp') is not null drop table #temp
	if OBJECT_ID('tempdb..#tempMovPrevios') is not null drop table #tempMovPrevios



	if not exists( select top 1 1 from @Filtros where Catalogo = 'RegPatronales')  
	BEGIN  
		RAISERROR('Debe seleccionar un Registro Patronal',16,1);  
		RETURN;  
	END  
  
	if exists( select top 1 1 from @Filtros where Catalogo = 'RegPatronales' and Value = '')  
	BEGIN  
		RAISERROR('Debe seleccionar un Registro Patronal',16,1);  
		RETURN;  
	END  
  
 --select @FechaIni,@Fechafin,@EmpleadoIni,@EmpleadoIni  
 --select * from @Filtros  
  
	Insert into @dtEmpleadosVigentes  
	Exec RH.spBuscarEmpleados 
		@FechaIni = @fechaFinBimestre  
		,@Fechafin = @fechaFinBimestre  
		,@EmpleadoIni =@EmpleadoIni  
		,@EmpleadoFin = @EmpleadoFin  
		,@dtFiltros= @Filtros   
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
				where dp.IDEmpleado = e.IDEmpleado and dp.IDConcepto in (select item from app.Split(vb.ConceptosDias,',')) ),0) as Dias  
	into #tempData  
	from @dtEmpleadosTrabajables e  
	cross join Nomina.tblConfigReporteVariablesBimestrales vb with (nolock)   
	left join #tempMovPrevios temp
              on temp.IDEmpleado=e.IDEmpleado
    left join RH.tblCatTiposPrestacionesDetalle ctpd 
				on e.IDTipoPrestacion = ctpd.IDTipoPrestacion	
					--and ctpd.Antiguedad =cast( Asistencia.fnBuscarAniosDiferencia(Empleados.FechaAntiguedad,@FechaFinPago) as int)
                    and ctpd.Antiguedad =CEILING([Asistencia].[fnBuscarAniosDiferencia](e.FechaAntiguedad,temp.Fecha)) 
  
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
  
 --select * from #tempcalc  
  
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
  

  
  
  select distinct
			d.DiaAplicacion  
			,d.IDEmpleado 
			,d.ClaveEmpleado
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
		into #temp
		from #tempDone d  
			left join #tempMovPrevios p
			 on p.IDEmpleado = d.IDEmpleado
		where not exists(select 1 from IMSS.tblMovAfiliatorios where IDEmpleado = d.IDEmpleado and Fecha = d.DiaAplicacion and IDTipoMovimiento = (Select top 1 IDTipoMovimiento from IMSS.tblCatTipoMovimientos where Codigo = 'M') )  
			 and ((cast(d.SalarioDiario as decimal(10,2)) <> cast(ISNULL(p.SalarioDiario, 0) as decimal(10,2)) ) 
					or (CAST(d.SalarioVariable as decimal(10,2)) <> CAST(ISNULL( p.SalarioVariable , 0 ) as decimal(10,2)) ) 
					or (CAST(d.SalarioIntegrado as decimal(10,2)) <> CAST(ISNULL(p.SalarioIntegrado,0) as decimal(10,2))))
			 and (d.AFECTAR = 1)

		delete #temp
		where RN > 1

		--select * from #temp

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
	
	select d.*,vb.* ,  
		@DescripcionBimestre Bimestre,  
		@Ejercicio as Ejercicio  
		,@SalarioMinimo as SalarioMinimo  
		,@UMA as UMA  
		,CriterioDias = CASE WHEN CriterioDias = 0 THEN 'DIAS ACUMULADOS DEL TRABAJADOR' else 'DIAS DEL BIMESTRE' END  
		,SUBSTRING(  
		(  
		SELECT ','+c.Codigo+' - '+c.Descripcion  AS [text()]  
		FROM Nomina.tblcatconceptos c  
		cross apply Nomina.tblConfigReporteVariablesBimestrales vb  
		where IDConcepto in (select item from app.Split(vb.ConceptosIntegrablesVariables,','))  
		FOR XML PATH ('')  
		), 2, 1000) [ConceptosIntegran]  
		,DATEADD(Day,1,@fechaFinBimestre) as DiaAplicacion  
		,t.viejoSalarioDiario
		,t.viejoSalariovariable
		,t.viejoSalariointegrado
		,t.FechaUltimoMovimiento
	from #tempDone  d
		cross apply Nomina.tblConfigReporteVariablesBimestrales vb 
	inner join #temp t
		on d.IDEmpleado = t.IDEmpleado
	--where Factor not like '%NO GENERA M/S%'
	Order by ClaveEmpleado asc  


  
END
GO
