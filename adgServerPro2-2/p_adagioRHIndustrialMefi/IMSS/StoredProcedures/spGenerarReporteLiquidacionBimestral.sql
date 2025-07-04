USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- exec [IMSS].[spGenerarReporteLiquidacionBimestral] 2018,1,null,null,'','','','','1',''

--select * from RH.tblCatRegPatronal


CREATE PROCEDURE [IMSS].[spGenerarReporteLiquidacionBimestral]
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
	@dtDivisiones Varchar(max) = ''
)
AS
BEGIN
	SET FMTONLY OFF
	DECLARE @dtEmpleadosVigentes RH.dtEmpleados,
			@dtEmpleadosTrabajables RH.dtEmpleados,
			@FechaIni Date = getdate(),
			@Fechafin Date = getdate(),
			@SalarioMinimo decimal(18,2),
			@UMA Decimal(18,2),
			@fechaInicioBimestre date,
			@fechaFinBimestre date,
			@diasBimestre int,
			@Filtros Nomina.dtFiltrosRH,
			@DescripcionBimestre Varchar(MAX),
			@CesantiaVejezPatronal bit

	insert into @Filtros(Catalogo,Value)
	values('Departamentos',@dtDepartamentos)

	insert into @Filtros(Catalogo,Value)
	values('Sucursales',@dtSucursales)
	
	insert into @Filtros(Catalogo,Value)
	values('Puestos',@dtPuestos)

	insert into @Filtros(Catalogo,Value)
	values('ClasificacionesCorporativas',@dtClasificacionesCorporativas)
		
	insert into @Filtros(Catalogo,Value)
	values('RegPatronales',@dtRegPatronales)

	insert into @Filtros(Catalogo,Value)
	values('Divisiones',@dtDivisiones)

		select top 1 @CesantiaVejezPatronal = ISNULL(valor,'0') from App.tblConfiguracionesGenerales where IDConfiguracion = 'CesantiaVejezPatronal'       


		select @fechaInicioBimestre = min(DATEADD(month,IDMes-1,DATEADD(year,@Ejercicio-1900,0))) 
			   , @fechaFinBimestre=MAX(DATEADD(day,-1,DATEADD(month,IDMes,DATEADD(year,@Ejercicio-1900,0)))) 
		from Nomina.tblCatMeses
		where cast(IDMes as varchar) in (select item from app.Split( (select top 1 meses from Nomina.tblCatBimestres where IDBimestre = @IDBimestre),','))
	
	--select @fechaInicioBimestre,@fechaFinBimestre

		set @diasBimestre = DATEDIFF(DAY, @fechaInicioBimestre, @fechaFinBimestre) +1

		select @DescripcionBimestre = Descripcion from Nomina.tblCatBimestres where IDBimestre = @IDBimestre

		set @EmpleadoIni = case when isnull(@EmpleadoIni,'') = '' then '0' else @EmpleadoIni end
		set @EmpleadoFin = case when isnull(@EmpleadoFin,'') = '' then 'ZZZZZZZZZZZZZZZZZZZZ' else @EmpleadoFin end

		select top 1 @SalarioMinimo = SalarioMinimo,
					@UMA = UMA 
		from Nomina.tblSalariosMinimos
		where Year(Fecha) = @Ejercicio
		order by Fecha desc


	if OBJECT_ID('tempdb..#tempData') is not null
		drop table #tempData
	if OBJECT_ID('tempdb..#tempData2') is not null
		drop table #tempData2
	if OBJECT_ID('tempdb..#tempData3') is not null
		drop table #tempData3
	if OBJECT_ID('tempdb..#tempData4') is not null
		drop table #tempData4
	if OBJECT_ID('tempdb..#tempDataRegPatronal') is not null
		drop table #tempDataRegPatronal
		if OBJECT_ID('tempdb..#empleadosDentro') is not null
		drop table #empleadosDentro
	if OBJECT_ID('tempdb..#empleadosDentroFecha') is not null
		drop table #empleadosDentroFecha	
		
	--if OBJECT_ID('tempdb..#tempcalc') is not null
	--	drop table #tempcalc
	--if OBJECT_ID('tempdb..#tempDone') is not null
	--	drop table #tempDone


	
	DECLARE @tempAusentismosAfectaSua as table(
		IDIncidencia Varchar(10)
	);

	INSERT INTO @tempAusentismosAfectaSua(IDIncidencia)
	SELECT IDIncidencia 
	FROM Asistencia.tblCatIncidencias 
	where isnull(AfectaSUA,0) = 1
		

	SELECT   
	  RP.IDRegPatronal  
	  ,RP.[RegistroPatronal]  
	  ,RP.RazonSocial  
	  ,RP.ActividadEconomica  
	  ,isnull(RP.IDClaseRiesgo,0) as IDClaseRiesgo  
	  ,'['+CR.Codigo+'] '+CR.Descripcion AS ClaseRiesgo  
	  ,isnull(RP.IDCodigoPostal,0) as IDCodigoPostal  
	  ,CP.CodigoPostal  
	  ,isnull(RP.IDEstado,0) as IDEstado  
	  ,'['+E.Codigo+'] '+E.NombreEstado as Estado  
	  ,isnull(RP.IDMunicipio,0) as IDMunicipio  
	  ,'['+M.Codigo+'] '+M.Descripcion as Municipio  
	  ,isnull(RP.IDColonia,0) as IDColonia  
	  ,'['+CL.Codigo+'] '+CL.NombreAsentamiento as Colonia  
	  ,isnull(RP.IDPais,0) as IDPais  
	  ,'['+P.Codigo+'] '+P.Descripcion as Pais  
	  ,RP.Calle  
	  ,RP.Exterior  
	  ,RP.Interior  
	  ,RP.Telefono  
	  ,isnull(RP.ConvenioSubsidios,cast(0 as bit)) as ConvenioSubsidios  
	  ,RP.DelegacionIMSS  
	  ,RP.SubDelegacionIMSS  
	  ,RP.FechaAfiliacion  
	  ,RP.RepresentanteLegal  
	  ,RP.OcupacionRepLegal 
	  into #tempDataRegPatronal 
	 FROM [RH].[tblCatRegPatronal] RP  
	  LEFT join Sat.tblCatCodigosPostales CP  
	   on RP.IDCodigoPostal = CP.IDCodigoPostal  
	  LEFT join Sat.tblCatPaises P  
	   on RP.IDPais = p.IDPais  
	  LEFT join Sat.tblCatEstados E  
	   on RP.IDEstado = E.IDEstado  
	  LEFT join Sat.tblCatMunicipios M  
	   on RP.IDMunicipio = m.IDMunicipio  
	  LEFT join Sat.tblCatColonias CL  
	   on RP.IDColonia = CL.IDColonia  
	  LEFT join IMSS.tblCatClaseRiesgo CR  
	   on CR.IDClaseRiesgo = RP.IDClaseRiesgo  
	 WHERE ((RP.IDRegPatronal in (select Item from app.Split(@dtRegPatronales,','))))  
	 ORDER BY RP.[RazonSocial] ASC  





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


	if object_id('tempdb..#tempMovAfil2') is not null    
    drop table #tempMovAfil2    
    
	select IDEmpleado, FechaAlta, FechaBaja,FechaMovimientoSalario,            
		  case when ((FechaBaja is not null and FechaReingreso is not null) and FechaReingreso > FechaBaja) then FechaReingreso else null end as FechaReingreso            
		  ,IDMovAfiliatorio    
	   into #tempMovAfil2            
		  from (select distinct tm.IDEmpleado,            
			case when(IDEmpleado is not null) then (select top 1 Fecha             
					 from [IMSS].[tblMovAfiliatorios]  mAlta WITH(NOLOCK)            
					join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mAlta.IDTipoMovimiento=c.IDTipoMovimiento            
					 where mAlta.IDEmpleado=tm.IDEmpleado and c.Codigo='A' 
						and mAlta.IDRegPatronal in (select item from app.Split(@dtRegPatronales,',')) 
						and mAlta.Fecha between @fechaInicioBimestre and @fechaFinBimestre             
					 Order By mAlta.Fecha Desc , c.Prioridad DESC ) end as FechaAlta,            
			case when (IDEmpleado is not null) then (select top 1 Fecha             
					 from [IMSS].[tblMovAfiliatorios]  mBaja WITH(NOLOCK)            
					join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mBaja.IDTipoMovimiento=c.IDTipoMovimiento            
					 where mBaja.IDEmpleado=tm.IDEmpleado and c.Codigo='B'    
					 and mBaja.IDRegPatronal in (select item from app.Split(@dtRegPatronales,','))          
				   and mBaja.Fecha between @fechaInicioBimestre and @fechaFinBimestre            
		  order by mBaja.Fecha desc, C.Prioridad desc) end as FechaBaja,            
			case when (IDEmpleado is not null) then (select top 1 Fecha             
					 from [IMSS].[tblMovAfiliatorios]  mReingreso WITH(NOLOCK)            
					join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mReingreso.IDTipoMovimiento=c.IDTipoMovimiento            
					 where mReingreso.IDEmpleado=tm.IDEmpleado and c.Codigo='R'   
					 and mReingreso.IDRegPatronal in (select item from app.Split(@dtRegPatronales,','))               
					and mReingreso.Fecha between @fechaInicioBimestre and @fechaFinBimestre               
					order by mReingreso.Fecha desc, C.Prioridad desc) end as FechaReingreso   
			  , case when (IDEmpleado is not null) then (select top 1 Fecha             
					 from [IMSS].[tblMovAfiliatorios]  mSalario WITH(NOLOCK)            
					join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mSalario.IDTipoMovimiento=c.IDTipoMovimiento            
					 where mSalario.IDEmpleado=tm.IDEmpleado and c.Codigo='M'   
					  and mSalario.IDRegPatronal in (select item from app.Split(@dtRegPatronales,','))             
				   and mSalario.Fecha between @fechaInicioBimestre and @fechaFinBimestre               
					order by mSalario.Fecha desc, C.Prioridad desc) end as FechaMovimientoSalario            
			,(Select top 1 mSalario.IDMovAfiliatorio from [IMSS].[tblMovAfiliatorios]  mSalario WITH(NOLOCK)            
					join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mSalario.IDTipoMovimiento=c.IDTipoMovimiento            
					 where mSalario.IDEmpleado=tm.IDEmpleado and c.Codigo in ('A','M','R')    
					  and mSalario.IDRegPatronal in (select item from app.Split(@dtRegPatronales,','))  
					  and mSalario.Fecha between @fechaInicioBimestre and @fechaFinBimestre            
					 order by mSalario.Fecha desc ) as IDMovAfiliatorio                                             
			from [IMSS].[tblMovAfiliatorios]  tm ) mm    

	--select @FechaIni,@Fechafin,@EmpleadoIni,@EmpleadoIni
	--select * from @Filtros

	Insert into @dtEmpleadosVigentes
	Exec RH.spBuscarEmpleados @FechaIni = @fechaInicioBimestre
							 ,@Fechafin = @fechaFinBimestre
							 ,@EmpleadoIni =@EmpleadoIni
							 ,@EmpleadoFin = @EmpleadoFin
							 ,@dtFiltros= @Filtros	
							,@IDUsuario = 1
	--select * from @dtEmpleadosVigentes
    --return
	
	select ev.* 
		  , SUM( CASE  WHEN ( RE.FechaIni between @fechaInicioBimestre and @fechaFinBimestre) and ( RE.FechaFin between @fechaInicioBimestre and @fechaFinBimestre) THEN DATEDIFF(DAY,RE.FechaIni, RE.FechaFin)+1    
         WHEN ( RE.FechaIni between @fechaInicioBimestre and @fechaFinBimestre) and  ( RE.FechaFin >= @fechaFinBimestre)THEN DATEDIFF(DAY,RE.FechaIni,@fechaFinBimestre)+1    
         WHEN ( RE.FechaIni <= @fechaInicioBimestre) and  ( RE.FechaFin Between @fechaInicioBimestre and @fechaFinBimestre)THEN DATEDIFF(DAY,@fechaInicioBimestre,RE.FechaFin)+1    
         WHEN ( RE.FechaIni <= @fechaInicioBimestre) and  (  RE.FechaFin <= @fechaInicioBimestre)THEN @diasBimestre  
         ELSE @diasBimestre    
         END) AS DiasenRegPatronal
		into #tempData
	from @dtEmpleadosVigentes ev
		inner join RH.tblRegPatronalEmpleado RE WITH(NOLOCK)   
			on RE.IDEmpleado = EV.IDEmpleado
			and RE.IDRegPatronal = ev.IDRegPatronal
	GROUP BY
	Ev.[IDEmpleado]									
	,Ev.[ClaveEmpleado]									
	,Ev.[RFC]											
	,Ev.[CURP]											
	,Ev.[IMSS]											
	,Ev.[Nombre]										
	,Ev.[SegundoNombre]									
	,Ev.[Paterno]										
	,Ev.[Materno]										
	,Ev.[NOMBRECOMPLETO]								
	,Ev.[IDLocalidadNacimiento]							
	,Ev.[LocalidadNacimiento]							
	,Ev.[IDMunicipioNacimiento]							
	,Ev.[MunicipioNacimiento]							
	,Ev.[IDEstadoNacimiento]							
	,Ev.[EstadoNacimiento]								
	,Ev.[IDPaisNacimiento]								
	,Ev.[PaisNacimiento]								
	,Ev.[FechaNacimiento]								
	,Ev.[IDEstadoCiviL]									
	,Ev.[EstadoCivil]									
	,Ev.[Sexo]											
	,Ev.[IDEscolaridad]									
	,Ev.[Escolaridad]									
	,Ev.[DescripcionEscolaridad]						
	,Ev.[IDInstitucion]									
	,Ev.[Institucion]									
	,Ev.[IDProbatorio]									
	,Ev.[Probatorio]									
	,Ev.[FechaPrimerIngreso]							
	,Ev.[FechaIngreso]									
	,Ev.[FechaAntiguedad]								
	,Ev.[Sindicalizado]									
	,Ev.[IDJornadaLaboral]								
	,Ev.[JornadaLaboral]								
	,Ev.[UMF]											
	,Ev.[CuentaContable]								
	,Ev.[IDTipoRegimen]									
	,Ev.[TipoRegimen]									
	,Ev.[IDPreferencia]									
	,Ev.[IDDepartamento]								
	,Ev.[Departamento]									
	,Ev.[IDSucursal]									
	,Ev.[Sucursal]										
	,Ev.[IDPuesto]										
	,Ev.[Puesto]										
	,Ev.[IDCliente]										
	,Ev.[Cliente]										
	,Ev.[IDEmpresa]										
	,Ev.[Empresa]										
	,Ev.[IDCentroCosto]									
	,Ev.[CentroCosto]									
	,Ev.[IDArea]										
	,Ev.[Area]											
	,Ev.[IDDivision]									
	,Ev.[Division]										
	,Ev.[IDRegion]										
	,Ev.[Region]										
	,Ev.[IDClasificacionCorporativa]					
	,Ev.[ClasificacionCorporativa]						
	,Ev.[IDRegPatronal]									
	,Ev.[RegPatronal]									
	,Ev.[IDTipoNomina]									
	,Ev.[TipoNomina]									
	,Ev.[SalarioDiario]									
	,Ev.[SalarioDiarioReal]								
	,Ev.[SalarioIntegrado]								
	,Ev.[SalarioVariable]								
	,Ev.[IDTipoPrestacion]								
	,Ev.[IDRazonSocial]									
	,Ev.[RazonSocial]									
	,Ev.[IDAfore]										
	,Ev.[Afore]											
	,Ev.[Vigente]										
	,Ev.[RowNumber]										
	,Ev.[ClaveNombreCompleto]							
	,Ev.[PermiteChecar]									
	,Ev.[RequiereChecar]								
	,Ev.[PagarTiempoExtra]								
	,Ev.[PagarPrimaDominical]							
	,Ev.[PagarDescansoLaborado]							
	,Ev.[PagarFestivoLaborado]							
	,Ev.[IDDocumento]									
	,Ev.[Documento]										
	,Ev.[IDTipoContrato]								
	,Ev.[TipoContrato]									
	,Ev.[FechaIniContrato]								
	,Ev.[FechaFinContrato]								
	,Ev.[tiposPrestacion]								
	,Ev.[tipoTrabajadorEmpleado]								

	select distinct
	
		data.IDEmpleado
		,data.ClaveEmpleado
		,data.NOMBRECOMPLETO as NombreCompleto
		,data.IMSS
		,data.RFC
		,data.CURP
		,data.IDRazonSocial
		,data.IDSucursal
		,data.IDRegPatronal
		,isnull(mov.SalarioIntegrado,data.SalarioIntegrado) as SalarioIntegrado
		,data.DiasenRegPatronal
		,case when tmov.Codigo = 'A' then 'Alta'
				when tmov.Codigo = 'B' then 'Baja'
				when tmov.Codigo = 'R' then 'Reingreso'
				when tmov.Codigo = 'M' then 'M/S'
			Else null
			end as tipoMovimiento
		,tMov.Codigo as CodigoMov
		,@fechaInicioBimestre as fechaInicioBimestre
		,@fechaFinBimestre as fechaFinBimestre
		,mov.Fecha as fechaMov
		--,fMovAfil.FechaAlta
		--,fMovAfil.FechaBaja
		--,fMovAfil.FechaReingreso
		--,fMovAfil.FechaMovimientoSalario
	    ,isnull((select max(fecha)
		from IMSS.tblMovAfiliatorios m
			inner join IMSS.tblCatTipoMovimientos tm
				on m.IDTipoMovimiento = tm.IDTipoMovimiento
		where IDEmpleado = data.IDEmpleado
			and fecha < mov.Fecha
			and m.IDRegPatronal in (select item from app.Split(@dtRegPatronales,','))  ),'1900-01-01') FechaMovAnterior
		,isnull((select min(fecha)
		from IMSS.tblMovAfiliatorios m
			inner join IMSS.tblCatTipoMovimientos tm
				on m.IDTipoMovimiento = tm.IDTipoMovimiento
		where IDEmpleado = data.IDEmpleado
			and fecha > mov.Fecha
			and m.IDRegPatronal in (select item from app.Split(@dtRegPatronales,','))  ), '9999-12-31')FechaMovPosterior
		,0 as ESTA
		into #tempdata2
	from #tempData data
		cross apply Nomina.tblCatBimestres b WITH(NOLOCK)   
	left join Nomina.tblCatPeriodos p WITH(NOLOCK)   
		on p.IDMes in (select item from app.Split(b.Meses,','))
	left join Nomina.tblDetallePeriodo dp WITH(NOLOCK)   
		on data.IDEmpleado = dp.IDEmpleado
		and p.IDPeriodo = dp.IDPeriodo
	left join IMSS.tblMovAfiliatorios mov WITH(NOLOCK)   
		on data.IDEmpleado = mov.IDEmpleado
		 and mov.Fecha <=  @fechaFinBimestre
		 and mov.fecha >= data.FechaAntiguedad
		 and mov.IDRegPatronal  in (select item from app.Split(@dtRegPatronales,','))
	left join imss.tblCatTipoMovimientos tMov WITH(NOLOCK)   
		on tMov.IDTipoMovimiento = mov.IDTipoMovimiento
	 left join #tempMovAfil2 fMovAfil
		on fMovAfil.IDEmpleado = data.IDEmpleado	   
	where p.Ejercicio = @Ejercicio
	and b.IDBimestre = @IDBimestre	
	order by data.ClaveEmpleado, mov.Fecha asc



	update m1
	set 
		m1.FechaMovPosterior = CASE WHEN (m1.FechaMovPosterior < @fechaFinBimestre) and tm.Codigo <> 'B' THEN DATEADD(day,-1,m1.FechaMovPosterior)
								WHEN (m1.FechaMovPosterior < @fechaFinBimestre) and tm.Codigo = 'B' THEN DATEADD(day,0,m1.FechaMovPosterior)
		ELSE FechaMovPosterior
		end
	from #tempdata2 m1
		inner join IMSS.tblMovAfiliatorios mov WITH(NOLOCK)   
			on m1.IDEmpleado = mov.IDEmpleado
			and m1.FechaMovPosterior = mov.Fecha
			and mov.IDRegPatronal  in (select item from app.Split(@dtRegPatronales,','))
		inner join imss.tblCatTipoMovimientos tm WITH(NOLOCK)   
			on mov.IDTipoMovimiento = tm.IDTipoMovimiento



	update #tempdata2
	set Esta =
			CASE WHEN (FechaMovAnterior between @fechaInicioBimestre and @fechaFinBimestre) 
				OR(FechaMovPosterior between @fechaInicioBimestre and @fechaFinBimestre)
				OR(fechaMov between @fechaInicioBimestre and @fechaFinBimestre) THEN 1 
				ELSE 0 END 
		--,FechaMovPosterior = CASE WHEN (FechaMovPosterior between @fechaInicioBimestre and @fechaFinBimestre) and FechaMovPosterior < @fechaFinBimestre THEN DATEADD(day,-1,FechaMovPosterior)
		--ELSE FechaMovPosterior
		--end

	SELECT IDEmpleado,SUM(Esta) SUMAMov
		into #empleadosDentro
	from #tempdata2 
	GROUP BY IDEmpleado

	--select * from #empleadosDentro


	select IDEmpleado, MAX(fechaMov) Fechamov
	into #empleadosDentroFecha
	from #tempdata2
	where IDEmpleado in (
	select IDEmpleado from #empleadosDentro where SUMAMov = 0
	)
	Group by IDEmpleado

	update t2
		set ESTA = 1
	from #tempdata2 t2
		inner join #empleadosDentroFecha df
			on t2.IDEmpleado = df.IDEmpleado
			and t2.fechaMov = df.Fechamov
			and t2.CodigoMov <> 'B'


	
			 /* CUOTA FIJA 20.4%  500*/  
			 /*  CESANTIA Y VEJEZ PATRON  508*/  
			  /*  Seguro de Retiro  509*/
			   /*  Infonavit  510*/  






	select 
		 t.IDEmpleado
		,t.ClaveEmpleado
		,t.NombreCompleto
		,t.IMSS
		,t.RFC
		,t.CURP
		,t.IDRazonSocial
		,t.IDRegPatronal
		,t.IDSucursal
		,t.SalarioIntegrado
		,t.CodigoMov
		,t.tipoMovimiento
		,t.fechaMov
		,t.DiasenRegPatronal
	  , (case when   t.CodigoMov is null  then DATEDIFF(DAY,@fechaInicioBimestre,@fechaFinBimestre)+1
			
			 when  t.CodigoMov in('B')  then 0
			 when  t.CodigoMov in('M','A','R') and   ( t.fechaMov  <= @fechaInicioBimestre) and  (t.FechaMovPosterior between @fechaInicioBimestre and @fechaFinBimestre) then datediff(day, @fechaInicioBimestre,dateadd(day,0,  t.FechaMovPosterior))+1	
			 when  t.CodigoMov in('M','A','R') and   ( t.fechaMov  <= @fechaInicioBimestre) and  (t.FechaMovPosterior not between @fechaInicioBimestre and @fechaFinBimestre) then datediff(day, @fechaInicioBimestre,dateadd(day,0,  @fechaFinBimestre))+1	
			 when  t.CodigoMov in('M','A','R') and   ( t.fechaMov  > @fechaInicioBimestre) and  (t.FechaMovPosterior  between @fechaInicioBimestre and @fechaFinBimestre) then datediff(day, t.fechaMov,dateadd(day,0,  t.FechaMovPosterior))+1	
			 when  t.CodigoMov in('M','A','R') and   ( t.fechaMov  > @fechaInicioBimestre) and  (t.FechaMovPosterior  not between @fechaInicioBimestre and @fechaFinBimestre) then datediff(day, t.fechaMov,dateadd(day,0,  @fechaFinBimestre))+1	
			else  t.DiasenRegPatronal
		END)--- 
		--(case when t.CodigoMov is null  then (select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia in( 'F','P','S') and  Fecha between @fechaInicioBimestre and @fechaFinBimestre and t.IDEmpleado = IDEmpleado and Autorizado = 1 )
		--	 when t.CodigoMov in('B')  then 0
		--	  when  t.CodigoMov in('M','A','R') and   ( t.fechaMov  <= @fechaInicioBimestre) and  (t.FechaMovPosterior between @fechaInicioBimestre and @fechaFinBimestre) then (select count(*) from Asistencia.tblIncidenciaEmpleado where  IDIncidencia in( 'F','P','S') and Fecha between @fechaInicioBimestre and FechaMovPosterior and t.IDEmpleado = IDEmpleado and Autorizado = 1 )	
		--	 when  t.CodigoMov in('M','A','R') and   ( t.fechaMov  <= @fechaInicioBimestre) and  (t.FechaMovPosterior not between @fechaInicioBimestre and @fechaFinBimestre) then  (select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia in( 'F','P','S') and Fecha between @fechaInicioBimestre and @fechaFinBimestre and t.IDEmpleado = IDEmpleado and Autorizado = 1 )		
		--	 when  t.CodigoMov in('M','A','R') and   ( t.fechaMov  > @fechaInicioBimestre) and  (t.FechaMovPosterior  between @fechaInicioBimestre and @fechaFinBimestre) then (select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia in( 'F','P','S') and Fecha between t.fechaMov and t.FechaMovPosterior and t.IDEmpleado = IDEmpleado and Autorizado = 1 )		
		--	 when  t.CodigoMov in('M','A','R') and   ( t.fechaMov  > @fechaInicioBimestre) and  (t.FechaMovPosterior  not between @fechaInicioBimestre and @fechaFinBimestre) then (select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia in( 'F','P','S') and Fecha between t.fechaMov and @fechaFinBimestre and t.IDEmpleado = IDEmpleado and Autorizado = 1 )			
		--	 else 0
		--END) 
		 as Dias

		 , case when t.CodigoMov is null  then (select count(*) from Asistencia.tblIncidenciaEmpleado IE WITH(NOLOCK)  JOIN Asistencia.tblIncapacidadEmpleado Inca WITH(NOLOCK)  on IE.IDIncapacidadEmpleado = Inca.IDIncapacidadEmpleado where IE.IDIncidencia = 'I' and  IE.Fecha between @fechaInicioBimestre and @fechaFinBimestre and t.IDEmpleado = IE.IDEmpleado and IE.Autorizado = 1 and Inca.IDTipoIncapacidad = 2)
			 when t.CodigoMov in('B')  then 0
			  when t.CodigoMov in('M','A','R') and   ( t.fechaMov  <= @fechaInicioBimestre) and  (t.FechaMovPosterior between @fechaInicioBimestre and @fechaFinBimestre)  then (select count(*) from Asistencia.tblIncidenciaEmpleado IE WITH(NOLOCK)  JOIN Asistencia.tblIncapacidadEmpleado Inca WITH(NOLOCK)  on IE.IDIncapacidadEmpleado = Inca.IDIncapacidadEmpleado  where IE.IDIncidencia = 'I' and IE.Fecha between @fechaInicioBimestre and FechaMovPosterior and t.IDEmpleado = IE.IDEmpleado and IE.Autorizado = 1  and Inca.IDTipoIncapacidad = 2)
			 when  t.CodigoMov in('M','A','R') and   ( t.fechaMov  <= @fechaInicioBimestre) and  (t.FechaMovPosterior not between @fechaInicioBimestre and @fechaFinBimestre) then (select count(*) from Asistencia.tblIncidenciaEmpleado IE  WITH(NOLOCK) JOIN Asistencia.tblIncapacidadEmpleado Inca WITH(NOLOCK)  on IE.IDIncapacidadEmpleado = Inca.IDIncapacidadEmpleado  where IE.IDIncidencia = 'I' and IE.Fecha between @fechaInicioBimestre and @fechaFinBimestre and t.IDEmpleado = IE.IDEmpleado and IE.Autorizado = 1  and Inca.IDTipoIncapacidad = 2)
			 when t.CodigoMov in('M','A','R') and   ( t.fechaMov  > @fechaInicioBimestre) and  (t.FechaMovPosterior  between @fechaInicioBimestre and @fechaFinBimestre)  then  (select count(*) from Asistencia.tblIncidenciaEmpleado IE WITH(NOLOCK)  JOIN Asistencia.tblIncapacidadEmpleado Inca WITH(NOLOCK)  on IE.IDIncapacidadEmpleado = Inca.IDIncapacidadEmpleado  where IE.IDIncidencia = 'I' and IE.Fecha between t.fechaMov and t.FechaMovPosterior and t.IDEmpleado = IE.IDEmpleado and IE.Autorizado = 1 and Inca.IDTipoIncapacidad = 2)
			 when t.CodigoMov in('M','A','R') and   ( t.fechaMov  > @fechaInicioBimestre) and  (t.FechaMovPosterior  not between @fechaInicioBimestre and @fechaFinBimestre)  then  (select count(*) from Asistencia.tblIncidenciaEmpleado IE WITH(NOLOCK) JOIN Asistencia.tblIncapacidadEmpleado Inca WITH(NOLOCK)  on IE.IDIncapacidadEmpleado = Inca.IDIncapacidadEmpleado   where IE.IDIncidencia = 'I' and IE.Fecha between t.fechaMov and @fechaFinBimestre and t.IDEmpleado = IE.IDEmpleado and IE.Autorizado = 1 and Inca.IDTipoIncapacidad = 2)
			 else 0
		END Incapacidades

		 , case when t.CodigoMov is null  then (select count(*) from Asistencia.tblIncidenciaEmpleado IE WITH(NOLOCK) JOIN Asistencia.tblIncapacidadEmpleado Inca WITH(NOLOCK) on IE.IDIncapacidadEmpleado = Inca.IDIncapacidadEmpleado where IE.IDIncidencia = 'I' and  IE.Fecha between @fechaInicioBimestre and @fechaFinBimestre and t.IDEmpleado = IE.IDEmpleado and IE.Autorizado = 1 and Inca.IDTipoIncapacidad = 3)
			 when t.CodigoMov in('B')  then 0
			  when t.CodigoMov in('M','A','R') and   ( t.fechaMov  <= @fechaInicioBimestre) and  (t.FechaMovPosterior between @fechaInicioBimestre and @fechaFinBimestre)  then (select count(*) from Asistencia.tblIncidenciaEmpleado IE WITH(NOLOCK) JOIN Asistencia.tblIncapacidadEmpleado Inca WITH(NOLOCK) on IE.IDIncapacidadEmpleado = Inca.IDIncapacidadEmpleado  where IE.IDIncidencia = 'I' and IE.Fecha between @fechaInicioBimestre and FechaMovPosterior and t.IDEmpleado = IE.IDEmpleado and IE.Autorizado = 1  and Inca.IDTipoIncapacidad = 3)
			 when  t.CodigoMov in('M','A','R') and   ( t.fechaMov  <= @fechaInicioBimestre) and  (t.FechaMovPosterior not between @fechaInicioBimestre and @fechaFinBimestre) then (select count(*) from Asistencia.tblIncidenciaEmpleado IE WITH(NOLOCK) JOIN Asistencia.tblIncapacidadEmpleado Inca WITH(NOLOCK) on IE.IDIncapacidadEmpleado = Inca.IDIncapacidadEmpleado  where IE.IDIncidencia = 'I' and IE.Fecha between @fechaInicioBimestre and @fechaFinBimestre and t.IDEmpleado = IE.IDEmpleado and IE.Autorizado = 1  and Inca.IDTipoIncapacidad = 3)
			 when t.CodigoMov in('M','A','R') and   ( t.fechaMov  > @fechaInicioBimestre) and  (t.FechaMovPosterior  between @fechaInicioBimestre and @fechaFinBimestre)  then  (select count(*) from Asistencia.tblIncidenciaEmpleado IE WITH(NOLOCK)JOIN Asistencia.tblIncapacidadEmpleado Inca WITH(NOLOCK) on IE.IDIncapacidadEmpleado = Inca.IDIncapacidadEmpleado  where IE.IDIncidencia = 'I' and IE.Fecha between t.fechaMov and t.FechaMovPosterior and t.IDEmpleado = IE.IDEmpleado and IE.Autorizado = 1 and Inca.IDTipoIncapacidad = 3)
			 when t.CodigoMov in('M','A','R') and   ( t.fechaMov  > @fechaInicioBimestre) and  (t.FechaMovPosterior  not between @fechaInicioBimestre and @fechaFinBimestre)  then  (select count(*) from Asistencia.tblIncidenciaEmpleado IE WITH(NOLOCK) JOIN Asistencia.tblIncapacidadEmpleado Inca WITH(NOLOCK) on IE.IDIncapacidadEmpleado = Inca.IDIncapacidadEmpleado   where IE.IDIncidencia = 'I' and IE.Fecha between t.fechaMov and @fechaFinBimestre and t.IDEmpleado = IE.IDEmpleado and IE.Autorizado = 1 and Inca.IDTipoIncapacidad = 3)
			 else 0
		END IncapacidadesMaternidad
		
		 , case when t.CodigoMov is null  then (select count(*) from Asistencia.tblIncidenciaEmpleado IE WITH(NOLOCK) JOIN Asistencia.tblIncapacidadEmpleado Inca WITH(NOLOCK) on IE.IDIncapacidadEmpleado = Inca.IDIncapacidadEmpleado where IE.IDIncidencia = 'I' and  IE.Fecha between @fechaInicioBimestre and @fechaFinBimestre and t.IDEmpleado = IE.IDEmpleado and IE.Autorizado = 1 and Inca.IDTipoIncapacidad = 1)
			 when t.CodigoMov in('B')  then 0
			  when t.CodigoMov in('M','A','R') and   ( t.fechaMov  <= @fechaInicioBimestre) and  (t.FechaMovPosterior between @fechaInicioBimestre and @fechaFinBimestre)  then (select count(*) from Asistencia.tblIncidenciaEmpleado IE  WITH(NOLOCK) JOIN Asistencia.tblIncapacidadEmpleado Inca WITH(NOLOCK) on IE.IDIncapacidadEmpleado = Inca.IDIncapacidadEmpleado  where IE.IDIncidencia = 'I' and IE.Fecha between @fechaInicioBimestre and FechaMovPosterior and t.IDEmpleado = IE.IDEmpleado and IE.Autorizado = 1  and Inca.IDTipoIncapacidad = 1)
			 when  t.CodigoMov in('M','A','R') and   ( t.fechaMov  <= @fechaInicioBimestre) and  (t.FechaMovPosterior not between @fechaInicioBimestre and @fechaFinBimestre) then (select count(*) from Asistencia.tblIncidenciaEmpleado IE WITH(NOLOCK) JOIN Asistencia.tblIncapacidadEmpleado Inca WITH(NOLOCK) on IE.IDIncapacidadEmpleado = Inca.IDIncapacidadEmpleado  where IE.IDIncidencia = 'I' and IE.Fecha between @fechaInicioBimestre and @fechaFinBimestre and t.IDEmpleado = IE.IDEmpleado and IE.Autorizado = 1  and Inca.IDTipoIncapacidad = 1)
			 when t.CodigoMov in('M','A','R') and   ( t.fechaMov  > @fechaInicioBimestre) and  (t.FechaMovPosterior  between @fechaInicioBimestre and @fechaFinBimestre)  then  (select count(*) from Asistencia.tblIncidenciaEmpleado IE WITH(NOLOCK) JOIN Asistencia.tblIncapacidadEmpleado Inca WITH(NOLOCK) on IE.IDIncapacidadEmpleado = Inca.IDIncapacidadEmpleado  where IE.IDIncidencia = 'I' and IE.Fecha between t.fechaMov and t.FechaMovPosterior and t.IDEmpleado = IE.IDEmpleado and IE.Autorizado = 1 and Inca.IDTipoIncapacidad = 1)
			 when t.CodigoMov in('M','A','R') and   ( t.fechaMov  > @fechaInicioBimestre) and  (t.FechaMovPosterior  not between @fechaInicioBimestre and @fechaFinBimestre)  then  (select count(*) from Asistencia.tblIncidenciaEmpleado IE WITH(NOLOCK) JOIN Asistencia.tblIncapacidadEmpleado Inca WITH(NOLOCK) on IE.IDIncapacidadEmpleado = Inca.IDIncapacidadEmpleado   where IE.IDIncidencia = 'I' and IE.Fecha between t.fechaMov and @fechaFinBimestre and t.IDEmpleado = IE.IDEmpleado and IE.Autorizado = 1 and Inca.IDTipoIncapacidad = 1)
			 else 0
		END IncapacidadesRT

		, case when t.CodigoMov is null  then (select count(*) from Asistencia.tblIncidenciaEmpleado WITH(NOLOCK) where IDIncidencia in( SELECT IDIncidencia from @tempAusentismosAfectaSua) and  Fecha between @fechaInicioBimestre and @fechaFinBimestre and t.IDEmpleado = IDEmpleado and Autorizado = 1 )
			 when t.CodigoMov in('B')  then 0
			  when  t.CodigoMov in('M','A','R') and   ( t.fechaMov  <= @fechaInicioBimestre) and  (t.FechaMovPosterior between @fechaInicioBimestre and @fechaFinBimestre) then (select count(*) from Asistencia.tblIncidenciaEmpleado WITH(NOLOCK) where IDIncidencia in( SELECT IDIncidencia from @tempAusentismosAfectaSua) and Fecha between @fechaInicioBimestre and FechaMovPosterior and t.IDEmpleado = IDEmpleado and Autorizado = 1 )	
			 when  t.CodigoMov in('M','A','R') and   ( t.fechaMov  <= @fechaInicioBimestre) and  (t.FechaMovPosterior not between @fechaInicioBimestre and @fechaFinBimestre) then  (select count(*) from Asistencia.tblIncidenciaEmpleado WITH(NOLOCK) where IDIncidencia in( SELECT IDIncidencia from @tempAusentismosAfectaSua) and Fecha between @fechaInicioBimestre and @fechaFinBimestre and t.IDEmpleado = IDEmpleado and Autorizado = 1 )		
			 when  t.CodigoMov in('M','A','R') and   ( t.fechaMov  > @fechaInicioBimestre) and  (t.FechaMovPosterior  between @fechaInicioBimestre and @fechaFinBimestre) then (select count(*) from Asistencia.tblIncidenciaEmpleado WITH(NOLOCK) where IDIncidencia in( SELECT IDIncidencia from @tempAusentismosAfectaSua) and Fecha between t.fechaMov and t.FechaMovPosterior and t.IDEmpleado = IDEmpleado and Autorizado = 1 )		
			 when  t.CodigoMov in('M','A','R') and   ( t.fechaMov  > @fechaInicioBimestre) and  (t.FechaMovPosterior  not between @fechaInicioBimestre and @fechaFinBimestre) then (select count(*) from Asistencia.tblIncidenciaEmpleado WITH(NOLOCK) where IDIncidencia in( SELECT IDIncidencia from @tempAusentismosAfectaSua) and Fecha between t.fechaMov and @fechaFinBimestre and t.IDEmpleado = IDEmpleado and Autorizado = 1 )			
			 else 0
		END Faltas
		, (Select top 1 Prima             
				from [RH].[tblHistorialPrimaRiesgo]   WITH(NOLOCK)           
				where IDRegPatronal in (select Item from app.Split(@dtRegPatronales,','))           
				and Anio <= @Ejercicio            
				--and Mes <= @IDMes            
				order by Anio desc,Mes desc) as PrimaRiesgo  

	into #tempData3
	from #tempdata2 t
	where ESTA = 1
	order by t.ClaveEmpleado asc, t.fechaMov asc


	update #tempData3
	set Faltas = CASE WHEN Faltas > 14 THEN 14 ELSE Faltas END
	
	update #tempData3
	set Dias = Dias - CASE WHEN Faltas > 14 THEN 14 ELSE Faltas END


	select  t.*
		  ,CASE WHEN isnull(Dias,0) > 0 THEN ((((SalarioIntegrado * SeguroRetiro) * (Dias - isnull(case when Faltas > 7 then 7 else Faltas end,0) ))/DiasenRegPatronal)*@diasBimestre) else 0 end as Retiro
		  ,((( (SalarioIntegrado * (CASE WHEN ISNULL(@CesantiaVejezPatronal,0) = 0 THEN CesantiaVejezPatron ELSE [IMSS].[fnGetCesantiaVejezPatronal](t.IDEmpleado, t.IDSucursal, SalarioIntegrado, @fechaFinBimestre ) END)) * (DiasenRegPatronal - (isnull(case when Faltas > 7 then 7 else Faltas end,0) + isnull(Incapacidades,0)) ) )/DiasenRegPatronal)*Dias) as CesantiaVejezPatronal
		  ,((((SalarioIntegrado * CesantiaVejezObrera) * (DiasenRegPatronal- (isnull(case when Faltas > 7 then 7 else Faltas end,0) +isnull(Incapacidades,0))))/DiasenRegPatronal)*Dias) as CesantiaVejezObrera
		  ,((((SalarioIntegrado * Infonavit) * (DiasenRegPatronal - isnull(case when Faltas > 7 then 7 else Faltas end,0) ) )/DiasenRegPatronal)*Dias) as AportacionPatronal

		,(select MAX( dp.IDReferencia) as  IDReferencia  
			from Nomina.tblDetallePeriodo dp WITH(NOLOCK)   
				inner join Nomina.tblCatConceptos c WITH(NOLOCK)   
					on dp.IDConcepto = c.IDConcepto
				inner join Nomina.tblCatPeriodos p WITH(NOLOCK)   
					on dp.IDPeriodo = p.IDPeriodo
		  where t.IDEmpleado = IDEmpleado
				and c.Descripcion = 'CREDITO INFONAVIT'
				and c.Codigo = '304'
				and p.Ejercicio = @Ejercicio
				and p.Cerrado = 1
				and p.IDMes in (select item from app.Split((select top 1 meses from Nomina.tblCatBimestres WITH(NOLOCK)    where IDBimestre = @IDBimestre),','))
		) as IDCreditoInfonavit
		,case when (select sum( dp.ImporteTotal1)  
					from Nomina.tblDetallePeriodo dp WITH(NOLOCK)   
						inner join Nomina.tblCatConceptos c WITH(NOLOCK)   
							on dp.IDConcepto = c.IDConcepto
						inner join Nomina.tblCatPeriodos p WITH(NOLOCK)   
							on dp.IDPeriodo = p.IDPeriodo
				  where t.IDEmpleado = IDEmpleado
						and c.Descripcion = 'CREDITO INFONAVIT'
						and c.Codigo = '304'
						and p.Ejercicio = @Ejercicio
						and p.Cerrado = 1
						and p.IDMes in (select item from app.Split((select top 1 meses from Nomina.tblCatBimestres WITH(NOLOCK)    where IDBimestre = @IDBimestre),','))
		) > 0 then (((select sum( dp.ImporteTotal1)  
			from Nomina.tblDetallePeriodo dp WITH(NOLOCK)   
				inner join Nomina.tblCatConceptos c WITH(NOLOCK)   
					on dp.IDConcepto = c.IDConcepto
				inner join Nomina.tblCatPeriodos p WITH(NOLOCK)   
					on dp.IDPeriodo = p.IDPeriodo
		  where t.IDEmpleado = IDEmpleado
				and c.Descripcion in( 'CREDITO INFONAVIT','SEGURO DE VIVIENDA')
				and c.Codigo in( '304','305')
				and p.Ejercicio = @Ejercicio
				and p.Cerrado = 1
				and p.IDMes in (select item from app.Split((select top 1 meses from Nomina.tblCatBimestres WITH(NOLOCK)    where IDBimestre = @IDBimestre),','))
		)/DiasenRegPatronal)*Dias)
		else 0 end as Amortizacion
		into #tempData4
	from #tempData3 t
		,(select top 1 *            
					from [IMSS].[tblCatPorcentajesPago]            
					where Fecha <= @fechaFinBimestre            
					order by Fecha desc) as PorcentajesPago   	
	order by t.ClaveEmpleado asc, t.fechaMov asc
--select * from #tempData4

	select t.*
		, case when td.Codigo = 2 /*Cuota Fija Monetaria*/then '$ '+cast(ie.ValorDescuento as varchar(100)) 
				when td.Codigo = 1 /*Porcentaje*/then '% '+cast(ie.ValorDescuento as varchar(100)) 
				when td.Codigo = 3 /*Factor de Descuento*/then 'FD '+cast(ie.ValorDescuento as varchar(100)) 
			ELSE null
		 END as Descuento
		 ,IE.NumeroCredito
		 ,case when tm.Codigo =  '15' /*Inicio de Crédito de Vivienda (ICV)*/then 'ICV'
				when tm.Codigo = '16' /*Fecha de Suspensión de Descuento (FS)*/then 'FSD' 
				when tm.Codigo = '17' /*Reinicio de Descuento (RD)*/then 'RD'
				when tm.Codigo = '18' /*Modificación de Tipo de Descuento (MTD)*/then 'MTD'
				when tm.Codigo = '19' /*Modificación de Valor de Descuento (MVD)*/then 'MVD'
				when tm.Codigo = '20' /*Modificación de Número de Crédito (MND)*/then 'MNC'
			ELSE null
		 END as TipoMovimientoInfonavit
		 ,IE.Fecha as FechaMovCredito
	 
		 ,RP.RegistroPatronal
		 ,RP.RazonSocial
		 ,RP.ActividadEconomica
		 ,RP.Calle
		 ,RP.CodigoPostal
		 ,RP.Estado
		 ,RP.DelegacionIMSS
		 ,RP.SubDelegacionIMSS
		 ,RP.Municipio
		 ,RP.ConvenioSubsidios
		 ,RS.RFC as RFCRazonSocial
		 ,sm.SalarioMinimo
		 ,sm.UMA
		 ,sm.FactorDescuento
		 ,cast(sm.Fecha as date) as FechaSalarioMinimo 
		 ,(pp.Infonavit * 100) cuotaAportacionInfonavitPatron
		 ,@DescripcionBimestre +' - '+ cast(@ejercicio as varchar(100)) bimestre
	from #tempData4 t
		left join rh.tblInfonavitEmpleado IE WITH(NOLOCK)   
			on t.IDCreditoInfonavit = IE.IDInfonavitEmpleado
		left join rh.tblCatInfonavitTipoMovimiento tm WITH(NOLOCK)   
			on ie.IDTipoMovimiento = tm.IDTipoMovimiento
		left join rh.tblCatInfonavitTipoDescuento td WITH(NOLOCK)   
			on ie.IDTipoDescuento = td.IDTipoDescuento
		left join #tempDataRegPatronal RP
			on RP.IDRegPatronal = t.IDRegPatronal
		left join RH.tblCatRazonesSociales RS WITH(NOLOCK)   
			on RS.IDRazonSocial = T.IDRazonSocial
	   , (select top 1 * from Nomina.tblSalariosMinimos WITH(NOLOCK)   
			where year(Fecha) = @Ejercicio
			order by Fecha desc) sm
	  ,(select top 1 * from IMSS.tblCatPorcentajesPago WITH(NOLOCK)   
			where year(Fecha) = @Ejercicio
			order by Fecha desc) PP
	
	order by t.ClaveEmpleado asc, t.fechaMov asc

END
GO
