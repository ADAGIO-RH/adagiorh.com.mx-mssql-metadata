USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	AJUSTES PARA CSM
	JOSEPH ROMAN
	2021-02-16

	NO MOVER..!!!
*/

CREATE PROCEDURE [IMSS].[spGenerarReporteLiquidacionMensual]
(
	@Ejercicio int,
	@IDMes int,
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
	DECLARE 
		@dtEmpleadosVigentes RH.dtEmpleados,
		@dtEmpleadosTrabajables RH.dtEmpleados,
		@FechaIni Date  ,
		@Fechafin Date ,
		@SalarioMinimo decimal(18,2),
		@UMA Decimal(18,2),
		@fechaInicioBimestre date,
		@fechaFinBimestre date,
		@diasBimestre int,
		@Filtros Nomina.dtFiltrosRH,
		@DescripcionBimestre Varchar(MAX),
		@Tope25UMA decimal(18,4),            
		@Tope3UMA decimal(18,4),
		@IDIdioma varchar(20) = 'esmx',
        @dtFechas app.dtFechas,
        @IDRegPatronal int = 0
	;

	insert into @Filtros(Catalogo,Value)
	values('Departamentos',@dtDepartamentos)
		,('Sucursales',@dtSucursales)
		,('Puestos',@dtPuestos)
		,('ClasificacionesCorporativas',@dtClasificacionesCorporativas)
		--,('RegPatronales',@dtRegPatronales)
		,('Divisiones',@dtDivisiones)

    Select @IDRegPatronal = (select item from app.Split(@dtRegPatronales,','))


    if (ISNULL(@IDRegPatronal,0) = 0)
    BEGIN
        RAISERROR('Debe seleccionar un Registro Patronal',16,1);
        RETURN;
    END


	Select @FechaIni =  min(DATEADD(month,@IDMes-1,DATEADD(year,@Ejercicio-1900,0))) 
	Select @Fechafin = MAX(DATEADD(day,-1,DATEADD(month,@IDMes,DATEADD(year,@Ejercicio-1900,0))))

	select @fechaInicioBimestre = min(DATEADD(month,IDMes-1,DATEADD(year,@Ejercicio-1900,0))) 
			, @fechaFinBimestre=MAX(DATEADD(day,-1,DATEADD(month,IDMes,DATEADD(year,@Ejercicio-1900,0)))) 
	from Nomina.tblCatMeses
	where IDMes = @IDMes
	
	--select @fechaInicioBimestre,@fechaFinBimestre

	set @diasBimestre = DATEDIFF(DAY, @fechaInicioBimestre, @fechaFinBimestre) +1

	select @DescripcionBimestre = JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) 
	from Nomina.tblCatMeses where IDMes = @IDMes

	set @EmpleadoIni = case when isnull(@EmpleadoIni,'') = '' then '0' else @EmpleadoIni end
	set @EmpleadoFin = case when isnull(@EmpleadoFin,'') = '' then 'ZZZZZZZZZZZZZZZZZZZZ' else @EmpleadoFin end

	select top 1 @UMA = UMA ,@SalarioMinimo = SalarioMinimo
				,@Tope25UMA = UMA * 25            
				,@Tope3UMA  = UMA *3 
	from Nomina.tblSalariosMinimos
	where Year(Fecha) = @Ejercicio and Fecha <= cast(@Fechafin as date)
	order by Fecha desc

	
	if OBJECT_ID('tempdb..#tempData')  is not null drop table #tempData
	if OBJECT_ID('tempdb..#tempData2') is not null drop table #tempData2
	if OBJECT_ID('tempdb..#tempData3') is not null drop table #tempData3
	if OBJECT_ID('tempdb..#tempData4') is not null drop table #tempData4
	if OBJECT_ID('tempdb..#tempDataRegPatronal')	is not null drop table #tempDataRegPatronal
	if OBJECT_ID('tempdb..#empleadosDentro')		is not null	drop table #empleadosDentro
	if OBJECT_ID('tempdb..#empleadosDentroFecha')	is not null drop table #empleadosDentroFecha	
	
	
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
		LEFT join Sat.tblCatCodigosPostales CP on RP.IDCodigoPostal = CP.IDCodigoPostal  
		LEFT join Sat.tblCatPaises P on RP.IDPais = p.IDPais  
		LEFT join Sat.tblCatEstados E on RP.IDEstado = E.IDEstado  
		LEFT join Sat.tblCatMunicipios M on RP.IDMunicipio = m.IDMunicipio  
		LEFT join Sat.tblCatColonias CL on RP.IDColonia = CL.IDColonia  
		LEFT join IMSS.tblCatClaseRiesgo CR on CR.IDClaseRiesgo = RP.IDClaseRiesgo  
	WHERE ((RP.IDRegPatronal in (select Item from app.Split(@dtRegPatronales,','))))  
	ORDER BY RP.[RazonSocial] ASC  

	Insert into @dtEmpleadosVigentes
	Exec RH.spBuscarEmpleados @FechaIni = @FechaIni
							 ,@Fechafin = @Fechafin
							 ,@EmpleadoIni =@EmpleadoIni
							 ,@EmpleadoFin = @EmpleadoFin
							 ,@dtFiltros= @Filtros	
							 ,@IDUsuario = 1

	INSERT INTO @dtFechas  
	EXEC [App].[spListaFechas] @FechaIni = @fechaInicioBimestre, @FechaFin = @FechaFinbimestre  

    IF object_id('tempdb..#tempVigenciaEmpleados') IS NOT NULL DROP TABLE #tempVigenciaEmpleados  
  
	CREATE TABLE #tempVigenciaEmpleados (  
		IDEmpleado int null, 
        FechaAlta Date null, 
        FechaBaja Date null,
        FechaReingreso Date null,
        FechaReingresoAntiguedad Date null,
        IDMovAfiliatorio int null,
        Fecha Date null,  
        Vigente bit null,
        IDRegPatronal int null,
		
	) 

    INSERT INTO #tempVigenciaEmpleados  
	EXEC [RH].[spBuscarListaFechasVigenciaRegPatronalEmpleado]  
		@dtEmpleados	= @dtEmpleadosVigentes  
		,@Fechas		= @dtFechas  
		,@IDUsuario		= 1
		,@IDRegPatronal =  @IDRegPatronal
   
	delete @dtEmpleadosVigentes
	where IDEmpleado not in (select IDEmpleado from #tempVigenciaEmpleados Where Vigente = 1)

    select ev.* 
		  , COUNT(VE.Vigente) AS DiasenRegPatronal
		 , ve.FechaReingresoAntiguedad
		into #tempData
	from @dtEmpleadosVigentes ev
		inner join RH.tblRegPatronalEmpleado RE
			on RE.IDEmpleado = EV.IDEmpleado
			and RE.IDRegPatronal in (select item from app.Split(@dtRegPatronales,','))
		inner join #tempVigenciaEmpleados VE
			on VE.IDEmpleado = ev.IDEmpleado AND VE.Vigente = 1
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
		,Ev.[TiposPrestacion]
		,Ev.[tipoTrabajadorEmpleado]
		, ve.FechaReingresoAntiguedad

	select distinct
		data.IDEmpleado
		,data.ClaveEmpleado
		,data.NOMBRECOMPLETO as NombreCompleto
		,data.IMSS
		,data.RFC
		,data.CURP
		,data.IDRazonSocial
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
		,mov.IDMovAfiliatorio as IDMovAfiliatorio
	    ,isnull((select max(fecha)
		from IMSS.tblMovAfiliatorios m
			inner join IMSS.tblCatTipoMovimientos tm
				on m.IDTipoMovimiento = tm.IDTipoMovimiento
		where m.IDEmpleado = data.IDEmpleado
			and m.fecha < mov.Fecha
			and m.IDRegPatronal in (select item from app.Split(@dtRegPatronales,','))  ),'1900-01-01') FechaMovAnterior
		 ,isnull((select max(IDMovAfiliatorio)
		from IMSS.tblMovAfiliatorios m
			inner join IMSS.tblCatTipoMovimientos tm
				on m.IDTipoMovimiento = tm.IDTipoMovimiento
		where IDEmpleado = data.IDEmpleado
			and m.fecha < mov.Fecha
			and m.IDRegPatronal in (select item from app.Split(@dtRegPatronales,','))  ),0) IDMovAnterior
		,isnull((select min(fecha)
		from IMSS.tblMovAfiliatorios m
			inner join IMSS.tblCatTipoMovimientos tm
				on m.IDTipoMovimiento = tm.IDTipoMovimiento
		where IDEmpleado = data.IDEmpleado
			and m.fecha > mov.Fecha
			and m.fecha <= @fechaFinBimestre
			and m.IDRegPatronal in (select item from app.Split(@dtRegPatronales,','))  ), DATEADD(DAY,-1,@FechaIni))FechaMovPosterior
		,0 as ESTA
		into #tempdata2
	from #tempData data
		cross apply Nomina.tblCatMeses b with(nolock)
	--left join Nomina.tblCatPeriodos p
	--	on p.IDMes  = b.IDMes
	--left join Nomina.tblDetallePeriodo dp
	--	on data.IDEmpleado = dp.IDEmpleado
	--	and p.IDPeriodo = dp.IDPeriodo
	left join IMSS.tblMovAfiliatorios mov with(nolock) on data.IDEmpleado = mov.IDEmpleado
		 and mov.Fecha <=  @fechaFinBimestre
		 and mov.fecha >= data.FechaReingresoAntiguedad
		 and mov.IDRegPatronal  in (select item from app.Split(@dtRegPatronales,','))
	left join imss.tblCatTipoMovimientos tMov with(nolock) on tMov.IDTipoMovimiento = mov.IDTipoMovimiento
	where b.IDMes = @IDMes
	order by data.ClaveEmpleado, mov.Fecha asc

	--select * from #tempdata2 order by IDEmpleado, fechaMov
			 /* CUOTA FIJA 20.4%  500*/  
			 /*  CESANTIA Y VEJEZ PATRON  508*/  
			  /*  Seguro de Retiro  509*/
			   /*  Infonavit  510*/  

	update m1
	set 
		m1.FechaMovPosterior = CASE WHEN (m1.FechaMovPosterior < @fechaFinBimestre) and tm.Codigo <> 'B' THEN DATEADD(day,-1,m1.FechaMovPosterior)
								WHEN (m1.FechaMovPosterior < @fechaFinBimestre) and tm.Codigo = 'B' THEN DATEADD(day,0,m1.FechaMovPosterior)
		ELSE FechaMovPosterior
		end
	from #tempdata2 m1
		inner join IMSS.tblMovAfiliatorios mov
			on m1.IDEmpleado = mov.IDEmpleado
			and m1.FechaMovPosterior = mov.Fecha
			and mov.IDRegPatronal  in (select item from app.Split(@dtRegPatronales,','))
		inner join imss.tblCatTipoMovimientos tm
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
--select * from #tempdata2


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


	--select * from #tempdata2 order by IDEmpleado, fechaMov
	--where Esta  = 1 order by NombreCompleto, fechaMov

	--DELETE #tempdata2
	
	--where IDMovAfiliatorio not in (
	--	select IDMovAfiliatorio from #tempdata2
	--	where ( (FechaMovAnterior between @fechaInicioBimestre and @fechaFinBimestre) 
	--		OR(FechaMovPosterior between @fechaInicioBimestre and @fechaFinBimestre)
	--		OR(fechaMov between @fechaInicioBimestre and @fechaFinBimestre))
	--		AND FechaMovAnterior <> '1900-01-01'
	--	)
	


select 
	 t.IDEmpleado
	,t.ClaveEmpleado
	,t.NombreCompleto
	,t.IMSS
	,t.RFC
	,t.CURP
	,t.IDRazonSocial
	,t.IDRegPatronal
	,t.SalarioIntegrado
	,t.CodigoMov
	,t.tipoMovimiento
	,t.fechaMov
	,t.FechaMovAnterior
	,t.FechaMovPosterior
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

		 , case when t.CodigoMov is null  then (select count(*) from Asistencia.tblIncidenciaEmpleado IE JOIN Asistencia.tblIncapacidadEmpleado Inca on IE.IDIncapacidadEmpleado = Inca.IDIncapacidadEmpleado where IE.IDIncidencia = 'I' and  IE.Fecha between @fechaInicioBimestre and @fechaFinBimestre and t.IDEmpleado = IE.IDEmpleado and IE.Autorizado = 1 and Inca.IDTipoIncapacidad = 2)
			 when t.CodigoMov in('B')  then 0
			  when t.CodigoMov in('M','A','R') and   ( t.fechaMov  <= @fechaInicioBimestre) and  (t.FechaMovPosterior between @fechaInicioBimestre and @fechaFinBimestre)  then (select count(*) from Asistencia.tblIncidenciaEmpleado IE JOIN Asistencia.tblIncapacidadEmpleado Inca on IE.IDIncapacidadEmpleado = Inca.IDIncapacidadEmpleado  where IE.IDIncidencia = 'I' and IE.Fecha between @fechaInicioBimestre and FechaMovPosterior and t.IDEmpleado = IE.IDEmpleado and IE.Autorizado = 1  and Inca.IDTipoIncapacidad = 2)
			 when  t.CodigoMov in('M','A','R') and   ( t.fechaMov  <= @fechaInicioBimestre) and  (t.FechaMovPosterior not between @fechaInicioBimestre and @fechaFinBimestre) then (select count(*) from Asistencia.tblIncidenciaEmpleado IE JOIN Asistencia.tblIncapacidadEmpleado Inca on IE.IDIncapacidadEmpleado = Inca.IDIncapacidadEmpleado  where IE.IDIncidencia = 'I' and IE.Fecha between @fechaInicioBimestre and @fechaFinBimestre and t.IDEmpleado = IE.IDEmpleado and IE.Autorizado = 1  and Inca.IDTipoIncapacidad = 2)
			 when t.CodigoMov in('M','A','R') and   ( t.fechaMov  > @fechaInicioBimestre) and  (t.FechaMovPosterior  between @fechaInicioBimestre and @fechaFinBimestre)  then  (select count(*) from Asistencia.tblIncidenciaEmpleado IE JOIN Asistencia.tblIncapacidadEmpleado Inca on IE.IDIncapacidadEmpleado = Inca.IDIncapacidadEmpleado  where IE.IDIncidencia = 'I' and IE.Fecha between t.fechaMov and t.FechaMovPosterior and t.IDEmpleado = IE.IDEmpleado and IE.Autorizado = 1 and Inca.IDTipoIncapacidad = 2)
			 when t.CodigoMov in('M','A','R') and   ( t.fechaMov  > @fechaInicioBimestre) and  (t.FechaMovPosterior  not between @fechaInicioBimestre and @fechaFinBimestre)  then  (select count(*) from Asistencia.tblIncidenciaEmpleado IE JOIN Asistencia.tblIncapacidadEmpleado Inca on IE.IDIncapacidadEmpleado = Inca.IDIncapacidadEmpleado   where IE.IDIncidencia = 'I' and IE.Fecha between t.fechaMov and @fechaFinBimestre and t.IDEmpleado = IE.IDEmpleado and IE.Autorizado = 1 and Inca.IDTipoIncapacidad = 2)
			 else 0
		END Incapacidades

		 , case when t.CodigoMov is null  then (select count(*) from Asistencia.tblIncidenciaEmpleado IE JOIN Asistencia.tblIncapacidadEmpleado Inca on IE.IDIncapacidadEmpleado = Inca.IDIncapacidadEmpleado where IE.IDIncidencia = 'I' and  IE.Fecha between @fechaInicioBimestre and @fechaFinBimestre and t.IDEmpleado = IE.IDEmpleado and IE.Autorizado = 1 and Inca.IDTipoIncapacidad = 3)
			 when t.CodigoMov in('B')  then 0
			  when t.CodigoMov in('M','A','R') and   ( t.fechaMov  <= @fechaInicioBimestre) and  (t.FechaMovPosterior between @fechaInicioBimestre and @fechaFinBimestre)  then (select count(*) from Asistencia.tblIncidenciaEmpleado IE JOIN Asistencia.tblIncapacidadEmpleado Inca on IE.IDIncapacidadEmpleado = Inca.IDIncapacidadEmpleado  where IE.IDIncidencia = 'I' and IE.Fecha between @fechaInicioBimestre and FechaMovPosterior and t.IDEmpleado = IE.IDEmpleado and IE.Autorizado = 1  and Inca.IDTipoIncapacidad = 3)
			 when  t.CodigoMov in('M','A','R') and   ( t.fechaMov  <= @fechaInicioBimestre) and  (t.FechaMovPosterior not between @fechaInicioBimestre and @fechaFinBimestre) then (select count(*) from Asistencia.tblIncidenciaEmpleado IE JOIN Asistencia.tblIncapacidadEmpleado Inca on IE.IDIncapacidadEmpleado = Inca.IDIncapacidadEmpleado  where IE.IDIncidencia = 'I' and IE.Fecha between @fechaInicioBimestre and @fechaFinBimestre and t.IDEmpleado = IE.IDEmpleado and IE.Autorizado = 1  and Inca.IDTipoIncapacidad = 3)
			 when t.CodigoMov in('M','A','R') and   ( t.fechaMov  > @fechaInicioBimestre) and  (t.FechaMovPosterior  between @fechaInicioBimestre and @fechaFinBimestre)  then  (select count(*) from Asistencia.tblIncidenciaEmpleado IE JOIN Asistencia.tblIncapacidadEmpleado Inca on IE.IDIncapacidadEmpleado = Inca.IDIncapacidadEmpleado  where IE.IDIncidencia = 'I' and IE.Fecha between t.fechaMov and t.FechaMovPosterior and t.IDEmpleado = IE.IDEmpleado and IE.Autorizado = 1 and Inca.IDTipoIncapacidad = 3)
			 when t.CodigoMov in('M','A','R') and   ( t.fechaMov  > @fechaInicioBimestre) and  (t.FechaMovPosterior  not between @fechaInicioBimestre and @fechaFinBimestre)  then  (select count(*) from Asistencia.tblIncidenciaEmpleado IE JOIN Asistencia.tblIncapacidadEmpleado Inca on IE.IDIncapacidadEmpleado = Inca.IDIncapacidadEmpleado   where IE.IDIncidencia = 'I' and IE.Fecha between t.fechaMov and @fechaFinBimestre and t.IDEmpleado = IE.IDEmpleado and IE.Autorizado = 1 and Inca.IDTipoIncapacidad = 3)
			 else 0
		END IncapacidadesMaternidad
		
		 , case when t.CodigoMov is null  then (select count(*) from Asistencia.tblIncidenciaEmpleado IE JOIN Asistencia.tblIncapacidadEmpleado Inca on IE.IDIncapacidadEmpleado = Inca.IDIncapacidadEmpleado where IE.IDIncidencia = 'I' and  IE.Fecha between @fechaInicioBimestre and @fechaFinBimestre and t.IDEmpleado = IE.IDEmpleado and IE.Autorizado = 1 and Inca.IDTipoIncapacidad = 1)
			 when t.CodigoMov in('B')  then 0
			  when t.CodigoMov in('M','A','R') and   ( t.fechaMov  <= @fechaInicioBimestre) and  (t.FechaMovPosterior between @fechaInicioBimestre and @fechaFinBimestre)  then (select count(*) from Asistencia.tblIncidenciaEmpleado IE JOIN Asistencia.tblIncapacidadEmpleado Inca on IE.IDIncapacidadEmpleado = Inca.IDIncapacidadEmpleado  where IE.IDIncidencia = 'I' and IE.Fecha between @fechaInicioBimestre and FechaMovPosterior and t.IDEmpleado = IE.IDEmpleado and IE.Autorizado = 1  and Inca.IDTipoIncapacidad = 1)
			 when  t.CodigoMov in('M','A','R') and   ( t.fechaMov  <= @fechaInicioBimestre) and  (t.FechaMovPosterior not between @fechaInicioBimestre and @fechaFinBimestre) then (select count(*) from Asistencia.tblIncidenciaEmpleado IE JOIN Asistencia.tblIncapacidadEmpleado Inca on IE.IDIncapacidadEmpleado = Inca.IDIncapacidadEmpleado  where IE.IDIncidencia = 'I' and IE.Fecha between @fechaInicioBimestre and @fechaFinBimestre and t.IDEmpleado = IE.IDEmpleado and IE.Autorizado = 1  and Inca.IDTipoIncapacidad = 1)
			 when t.CodigoMov in('M','A','R') and   ( t.fechaMov  > @fechaInicioBimestre) and  (t.FechaMovPosterior  between @fechaInicioBimestre and @fechaFinBimestre)  then  (select count(*) from Asistencia.tblIncidenciaEmpleado IE JOIN Asistencia.tblIncapacidadEmpleado Inca on IE.IDIncapacidadEmpleado = Inca.IDIncapacidadEmpleado  where IE.IDIncidencia = 'I' and IE.Fecha between t.fechaMov and t.FechaMovPosterior and t.IDEmpleado = IE.IDEmpleado and IE.Autorizado = 1 and Inca.IDTipoIncapacidad = 1)
			 when t.CodigoMov in('M','A','R') and   ( t.fechaMov  > @fechaInicioBimestre) and  (t.FechaMovPosterior  not between @fechaInicioBimestre and @fechaFinBimestre)  then  (select count(*) from Asistencia.tblIncidenciaEmpleado IE JOIN Asistencia.tblIncapacidadEmpleado Inca on IE.IDIncapacidadEmpleado = Inca.IDIncapacidadEmpleado   where IE.IDIncidencia = 'I' and IE.Fecha between t.fechaMov and @fechaFinBimestre and t.IDEmpleado = IE.IDEmpleado and IE.Autorizado = 1 and Inca.IDTipoIncapacidad = 1)
			 else 0
		END IncapacidadesRT

		, case when t.CodigoMov is null  then (select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia in( SELECT IDIncidencia from @tempAusentismosAfectaSua) and  Fecha between @fechaInicioBimestre and @fechaFinBimestre and t.IDEmpleado = IDEmpleado and Autorizado = 1 )
			 when t.CodigoMov in('B')  then 0
			  when  t.CodigoMov in('M','A','R') and   ( t.fechaMov  <= @fechaInicioBimestre) and  (t.FechaMovPosterior between @fechaInicioBimestre and @fechaFinBimestre) then (select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia in( SELECT IDIncidencia from @tempAusentismosAfectaSua) and Fecha between @fechaInicioBimestre and FechaMovPosterior and t.IDEmpleado = IDEmpleado and Autorizado = 1 )	
			 when  t.CodigoMov in('M','A','R') and   ( t.fechaMov  <= @fechaInicioBimestre) and  (t.FechaMovPosterior not between @fechaInicioBimestre and @fechaFinBimestre) then  (select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia in( SELECT IDIncidencia from @tempAusentismosAfectaSua) and Fecha between @fechaInicioBimestre and @fechaFinBimestre and t.IDEmpleado = IDEmpleado and Autorizado = 1 )		
			 when  t.CodigoMov in('M','A','R') and   ( t.fechaMov  > @fechaInicioBimestre) and  (t.FechaMovPosterior  between @fechaInicioBimestre and @fechaFinBimestre) then (select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia in( SELECT IDIncidencia from @tempAusentismosAfectaSua) and Fecha between t.fechaMov and t.FechaMovPosterior and t.IDEmpleado = IDEmpleado and Autorizado = 1 )		
			 when  t.CodigoMov in('M','A','R') and   ( t.fechaMov  > @fechaInicioBimestre) and  (t.FechaMovPosterior  not between @fechaInicioBimestre and @fechaFinBimestre) then (select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia in( SELECT IDIncidencia from @tempAusentismosAfectaSua) and Fecha between t.fechaMov and @fechaFinBimestre and t.IDEmpleado = IDEmpleado and Autorizado = 1 )			
			 else 0
		END Faltas
		, (Select top 1 Prima             
				from [RH].[tblHistorialPrimaRiesgo]             
				where IDRegPatronal in (select Item from app.Split(@dtRegPatronales,','))           
				and Anio <= @Ejercicio            
				--and Mes <= @IDMes            
				order by Anio desc,Mes desc) as PrimaRiesgo    
			
	into #tempData3
from #tempdata2 t
where ESTA = 1
     
order by t.ClaveEmpleado asc, t.fechaMov asc



update #tempData3
	set Faltas = CASE WHEN Faltas > 7 THEN 7 ELSE Faltas END
	
update #tempData3
	set Dias = Dias - CASE WHEN Faltas > 7 THEN 7 ELSE Faltas END

--select * from #tempData3 order by NombreCompleto, fechaMov
--
--, Dias = CASE WHEN (Dias - (Faltas)) <= 0 THEN 0 ELSE Dias - (Faltas) END

	--select * from @dtEmpleadosVigentes where IDEmpleado not in (
	--select IDEmpleado from #tempData3)

--delete #tempData3
--where
--   ((FechaMovAnterior between @fechaInicioBimestre and @fechaFinBimestre) 
--			OR(FechaMovPosterior between @fechaInicioBimestre and @fechaFinBimestre)
--			OR(fechaMov between @fechaInicioBimestre and @fechaFinBimestre)
--		)



select  t.*
	  ,CASE WHEN T.codigoMov = 'B' then 0 else  ((((@UMA*CuotaFija)))*((Dias+Faltas)- (isnull(Incapacidades,0)+isnull(IncapacidadesMaternidad,0)+isnull(IncapacidadesRT,0)))) END as CuotaFija 
	  ,CASE WHEN T.codigoMov = 'B' then 0 else  (((CASE when SalarioIntegrado > @Tope3UMA then ((SalarioIntegrado-@Tope3UMA) * ExcedentePatronal)else 0 end))*((Dias+Faltas)- (isnull(Incapacidades,0)+isnull(IncapacidadesMaternidad,0)+isnull(IncapacidadesRT,0)))) END as ExcedentePatronal
	  ,CASE WHEN T.codigoMov = 'B' then 0 else  (CASE when SalarioIntegrado > @Tope3UMA then ((SalarioIntegrado-@Tope3UMA) * ExcedenteObrera) * ((Dias+Faltas)- (isnull(Incapacidades,0)+isnull(IncapacidadesMaternidad,0)+isnull(IncapacidadesRT,0))) else 0 end)/*/DiasenRegPatronal)*Dias)*/ END as ExcedenteObrera
	  ,CASE WHEN T.codigoMov = 'B' then 0 else  ((((SalarioIntegrado * PrestacionesDineroPatronal)))*((Dias+Faltas)- (isnull(Incapacidades,0)+isnull(IncapacidadesMaternidad,0)+isnull(IncapacidadesRT,0)))) END as PrestacionesDineroPatronal
	  ,CASE WHEN T.codigoMov = 'B' then 0 else  ((SalarioIntegrado * PrestacionesDineroObrera) * ((Dias+Faltas) - (isnull(Incapacidades,0)+isnull(IncapacidadesMaternidad,0)+isnull(IncapacidadesRT,0)))) END as PrestacionesDineroObrera
	  ,CASE WHEN T.codigoMov = 'B' then 0 else  ((SalarioIntegrado * ReservaPensionado) * ((Dias+Faltas)- (isnull(Incapacidades,0)+isnull(IncapacidadesMaternidad,0)+isnull(IncapacidadesRT,0)))) END as GMPensionadosPatronal
	  ,CASE WHEN T.codigoMov = 'B' then 0 else  ((SalarioIntegrado * GMPensionadosObrera) * ((Dias+Faltas) - (isnull(Incapacidades,0)+isnull(IncapacidadesMaternidad,0)+isnull(IncapacidadesRT,0)))) END as GMPensionadosObrera
	  ,CASE WHEN T.codigoMov = 'B' then 0 else  ((SalarioIntegrado * PrimaRiesgo) *  ((Dias+Faltas) - (isnull(case when Faltas > 7 then 7 else Faltas end,0) + (isnull(Incapacidades,0)+isnull(IncapacidadesMaternidad,0)+isnull(IncapacidadesRT,0)) ) )) END as RiesgoTrabajo
	  ,CASE WHEN T.codigoMov = 'B' then 0 else  ((SalarioIntegrado * InvalidezVidaPatronal) * ((Dias+Faltas)- (isnull(case when Faltas > 7 then 7 else Faltas end,0)+isnull(Incapacidades,0)+isnull(IncapacidadesMaternidad,0)+isnull(IncapacidadesRT,0)))) END as InvalidezVidaPatronal
	  ,CASE WHEN T.codigoMov = 'B' then 0 else  ((SalarioIntegrado * InvalidezVidaObrera) * ((Dias+Faltas)- (isnull(case when Faltas > 7 then 7 else Faltas end,0) +isnull(Incapacidades,0)+isnull(IncapacidadesMaternidad,0)+isnull(IncapacidadesRT,0))) ) END as InvalidezVidaObrera
	  ,CASE WHEN T.codigoMov = 'B' then 0 else  ((SalarioIntegrado * GuarderiasPrestacionesSociales) * ((Dias+Faltas) - (isnull(case when Faltas > 7 then 7 else Faltas end,0) + isnull(Incapacidades,0)+isnull(IncapacidadesMaternidad,0)+isnull(IncapacidadesRT,0)) ) ) END as GuarderiaPrestacionesSociales

	into #tempData4
from #tempData3 t
,(select top 1 *            
				from [IMSS].[tblCatPorcentajesPago]            
				where Fecha <= @fechaFinBimestre            
				order by Fecha desc) as PorcentajesPago 
	
order by t.NombreCompleto asc, t.fechaMov asc


update #tempData4
	set Dias = Dias - ( Incapacidades + IncapacidadesMaternidad + IncapacidadesRT),
		Incapacidades = Incapacidades + IncapacidadesMaternidad + IncapacidadesRT

--select * from #tempData4

select t.*

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
	 ,'' as RFCRazonSocial
	 ,sm.SalarioMinimo
	 ,sm.UMA
	 ,sm.FactorDescuento
	 ,cast(sm.Fecha as date) as FechaSalarioMinimo 
	 ,@DescripcionBimestre +' - '+ cast(@ejercicio as varchar(100)) bimestre
from #tempData4 t
	
	left join #tempDataRegPatronal RP
		on RP.IDRegPatronal in (select Item from app.Split(@dtRegPatronales,','))   
   , (select top 1 * from Nomina.tblSalariosMinimos
		where year(Fecha) = @Ejercicio
		order by Fecha desc) sm
  ,(select top 1 * from IMSS.tblCatPorcentajesPago
		where year(Fecha) = @Ejercicio
		order by Fecha desc) PP
	
order by t.NombreCompleto asc, t.fechaMov asc

END
GO
