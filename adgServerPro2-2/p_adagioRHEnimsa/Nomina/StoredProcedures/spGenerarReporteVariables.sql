USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
		@FechaIni Date = getdate(),  
		@Fechafin Date = getdate(),  
		@SalarioMinimo decimal(18,2),  
		@UMA Decimal(18,2),  
		@fechaInicioBimestre date,  
		@fechaFinBimestre date,  
		@diasBimestre int,  
		@Filtros Nomina.dtFiltrosRH,  
		@DescripcionBimestre Varchar(MAX)  
  
	insert into @Filtros(Catalogo,Value)  
	values('Departamentos',@dtDepartamentos)  
	      ,('Sucursales',@dtSucursales)  
	      ,('Puestos',@dtPuestos)  
	      ,('ClasificacionesCorporativas',@dtClasificacionesCorporativas)  
	      ,('RegPatronales',@dtRegPatronales)  
	      ,('Divisiones',@dtDivisiones)  
  
	select @fechaInicioBimestre = min(DATEADD(month,IDMes-1,DATEADD(year,@Ejercicio-1900,0)))   
		, @fechaFinBimestre=MAX(DATEADD(day,-1,DATEADD(month,IDMes,DATEADD(year,@Ejercicio-1900,0))))   
	from Nomina.tblCatMeses with (nolock)  
	where cast(IDMes as varchar) in (select item from app.Split( (select top 1 meses from Nomina.tblCatBimestres with (nolock) where IDBimestre = @IDBimestre),','))  
   
	set @diasBimestre = DATEDIFF(DAY, @fechaInicioBimestre, @fechaFinBimestre) + 1 
  
	select @DescripcionBimestre = Descripcion from Nomina.tblCatBimestres with (nolock) where IDBimestre = @IDBimestre  
  
	set @EmpleadoIni = case when isnull(@EmpleadoIni,'') = '' then '0' else @EmpleadoIni end  
	set @EmpleadoFin = case when isnull(@EmpleadoFin,'') = '' then 'ZZZZZZZZZZZZZZZZZZ' else @EmpleadoFin end  
  
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
		@FechaIni = @FechaIni  
		,@Fechafin = @Fechafin  
		,@EmpleadoIni =@EmpleadoIni  
		,@EmpleadoFin = @EmpleadoFin  
		,@dtFiltros= @Filtros   
		,@IDUsuario = @IDUsuario

	insert into @dtEmpleadosTrabajables  
	select ev.*   
	from @dtEmpleadosVigentes ev  
		left join IMSS.tblMovAfiliatorios mov with (nolock)  
			on ev.IDEmpleado = mov.IDEmpleado  
		and mov.Fecha = @FechaIni  
		left join imss.tblCatTipoMovimientos tm with (nolock)  
			on tm.IDTipoMovimiento = mov.IDTipoMovimiento  
		and tm.Codigo = 'B'  
	where mov.IDMovAfiliatorio is null   
  
 --select * from @dtEmpleadosTrabajables   
   
	select e.IDEmpleado  
		,e.ClaveEmpleado  
		,e.NOMBRECOMPLETO  
		,e.Departamento  
		,e.Sucursal  
		,e.Puesto  
		,e.IDRegPatronal  
		,e.RegPatronal  
		,e.SalarioDiario  
		,e.SalarioVariable  
		,e.SalarioIntegrado  
		,(select top 1 Factor   
			from [RH].[tblCatTiposPrestacionesDetalle] with (nolock)  
			where IDTipoPrestacion = e.IDTipoPrestacion   
			and Antiguedad >= CASE WHEN DATEDIFF(YEAR, e.FechaAntiguedad,@FechaIni) = 0 THEN 1 else DATEDIFF(YEAR, e.FechaAntiguedad,@FechaIni) end) Factor  
		,vb.*  
		,isnull((select SUM(Importetotal1)   
				from Nomina.tblDetallePeriodo dp with (nolock)    
					inner join Nomina.tblCatPeriodos p with (nolock)     
					on dp.IDPeriodo = p.IDPeriodo  
						and p.Ejercicio = @Ejercicio  
						and p.IDMes in (select item from app.Split( (select top 1 meses from Nomina.tblCatBimestres with (nolock)   where IDBimestre = @IDBimestre),','))  
						and p.Cerrado = 1  
				where dp.IDEmpleado = e.IDEmpleado and dp.IDConcepto in (select item from app.Split(vb.ConceptosValesDespensa,','))),0) as Vales  
		,isnull((select SUM(Importetotal1)   
				from Nomina.tblDetallePeriodo dp with (nolock)  
					inner join Nomina.tblCatPeriodos p with (nolock)   
					on dp.IDPeriodo = p.IDPeriodo  
					and p.Ejercicio = @Ejercicio  
					and p.IDMes in (select item from app.Split( (select top 1 meses from Nomina.tblCatBimestres with (nolock) where IDBimestre = @IDBimestre),','))  
					and p.Cerrado = 1  
				where dp.IDEmpleado = e.IDEmpleado and dp.IDConcepto in (select item from app.Split(vb.ConceptosPremioPuntualidad,',')) ),0) as PremioPuntualidad  
		,isnull((select SUM(Importetotal1)   
				from Nomina.tblDetallePeriodo dp with (nolock)  
					inner join Nomina.tblCatPeriodos p with (nolock)   
						on dp.IDPeriodo = p.IDPeriodo  
							and p.Ejercicio = @Ejercicio  
							and p.IDMes in (select item from app.Split( (select top 1 meses from Nomina.tblCatBimestres with (nolock) where IDBimestre = @IDBimestre),','))  
							and p.Cerrado = 1  
				where dp.IDEmpleado = e.IDEmpleado and dp.IDConcepto in (select item from app.Split(vb.ConceptosPremioAsistencia,',')) ),0) as PremioAsistencia  
		,isnull((select SUM(ImporteGravado)   
				from Nomina.tblDetallePeriodo dp with (nolock)  
					inner join Nomina.tblCatPeriodos p with (nolock)   
						on dp.IDPeriodo = p.IDPeriodo  
							and p.Ejercicio = @Ejercicio  
							and p.IDMes in (select item from app.Split( (select top 1 meses from Nomina.tblCatBimestres with (nolock) where IDBimestre = @IDBimestre),','))  
							and p.Cerrado = 1  
				where dp.IDEmpleado = e.IDEmpleado and dp.IDConcepto in (select item from app.Split(vb.ConceptosHorasExtrasDobles,',')) ),0) as HorasExtrasDobles  
		,isnull((select SUM(Importetotal1)   
				from Nomina.tblDetallePeriodo dp with (nolock)  
					inner join Nomina.tblCatPeriodos p with (nolock)   
						on dp.IDPeriodo = p.IDPeriodo  
							and p.Ejercicio = @Ejercicio  
							and p.IDMes in (select item from app.Split( (select top 1 meses from Nomina.tblCatBimestres with (nolock) where IDBimestre = @IDBimestre),','))  
							and p.Cerrado = 1  
				where dp.IDEmpleado = e.IDEmpleado and dp.IDConcepto in (select item from app.Split(vb.ConceptosIntegrablesVariables,',')) ),0) as IntegrablesVariables  
		,isnull((select SUM(Importetotal1)   
				from Nomina.tblDetallePeriodo dp with (nolock)  
				inner join Nomina.tblCatPeriodos p with (nolock)   
					on dp.IDPeriodo = p.IDPeriodo  
						and p.Ejercicio = @Ejercicio  
						and p.IDMes in (select item from app.Split( (select top 1 meses from Nomina.tblCatBimestres with (nolock) where IDBimestre = @IDBimestre),','))  
						and p.Cerrado = 1  
				where dp.IDEmpleado = e.IDEmpleado and dp.IDConcepto in (select item from app.Split(vb.ConceptosDias,',')) ),0) as Dias  
	into #tempData  
	from @dtEmpleadosTrabajables e  
	cross join Nomina.tblConfigReporteVariablesBimestrales vb with (nolock)   
  
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
		,SalarioDiario  
    
		,case when Vales > ((@UMA * case when CriterioDias = 0 then Dias else @diasBimestre end)*0.40) then Vales - ((@UMA * case when CriterioDias = 0 then Dias else @diasBimestre end)*0.40)  
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
		,c.Departamento  
		,c.Sucursal  
		,c.Puesto  
		,c.IDRegPatronal  
		,c.RegPatronal  
		,CASE WHEN (((isnull(c.ConceptosValesDespensa,0)+ isnull(c.ConceptosPremioPuntualidad,0)+   
			isnull(c.ConceptosPremioAsistencia,0)+ isnull(c.HorasExtrasDobles,0)+ isnull(c.IntegrablesVariables,0))  
			)) = 0 then 'NO GENERA M/S' else cast(c.Factor as varchar) END Factor  
		,c.SalarioDiario  
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
	into #tempDone  
	from #tempcalc c  
  
  --select * from #tempDone  
  
 -- if(@Aplicar = 1)  
 -- BEGIN  
 --  insert into IMSS.tblMovAfiliatorios(  
 --      Fecha  
 --     ,IDEmpleado  
 --     ,IDTipoMovimiento  
 --     ,IDRazonMovimiento  
 --     ,SalarioDiario  
 --     ,SalarioIntegrado  
 --     ,SalarioVariable  
	--  ,SalarioDiarioReal
 --     ,IDRegPatronal)  
 --  select DiaAplicacion  
 --   ,IDEmpleado  
 --   ,(Select top 1 IDTipoMovimiento from IMSS.tblCatTipoMovimientos where Codigo = 'M')  
 --   ,IDRazonMovimiento  
 --   ,SalarioDiario  
 --   ,SalarioIntegrado  
 --   ,SalarioVariable 
	--,SalarioDiarioReal 
 --   ,IDRegPatronal  
 --  from #tempDone d  
 --  where not exists(select 1 from IMSS.tblMovAfiliatorios where IDEmpleado = d.IDEmpleado and Fecha = d.DiaAplicacion and IDTipoMovimiento = (Select top 1 IDTipoMovimiento from IMSS.tblCatTipoMovimientos where Codigo = 'M') )  
 --  and Factor not like '%NO GENERA M/S%'  
 -- END  
  
 -- select * from #tempDone


	if(@Aplicar = 1)  
	BEGIN  
		select distinct
			d.DiaAplicacion  
			,d.IDEmpleado  
			,(Select top 1 IDTipoMovimiento from IMSS.tblCatTipoMovimientos where Codigo = 'M') IDTipoMovimiento 
			,d.IDRazonMovimiento  
			,d.SalarioDiario  
			,d.SalarioIntegrado  
			,d.SalarioVariable 
			,d.SalarioDiarioReal 
			,d.IDRegPatronal  
			,ROW_NUMBER()OVER(Partition by d.DiaAplicacion,d.IDEmpleado order by d.IDEmpleado asc)RN
		into #temp
		from #tempDone d  
			--, (Select top 1 * 
			--			from imss.tblMovAfiliatorios m
			--			where m.Fecha < d.DiaAplicacion 
			--				and m.IDEmpleado = d.IDEmpleado
			--				and m.IDTipoMovimiento = (Select top 1 IDTipoMovimiento from IMSS.tblCatTipoMovimientos where Codigo = 'M')
			--			order by Fecha desc
			--			) as p
			left join (select * from imss.tblMovAfiliatorios m where m.IDTipoMovimiento = (Select top 1 IDTipoMovimiento from IMSS.tblCatTipoMovimientos where Codigo = 'M')
			) p on p.IDEmpleado = d.IDEmpleado and p.Fecha < d.DiaAplicacion
	
		where not exists(select 1 from IMSS.tblMovAfiliatorios where IDEmpleado = d.IDEmpleado and Fecha = d.DiaAplicacion and IDTipoMovimiento = (Select top 1 IDTipoMovimiento from IMSS.tblCatTipoMovimientos where Codigo = 'M') )  
			 and ((d.SalarioDiario <> ISNULL(p.SalarioDiario, 0) ) or (d.SalarioVariable <> ISNULL( p.SalarioVariable , 0 ) ) or (d.SalarioIntegrado <> ISNULL(p.SalarioIntegrado,0)))
			 and (Factor not like '%NO GENERA M/S%' or 
			 (CAST(d.SalarioIntegrado AS DECIMAL(10,2)) <>
			 isnull((select top(1) CAST(MA.SalarioIntegrado AS DECIMAL(10,2)) from IMSS.tblMovAfiliatorios MA where d.IDEmpleado = MA.IDEmpleado
										and Fecha <= @fechaInicioBimestre
										and MA.IDTipoMovimiento = (Select top 1 IDTipoMovimiento from IMSS.tblCatTipoMovimientos where Codigo = 'M') 
										order by Fecha desc),0))
										)

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
		select 
			DiaAplicacion  
			,IDEmpleado  
			,IDTipoMovimiento 
			,IDRazonMovimiento  
			,SalarioDiario  
			,SalarioIntegrado  
			,SalarioVariable 
			,SalarioDiarioReal 
			,IDRegPatronal 
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
	
	 --Where evita la duplicidad.
	END
	
	select * ,  
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
	from #tempDone  
		cross apply Nomina.tblConfigReporteVariablesBimestrales  
	Order by ClaveEmpleado asc  


  
END
GO
