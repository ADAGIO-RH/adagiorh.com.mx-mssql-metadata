USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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
		@Tope25UMA decimal(18,4),            
		@Tope3UMA decimal(18,4)   

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




		select @fechaInicioBimestre = min(DATEADD(month,IDMes-1,DATEADD(year,@Ejercicio-1900,0))) 
			   , @fechaFinBimestre=MAX(DATEADD(day,-1,DATEADD(month,IDMes,DATEADD(year,@Ejercicio-1900,0)))) 
		from Nomina.tblCatMeses
		where IDMes = @IDMes
	
	--select @fechaInicioBimestre,@fechaFinBimestre

		set @diasBimestre = DATEDIFF(DAY, @fechaInicioBimestre, @fechaFinBimestre) +1

		select @DescripcionBimestre = Descripcion from Nomina.tblCatMeses where IDMes = @IDMes

		set @EmpleadoIni = case when isnull(@EmpleadoIni,'') = '' then '0' else @EmpleadoIni end
		set @EmpleadoFin = case when isnull(@EmpleadoFin,'') = '' then 'ZZZZZZZZZZZZZZZZZZ' else @EmpleadoFin end

		select top 1 @SalarioMinimo = SalarioMinimo
					,@UMA = UMA 
					,@Tope25UMA = UMA * 25            
					,@Tope3UMA  = UMA *3 
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

		
	--if OBJECT_ID('tempdb..#tempcalc') is not null
	--	drop table #tempcalc
	--if OBJECT_ID('tempdb..#tempDone') is not null
	--	drop table #tempDone
		

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
	Exec RH.spBuscarEmpleados @FechaIni = @FechaIni
							 ,@Fechafin = @Fechafin
							 ,@EmpleadoIni =@EmpleadoIni
							 ,@EmpleadoFin = @EmpleadoFin
							 ,@dtFiltros= @Filtros	
							 ,@IDUsuario = 1
	
	
	select ev.* 
		  , SUM( CASE  WHEN ( RE.FechaIni between @fechaInicioBimestre and @fechaFinBimestre) and ( RE.FechaFin between @fechaInicioBimestre and @fechaFinBimestre) THEN DATEDIFF(DAY,RE.FechaIni, RE.FechaFin)+1    
         WHEN ( RE.FechaIni between @fechaInicioBimestre and @fechaFinBimestre) and  ( RE.FechaFin >= @fechaFinBimestre)THEN DATEDIFF(DAY,RE.FechaIni,@fechaFinBimestre)+1    
         WHEN ( RE.FechaIni <= @fechaInicioBimestre) and  ( RE.FechaFin Between @fechaInicioBimestre and @fechaFinBimestre)THEN DATEDIFF(DAY,@fechaInicioBimestre,RE.FechaFin)+1    
         WHEN ( RE.FechaIni <= @fechaInicioBimestre) and  (  RE.FechaFin <= @fechaInicioBimestre)THEN @diasBimestre  
         ELSE @diasBimestre    
         END) AS DiasenRegPatronal
		into #tempData
	from @dtEmpleadosVigentes ev
		inner join RH.tblRegPatronalEmpleado RE
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
	,Ev.[TiposPrestacion]
	,Ev.[tipoTrabajadorEmpleado]
	 
	 




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
		into #tempdata2
	from #tempData data
		cross apply Nomina.tblCatMeses b
	left join Nomina.tblCatPeriodos p
		on p.IDMes  = b.IDMes
	left join Nomina.tblDetallePeriodo dp
		on data.IDEmpleado = dp.IDEmpleado
		and p.IDPeriodo = dp.IDPeriodo
	left join IMSS.tblMovAfiliatorios mov
		on data.IDEmpleado = mov.IDEmpleado
		 and mov.Fecha between @fechaInicioBimestre and @fechaFinBimestre
		 and mov.IDRegPatronal = data.IDRegPatronal
	left join imss.tblCatTipoMovimientos tMov
		on tMov.IDTipoMovimiento = mov.IDTipoMovimiento
	 left join #tempMovAfil2 fMovAfil
		on fMovAfil.IDEmpleado = data.IDEmpleado

		   
	where p.Ejercicio = @Ejercicio
	and b.IDMes = @IDMes
			
	order by data.ClaveEmpleado, mov.Fecha asc

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
	,t.SalarioIntegrado
	,t.CodigoMov
	,t.tipoMovimiento
	,t.fechaMov
	,t.DiasenRegPatronal
	 , (case when   t.CodigoMov is null  then DATEDIFF(DAY,@fechaInicioBimestre,@fechaFinBimestre)+1
			 when  t.CodigoMov in ('A','R') and   ( t.FechaMovPosterior between @fechaInicioBimestre and @fechaFinBimestre)  then datediff(day, t.fechaMov,dateadd(day,-1,  t.FechaMovPosterior))	+1
			 when  t.CodigoMov in ('A','R') and   ( t.FechaMovPosterior not between @fechaInicioBimestre and @fechaFinBimestre)  then datediff(day, t.fechaMov,@fechaFinBimestre)+1	
			 when  t.CodigoMov in('B')  then 0
			 when  t.CodigoMov in('M') and   ( t.FechaMovPosterior  between @fechaInicioBimestre and @fechaFinBimestre)  then datediff(day, t.fechaMov,dateadd(day,-1,  t.FechaMovPosterior))+1	
			 when  t.CodigoMov in('M') and    ( t.FechaMovPosterior  not between @fechaInicioBimestre and @fechaFinBimestre)  then datediff(day, t.fechaMov,@fechaFinBimestre)+1	
			 when  t.CodigoMov in('M') and  ( t.FechaMovAnterior between @fechaInicioBimestre and @fechaFinBimestre) and  ( t.FechaMovPosterior  not between @fechaInicioBimestre and @fechaFinBimestre)  then datediff(day, t.fechaMov,@fechaFinBimestre)	+1 
			 when  t.CodigoMov in('M') and  ( t.FechaMovAnterior not between @fechaInicioBimestre and @fechaFinBimestre) and  ( t.FechaMovPosterior  between @fechaInicioBimestre and @fechaFinBimestre)  then datediff(day, t.fechaMov,dateadd(day,-1,  t.FechaMovPosterior) )	+1 
			 else  t.DiasenRegPatronal
		END)-(case when t.CodigoMov is null  then (select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'F' and  Fecha between @fechaInicioBimestre and @fechaFinBimestre and t.IDEmpleado = IDEmpleado and Autorizado = 1 )
			 when t.CodigoMov in ('A','R') and   (t.FechaMovPosterior between @fechaInicioBimestre and @fechaFinBimestre)  then (select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'F' and Fecha between t.fechaMov and dateadd(day,-1, FechaMovPosterior) and t.IDEmpleado = IDEmpleado and Autorizado = 1 )
			 when t.CodigoMov in ('A','R') and   (t.FechaMovPosterior not between @fechaInicioBimestre and @fechaFinBimestre)  then (select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'F' and Fecha between t.fechaMov and @fechaFinBimestre and t.IDEmpleado = IDEmpleado and Autorizado = 1 )
			 when t.CodigoMov in('B')  then 0
			 when t.CodigoMov in('M') and   (t.FechaMovPosterior  between @fechaInicioBimestre and @fechaFinBimestre)  then (select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'F' and Fecha between t.fechaMov and dateadd(day,-1, FechaMovPosterior) and t.IDEmpleado = IDEmpleado and Autorizado = 1 )
			 when t.CodigoMov in('M') and    (t.FechaMovPosterior  not between @fechaInicioBimestre and @fechaFinBimestre)  then  (select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'F' and Fecha between t.fechaMov and @fechaFinBimestre and t.IDEmpleado = IDEmpleado and Autorizado = 1 )
			 when t.CodigoMov in('M') and  (t.FechaMovAnterior between @fechaInicioBimestre and @fechaFinBimestre) and  (t.FechaMovPosterior  not between @fechaInicioBimestre and @fechaFinBimestre)  then  (select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'F' and Fecha between t.fechaMov and @fechaFinBimestre and t.IDEmpleado = IDEmpleado and Autorizado = 1 )
			 when t.CodigoMov in('M') and  (t.FechaMovAnterior not between @fechaInicioBimestre and @fechaFinBimestre) and  (t.FechaMovPosterior  between @fechaInicioBimestre and @fechaFinBimestre)  then  (select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'F' and Fecha between t.fechaMov and dateadd(day,-1, FechaMovPosterior) and t.IDEmpleado = IDEmpleado and Autorizado = 1 )
			 else 0
		END) as Dias

		 , case when t.CodigoMov is null  then (select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'I' and  Fecha between @fechaInicioBimestre and @fechaFinBimestre and t.IDEmpleado = IDEmpleado and Autorizado = 1 )
			 when t.CodigoMov in ('A','R') and   (t.FechaMovPosterior between @fechaInicioBimestre and @fechaFinBimestre)  then (select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'I' and Fecha between t.fechaMov and dateadd(day,-1, FechaMovPosterior) and t.IDEmpleado = IDEmpleado and Autorizado = 1 )
			 when t.CodigoMov in ('A','R') and   (t.FechaMovPosterior not between @fechaInicioBimestre and @fechaFinBimestre)  then (select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'I' and Fecha between t.fechaMov and @fechaFinBimestre and t.IDEmpleado = IDEmpleado and Autorizado = 1 )
			 when t.CodigoMov in('B')  then 0
			 when t.CodigoMov in('M') and   (t.FechaMovPosterior  between @fechaInicioBimestre and @fechaFinBimestre)  then (select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'I' and Fecha between t.fechaMov and dateadd(day,-1, FechaMovPosterior) and t.IDEmpleado = IDEmpleado and Autorizado = 1 )
			 when t.CodigoMov in('M') and    (t.FechaMovPosterior  not between @fechaInicioBimestre and @fechaFinBimestre)  then  (select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'I' and Fecha between t.fechaMov and @fechaFinBimestre and t.IDEmpleado = IDEmpleado and Autorizado = 1 )
			 when t.CodigoMov in('M') and  (t.FechaMovAnterior between @fechaInicioBimestre and @fechaFinBimestre) and  (t.FechaMovPosterior  not between @fechaInicioBimestre and @fechaFinBimestre)  then  (select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'I' and Fecha between t.fechaMov and @fechaFinBimestre and t.IDEmpleado = IDEmpleado and Autorizado = 1 )
			 when t.CodigoMov in('M') and  (t.FechaMovAnterior not between @fechaInicioBimestre and @fechaFinBimestre) and  (t.FechaMovPosterior  between @fechaInicioBimestre and @fechaFinBimestre)  then  (select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'I' and Fecha between t.fechaMov and dateadd(day,-1, FechaMovPosterior) and t.IDEmpleado = IDEmpleado and Autorizado = 1 )
			 else 0
		END Incapacidades
				 , case when t.CodigoMov is null  then (select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'F' and  Fecha between @fechaInicioBimestre and @fechaFinBimestre and t.IDEmpleado = IDEmpleado and Autorizado = 1 )
			 when t.CodigoMov in ('A','R') and   (t.FechaMovPosterior between @fechaInicioBimestre and @fechaFinBimestre)  then (select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'F' and Fecha between t.fechaMov and dateadd(day,-1, FechaMovPosterior) and t.IDEmpleado = IDEmpleado and Autorizado = 1 )
			 when t.CodigoMov in ('A','R') and   (t.FechaMovPosterior not between @fechaInicioBimestre and @fechaFinBimestre)  then (select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'F' and Fecha between t.fechaMov and @fechaFinBimestre and t.IDEmpleado = IDEmpleado and Autorizado = 1 )
			 when t.CodigoMov in('B')  then 0
			 when t.CodigoMov in('M') and   (t.FechaMovPosterior  between @fechaInicioBimestre and @fechaFinBimestre)  then (select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'F' and Fecha between t.fechaMov and dateadd(day,-1, FechaMovPosterior) and t.IDEmpleado = IDEmpleado and Autorizado = 1 )
			 when t.CodigoMov in('M') and    (t.FechaMovPosterior  not between @fechaInicioBimestre and @fechaFinBimestre)  then  (select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'F' and Fecha between t.fechaMov and @fechaFinBimestre and t.IDEmpleado = IDEmpleado and Autorizado = 1 )
			 when t.CodigoMov in('M') and  (t.FechaMovAnterior between @fechaInicioBimestre and @fechaFinBimestre) and  (t.FechaMovPosterior  not between @fechaInicioBimestre and @fechaFinBimestre)  then  (select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'F' and Fecha between t.fechaMov and @fechaFinBimestre and t.IDEmpleado = IDEmpleado and Autorizado = 1 )
			 when t.CodigoMov in('M') and  (t.FechaMovAnterior not between @fechaInicioBimestre and @fechaFinBimestre) and  (t.FechaMovPosterior  between @fechaInicioBimestre and @fechaFinBimestre)  then  (select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'F' and Fecha between t.fechaMov and dateadd(day,-1, FechaMovPosterior) and t.IDEmpleado = IDEmpleado and Autorizado = 1 )
			 else 0
		END Faltas
		, (Select top 1 Prima             
				from [RH].[tblHistorialPrimaRiesgo]             
				where IDRegPatronal= t.IDRegPatronal           
				and Anio <= @Ejercicio            
				and Mes <= @IDMes            
				order by Anio desc,Mes desc) as PrimaRiesgo    
			
	into #tempData3
from #tempdata2 t
     
order by t.ClaveEmpleado asc, t.fechaMov asc

--select  t.*
--	  ,(((select sum(dp.ImporteTotal1)  from Nomina.tblDetallePeriodo dp
--			inner join Nomina.tblCatConceptos c
--				on dp.IDConcepto = c.IDConcepto
--			inner join Nomina.tblCatPeriodos p
--				on dp.IDPeriodo = p.IDPeriodo
--	  where t.IDEmpleado = IDEmpleado
--			and c.Codigo = '500'
--			and p.Ejercicio = @Ejercicio
--			and p.Cerrado = 1
--			and p.IDMes  = @IDMes
--	)/DiasenRegPatronal)*Dias) as CuotaFija
--		  ,(((select sum(dp.ImporteTotal1)  from Nomina.tblDetallePeriodo dp
--			inner join Nomina.tblCatConceptos c
--				on dp.IDConcepto = c.IDConcepto
--			inner join Nomina.tblCatPeriodos p
--				on dp.IDPeriodo = p.IDPeriodo
--	  where t.IDEmpleado = IDEmpleado
--			and c.Codigo = '501'
--			and p.Ejercicio = @Ejercicio
--			and p.Cerrado = 1
--			and p.IDMes  = @IDMes
--	)/DiasenRegPatronal)*Dias) as ExcedentePatronal
--			  ,(((select sum(dp.ImporteTotal1)  from Nomina.tblDetallePeriodo dp
--			inner join Nomina.tblCatConceptos c
--				on dp.IDConcepto = c.IDConcepto
--			inner join Nomina.tblCatPeriodos p
--				on dp.IDPeriodo = p.IDPeriodo
--	  where t.IDEmpleado = IDEmpleado
--			and c.Codigo = '520'
--			and p.Ejercicio = @Ejercicio
--			and p.Cerrado = 1
--			and p.IDMes  = @IDMes
--	)/DiasenRegPatronal)*Dias) as ExcedenteObrera
--				  ,(((select sum(dp.ImporteTotal1)  from Nomina.tblDetallePeriodo dp
--			inner join Nomina.tblCatConceptos c
--				on dp.IDConcepto = c.IDConcepto
--			inner join Nomina.tblCatPeriodos p
--				on dp.IDPeriodo = p.IDPeriodo
--	  where t.IDEmpleado = IDEmpleado
--			and c.Codigo = '502'
--			and p.Ejercicio = @Ejercicio
--			and p.Cerrado = 1
--			and p.IDMes  = @IDMes
--	)/DiasenRegPatronal)*Dias) as PrestacionesDineroPatronal
--					  ,(((select sum(dp.ImporteTotal1)  from Nomina.tblDetallePeriodo dp
--			inner join Nomina.tblCatConceptos c
--				on dp.IDConcepto = c.IDConcepto
--			inner join Nomina.tblCatPeriodos p
--				on dp.IDPeriodo = p.IDPeriodo
--	  where t.IDEmpleado = IDEmpleado
--			and c.Codigo = '514'
--			and p.Ejercicio = @Ejercicio
--			and p.Cerrado = 1
--			and p.IDMes  = @IDMes
--	)/DiasenRegPatronal)*Dias) as PrestacionesDineroObrera
--						  ,(((select sum(dp.ImporteTotal1)  from Nomina.tblDetallePeriodo dp
--			inner join Nomina.tblCatConceptos c
--				on dp.IDConcepto = c.IDConcepto
--			inner join Nomina.tblCatPeriodos p
--				on dp.IDPeriodo = p.IDPeriodo
--	  where t.IDEmpleado = IDEmpleado
--			and c.Codigo = '505'
--			and p.Ejercicio = @Ejercicio
--			and p.Cerrado = 1
--			and p.IDMes  = @IDMes
--	)/DiasenRegPatronal)*Dias) as GMPensionadosPatronal

--	 ,(((select sum(dp.ImporteTotal1)  from Nomina.tblDetallePeriodo dp
--			inner join Nomina.tblCatConceptos c
--				on dp.IDConcepto = c.IDConcepto
--			inner join Nomina.tblCatPeriodos p
--				on dp.IDPeriodo = p.IDPeriodo
--	  where t.IDEmpleado = IDEmpleado
--			and c.Codigo = '515'
--			and p.Ejercicio = @Ejercicio
--			and p.Cerrado = 1
--			and p.IDMes  = @IDMes
--	)/DiasenRegPatronal)*Dias) as GMPensionadosObrera

--		 ,(((select sum(dp.ImporteTotal1)  from Nomina.tblDetallePeriodo dp
--			inner join Nomina.tblCatConceptos c
--				on dp.IDConcepto = c.IDConcepto
--			inner join Nomina.tblCatPeriodos p
--				on dp.IDPeriodo = p.IDPeriodo
--	  where t.IDEmpleado = IDEmpleado
--			and c.Codigo = '504'
--			and p.Ejercicio = @Ejercicio
--			and p.Cerrado = 1
--			and p.IDMes  = @IDMes
--	)/DiasenRegPatronal)*Dias) as RiesgoTrabajo
--			 ,(((select sum(dp.ImporteTotal1)  from Nomina.tblDetallePeriodo dp
--			inner join Nomina.tblCatConceptos c
--				on dp.IDConcepto = c.IDConcepto
--			inner join Nomina.tblCatPeriodos p
--				on dp.IDPeriodo = p.IDPeriodo
--	  where t.IDEmpleado = IDEmpleado
--			and c.Codigo = '506'
--			and p.Ejercicio = @Ejercicio
--			and p.Cerrado = 1
--			and p.IDMes  = @IDMes
--	)/DiasenRegPatronal)*Dias) as InvalidezVidaPatronal
--				 ,(((select sum(dp.ImporteTotal1)  from Nomina.tblDetallePeriodo dp
--			inner join Nomina.tblCatConceptos c
--				on dp.IDConcepto = c.IDConcepto
--			inner join Nomina.tblCatPeriodos p
--				on dp.IDPeriodo = p.IDPeriodo
--	  where t.IDEmpleado = IDEmpleado
--			and c.Codigo = '516'
--			and p.Ejercicio = @Ejercicio
--			and p.Cerrado = 1
--			and p.IDMes  = @IDMes
--	)/DiasenRegPatronal)*Dias) as InvalidezVidaObrera
--					 ,(((select sum(dp.ImporteTotal1)  from Nomina.tblDetallePeriodo dp
--			inner join Nomina.tblCatConceptos c
--				on dp.IDConcepto = c.IDConcepto
--			inner join Nomina.tblCatPeriodos p
--				on dp.IDPeriodo = p.IDPeriodo
--	  where t.IDEmpleado = IDEmpleado
--			and c.Codigo = '503'
--			and p.Ejercicio = @Ejercicio
--			and p.Cerrado = 1
--			and p.IDMes  = @IDMes
--	)/DiasenRegPatronal)*Dias) as GuarderiaPrestacionesSociales

--	into #tempData4
--from #tempData3 t
	
--order by t.ClaveEmpleado asc, t.fechaMov asc



select  t.*
	  ,((((@UMA*CuotaFija)))*Dias) as CuotaFija 
	  ,(((CASE when SalarioIntegrado > @Tope3UMA then ((SalarioIntegrado-@Tope3UMA) * ExcedentePatronal)else 0 end))*Dias) as ExcedentePatronal
	  ,(((CASE when SalarioIntegrado > @Tope3UMA then ((SalarioIntegrado-@Tope3UMA) * ExcedenteObrera) * (DiasenRegPatronal- isnull(Incapacidades,0)) else 0 end)/DiasenRegPatronal)*Dias) as ExcedenteObrera
	  ,((((SalarioIntegrado * PrestacionesDineroPatronal)))*Dias) as PrestacionesDineroPatronal
	  ,((((SalarioIntegrado * PrestacionesDineroObrera) * (DiasenRegPatronal - isnull(Incapacidades,0)))/DiasenRegPatronal)*Dias) as PrestacionesDineroObrera
	  ,((((SalarioIntegrado * ReservaPensionado) * (DiasenRegPatronal- isnull(Incapacidades,0)))/DiasenRegPatronal)*Dias) as GMPensionadosPatronal
	  ,((((SalarioIntegrado * GMPensionadosObrera) * (DiasenRegPatronal - isnull(Incapacidades,0)))/DiasenRegPatronal)*Dias) as GMPensionadosObrera
	  ,((((SalarioIntegrado * PrimaRiesgo) *  (DiasenRegPatronal - (isnull(case when Faltas > 7 then 7 else Faltas end,0) ) ))/DiasenRegPatronal)*Dias) as RiesgoTrabajo
	  ,((((SalarioIntegrado * InvalidezVidaPatronal) * (DiasenRegPatronal - (isnull(case when Faltas > 7 then 7 else Faltas end,0) )))/DiasenRegPatronal)*Dias) as InvalidezVidaPatronal
	  ,((((SalarioIntegrado * InvalidezVidaObrera) * (DiasenRegPatronal- (isnull(case when Faltas > 7 then 7 else Faltas end,0) +isnull(Incapacidades,0))) )/DiasenRegPatronal)*Dias) as InvalidezVidaObrera
	  ,((((SalarioIntegrado * GuarderiasPrestacionesSociales) * (DiasenRegPatronal - (isnull(case when Faltas > 7 then 7 else Faltas end,0) + isnull(Incapacidades,0)) ) )/DiasenRegPatronal)*Dias) as GuarderiaPrestacionesSociales

	into #tempData4
from #tempData3 t
,(select top 1 *            
				from [IMSS].[tblCatPorcentajesPago]            
				where Fecha <= @fechaFinBimestre            
				order by Fecha desc) as PorcentajesPago 
	
order by t.ClaveEmpleado asc, t.fechaMov asc






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
	 ,RS.RFC as RFCRazonSocial
	 ,sm.SalarioMinimo
	 ,sm.UMA
	 ,sm.FactorDescuento
	 ,cast(sm.Fecha as date) as FechaSalarioMinimo 
	 ,@DescripcionBimestre +' - '+ cast(@ejercicio as varchar(100)) bimestre
from #tempData4 t
	
	left join #tempDataRegPatronal RP
		on RP.IDRegPatronal = t.IDRegPatronal
	left join RH.tblCatRazonesSociales RS
		on RS.IDRazonSocial = T.IDRazonSocial
   , (select top 1 * from Nomina.tblSalariosMinimos
		where year(Fecha) = @Ejercicio
		order by Fecha desc) sm
  ,(select top 1 * from IMSS.tblCatPorcentajesPago
		where year(Fecha) = @Ejercicio
		order by Fecha desc) PP
	
order by t.ClaveEmpleado asc, t.fechaMov asc

END
GO
