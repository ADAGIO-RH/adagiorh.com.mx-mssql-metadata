USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: CREDITO INFONAVIT (SIA)
** Autor			: Aneudy Abreu					| Jose Román,
** Email			: aneudy.abreu@adagio.com.mx	| jose.roman@adagio.com.mx
** FechaCreacion	: 2019-08-12
** Paremetros		:              
** Versión 1.2 

** DataTypes Relacionados: 
  @dtconfigs [Nomina].[dtConfiguracionNomina]  
  @dtempleados [RH].[dtEmpleados]  
  @dtConceptos [Nomina].[dtConceptos]  
  @dtPeriodo [Nomina].[dtPeriodos]  
  @dtDetallePeriodo [Nomina].[dtDetallePeriodo] 


  VARIABLES A REEMPLAZAR (SIN LOS ESPACIOS)

  {{ DescripcionConcepto }}
  {{ CodigoConcepto }}

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE PROC [Nomina].[spCoreConcepto_304A]
( @dtconfigs [Nomina].[dtConfiguracionNomina] READONLY 
 ,@dtempleados [RH].[dtEmpleados] READONLY 
 ,@dtConceptos [Nomina].[dtConceptos] READONLY 
 ,@dtPeriodo [Nomina].[dtPeriodos] READONLY 
 ,@dtDetallePeriodo [Nomina].[dtDetallePeriodo] READONLY) 
AS 
BEGIN 

	DECLARE 
		@ClaveEmpleado varchar(20) 
		,@IDEmpleado int 
		,@i int = 0 
		,@Codigo varchar(20) = '304A' 
		,@IDConcepto int 
		,@dtDetallePeriodoLocal [Nomina].[dtDetallePeriodo] 
		,@IDPeriodo int 
		,@IDTipoNomina int 
		,@Ejercicio int 
		,@ClavePeriodo varchar(20) 
		,@DescripcionPeriodo	varchar(250) 
		,@FechaInicioPago date 
		,@FechaFinPago date 
		,@FechaInicioIncidencia date 
		,@FechaFinIncidencia	date 
		,@Dias int 
		,@AnioInicio bit 
		,@AnioFin bit 
		,@MesInicio bit 
		,@MesFin bit 
		,@IDMes int 
		,@BimestreInicio bit 
		,@BimestreFin bit 
		,@General bit 
		,@Finiquito bit 
		,@Especial bit 
		,@Cerrado bit 
		,@PeriodicidadPago Varchar(100)
		,@isPreviewFiniquito bit 
		,@dtFechas app.dtFechas
		,@dtFechasMesActual app.dtFechasFull
		,@StartYear date
		,@dtVigenciaEmpleado app.dtFechasVigenciaEmpleado
		,@FechaMinAvisos Date
		,@FechaMaxAvisos Date
		,@AusentimosAfectaSUA varchar(max)
		,@AjustarUMI bit = 0
		,@FechaAjustarUMI date
		,@INFONAVITREFORMA2025 bit = 0
	;

	select top 1 
		@IDPeriodo = IDPeriodo ,@IDTipoNomina= IDTipoNomina,@Ejercicio = Ejercicio,@ClavePeriodo	= ClavePeriodo,@DescripcionPeriodo =  Descripcion 
		,@FechaInicioPago = FechaInicioPago,@FechaFinPago	= FechaFinPago,@FechaInicioIncidencia = FechaInicioIncidencia,@FechaFinIncidencia=	 FechaFinIncidencia 
		,@Dias = Dias,@AnioInicio = AnioInicio,@AnioFin = AnioFin,@MesInicio = MesInicio,@MesFin = MesFin 
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin 
		,@General = General,@Finiquito = Finiquito,@Especial = Especial,@Cerrado = Cerrado 
	from @dtPeriodo 
	
	SELECT @INFONAVITREFORMA2025 = CAST(ISNULL(Valor,'0') as bit) FROM Nomina.tblConfiguracionNomina where Configuracion = 'INFONAVITREFORMA2025'
	select top 1 @IDConcepto=IDConcepto from @dtConceptos where Codigo=@Codigo; 

	select top 1 @AjustarUMI = isnull(AjustarUMI,0), @FechaAjustarUMI = Fecha from nomina.tblSalariosMinimos 
	where Fecha <= @FechaInicioPago order by Fecha desc
 
	DECLARE
		@Concepto_IDConcepto int
		,@Concepto_Codigo varchar(20)
		,@Concepto_Descripcion varchar(100)
		,@Concepto_IDTipoConcepto int
		,@Concepto_Estatus bit
		,@Concepto_Impresion bit
		,@Concepto_IDCalculo int
		,@Concepto_CuentaAbono varchar(50)
		,@Concepto_CuentaCargo  varchar(50)
		,@Concepto_bCantidadMonto bit
		,@Concepto_bCantidadDias bit
		,@Concepto_bCantidadVeces bit
		,@Concepto_bCantidadOtro1 bit
		,@Concepto_bCantidadOtro2 bit
		,@Concepto_IDCodigoSAT int
		,@Concepto_NombreProcedure varchar(200)
		,@Concepto_OrdenCalculo int
		,@Concepto_LFT bit
		,@Concepto_Personalizada bit
		,@Concepto_ConDoblePago bit;
		
		
	select top 1 
		@Concepto_IDConcepto = IDConcepto 
		,@Concepto_Codigo  = Codigo 
		,@Concepto_Descripcion = Descripcion
		,@Concepto_IDTipoConcepto = IDTipoConcepto 
		,@Concepto_Estatus = Estatus 
		,@Concepto_Impresion = Impresion 
		,@Concepto_IDCalculo = IDCalculo 
		,@Concepto_CuentaAbono = CuentaAbono 
		,@Concepto_CuentaCargo = CuentaCargo 
		,@Concepto_bCantidadMonto = bCantidadMonto
		,@Concepto_bCantidadDias = bCantidadDias
		,@Concepto_bCantidadVeces = bCantidadVeces
		,@Concepto_bCantidadOtro1 = bCantidadOtro1
		,@Concepto_bCantidadOtro2 = bCantidadOtro2 
		,@Concepto_IDCodigoSAT = IDCodigoSAT
		,@Concepto_NombreProcedure = NombreProcedure 
		,@Concepto_OrdenCalculo = OrdenCalculo
		,@Concepto_LFT = LFT
		,@Concepto_Personalizada = Personalizada 
		,@Concepto_ConDoblePago = ConDoblePago
	from @dtConceptos where Codigo=@Codigo;
		
	insert into @dtDetallePeriodoLocal 
	select * from @dtDetallePeriodo where IDConcepto=@IDConcepto 
 
 	select top 1 @isPreviewFiniquito = cast(isnull(valor,0) as bit) from @dtconfigs
	 where Configuracion = 'isPreviewFiniquito'

	select @PeriodicidadPago = PP.Descripcion from Nomina.tblCatTipoNomina TN
		Inner join [Sat].[tblCatPeriodicidadesPago] PP
			on TN.IDPEriodicidadPAgo = PP.IDPeriodicidadPago
	Where TN.IDTipoNomina = @IDTipoNomina
 	 /* @configs: Contiene todos los parametros de configuración de la nómina. */ 
 	 /* @empleados: Contiene todos los trabajadores a calcular.*/ 
 
	/* 
	Descomenta esta parte de código si necesitas recorrer la lista de trabajadores 
 
	select @i=min(RowNumber) from @dtempleados; 
 
	while exists(select 1 from @empleados where RowNumber >= @i) 
	begin 
 		select @IDEmpleado=IDEmpleado, @ClaveEmpleado=ClaveEmpleado from @dtempleados where RowNumber =@i; 
 		print @ClaveEmpleado 
 		select @i=min(RowNumber) from @empleados where RowNumber > @i; 
	end;  
	*/ 
	if object_id('tempdb..#tempAusentismosSemanales') is not null drop table #tempAusentismosSemanales

	CREATE TABLE #tempAusentismosSemanales(
		IDJornadaLaboral int,
		DiasLaboraSemana int,
		DiasAusentimosMes int,
		DescuentoDias int
	)

	Insert into #tempAusentismosSemanales(IDJornadaLaboral,DiasLaboraSemana,DiasAusentimosMes,DescuentoDias)
	Values(0,0,0,0),
		  (1,1,1,7),
		  (2,2,2,7),
		  (2,2,1,4),
		  (3,3,3,7),
		  (3,3,2,5),
		  (3,3,1,2),
		  (4,4,4,7),
		  (4,4,3,5),
		  (4,4,2,4),
		  (4,4,1,2),
		  (5,5,5,7),
		  (5,5,4,6),
		  (5,5,3,4),
		  (5,5,2,3),
		  (5,5,1,1)

	if object_id('tempdb..#tempPorcentajes1998') is not null drop table #tempPorcentajes1998

	CREATE TABLE #tempPorcentajes1998(
		Minimo decimal(18,3),
		Maximo decimal(18,3),
		_20 decimal(18,3),
		_25 decimal(18,3),
		_30 decimal(18,3)
	)

	Insert into #tempPorcentajes1998(Minimo,Maximo,_20,_25,_30)
	Values(1.00,2.50,0.157,0.196,0.246),
	(2.51,3.50,0.168,0.210,0.260),
	(3.51,4.50,0.172,0.215,0.265),
	(4.51,5.50,0.177,0.221,0.271),
	(5.51,6.50,0.178,0.223,0.273),
	(6.51,99999,0.200,0.250,0.300)
		


		  --select * from #tempAusentismosSemanales
	if object_id('tempdb..#tempAusentismosIncapacidades') is not null drop table #tempAusentismosIncapacidades
 
	if object_id('tempdb..#tempInfonavitAvisos') is not null drop table #tempInfonavitAvisos
	if object_id('tempdb..#tempInfonavitAvisosCompletos') is not null drop table #tempInfonavitAvisosCompletos
	if object_id('tempdb..#tempAplicable') is not null drop table #tempAplicable
	if object_id('tempdb..#tempAjustable') is not null drop table #tempAjustable

	--
	----- CODIGO DE CALCULO MODO SIA
		--insert into @dtFechas  
		--exec [App].[spListaFechas] @FechaIni = @FechaInicioPago, @FechaFin = @FechaFinPago  
    -- use the catalog views to generate as many rows as we need

		

		SELECT 
			@FechaMinAvisos = CASE WHEN isnull(min(HAI.FechCreaAviso),@FechaInicioPago) < @FechaInicioPago THEN isnull(min(HAI.FechCreaAviso),@FechaInicioPago) 
									else @FechaInicioPago end 
		, @FechaMaxAvisos = CASE WHEN isnull(MAX(HAI.FechCreaAviso),@FechaFinPago) < @FechaFinPago THEN @FechaFinPago
								ELSE isnull(MAX(HAI.FechCreaAviso),@FechaFinPago)
								end
		FROM RH.tblHistorialAvisosInfonavitEmpleado HAI with(nolock)
			inner join @dtempleados e 
				on HAI.IDEmpleado  = E.IDEmpleado
		
		select HAI.* 
		, CAST(getdate() as date) as FechaAplicacion
		, CAST(getdate() as date) as FechaFinAplicacion
		, E.SalarioIntegrado
		, CAST(0.00 as decimal(18,2)) FactorDescuento
		, DiasBimestre = 0 
		, Descuento =  CAST(0.00 as decimal(18,2)) 
		into #tempInfonavitAvisos
		FROM RH.tblHistorialAvisosInfonavitEmpleado HAI with(nolock)
			inner join @dtempleados e 
				on HAI.IDEmpleado  = E.IDEmpleado

				--select * from #tempInfonavitAvisos

		UPDATE a
			set a.FechaAplicacion = CASE WHEN tai.Clasificacion = 'Modificación' THEN DATEADD(DAY,1, [Asistencia].[fnGetFechaFinBimestre](a.FechCreaAviso))
										ELSE a.FechCreaAviso
										end
		from #tempInfonavitAvisos a
			inner join RH.tblcatTiposAvisosInfonavit tai
				on a.IDTipoAvisoInfonavit = tai.IDTipoAvisoInfonavit
		

		UPDATE a
			set a.FechaFinAplicacion = ISNULL((select top 1 DATEADD(day,-1,FechaAplicacion) 
										from #tempInfonavitAvisos 
										where NumeroCredito = a.NumeroCredito 
										and IDEmpleado = A.IDEmpleado
										and FechaAplicacion > a.FechaAplicacion
										order by fechaAplicacion ASC),'9999-12-31')
		from #tempInfonavitAvisos a
			
			--select * from #tempInfonavitAvisos
			
		set @StartYear = cast(cast(@Ejercicio as varchar)+'-01-01' as date)     

		--update #tempInfonavitAvisos
		--	set FactorDescuento = (select top 1 FactorDescuento from nomina.tblSalariosMinimos where Fecha <= FechaAplicacion order by Fecha desc)

	
		
		--insert into @dtFechas  
		--exec [App].[spListaFechas] 
		--select  @FechaMinAvisos,  @FechaMaxAvisos  

		INSERT @dtFechas([Fecha]) 
		SELECT d
		FROM
		(
			SELECT d = DATEADD(DAY, rn - 1, @FechaMinAvisos)
			FROM 
			(
			SELECT TOP (DATEDIFF(DAY, @FechaMinAvisos, @FechaMaxAvisos) +1) 
			rn = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
			FROM sys.all_objects AS s1
			CROSS JOIN sys.all_objects AS s2
			-- on my system this would support > 5 million days
			ORDER BY s1.[object_id]
			) AS x
		) AS y;

		insert into @dtFechasMesActual([Fecha]) 
		SELECT d
		FROM
		(
			SELECT d = DATEADD(DAY, rn - 1, DATEADD(month, DATEDIFF(month, 0, @FechaInicioPago), 0))
			FROM 
			(
			SELECT TOP (DATEDIFF(DAY, DATEADD(month, DATEDIFF(month, 0, @FechaInicioPago), 0) , EOMONTH(@FechaFinPago)) +1) 
			rn = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
			FROM sys.all_objects AS s1
			CROSS JOIN sys.all_objects AS s2
			-- on my system this would support > 5 million days
			ORDER BY s1.[object_id]
			) AS x
		) AS y;
		
		--select * from @dtFechasMesActual
		
	BEGIN /* Determina la fechas de inicio y fin para buscar las incidencias tomando en cuenta los movimientos afiliatorios del colaborador en el periodo */
		IF object_ID('tempdb..#TempMovimientos') IS NOT NULL DROP TABLE #TempMovimientos;  
      
		select m.*,TipoMovimiento.Codigo, ROW_NUMBER()over(partition by m.IDEmpleado order by  m.Fecha desc) as [Row]  
		into #TempMovimientos  
		from @dtempleados e  
			join IMSS.tblMovAfiliatorios m on e.IDEmpleado = m.IDEmpleado  
			left join IMSS.tblCatTipoMovimientos TipoMovimiento on m.IDTipoMovimiento = TipoMovimiento.IDTipoMovimiento  
				and TipoMovimiento.Codigo <>'M' and m.Fecha <= @FechaFinIncidencia  

		delete from #TempMovimientos where [Row] <> 1

		IF object_ID('tempdb..#TempFechasHabiles') IS NOT NULL DROP TABLE #TempFechasHabiles;  

		select Movimientos.IDEmpleado
			,FechaInicio =CASE  WHEN ( Movimientos.Fecha between @FechaInicioIncidencia and @FechaFinIncidencia) AND (Movimientos.Codigo = 'A' OR Movimientos.Codigo = 'R') THEN Movimientos.Fecha
				--WHEN ( Movimientos.Fecha between @FechaInicioIncidencia and @FechaFinIncidencia) AND (Movimientos.Codigo = 'B') THEN @FechaInicioIncidencia
				--WHEN ( Movimientos.Fecha <= @FechaInicioIncidencia) AND (Movimientos.Codigo = 'A' OR Movimientos.Codigo = 'R') THEN @FechaInicioIncidencia
				ELSE @FechaInicioIncidencia  
				END  
			,FechaFin =CASE WHEN ( Movimientos.Fecha between @FechaInicioIncidencia and @FechaFinIncidencia) AND (Movimientos.Codigo = 'B') THEN Movimientos.Fecha
				--WHEN ( Movimientos.Fecha between @FechaInicioIncidencia and @FechaFinIncidencia) AND (Movimientos.Codigo = 'A' OR Movimientos.Codigo = 'R') THEN Movimientos.Fecha
				--WHEN ( Movimientos.Fecha <= @FechaInicioIncidencia) AND (Movimientos.Codigo = 'A' OR Movimientos.Codigo = 'R') THEN @FechaInicioIncidencia
				ELSE @FechaFinIncidencia  
				END  
		INTO #TempFechasHabiles
		from #TempMovimientos Movimientos


	END;
		--select * from #TempFechasHabiles

		SELECT @AusentimosAfectaSUA = STUFF(
                        (   SELECT ',' + CONVERT(NVARCHAR(20), a.IDIncidencia) 
                            FROM ( SELECT IDIncidencia
									FROM Asistencia.tblCatIncidencias
									Where EsAusentismo = 1
									AND GoceSueldo = 0
									and IDIncidencia <> 'I'
									and afectaSUA = 1
									UNION
							  SELECT IDIncidencia
									FROM Asistencia.tblCatIncidencias
									Where IDIncidencia = 'F'  
									and afectaSUA = 1) A
                            FOR xml path('')
                        )
                        , 1
                        , 1
                        , '')

		insert into @dtVigenciaEmpleado(IDEmpleado,Fecha,Vigente)
		select Empleados.IDEmpleado, F.Fecha, 1
		FROM @dtEmpleados Empleados
			Cross Apply @dtFechas F
			inner join #TempFechasHabiles FA
				on FA.IDEmpleado = Empleados.IDEmpleado
		where F.Fecha Between case when @AjustarUMI = 1 then @FechaAjustarUMI else FA.FechaInicio end and FA.FechaFin 
		
		select Empleados.IDEmpleado
			,F.Fecha
			,Ausentismo = [Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,(@AusentimosAfectaSUA),f.fecha, f.fecha)
			,RNAusentismo = 0
			,Incapacidad = [Asistencia].[fnBuscarIncapacidadEmpleado](Empleados.IDEmpleado,'1,2,3',F.fecha, F.fecha)
			,TJ.Codigo as IDJornadaLaboral
			,0 as ValorAusentismo
		into #tempAusentismosIncapacidades
		from @dtempleados Empleados
		inner join RH.tblEmpleados e
			on e.IDEmpleado = Empleados.IDEmpleado
		left join IMSS.tblCatTipoJornada TJ
				on TJ.IDTipoJornada = e.IDTipoJornada
			Cross Apply @dtFechasMesActual F

			update a 
				set a.RNAusentismo = CASE WHEN s.IDJornadaLaboral is not null then (Select count(*) from #tempAusentismosIncapacidades where Fecha <= a.Fecha and month(Fecha) = month(a.Fecha)  and IDEmpleado = a.IDEmpleado and Ausentismo = 1)
										  else 0
										  end
					--,a.ValorAusentismo = s.DescuentoDias
			from #tempAusentismosIncapacidades a
				left join #tempAusentismosSemanales s
					on a.IDJornadaLaboral = s.IDJornadaLaboral
					and s.DiasAusentimosMes = (Select count(*) from #tempAusentismosIncapacidades where Fecha <= a.Fecha and month(Fecha) = month(a.Fecha)  and IDEmpleado = a.IDEmpleado and Ausentismo = 1) 
			where a.Ausentismo = 1

			update  ai
				set ai.Ausentismo = CASE WHEN ai.RNAusentismo > 0 THEN 1 else 0 END
					,ai.ValorAusentismo = isnull(s.DescuentoDias,0)
			from #tempAusentismosIncapacidades ai
				left join #tempAusentismosSemanales s
					on s.IDJornadaLaboral = ai.IDJornadaLaboral
					and s.DiasAusentimosMes = ai.RNAusentismo
			where ai.RNAusentismo > 0


		IF object_ID('tempdb..#TempMaxValueAusentismoFecha') IS NOT NULL DROP TABLE #TempMaxValueAusentismoFecha;  

		 select IDEmpleado,Month(Fecha)Mes, MAX(ValorAusentismo) valor 
		 into #TempMaxValueAusentismoFecha
		 from #tempAusentismosIncapacidades
		 Group by  IDEmpleado,Month(Fecha)

		 update a
			set a.ValorAusentismo = 0
		 
		 from #tempAusentismosIncapacidades a
			left join #TempMaxValueAusentismoFecha m
				on a.IDEmpleado = m.IDEmpleado
				and a.ValorAusentismo = m.valor
				and month(a.Fecha) = m.Mes
		where m.valor is null
		--select * from #tempAusentismosIncapacidades

		select 
			 VE.IDEmpleado	
			,VE.Fecha	
			,VE.Vigente
			,IA.IDHistorialAvisosInfonavitEmpleado
			,IA.IDRegPatronal
			,IA.IDEmpresa
			,IA.NumeroCredito
			,IA.FolioAviso
			,IA.FechCreaAviso
			,IA.FacDescuento
			,IA.MonDescuento
			,IA.IDTipoDescuento
			,IA.IDTipoAvisoInfonavit
			,IA.FechaAplicacion
			,IA.FechaFinAplicacion
			,IA.SalarioIntegrado
			,IA.FechaOtorgamiento
			,FactorDescuento = (select top 1 FactorDescuento from nomina.tblSalariosMinimos where Fecha <= VE.Fecha order by Fecha desc)
			,SalarioMinimo = (select top 1 SalarioMinimo from nomina.tblSalariosMinimos where Fecha <= VE.Fecha order by Fecha desc)
			,FactorDescuentoAnterior = (select top 1 FactorDescuento from nomina.tblSalariosMinimos where Fecha < CASE WHEN @AjustarUMI =1 THEN @FechaAjustarUMI ELSE VE.Fecha END order by Fecha desc)
			,SalarioMinimoAnterior = (select top 1 SalarioMinimo from nomina.tblSalariosMinimos where Fecha < CASE WHEN @AjustarUMI =1 THEN @FechaAjustarUMI ELSE VE.Fecha END order by Fecha desc)
			,DiasBimestre = [Asistencia].[fnGetDiasBimestreByFecha](VE.Fecha)
			,Descuento = 
							CASE WHEN IA.SalarioIntegrado <= ((select top 1 SalarioMinimo from nomina.tblSalariosMinimos where Fecha <= VE.Fecha order by Fecha desc) * 1.0452) THEN IA.SalarioIntegrado * 0.20
								ELSE
									CASE WHEN IA.IDTipoDescuento = 1 THEN 
																	CASE WHEN IA.FechaOtorgamiento > CAST('1998-01-31' as date) THEN IA.SalarioIntegrado * IA.MonDescuento/100.0
																		 ELSE IA.SalarioIntegrado*(Select top 1 CASE WHEN IA.MonDescuento = 20.0 THEN _20
																								WHEN IA.MonDescuento = 25.0 THEN _25
																								WHEN IA.MonDescuento = 30.0 THEN _30
																								END as MontoDescuento
																		 from #tempPorcentajes1998 where 
																		 (IA.SalarioIntegrado / (select top 1 SalarioMinimo from nomina.tblSalariosMinimos where Fecha <= VE.Fecha order by Fecha desc))
																			BETWEEN Minimo and Maximo
																		 )
																		 END
										WHEN IA.IDTipoDescuento = 2 THEN (IA.MonDescuento * 2.0) / [Asistencia].[fnGetDiasBimestreByFecha](VE.Fecha)
										WHEN IA.IDTipoDescuento = 3 THEN (IA.FacDescuento * (select top 1 FactorDescuento from nomina.tblSalariosMinimos where Fecha <= VE.Fecha order by Fecha desc) * 2.0) / [Asistencia].[fnGetDiasBimestreByFecha](VE.Fecha)
										else 0.00
										end
								END

			,DescuentoAjuste = 	CASE WHEN IA.SalarioIntegrado <= ((select top 1 SalarioMinimo from nomina.tblSalariosMinimos where Fecha <= VE.Fecha order by Fecha desc) * 1.0452) THEN IA.SalarioIntegrado * 0.20
								ELSE
								CASE WHEN IA.IDTipoDescuento = 1 THEN 
																	CASE WHEN IA.FechaOtorgamiento > CAST('1998-01-31' as date) THEN IA.SalarioIntegrado * IA.MonDescuento/100.0
																		ELSE IA.SalarioIntegrado*(Select top 1 CASE WHEN IA.MonDescuento = 20.0 THEN _20
																							WHEN IA.MonDescuento = 25.0 THEN _25
																							WHEN IA.MonDescuento = 30.0 THEN _30
																							END as MontoDescuento
																		from #tempPorcentajes1998 where 
																		(IA.SalarioIntegrado / (select top 1 SalarioMinimo from nomina.tblSalariosMinimos where Fecha <= VE.Fecha order by Fecha desc))
																		BETWEEN Minimo and Maximo
																		)
																		END
									WHEN IA.IDTipoDescuento = 2 THEN (IA.MonDescuento * 2.0) / [Asistencia].[fnGetDiasBimestreByFecha](VE.Fecha)
									WHEN IA.IDTipoDescuento = 3 THEN (IA.FacDescuento * (select top 1 FactorDescuento from nomina.tblSalariosMinimos where Fecha < CASE WHEN @AjustarUMI =1 THEN @FechaAjustarUMI ELSE VE.Fecha END order by Fecha desc) * 2.0) / [Asistencia].[fnGetDiasBimestreByFecha](VE.Fecha)
									else 0.00
									end
								END
			,CASE WHEN @AjustarUMI = 1 and VE.Fecha >= @FechaAjustarUMI and ve.Fecha <= @FechaInicioPago THEN 1 ELSE 0 END as Ajustar

			, CAST( AusentismosIncapacidades.Ausentismo as int) as ausentismo
			, CAST( AusentismosIncapacidades.RNAusentismo as int) as RNausentismo
			, CAST( AusentismosIncapacidades.Incapacidad as int) as Incapacidad
			, CAST( 0 as decimal(18,2)) as DiferenciaAjuste
			, isnull(TJ.Codigo,0) as IDJornadaLaboral
			, RN = ROW_NUMBER()OVER(Partition by VE.IDEmpleado, VE.Fecha order by IA.FechCreaAviso desc, IA.FolioAviso asc)
			, isnull(AusentismosIncapacidades.ValorAusentismo,0) valorAusentismoDias
		into #tempInfonavitAvisosCompletos
		from @dtVigenciaEmpleado VE
			inner join #tempInfonavitAvisos IA
				on VE.IDEmpleado = IA.IDEmpleado
				and VE.Fecha between IA.FechaAplicacion and IA.FechaFinAplicacion
			inner join RH.tblEmpleados e
				on VE.IDEmpleado = E.IDEmpleado
			left join IMSS.tblCatTipoJornada TJ
				on TJ.IDTipoJornada = E.IDTipoJornada
			left join #tempAusentismosIncapacidades AusentismosIncapacidades
				on AusentismosIncapacidades.Fecha = ve.Fecha
				and AusentismosIncapacidades.IDEmpleado = ve.IDEmpleado
		--select * from #tempInfonavitAvisosCompletos
			
			delete #tempInfonavitAvisosCompletos where RN > 1
	
		--select * from #tempInfonavitAvisosCompletos

		delete c
		from  #tempInfonavitAvisosCompletos c
			inner join RH.tblcatTiposAvisosInfonavit TA
				on C.IDTipoAvisoInfonavit = TA.IDTipoAvisoInfonavit
			where TA.Clasificacion = 'Suspensión'  -- Pronta culminación
		--select * from #tempInfonavitAvisosCompletos order by fecha, folioAviso


		/* Inicio de segmento para programar el cuerpo del concepto*/
	  IF object_ID('TEMPDB..#TempDetalle') IS NOT NULL
	   DROP TABLE #TempDetalle
	   CREATE TABLE #TempDetalle(
		IDEmpleado int,
		IDPeriodo int,
		IDConcepto int,
		CantidadDias Decimal(18,2) null,
		CantidadMonto Decimal(18,2) null,
		CantidadVeces Decimal(18,2) null,
		CantidadOtro1 Decimal(18,2) null,
		CantidadOtro2 Decimal(18,2) null,
		ImporteGravado Decimal(18,2) null,
		ImporteExcento Decimal(18,2) null,
		ImporteTotal1 Decimal(18,2) null,
		ImporteTotal2 Decimal(18,2) null,
		Descripcion varchar(255) null,
		IDReferencia int null
	   );
	  
	IF( @General = 1 OR @Finiquito = 1 )
	BEGIN
	SELECT ac.IDEmpleado
	,ac.IDHistorialAvisosInfonavitEmpleado
	,ac.IDJornadaLaboral
	 ,ac.Descuento Descuento
	
	 ,SUM(ac.Descuento) totalDescuento
	 ,count(*) diasVigentes
	 ,SUM(CASE WHEN ac.ausentismo = 0 THEN 0 ELSE 1 END) ausentismos
	 ,SUM(ac.Incapacidad) incapacidades
	 ,CASE WHEN isnull(AC.IDJornadaLaboral,0) = 0  THEN (SUM(ac.Descuento)) - (
			CASE WHEN ISNULL(@INFONAVITREFORMA2025,0) = 0 THEN ((SUM(CASE WHEN ac.ausentismo = 0 THEN 0 ELSE 1 END)*AC.Descuento)+ ((SUM(CASE WHEN ac.Incapacidad = 0 THEN 0 ELSE 1 END)*ac.Descuento))) 
				ELSE 0 
				END
		)
		 ELSE (SUM(ac.Descuento)) 
			-(
			CASE WHEN ISNULL(@INFONAVITREFORMA2025,0) = 0 THEN
				(isnull((
				select SUM(valorAusentismoDias * Descuento) from #tempInfonavitAvisosCompletos
				where IDEmpleado = ac.IDEmpleado
					and valorAusentismoDias > 0),0)+
				 ISNULL((select SUM(Descuento) from #tempInfonavitAvisosCompletos
				where IDEmpleado = ac.IDEmpleado
					and Incapacidad = 1),0))
			ELSE 0
			END)	



		  --((ISNULL( (
				--				(SELECT isnull(DescuentoDias,0  )
				--				from #tempAusentismosSemanales 
				--				where IDJornadaLaboral = AC.IDJornadaLaboral
					--				and DiasAusentimosMes = (SUM(CASE WHEN ac.ausentismo = 0 THEN 0 ELSE 1 END)))*AC.Descuento),0)+ ((SUM(CASE WHEN ac.Incapacidad = 0 THEN 0 ELSE 1 END)*ac.Descuento))) )
		END DescuentoAplicable
		
		into #tempAplicable	
	FROM #tempInfonavitAvisosCompletos ac
	where ac.Fecha between @FechaInicioPago and @FechaFinPago
	group by ac.IDEmpleado, ac.IDHistorialAvisosInfonavitEmpleado, ac.IDJornadaLaboral, ac.Descuento, AC.DiferenciaAjuste
		
		
	--select * from #tempAplicable	
	--select * from #tempAusentismosSemanales	

	select IDEmpleado, SUM(DiferenciaAjuste) Diferencia 
		into #tempAjustable
	from #tempInfonavitAvisosCompletos
	where Ajustar = 1
	group by IDEmpleado
	--select * from #tempAjustable
		
		IF object_ID('TEMPDB..#TempValores') IS NOT NULL DROP TABLE #TempValores
		SELECT
			Empleados.IDEmpleado,
			@IDPeriodo as IDPeriodo,
			@Concepto_IDConcepto as IDConcepto,
			CASE		WHEN ISNULL(DTLocal.CantidadOtro2 , 0) = -1 THEN 0
						WHEN ( ( @Concepto_bCantidadMonto  = 1 ) and ( ISNULL(DTLocal.CantidadMonto,0) > 0 ) ) OR
							 ( ( @Concepto_bCantidadDias   = 1 ) and ( ISNULL(DTLocal.CantidadDias,0)  > 0 ) )
							
							THEN ( ISNULL(DTLocal.CantidadDias,0) * ISNULL ( Empleados.SalarioDiario , 0 ) ) + ISNULL(DTLocal.CantidadMonto,0)		
						WHEN @Concepto_bCantidadVeces = 1 and ISNULL(DTLocal.CantidadVeces,0) > 0 THEN ISNULL(DTLocal.CantidadVeces,0)	 
						WHEN @Concepto_bCantidadOtro1 = 1 and ISNULL(DTLocal.CantidadOtro1,0) > 0 THEN ISNULL(DTLocal.CantidadOtro1,0)	 
						WHEN @Concepto_bCantidadOtro2 = 1 and ISNULL(DTLocal.CantidadOtro2,0) > 0 THEN ISNULL(DTLocal.CantidadOtro2,0)	 
				ELSE 
					isnull((SELECT SUM(DescuentoAplicable) 
						FROM #tempAplicable
						WHERE IDEmpleado = Empleados.IDEmpleado
						),0) + isnull((SELECT SUM(Diferencia) 
						FROM #tempAjustable
						WHERE IDEmpleado = Empleados.IDEmpleado
						),0)
				END Valor
			,ISNULL(DTLocal.CantidadMonto,0) as CantidadMonto
			,ISNULL(DTLocal.CantidadDias ,0) as CantidadDias
			,ISNULL(DTLocal.CantidadVeces,0) as CantidadVeces  																							 
			,ISNULL(DTLocal.CantidadOtro1,0) as CantidadOtro1  																							 
			,ISNULL(DTLocal.CantidadOtro2,0) as CantidadOtro2  																							 
		INTO #TempValores
		FROM @dtempleados Empleados
			Left Join @dtDetallePeriodoLocal DTLocal
				on Empleados.IDEmpleado = DTLocal.IDEmpleado
			Inner join RH.tblEmpleados e with(nolock)
				on e.IDEmpleado = Empleados.IDEmpleado
			left join IMSS.tblCatTipoJornada TJ
				on TJ.IDTipoJornada = Empleados.IDJornadaLaboral
			--select * from #TempValores
			
		/* Inicio de segmento para programar las opciones de LFT, Personalizada, Doble Paga*/
		/* @Concepto_LFT, @Concepto_Personalizada, @Concepto_ConDoblePago*/
		
		
			insert into #TempDetalle(IDEmpleado,IDPeriodo,IDConcepto,CantidadDias,CantidadMonto,CantidadVeces,CantidadOtro1,CantidadOtro2,ImporteGravado,ImporteExcento,ImporteTotal1,ImporteTotal2,Descripcion,IDReferencia)
			Select IDEmpleado,
				IDPeriodo,
				IDConcepto,
				CantidadDias ,
				CantidadMonto,
				CantidadVeces,
				CantidadOtro1,
				CantidadOtro2,
				ImporteGravado = 0.00,
				ImporteExcento = 0.00,
				ImporteTotal1 = Valor,
				ImporteTotal2 = 0.00,
				Descripcion = '',
				IDReferencia = NULL
			FROM #TempValores
	
		/* FIN de segmento para programar las opciones de LFT, Personalizada, Doble Paga*/
		/* Fin de segmento para programar el cuerpo del concepto*/
	END 
		MERGE @dtDetallePeriodoLocal AS TARGET
		USING #TempDetalle AS SOURCE
			ON TARGET.IDPeriodo = SOURCE.IDPeriodo
				and TARGET.IDConcepto = @Concepto_IDConcepto
				and TARGET.IDEmpleado = SOURCE.IDEmpleado
		WHEN MATCHED Then
			update
				Set TARGET.CantidadMonto  = isnull(SOURCE.CantidadMonto ,0)
			 ,TARGET.CantidadDias   = isnull(SOURCE.CantidadDias  ,0)
			 ,TARGET.CantidadVeces  = isnull(SOURCE.CantidadVeces ,0)
			 ,TARGET.CantidadOtro1  = isnull(SOURCE.CantidadOtro1 ,0)
			 ,TARGET.CantidadOtro2  = isnull(SOURCE.CantidadOtro2 ,0)
			 ,TARGET.ImporteTotal1  = ISNULL(SOURCE.ImporteTotal1 ,0)
			 ,TARGET.ImporteTotal2  = ISNULL(SOURCE.ImporteTotal2 ,0)
			 ,TARGET.ImporteGravado = ISNULL(SOURCE.ImporteGravado,0)
			 ,TARGET.ImporteExcento = ISNULL(SOURCE.ImporteExcento,0)
			 ,TARGET.Descripcion	= SOURCE.Descripcion
			 ,TARGET.IDReferencia	= NULL
		WHEN NOT MATCHED BY TARGET THEN
			INSERT(IDEmpleado,IDPeriodo,IDConcepto,
			CantidadMonto,CantidadDias ,CantidadVeces,CantidadOtro1,CantidadOtro2,
			ImporteTotal1,ImporteTotal2, ImporteGravado,ImporteExcento,Descripcion,IDReferencia
			 
			)
			VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,@Concepto_IDConcepto,
			isnull(SOURCE.CantidadMonto ,0),isnull(SOURCE.CantidadDias  ,0),isnull(SOURCE.CantidadVeces ,0)
			,isnull(SOURCE.CantidadOtro1 ,0),isnull(SOURCE.CantidadOtro2 ,0),
			ISNULL(SOURCE.ImporteTotal1 ,0),ISNULL(SOURCE.ImporteTotal2 ,0),ISNULL(SOURCE.ImporteGravado,0)
			,ISNULL(SOURCE.ImporteExcento,0),SOURCE.Descripcion, NULL
			)
		WHEN NOT MATCHED BY SOURCE THEN
		DELETE;
	Select * from @dtDetallePeriodoLocal
 		where
		   isnull(CantidadMonto,0)	<> 0	
		or isnull(CantidadDias,0)	<> 0	
		or isnull(CantidadVeces,0)	<> 0	
		or isnull(CantidadOtro1,0)	<> 0	
		or isnull(CantidadOtro2,0)	<> 0	
		or isnull(ImporteGravado,0) <> 0		
		or isnull(ImporteExcento,0) <> 0		
		or isnull(ImporteOtro,0)	<> 0	
		or isnull(ImporteTotal1,0)	<> 0	
		or isnull(ImporteTotal2,0)	<> 0
END;
GO
