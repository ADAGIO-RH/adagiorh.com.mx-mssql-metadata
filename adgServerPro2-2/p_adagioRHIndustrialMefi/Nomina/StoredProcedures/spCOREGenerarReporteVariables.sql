USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [Nomina].[spCOREGenerarReporteVariables]  
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
		@ListaFechasUltimaVigencia [App].[dtFechasVigenciaEmpleado],
		@ListaFechasEmpleadosTrabajables [App].[dtFechasVigenciaEmpleado],
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
		@dtFechas app.dtFechas,
		@ConfigPromediarUMA int = 0,
		@fechasUltimaVigencia app.dtFechas


	BEGIN TRY
		BEGIN TRANSACTION TRANVariables
  
	insert into @Filtros(Catalogo,Value)  
	values('Departamentos',@dtDepartamentos)  
	      ,('Sucursales',@dtSucursales)  
	      ,('Puestos',@dtPuestos)  
	      ,('ClasificacionesCorporativas',@dtClasificacionesCorporativas)  
	      ,('RegPatronales',@dtRegPatronales)  
	      ,('Divisiones',@dtDivisiones)  

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


	select top 1 @IDRegPatronal = item from app.Split((select top 1 value from @Filtros where Catalogo = 'RegPatronales'),',')
  
	select @fechaInicioBimestre = min(DATEADD(month,IDMes-1,DATEADD(year,@Ejercicio-1900,0)))   
	from Nomina.tblCatMeses with (nolock)  
	where cast(IDMes as varchar) in (select item from app.Split( (select top 1 meses from Nomina.tblCatBimestres with (nolock) where IDBimestre = @IDBimestre),','))  
   
    set  @fechaFinBimestre=[Asistencia].[fnGetFechaFinBimestre](@fechaInicioBimestre)   

	set @diasBimestre = DATEDIFF(DAY, @fechaInicioBimestre, @fechaFinBimestre) + 1 
  
	select @DescripcionBimestre = Descripcion from Nomina.tblCatBimestres with (nolock) where IDBimestre = @IDBimestre  

	DECLARE @dtData as TABLE (
		IDBimestre int,
		IDMes int,
		UMA Decimal(18,2),
		SalarioMinimo Decimal(18,2),
		IniMes date,
		FinMes date
	)

	select top 1 @ConfigPromediarUMA = isnull(PromediarUMA,1) from Nomina.tblConfigReporteVariablesBimestrales with(nolock)

	insert into @dtData
	select @IDBimestre 
		,item
		,(Select top 1 UMA from Nomina.tblSalariosMinimos with(nolock) where Fecha <= DATEADD(day,-1,DATEADD(month,cast(item as int),DATEADD(year,@Ejercicio-1900,0))) order by Fecha desc)
		,(Select top 1 SalarioMinimo from Nomina.tblSalariosMinimos with(nolock) where Fecha <= DATEADD(day,-1,DATEADD(month,cast(item as int),DATEADD(year,@Ejercicio-1900,0))) order by Fecha desc)
		,(DATEADD(month,cast(item as int)-1,DATEADD(year,@Ejercicio-1900,0)))   
		,DATEADD(day,-1,DATEADD(month,cast(item as int),DATEADD(year,@Ejercicio-1900,0)))
	from app.Split( (select top 1 meses from Nomina.tblCatBimestres with (nolock) where IDBimestre = @IDBimestre),',')

	IF(@ConfigPromediarUMA = 2)
	BEGIN
		update @dtData
		set UMA = (Select top 1 UMA from Nomina.tblSalariosMinimos with(nolock) where Fecha <= @fechaFinBimestre order by Fecha desc)
	END

	
	IF(@ConfigPromediarUMA = 3)
	BEGIN

		select @UMA =  (select AVG(UMA) UMA from (
							select f.FinMes,
									(select top 1 UMA from  Nomina.tblSalariosMinimos with (nolock) where Fecha <= f.FinMes order by Fecha desc) UMA
							from @dtData f
						) info)

		update @dtData
		set UMA =  @UMA


	END

	--SELECT * from @dtData
	--RETURN;


  
	set @EmpleadoIni = case when isnull(@EmpleadoIni,'') = '' then '0' else @EmpleadoIni end  
	set @EmpleadoFin = case when isnull(@EmpleadoFin,'') = '' then 'ZZZZZZZZZZZZZZZZZZZZ' else @EmpleadoFin end  

		if OBJECT_ID('tempdb..#tempMovPrevios') is not null drop table #tempMovPrevios
		if OBJECT_ID('tempdb..#tempData2') is not null drop table #tempData2
		if OBJECT_ID('tempdb..#tempData') is not null drop table #tempData
		if OBJECT_ID('tempdb..#tempcalc') is not null drop table #tempcalc
		if OBJECT_ID('tempdb..#tempDone') is not null drop table #tempDone
        if OBJECT_ID('tempdb..#tempMovBajas') is not null drop table #tempMovBajas

     -----------------------------------------------------------------Sacar promedio de UMA en enero y febrero-------------------------------------------------------------------------------



	   	Insert into @dtEmpleadosVigentes  
		Exec RH.spBuscarEmpleados 
		@FechaIni = @fechaInicioBimestre  
		,@Fechafin = @fechaFinBimestre  
		,@EmpleadoIni =@EmpleadoIni  
		,@EmpleadoFin = @EmpleadoFin  
		,@dtFiltros= @Filtros   
		,@IDUsuario = @IDUsuario


	   insert into @fechasUltimaVigencia
	   exec [App].[spListaFechas]@fechaFinBimestre,@fechaFinBimestre
	
 
		insert @ListaFechasUltimaVigencia
		exec [RH].[spBuscarListaFechasVigenciaEmpleado] @dtEmpleadosVigentes,@fechasUltimaVigencia,@IDUsuario

        select m.*,ROW_NUMBER()OVER(partition by m.idempleado order by m.fecha desc) RN
	    into #tempMovBajas
	    from @dtEmpleadosVigentes  E
		inner join IMSS.tblMovAfiliatorios M
		 on E.IDEmpleado = M.IDEmpleado
		 and m.Fecha >= e.FechaAntiguedad
		 and m.Fecha <= @fechaFinBimestre
		 and m.IDRegPatronal = @IDRegPatronal
	
		 delete #tempMovBajas
		 where RN > 1
    
        delete #tempMovBajas
		where IDTipoMovimiento<>(Select  IDTipoMovimiento from IMSS.tblCatTipoMovimientos where Codigo = 'B')



		insert into @dtEmpleadosTrabajables  
		select ev.*   
		from @dtEmpleadosVigentes ev  
			inner join @ListaFechasUltimaVigencia fuv 
				on ev.IDEmpleado = fuv.IDEmpleado
				and fuv.Vigente = 1
			left join IMSS.tblMovAfiliatorios mov with (nolock)  
				on ev.IDEmpleado = mov.IDEmpleado  
			and mov.Fecha = DATEADD(Day,1,@fechaFinBimestre)  
			left join Asistencia.tblIncidenciaEmpleado IE with(nolock)
				on Ev.idEmpleado = IE.idempleado
				and IE.IDIncidencia = 'I'
				and IE.fecha = DATEADD(Day,1,@fechaFinBimestre)
            left join #tempMovBajas bajas
                on bajas.IDEmpleado=ev.IDEmpleado
		where mov.IDMovAfiliatorio is null   
		and ie.IDIncidenciaEmpleado is null
        and bajas.IDEmpleado is null
		

	   select d.*,
		e.IDEmpleado,
		(SELECT top 1 IDMovAfiliatorio 
		  from IMSS.tblMovAfiliatorios M with(nolock) 
		  where 
				E.IDEmpleado = M.IDEmpleado
			 and M.IDTipoMovimiento in (Select  IDTipoMovimiento from IMSS.tblCatTipoMovimientos where Codigo <> 'B')
			 and m.Fecha >= e.FechaAntiguedad
			 and m.Fecha <= d.FinMes
			 and m.IDRegPatronal = @IDRegPatronal
		order by m.Fecha desc
		  )IDMovAfiliatorio
		
	    into #tempMovPrevios 
	    from @dtEmpleadosTrabajables E
		cross apply @dtData d
	
		


	select e.IDEmpleado  
		,e.ClaveEmpleado  
		,e.NOMBRECOMPLETO  
		,e.Departamento  
		,e.Sucursal  
		,e.Puesto  
		,e.IDRegPatronal  
		,e.RegPatronal  
		,CAST(mov.SalarioDiario as decimal(10,2))  SalarioDiario
		,CAST(mov.SalarioVariable  as decimal(10,2)) SalarioVariable
		,CAST(mov.SalarioIntegrado as decimal(10,2))  SalarioIntegrado
		,mov.Fecha as FechaMov
		,e.FechaAntiguedad
		,vb. *
		,temp.IDBimestre
		,temp.UMA
		,temp.SalarioMinimo
		,temp.IDMes
		,temp.IniMes
		,temp.FinMes
		,temp.IDMovAfiliatorio
		,(select min(Factor)   
			from [RH].[tblCatTiposPrestacionesDetalle] with (nolock)  
			where IDTipoPrestacion = e.IDTipoPrestacion   
			 AND Antiguedad     = ISNULL(FLOOR(DATEDIFF(day,e.FechaAntiguedad,temp.FinMes)/365.25),0)+1 ) Factor 
		,ctpd.Factor AS FactorAntiguo
		,CEILING([Asistencia].[fnBuscarAniosDiferencia](e.FechaAntiguedad,temp.FinMes))AniosPrestacion
		,isnull((select CAST(SUM(Importetotal1) as decimal(18,2))   
				from Nomina.tblDetallePeriodo dp with (nolock)    
					inner join Nomina.tblCatPeriodos p with (nolock)    
					on dp.IDPeriodo = p.IDPeriodo  
						and p.Ejercicio = @Ejercicio  
						and p.IDMes =  temp.IDMes 
						and p.Cerrado = 1  
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
					and p.IDMes =  temp.IDMes   
					and p.Cerrado = 1  
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
							and p.IDMes =  temp.IDMes
							and p.Cerrado = 1 
						inner join Nomina.tblHistorialesEmpleadosPeriodos HEP with(Nolock)
						on hep.IDEmpleado = e.IDEmpleado
						and hep.IDPeriodo = p.IDPeriodo
						and hep.IDRegPatronal = @IDRegPatronal
				where dp.IDEmpleado = e.IDEmpleado and dp.IDConcepto in (select item from app.Split(vb.ConceptosPremioAsistencia,',')) ),0) as PremioAsistencia  
			,CASE WHEN isnull((select CAST(SUM(dp.ImporteGravado) as decimal(18,2))     
				from Nomina.tblDetallePeriodo dp with (nolock)  
					inner join Nomina.tblCatPeriodos p with (nolock)   
						on dp.IDPeriodo = p.IDPeriodo  
							and p.Ejercicio = @Ejercicio  
							and p.IDMes  =  temp.IDMes
							and p.Cerrado = 1 
						inner join Nomina.tblHistorialesEmpleadosPeriodos HEP with(Nolock)
						on hep.IDEmpleado = e.IDEmpleado
						and hep.IDPeriodo = p.IDPeriodo
						and hep.IDRegPatronal = @IDRegPatronal
				where dp.IDEmpleado = e.IDEmpleado and dp.IDConcepto in (select item from app.Split(vb.ConceptosHorasExtrasDobles,',')) ),0) <= ((mov.SalarioDiario /  8.0)*2.0)*72.0
				THEN 0.00
				ELSE isnull((select CAST(SUM(ImporteGravado) as decimal(18,2))     
				from Nomina.tblDetallePeriodo dp with (nolock)  
					inner join Nomina.tblCatPeriodos p with (nolock)   
						on dp.IDPeriodo = p.IDPeriodo  
							and p.Ejercicio = @Ejercicio  
							and p.IDMes  =  temp.IDMes
							and p.Cerrado = 1 
						inner join Nomina.tblHistorialesEmpleadosPeriodos HEP with(Nolock)
						on hep.IDEmpleado = e.IDEmpleado
						and hep.IDPeriodo = p.IDPeriodo
						and hep.IDRegPatronal = @IDRegPatronal
				where dp.IDEmpleado = e.IDEmpleado and dp.IDConcepto in (select item from app.Split(vb.ConceptosHorasExtrasDobles,',')) ),0) - ((mov.SalarioDiario /  8.0)*2.0)*72.0
				END
				as HorasExtrasDobles  
		,isnull((select CAST(SUM(Importetotal1) as decimal(18,2))     
				from Nomina.tblDetallePeriodo dp with (nolock)  
					inner join Nomina.tblCatPeriodos p with (nolock)   
						on dp.IDPeriodo = p.IDPeriodo  
							and p.Ejercicio = @Ejercicio  
							and p.IDMes  =  temp.IDMes
							and p.Cerrado = 1  
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
						and p.IDMes  =  temp.IDMes 
						and p.Cerrado = 1 
					inner join Nomina.tblHistorialesEmpleadosPeriodos HEP with(Nolock)
						on hep.IDEmpleado = e.IDEmpleado
						and hep.IDPeriodo = p.IDPeriodo
						and hep.IDRegPatronal = @IDRegPatronal
				where dp.IDEmpleado = e.IDEmpleado and dp.IDConcepto in (select item from app.Split(vb.ConceptosDias,',')) ),0) as Dias  
	 ,CASE WHEN E.FechaAntiguedad>temp.IniMes THEN DATEDIFF(DAY,E.FechaAntiguedad,temp.FinMes)+1 ELSE DATEDIFF(DAY,temp.IniMes,temp.FinMes)+1 END AS DiasMes
	into #tempData  
	from @dtEmpleadosTrabajables e  
	left join #tempMovPrevios temp
              on temp.IDEmpleado=e.IDEmpleado
	inner join IMSS.tblMovAfiliatorios mov with(nolock)
		on mov.IDMovAfiliatorio = temp.IDMovAfiliatorio
	cross join Nomina.tblConfigReporteVariablesBimestrales vb with (nolock)   
	 LEFT JOIN [RH].[tblPrestacionesEmpleado] PE WITH(NOLOCK) 
                ON E.IDEmpleado = PE.IDEmpleado 
                AND PE.FechaIni<= mov.Fecha
                AND PE.FechaFin >= mov.Fecha
    left join RH.tblCatTiposPrestacionesDetalle ctpd  with(nolock)
				on PE.IDTipoPrestacion = ctpd.IDTipoPrestacion	
					--and ctpd.Antiguedad =cast( Asistencia.fnBuscarAniosDiferencia(Empleados.FechaAntiguedad,@FechaFinPago) as int)
                    and ctpd.Antiguedad = ISNULL(FLOOR(DATEDIFF(day,[IMSS].[fnObtenerFechaAntiguedad](E.IDEmpleado, MOV.IDMovAfiliatorio), MOV.Fecha)/365.25),0)+1
	--select * from #tempData
	--order by ClaveEmpleado

	SELECT 
		 m.IDEmpleado 
		,MAX(m.ClaveEmpleado)  ClaveEmpleado
		,MAX(m.NOMBRECOMPLETO)  NOMBRECOMPLETO
		,MAX(m.Departamento  )Departamento
		,MAX(m.Sucursal  )Sucursal
		,MAX(m.Puesto  )Puesto
		,MAX(m.IDRegPatronal)IDRegPatronal
		,MAX(m.RegPatronal)RegPatronal
		,CAST(MAX(m.SalarioDiario) as decimal(18,2))SalarioDiario
		,CAST(MAX(m.SalarioVariable) as decimal(18,2))SalarioVariable
		,CAST(MAX(m.SalarioIntegrado) as decimal(18,2))SalarioIntegrado
		,MAX(m.Factor)Factor
		,MIN(m.FactorAntiguo)FactorAntiguo
		,MIN(m.FechaAntiguedad)FechaAntiguedad
		,MAX(m.AniosPrestacion) AniosPrestacion
		,SUM(ValesDespensa) as ValesDespensa
		,SUM(TopeVales) as TopeVales
		,SUM(ConceptosValesDespensa) as ConceptosValesDespensa
		,SUM(ConceptosPremioPuntualidad) as ConceptosPremioPuntualidad
		,SUM(ConceptosPremioAsistencia) as ConceptosPremioAsistencia
		,SUM(HorasExtrasDobles ) as HorasExtrasDobles
		,SUM(IntegrablesVariables)  as IntegrablesVariables
		,MAX(ConceptosDias)  ConceptosDias
		,MAX(IDRazonMovimiento) IDRazonMovimiento 
		,(CriterioDias) as CriterioDias 
		,SUM(Dias  )Dias
		,SUM(DiasMes)DiasMes
		,MAX(UMA) UMA
		,MAX(SalarioMinimo) SalarioMinimo
		,MAX(FechaMov) FechaMov
	into #tempcalc
	FROM (
		select 
			IDEmpleado  
			,ClaveEmpleado  
			,NOMBRECOMPLETO  
			,Departamento  
			,Sucursal  
			,Puesto  
			,IDRegPatronal  
			,RegPatronal  
			,SalarioDiario
			,SalarioVariable
			,SalarioIntegrado
			,Factor
			,FactorAntiguo
			,FechaAntiguedad
			,AniosPrestacion
			,FechaMov
			,IDMes
			,Vales as ValesDespensa
			,((UMA * case when CriterioDias = 0 then Dias else DiasMes end)*0.40) TopeVales
			,case when Vales > ((UMA * case when CriterioDias = 0 then Dias else DiasMes end)*0.40) then Vales - ((UMA * case when CriterioDias = 0 then Dias else DiasMes end)*0.40)  
				else 0 end as ConceptosValesDespensa  
  
			,case when PremioPuntualidad > (( (CASE WHEN isnull(TopePremioPuntualidadAsistencia,1) = 1 THEN SalarioDiario ELSE SalarioIntegrado END) * case when CriterioDias = 0 then Dias else DiasMes end)*0.10) then PremioPuntualidad - (( (CASE WHEN isnull(TopePremioPuntualidadAsistencia,1) = 1 THEN SalarioDiario ELSE SalarioIntegrado END) * case when CriterioDias = 0 then Dias else DiasMes end)*0.10)  
				else 0 end as ConceptosPremioPuntualidad  
    
			,case when PremioAsistencia > (( (CASE WHEN isnull(TopePremioPuntualidadAsistencia,1) = 1 THEN SalarioDiario ELSE SalarioIntegrado END) * case when CriterioDias = 0 then Dias else DiasMes end)*0.10) then PremioAsistencia - (( (CASE WHEN isnull(TopePremioPuntualidadAsistencia,1) = 1 THEN SalarioDiario ELSE SalarioIntegrado END) * case when CriterioDias = 0 then Dias else DiasMes end)*0.10)  
				else 0 end as ConceptosPremioAsistencia  
  
			,HorasExtrasDobles  
			,IntegrablesVariables  
			,ConceptosDias  
			,IDRazonMovimiento  
			,CriterioDias  
			,Dias  
			,DiasMes
			,UMA
			,SalarioMinimo
		from #tempData
	where (case when CriterioDias = 0 and isnull(Dias,0) > 0 then isnull(Dias,0) else isnull(DiasMes,0) end) > 0
	) M
	GROUP BY m.IDEmpleado, m.CriterioDias

	

	UPDATE #tempcalc
		set ConceptosValesDespensa = CASE WHEN  ValesDespensa > TopeVales THEN ConceptosValesDespensa else 0 end

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
		, VariableCambio = 0
		,c.Factor as NewFactor
		,c.FactorAntiguo
		,FactorCambio = 0
		,IntegradoCambio = 0
		,c.aniosPrestacion
		,CAST(c.SalarioDiario as decimal(18,2)) as SalarioDiario
		,0 as AFECTAR
		,CAST( case when ((isnull(c.ConceptosValesDespensa,0)+ isnull(c.ConceptosPremioPuntualidad,0)+   
			isnull(c.ConceptosPremioAsistencia,0)+ isnull(c.HorasExtrasDobles,0)+ isnull(c.IntegrablesVariables,0))) = 0 then 0 else  
    
			((isnull(c.ConceptosValesDespensa,0)+ isnull(c.ConceptosPremioPuntualidad,0)+   
			isnull(c.ConceptosPremioAsistencia,0)+ isnull(c.HorasExtrasDobles,0)+ isnull(c.IntegrablesVariables,0))  
			/ case when c.CriterioDias = 0 and c.Dias > 0 then c.Dias else c.DiasMes end) END as decimal(18,2)) SalarioVariable  
  	   ,case when c.CriterioDias = 0 and isnull(c.Dias,0) > 0 then c.Dias else c.DiasMes end as Dias  

	   ,CAST(case when ((c.SalarioDiario*c.Factor) + 
			case when ((isnull(c.ConceptosValesDespensa,0)+ isnull(c.ConceptosPremioPuntualidad,0)+isnull(c.ConceptosPremioAsistencia,0)+ isnull(c.HorasExtrasDobles,0)+ isnull(c.IntegrablesVariables,0))) = 0 then 0 
			else  
    
			((isnull(c.ConceptosValesDespensa,0)+ isnull(c.ConceptosPremioPuntualidad,0)+   
			isnull(c.ConceptosPremioAsistencia,0)+ isnull(c.HorasExtrasDobles,0)+ isnull(c.IntegrablesVariables,0))  
			/case when c.CriterioDias = 0 and c.Dias > 0 then c.Dias else @diasBimestre end) 
   
		END ) >= UMA * 25 then (UMA * 25)
		ELSE
			(c.SalarioDiario*c.Factor) + 
			case when ((isnull(c.ConceptosValesDespensa,0)+ isnull(c.ConceptosPremioPuntualidad,0)+isnull(c.ConceptosPremioAsistencia,0)+ isnull(c.HorasExtrasDobles,0)+ isnull(c.IntegrablesVariables,0))) = 0 then 0 
			else  
    
			((isnull(c.ConceptosValesDespensa,0)+ isnull(c.ConceptosPremioPuntualidad,0)+   
			isnull(c.ConceptosPremioAsistencia,0)+ isnull(c.HorasExtrasDobles,0)+ isnull(c.IntegrablesVariables,0))  
			/case when c.CriterioDias = 0 and c.Dias > 0 then c.Dias else @diasBimestre end) 
   
		END 
		END  as decimal(18,2))SalarioIntegrado  

		,CAST((Select top 1 isnull(SalarioDiarioReal,0.00) from IMSS.tblMovAfiliatorios m with(nolock) inner join IMSS.tblCatTipoMovimientos tm with(nolock) on tm.IDTipoMovimiento = m.IDTipoMovimiento where IDEmpleado = c.IDEmpleado and tm.Codigo <> 'B' order by Fecha desc ) as decimal(18,2)) as SalarioDiarioReal
		,c.IDRazonMovimiento  
		,(Select top 1 Descripcion from IMSS.tblCatRazonesMovAfiliatorios where IDRazonMovimiento = c.IDRazonMovimiento) RazonMovimiento  
		, DATEADD(Day,1,@fechaFinBimestre) as DiaAplicacion  
		,CAST(ISNULL(c.ConceptosPremioAsistencia,0) as decimal(18,2)) as CantidadPremioAsistencia
		,CAST(ISNULL(c.ConceptosPremioPuntualidad,0) as decimal(18,2)) as CantidadPremioPuntualidad
		,CAST(ISNULL(c.ConceptosValesDespensa,0) as decimal(18,2)) as CantidadValesDespensa
		,CAST(ISNULL(c.IntegrablesVariables,0) as decimal(18,2)) as CantidadIntegrablesVariables
		,CAST(ISNULL(c.HorasExtrasDobles,0) as decimal(18,2)) as CantidadHorasExtrasDobles

		,config.ConceptosValesDespensa
		,config.ConceptosPremioPuntualidad
		,config.ConceptosPremioAsistencia
		,config.ConceptosHorasExtrasDobles
		,config.ConceptosIntegrablesVariables
		,config.ConceptosDias
		,config.PromediarUMA
		,config.TopePremioPuntualidadAsistencia
		,c.UMA
		,c.SalarioMinimo
		,@Ejercicio as Ejercicio
		,@DescripcionBimestre as Bimestre
		,m.SalarioDiario as ViejoSalarioDiario
		,m.SalarioVariable as ViejoSalarioVariable
		,m.SalarioIntegrado as ViejoSalarioIntegrado

		,CriterioDias = CASE WHEN config.CriterioDias = 0 THEN 'DIAS ACUMULADOS DEL TRABAJADOR' else 'DIAS DEL BIMESTRE' END  
		,CriterioUMA = CASE WHEN isnull(config.PromediarUMA,1) = 1 THEN 'UMA CORRESPONDIENTE A CADA MES DEL BIMESTRE' 
						   WHEN isnull(config.PromediarUMA,1) = 2 THEN 'ULTIMA UMA DEL BIMESTRE'
							else 'PROMEDIO DE UMA DEL BIMESTRE' END  

		,SUBSTRING(  
		(  
		SELECT ','+c.Codigo+' - '+c.Descripcion  AS [text()]  
		FROM Nomina.tblcatconceptos c  with(nolock)
		cross apply Nomina.tblConfigReporteVariablesBimestrales vb with(nolock) 
		where IDConcepto in (select item from app.Split(vb.ConceptosIntegrablesVariables,','))  
		FOR XML PATH ('')  
		), 2, 1000) [ConceptosIntegran]  
		,c.FechaMov as FechaUltimoMovimiento
	into #tempDone  
	from #tempcalc c  
	inner join RH.tblEmpleadosMaster m with(nolock)
		on c.IDEmpleado = m.IDEmpleado
	cross apply Nomina.tblConfigReporteVariablesBimestrales config with(nolock)
	WHERE (case when c.CriterioDias = 0 and isnull(c.Dias,0) > 0 then c.Dias else @diasBimestre end) > 0


	
	  
  update  #tempDone  
	set VariableCambio = CASE WHEN  ViejoSalarioVariable <> SalarioVariable THEN 1 else 0 END
		,FactorCambio = CASE WHEN FactorAntiguo <> NewFactor THEN 1 ELSE 0 END 
		,IntegradoCambio = CASE WHEN  ViejoSalarioIntegrado <> SalarioIntegrado THEN 1 else 0 END

	UPDATE #tempDone 
		--set AFECTAR = CASE WHEN VariableCambio = 1 OR FactorCambio = 1 or IntegradoCambio = 1 THEN 1 ELSE 0 END
    SET Afectar = CASE WHEN VariableCambio = 1 OR FactorCambio = 1 THEN 1 ELSE 0 END

	if(@Aplicar = 1)  
		BEGIN  



            CREATE TABLE #IdentityMovAfiliatorios (IDMovAfiliatorio INT);

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
				,4 
				,IDRazonMovimiento  
				,CAST(SalarioDiario AS DECIMAL(18,2)) SalarioDiario
				,CAST(SalarioIntegrado AS DECIMAL(18,2))  SalarioIntegrado 
				,CAST(SalarioVariable AS DECIMAL(18,2)) SalarioVariable
				,CAST(SalarioDiarioReal AS DECIMAL(18,2)) SalarioDiarioReal
				,IDRegPatronal 
				--, d.Afecta
			from #tempDone d 
			WHERE
			NOT EXISTS( SELECT 1
				FROM IMSS.tblMovAfiliatorios t2
				WHERE     d.DiaAplicacion = t2.Fecha
					  AND d.IDEmpleado = t2.IDEmpleado
					  AND (CAST(d.SalarioDiario AS DECIMAL(18,2))     = CAST(t2.SalarioDiario AS DECIMAL(18,2)))
					  AND (CAST(d.SalarioIntegrado AS DECIMAL(18,2))  = CAST(t2.SalarioIntegrado AS DECIMAL(18,2)))
					  AND (CAST(d.SalarioVariable AS DECIMAL(18,2))   = CAST(t2.SalarioVariable AS DECIMAL(18,2)))
					  AND (CAST(d.SalarioDiarioReal AS DECIMAL(18,2)) = CAST(t2.SalarioDiarioReal AS DECIMAL(18,2)))
					  AND d.IDRegPatronal = t2.IDRegPatronal) AND D.AFECTAR=1
		 
			group by IDEmpleado
				,DiaAplicacion  
				,IDEmpleado  
				,IDRazonMovimiento  
				,SalarioDiario  
				,SalarioIntegrado  
				,SalarioVariable 
				,SalarioDiarioReal 
				,IDRegPatronal
				,viejoSalarioDiario
				,viejoSalariovariable
				,viejoSalariointegrado
				,d.ClaveEmpleado;

            -- DECLARE @CurrentIdentity INT;                
            -- SELECT TOP 1 @CurrentIdentity = IDMovAfiliatorio
            -- FROM #IdentityMovAfiliatorios;                
            -- WHILE @CurrentIdentity IS NOT NULL
            -- BEGIN
            --     exec [IMSS].[spCalcularFechaAntiguedadMovAfiliatorios] @IDMovAfiliatorio=@CurrentIdentity;
            --     SELECT TOP 1 @CurrentIdentity = IDMovAfiliatorio
            --     FROM #IdentityMovAfiliatorios
            --     WHERE IDMovAfiliatorio > @CurrentIdentity;
            -- END;    
    
		END


	select * 
	from #tempDone
	order by ClaveEmpleado
	
		COMMIT TRANSACTION TRANVariables

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION TRANVariables
		DECLARE @MESSAGE Varchar(max) =  ERROR_MESSAGE ( ) 
		RAISERROR(@MESSAGE,16,1)
	END CATCH

END

--select * from RH.tblEmpleados where ClaveEmpleado = 'ADG0002'
GO
