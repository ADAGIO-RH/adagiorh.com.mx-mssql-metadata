USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: IMSS
** Autor			: Aneudy Abreu | Jose Román,
** Email			: aneudy.abreu@adagio.com.mx | jose.roman@adagio.com.mx
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
2023-01-23			JOSE ROMAN			CAMBIO EN FORMULA PARA TOMAR LA PRIMA DE RIESGO DEL HISTORIAL
										DE PRIMAS DEL REGISTRO PATRONAL.
										DATEFROMPARTS( Anio, mes, 1 )   <= DATEFROMPARTS ( @Ejercicio, @IDMes, 1 )
2023-05-18			JOSE ROMAN			REFORMA DEL IMSS SOBRE EL TIPO DE PENSION. 
***************************************************************************************************/
CREATE PROC [Nomina].[spCoreConcepto_302]
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
		,@Codigo varchar(20) = '302' 
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
		,@IDConceptoDiasVigencia int            
		,@ConceptosExcluidos varchar(1000) = '302,303,500,501,502,503,504,505,506,507,508,509,510,511,512,513,514,515,516,517,518,519,520,521'            
		,@IDConceptoIncapacidades int            
		,@IDConceptoAusentismos int            
		,@IDConceptoDiasCotizados int          
		,@IDConceptoFaltas int          
		,@Homologa varchar(10)
		,@UMA decimal(18,4)            
		,@Tope25UMA decimal(18,4)            
		,@Tope3UMA decimal(18,4)   
		,@SalarioMinimo decimal(18,4)
		,@CesantiaVejezPatronal bit
        ,@CesantiaVejezObrera518 bit
	;

	select top 1 
		@IDPeriodo = IDPeriodo ,@IDTipoNomina= IDTipoNomina,@Ejercicio = Ejercicio,@ClavePeriodo	= ClavePeriodo,@DescripcionPeriodo =  Descripcion 
		,@FechaInicioPago = FechaInicioPago,@FechaFinPago	= FechaFinPago,@FechaInicioIncidencia = FechaInicioIncidencia,@FechaFinIncidencia=	 FechaFinIncidencia 
		,@Dias = Dias,@AnioInicio = AnioInicio,@AnioFin = AnioFin,@MesInicio = MesInicio,@MesFin = MesFin 
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin 
		,@General = General,@Finiquito = Finiquito,@Especial = Especial,@Cerrado = Cerrado 
	from @dtPeriodo 
 
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
	from Nomina.tblCatConceptos where Codigo=@Codigo;
		
	select top 1 @IDConcepto=IDConcepto from  Nomina.tblCatConceptos where Codigo=@Codigo; 
	select @IDConceptoDiasVigencia=IDConcepto from @dtConceptos where Codigo= '001'             
	select @IDConceptoIncapacidades=IDConcepto from @dtConceptos where Codigo= '003'             
	select @IDConceptoAusentismos=IDConcepto from @dtConceptos where Codigo= '004'             
	select @IDConceptoDiasCotizados=IDConcepto from @dtConceptos where Codigo= '006'   
	        
	if exists( select top 1 1 from @dtconfigs where Configuracion = 'HomologarIMSS')          
	BEGIN          
		select top 1 @Homologa = ISNULL(valor,'0') from @dtconfigs where Configuracion = 'HomologarIMSS'          
	END ELSE          
	BEGIN          
		set @Homologa = '0'          
	END          		       
    select top 1 @CesantiaVejezPatronal = ISNULL(valor,'0') from App.tblConfiguracionesGenerales where IDConfiguracion = 'CesantiaVejezPatronal'          
    select top 1 @CesantiaVejezObrera518 = ISNULL(valor,'0') from Nomina.tblConfiguracionNomina where Configuracion = 'IMSSTCYVO'   

	select top 1             
		@IDPeriodo = IDPeriodo ,@IDTipoNomina= IDTipoNomina,@Ejercicio = Ejercicio,@ClavePeriodo = ClavePeriodo,@DescripcionPeriodo =  Descripcion             
		,@FechaInicioPago = FechaInicioPago,@FechaFinPago = FechaFinPago,@FechaInicioIncidencia = FechaInicioIncidencia,@FechaFinIncidencia=  FechaFinIncidencia             
		,@Dias = Dias,@AnioInicio = AnioInicio,@AnioFin = AnioFin,@MesInicio = MesInicio,@MesFin = MesFin             
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin             
		,@General = General,@Finiquito = Finiquito,@Especial = Especial,@Cerrado = Cerrado             
	from @dtPeriodo             
            
	if(@General = 1 OR @Finiquito =1)            
	BEGIN    
		insert into @dtDetallePeriodoLocal             
		select *             
		from @dtDetallePeriodo             
		where IDConcepto in (select c.IDConcepto from App.split(@ConceptosExcluidos,',') as ce join Nomina.tblCatConceptos c on ce.Item = c.Codigo)            
			and IDEmpleado in (Select IDEmpleado from @dtempleados)            
		-- IDConcepto=@IDConcepto             
             
		select top 1             
			@UMA  = UMA            
			,@Tope25UMA = UMA * 25            
			,@Tope3UMA  = UMA *3   
			,@SalarioMinimo = SalarioMinimo         
		from Nomina.TblSalariosMinimos            
		where Fecha <= @FechaFinPago            
		order by Fecha desc            
            
		if object_id('tempdb..#tempIMSS') is not null				drop table #tempIMSS;             
		if object_id('tempdb..#tempIMSSDetalleTotales') is not null drop table #tempIMSSDetalleTotales;             
		if object_id('tempdb..#tempIMSSFinal') is not null		drop table #tempIMSSFinal;             
		if object_id('tempdb..#tempTodosConceptos') is not null drop table #tempTodosConceptos;       
		if object_id('tempdb..#TempGravadoPeriodo') is not null drop table #TempGravadoPeriodo;     
		     
		--SACAR GRAVADO DEL PERIODO     
		select dp.IDEmpleado as IDEmpleado                   
		   ,SUM(dp.ImporteGravado) as Gravado           
		into #TempGravadoPeriodo         
		from @dtDetallePeriodo dp            
			inner join @dtConceptos c            
			on dp.IDConcepto = c.IDConcepto            
			inner join Nomina.tblCatTipoCalculoISR ti            
			on ti.IDCalculo = c.IDCalculo            
			inner join Nomina.tblCatTipoConcepto TC    
			on TC.IDTipoConcepto = c.IDTipoConcepto    
		where ti.Codigo = 'ISR_SUELDOS'            
			and tc.Descripcion = 'PERCEPCION'      
		group by dp.IDEmpleado     
		--SACAR GRAVADO DEL PERIODO  
            
		--select * from #TempGravadoPeriodo

	select e.*, Antiguedad = case when DATEDIFF(YEAR,e.FechaAntiguedad,@FechaFinPago) = 0 then 1             
			else DATEDIFF(YEAR,e.FechaAntiguedad,@FechaFinPago)             
			end            
			, e.SalarioDiario * 30.4  as SalarioMensual            
			, DiasCotizados = isnull(DC.ImporteTotal1,0)             
			, DiasVigencia = isnull(dp.ImporteTotal1,0)            
			, DiasFaltas =  case 
								when  ISNULL(AcumAusentismos.ImporteTotal1,0) >= 7 then 0     
								when  ISNULL(Ausentismos.ImporteTotal1,0) <= (7 - ISNULL(AcumAusentismos.ImporteTotal1,0)) then ISNULL(Ausentismos.ImporteTotal1,0)
								when ISNULL(Ausentismos.ImporteTotal1,0) >= (7 - ISNULL(AcumAusentismos.ImporteTotal1,0)) then ISNULL(Ausentismos.ImporteTotal1,0) - (7 - ISNULL(AcumAusentismos.ImporteTotal1,0))

									--CASE WHEN (ISNULL(AcumAusentismos.ImporteTotal1,0) + ISNULL(Ausentismos.ImporteTotal1,0)) >= 7 THEN  7   
									--	ELSE (ISNULL(AcumAusentismos.ImporteTotal1,0) + ISNULL(Ausentismos.ImporteTotal1,0))    
									--END    
							else 0    
							end           
			, DiasIncapacidad = isnull(inca.ImporteTotal1,0)            
			,dp.CantidadMonto    
			,Ausentismos.ImporteTotal1  as Faltas   
			,AcumAusentismos.ImporteTotal1   as  AcumFaltas   
			, (Select top 1 Prima             
				from [RH].[tblHistorialPrimaRiesgo]             
				where IDRegPatronal= e.IDRegPatronal    
				and DATEFROMPARTS( Anio, mes, 1 )   <= DATEFROMPARTS ( @Ejercicio, @IDMes, 1 ) --- BUG CORREGIDO PARA TOMA DE PRIMA DE RIESGO
				--and Anio <= @Ejercicio														-- JOSE ROMAN 2023-01-23
				--and Mes <= @IDMes            
				order by Anio desc,Mes desc) as PrimaRiesgo            
			,PorcentajesPago.*   
			,Case when ISNULL(app.CantidadOtro2,0) = -1 THEN 0 Else 1 END Aplica  
			,ISNULL(TTE.IDTipoPension,1) as IDTipoPension -- SI NO TIENE PENSION EL TIPO 1 ES LA OPCION DE SIN PENSION
		INTO #tempIMSS										-- JOSE ROMAN 2023-05-18
		from @dtempleados E    
			Left Join RH.tblTipoTrabajadorEmpleado TTE on E.IDEmpleado = TTE.IDEmpleado
			left join @dtDetallePeriodo app on e.IDEmpleado = app.IDEmpleado and app.IDConcepto = @IDConcepto          
			left join @dtDetallePeriodo dp on e.IDEmpleado = dp.IDEmpleado and dp.IDConcepto = @IDConceptoDiasVigencia            
			left join @dtDetallePeriodo inca on e.IDEmpleado = inca.IDEmpleado and inca.IDConcepto = @IDConceptoIncapacidades            
			left join @dtDetallePeriodo Ausentismos on e.IDEmpleado = Ausentismos.IDEmpleado and Ausentismos.IDConcepto = @IDConceptoAusentismos            
			--left join @dtDetallePeriodo Faltas on e.IDEmpleado = Faltas.IDEmpleado and Faltas.IDConcepto = @IDConceptoFaltas            
			left join @dtDetallePeriodo DC on e.IDEmpleado = DC.IDEmpleado and DC.IDConcepto = @IDConceptoDiasCotizados    
			Cross Apply [Nomina].[fnObtenerAcumuladoPorConceptoPorMes](e.IDEmpleado,@IDConceptoAusentismos,@IDMes,@Ejercicio) AcumAusentismos           
			--Cross Apply [Nomina].[fnObtenerAcumuladoPorConceptoPorMes](e.IDEmpleado,@IDConceptoFaltas,@IDMes,@Ejercicio) AcumFaltas          
			,(select top 1 *            
				from [IMSS].[tblCatPorcentajesPago]            
				where Fecha <= @FechaFinPago            
				order by Fecha desc) as PorcentajesPago                        
            
		-- select * from #tempIMSS            
              
		select             
			imss.IDEmpleado            
			,imss.Antiguedad            
			,imss.SalarioMensual            
			,imss.DiasCotizados            
			,imss.PrimaRiesgo            
			,imss.Aplica  
			,imss.SalarioIntegrado  
			,imss.GuarderiasPrestacionesSociales  
			,imss.DiasFaltas  
			,imss.DiasIncapacidad  
            
			/* CUOTA FIJA 20.4% */            
			,'500' as IDCuotaFija_1              
			,CuotaFija_1 =  case when isnull(CantidadMonto,0) > 0 then isnull(CantidadMonto,0)       
			else (@UMA*imss.CuotaFija)*(imss.DiasCotizados - imss.DiasIncapacidad) end            
            
			/* EXCEDENTE PATRONAL */              
			,'501' as IDExcedentePatronal_2              
			,ExcedentePatronal_2 = case when isnull(CantidadMonto,0) > 0 then isnull(CantidadMonto,0)             
					when imss.SalarioIntegrado > @Tope3UMA then ((imss.SalarioIntegrado-@Tope3UMA) * imss.ExcedentePatronal) * (imss.DiasCotizados - imss.DiasIncapacidad ) else 0 end            
            
			/* PRESTACIONES EN DINERO PATRONAL*/            
			,'502' as IDPrestacionesDineroPatronal_3              
			,PrestacionesDineroPatronal_3 = case when isnull(CantidadMonto,0) > 0 then isnull(CantidadMonto,0)             
			else (imss.SalarioIntegrado * imss.PrestacionesDineroPatronal) * (imss.DiasCotizados - imss.DiasIncapacidad) end              

			/* GUARDERIAS */            
			,'503' as IDGuarderia_4              
				,Guarderia_4 =  case when isnull(CantidadMonto,0) > 0 then isnull(CantidadMonto,0)             
			else (imss.SalarioIntegrado * imss.GuarderiasPrestacionesSociales) * (imss.DiasCotizados - (isnull(case when imss.DiasFaltas > 7 then 7 else imss.DiasFaltas end,0) + isnull(imss.DiasIncapacidad,0)) ) end            
              
			/*RIESGO DE TRABAJO*/            
			,'504' as IDPrimaRiesgoTrabajo_5              
				,PrimaRiesgoTrabajo_5 =  case when isnull(CantidadMonto,0) > 0 then isnull(CantidadMonto,0)             
			else (imss.SalarioIntegrado * imss.PrimaRiesgo) *  (imss.DiasCotizados - (isnull(case when imss.DiasFaltas > 7 then 7 else imss.DiasFaltas end,0) + isnull(imss.DiasIncapacidad,0)) ) end            
              
			/*RESERVA PENSIONADO*/            
			,'505' as IDReservaPensionado_6              
				,ReservaPensionado_6 =  case when isnull(CantidadMonto,0) > 0 then isnull(CantidadMonto,0)             
			else case when imss.IDTipoPension in (3) THEN 0 ELSE (imss.SalarioIntegrado * imss.ReservaPensionado) * (imss.DiasCotizados- isnull(imss.DiasIncapacidad,0)) END end            
            
			/*  INVALIDEZ Y VIDA  */            
			,'506' as IDInvalidezVidaPatronal_7             
				,InvalidezVidaPatronal_7 =  case when isnull(CantidadMonto,0) > 0 then isnull(CantidadMonto,0)             
			else case when imss.IDTipoPension in (2,3) THEN 0 ELSE (imss.SalarioIntegrado * imss.InvalidezVidaPatronal) * (imss.DiasCotizados - (isnull(case when imss.DiasFaltas > 7 then 7 else imss.DiasFaltas end,0) + isnull(imss.DiasIncapacidad,0)))END end            
            
			-- 507 Total Imss Patronal            
            
			/*  CESANTIA Y VEJEZ PATRON  */            
			,'508' as IDCesantiaVejezPatron_8            
				,CesantiaVejezPatron_8 =  case when isnull(CantidadMonto,0) > 0 then isnull(CantidadMonto,0)             
			else (imss.SalarioIntegrado * (CASE WHEN ISNULL(@CesantiaVejezPatronal,0) = 0 THEN imss.CesantiaVejezPatron ELSE [IMSS].[fnGetCesantiaVejezPatronal](imss.IDEmpleado, imss.IDSucursal, imss.SalarioIntegrado, @FechaFinPago ) END)) * (imss.DiasCotizados - (isnull(case when imss.DiasFaltas > 7 then 7 else imss.DiasFaltas end,0) + isnull(imss.DiasIncapacidad,0)) ) end            
            
			/*  Seguro de Retiro  */            
			,'509' as IDSeguroRetiro_9            
				,SeguroRetiro_9 =  case when isnull(CantidadMonto,0) > 0 then isnull(CantidadMonto,0)             
			else (imss.SalarioIntegrado * imss.SeguroRetiro) * (imss.DiasCotizados - isnull(case when imss.DiasFaltas > 7 then 7 else imss.DiasFaltas end,0) ) end            
            
			/*  Infonavit  */            
			,'510' as IDInfonavit_10            
				,Infonavit_10 =  case when isnull(CantidadMonto,0) > 0 then isnull(CantidadMonto,0)      
			else (imss.SalarioIntegrado * imss.Infonavit) * (imss.DiasCotizados - isnull(case when imss.DiasFaltas > 7 then 7 else imss.DiasFaltas end,0) ) end            
            
			--  511 TOTAL PRESTACIONES PATRON            
			--  512 TOTAL PATRON MENSUAL            
            
			/* CUOTA PROPORCIONAL */            
				,'513' as IDCuotaPatrolObrera_11            
			,CuotaPatrolObrera_11 =  CASE WHEN SalarioDiario > @SalarioMinimo THEN
										case  when isnull(CantidadMonto,0) > 0 then isnull(CantidadMonto,0)              
										  when imss.SalarioIntegrado > @Tope3UMA then 
											((imss.SalarioIntegrado-@Tope3UMA) * imss.CuotaProporcionalObrera) * (imss.DiasCotizados - isnull(imss.DiasIncapacidad,0))  
										  else 0 
										  end
									ELSE 0
									END
            
			/* PRESTACIONES EN DINERO OBRERA*/            
			,'514' as IDPrestacionesDineroObrera_12            
			,PrestacionesDineroObrera_12 =  CASE WHEN SalarioDiario + SalarioVariable > @SalarioMinimo THEN 
												case when isnull(CantidadMonto,0) > 0 then isnull(CantidadMonto,0)             
												else (imss.SalarioIntegrado * imss.PrestacionesDineroObrera) * (imss.DiasCotizados - isnull(imss.DiasIncapacidad,0)) end            
											ELSE 0 
											END
			/* GMPensionados Obrera */            
			,'515' as IDGMPensionadosObrera_13            
			,GMPensionadosObrera_13 =  CASE WHEN SalarioDiario + SalarioVariable > @SalarioMinimo THEN
											case when isnull(CantidadMonto,0) > 0 then isnull(CantidadMonto,0)             
											else (imss.SalarioIntegrado * imss.GMPensionadosObrera) * (imss.DiasCotizados - isnull(imss.DiasIncapacidad,0))end     
										ELSE 0
										END
            
			/* Invalidez Vida Obrera */            
			,'516' as IDInvalidezVidaObrera_14            
			,InvalidezVidaObrera_14 =  CASE WHEN SalarioDiario + SalarioVariable > @SalarioMinimo THEN 
												case when isnull(CantidadMonto,0) > 0 then isnull(CantidadMonto,0)             
												else (imss.SalarioIntegrado * imss.InvalidezVidaObrera) * (imss.DiasCotizados- (isnull(case when imss.DiasFaltas > 7 then 7 else imss.DiasFaltas end,0) +isnull(imss.DiasIncapacidad,0))) end     
										ELSE 0 
										END
              
			--  517 IMSS - TOTAL IMSS TRABAJADOR            
            
			/* CesantiaVejezObrera */            
			,'303' as IDCesantiaVejezObrera_15            
			,CesantiaVejezObrera_15 = CASE WHEN Imss.SalarioDiario + IMSS.SalarioVariable <= @SalarioMinimo THEN 0 else 
				case when isnull(CantidadMonto,0) > 0 then isnull(CantidadMonto,0)             
				else (imss.SalarioIntegrado * imss.CesantiaVejezObrera) * (imss.DiasCotizados- (isnull(case when imss.DiasFaltas > 7 then 7 else imss.DiasFaltas end,0) +isnull(imss.DiasIncapacidad,0))) 
				end
			END            
            
			-- 519 TOTAL IMSS MENSUAL            
            
			/* EXCEDENTE OBRERA */              
			,'520' as IDExcedenteObrera_16              
			,ExcedenteObrera_16 = case when isnull(CantidadMonto,0) > 0 then isnull(CantidadMonto,0)             
					when imss.SalarioIntegrado > @Tope3UMA then ((imss.SalarioIntegrado-@Tope3UMA) * imss.ExcedenteObrera) * (imss.DiasCotizados- isnull(imss.DiasIncapacidad,0)) else 0 end            
            
		INTO #tempIMSSDetalleTotales            
		from #tempIMSS imss            
             
		--select * from #tempIMSSDetalleTotales            
            
		--select * from #tempIMSSDetalleTotales            
		/* @configs: Contiene todos los parametros de configuración de la nómina. */             
		/* @empleados: Contiene todos los trabajadores a calcular.*/             
             
		/* Descomenta esta parte de código si necesitas recorrer la lista de trabajadores             
             
		select @i=min(RowNumber) from @dtempleados;             
             
		while exists(select 1 from @empleados where RowNumber >= @i)             
		begin             
			select @IDEmpleado=IDEmpleado, @ClaveEmpleado=ClaveEmpleado from @dtempleados where RowNumber =@i;             
			print @ClaveEmpleado             
			select @i=min(RowNumber) from @empleados where RowNumber > @i;             
		end;              
		*/             
            
		create table #tempIMSSFinal(IDEmpleado int, IDConcepto varchar(20) collate database_default, Total decimal(18,4));            
            
		Insert into #tempIMSSFinal            
		Select IDEmpleado, IDConcepto,Total               
		from (            
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
		select IDEmpleado  
		,'507' IDConcepto            
		, Sum(Total) as total            
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
   
		Insert into #tempIMSSFinal            
		select IDEmpleado,'521' IDConcepto            
		,Sum(Total) as total            
			from #tempIMSSFinal            
		where IDConcepto in ('303')            
		group by IDEmpleado          
          
		IF(@Homologa = '0')          
		BEGIN          
			Insert into #tempIMSSFinal            
			select IDEmpleado,'517' IDConcepto            
			,Sum(Total) as total            
				from #tempIMSSFinal            
			where IDConcepto in ('513','514','515','516') --,'303'       
			and IDEmpleado in (select IDEmpleado from @dtempleados where SalarioDiario+SalarioVariable > @SalarioMinimo) 
			group by IDEmpleado            
          
			Insert into #tempIMSSFinal            
			select IDEmpleado,'302' IDConcepto            
			,Sum(Total) as total            
				from #tempIMSSFinal            
			where           
			IDConcepto in ('517','520') --, 
			and IDEmpleado in (select IDEmpleado from @dtempleados where SalarioDiario+ SalarioVariable > @SalarioMinimo)           
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
			and IDEmpleado in (select IDEmpleado from @dtempleados where SalarioDiario + SalarioVariable > @SalarioMinimo)           
			group by IDEmpleado            
           
		END          
          
		Insert into #tempIMSSFinal            
		select IDEmpleado
			,'518' IDConcepto  
			,0
		from #tempIMSSFinal
		group by IDEmpleado  

		Insert into #tempIMSSFinal            
		select IDEmpleado
			,'519' IDConcepto            
			,Sum(Total) as total            
		from #tempIMSSFinal            
		where IDConcepto in ('302','512')            
		group by IDEmpleado            
		--select * from #tempIMSSFinal
		--select tif.*,gravado.Gravado
		--from #tempIMSSFinal  tif
		--	left join #TempGravadoPeriodo gravado on tif.IDEmpleado = gravado.IDEmpleado
		--where IDConcepto in ('302','303','507','508')		
		--order by tif.IDEmpleado,tif.IDConcepto         

		BEGIN -- Cuando no existe Importe gravado de un colaborador en el cálculo se sumal los conceptos de imss 302 - IMSS al 507 - TOTAL IMSS PATRONAL 303 - IMSS - CESANTIA Y VEJEZ OBRERA al 508 - IMSSP - CESANTIA Y VEJEZ PATRON
			update tif
				set tif.Total = case when 
								ISNULL(gravado.Gravado,0.00) = 0.00 and tif.IDConcepto = '507' then tif.Total + isnull((select top 1 isnull(Total,0)-- LINEA ORIGINAL
																										--SE DEJO EN CEROS POR QUE EN THANGOS NO CUADRABA
																										--select 0 --top 1 isnull(Total,0)					
																											from #tempIMSSFinal
																										where IDEmpleado = tif.IDEmpleado and IDConcepto = '302'),0)
																						else tif.Total 
																						end
			from #tempIMSSFinal tif		
				left join #TempGravadoPeriodo gravado on tif.IDEmpleado = gravado.IDEmpleado															
			where ISNULL(gravado.Gravado,0.00) = 0.00 and tif.IDConcepto = '507' 
			
			update tif
				set tif.Total = case when 
								( ISNULL(gravado.Gravado,0.00) = 0.00 or Isnull(@CesantiaVejezObrera518,0) = 1 ) and tif.IDConcepto = '518' then isnull((select top 1 isnull(Total,0)
																										from #tempIMSSFinal
																										where IDEmpleado = tif.IDEmpleado and IDConcepto = '303'),0)
																						else tif.Total end
			from #tempIMSSFinal tif		
				left join #TempGravadoPeriodo gravado on tif.IDEmpleado = gravado.IDEmpleado															
			where ( ISNULL(gravado.Gravado,0.00) = 0.00 or Isnull(@CesantiaVejezObrera518,0) = 1 ) and tif.IDConcepto = '518' 

			update tif
				set tif.Total = case when 
								ISNULL(gravado.Gravado,0.00) = 0.00 and tif.IDConcepto = '508' then tif.Total + isnull((select top 1 isnull(Total,0)
																										from #tempIMSSFinal
																										where IDEmpleado = tif.IDEmpleado and IDConcepto = '518'),0) 
																						else tif.Total end
			from #tempIMSSFinal tif		
				left join #TempGravadoPeriodo gravado on tif.IDEmpleado = gravado.IDEmpleado															
			where ISNULL(gravado.Gravado,0.00) = 0.00 and tif.IDConcepto = '508' 

			update tif
				set tif.Total = case when 
								ISNULL(gravado.Gravado,0.00) = 0.00 and tif.IDConcepto = '511' then  isnull((select SUM( isnull(Total,0))
																										from #tempIMSSFinal
																										where IDEmpleado = tif.IDEmpleado and IDConcepto in ('508','509','510')),0) 
																						else tif.Total end
			from #tempIMSSFinal tif		
				left join #TempGravadoPeriodo gravado on tif.IDEmpleado = gravado.IDEmpleado															
			where ISNULL(gravado.Gravado,0.00) = 0.00 and tif.IDConcepto = '511' 

			update tif
				set tif.Total = 0.00
			from #tempIMSSFinal tif		
				left join #TempGravadoPeriodo gravado on tif.IDEmpleado = gravado.IDEmpleado															
			where ISNULL(gravado.Gravado,0.00) = 0.00 and tif.IDConcepto in ('302','303')
		END

		select imf.IDEmpleado, @IDPeriodo as IDPeriodo,c.IDConcepto,imf.Total, dl.CantidadOtro2            
		into #tempTodosConceptos            
		from #tempIMSSFinal imf            
			join [Nomina].[tblCatConceptos] c on imf.IDConcepto = c.Codigo  
			left join @dtDetallePeriodoLocal  dl on imf.IDEmpleado = dl.IDEmpleado  and dl.IDConcepto = @IDConcepto          
		order by imf.IDEmpleado, imf.IDConcepto            
            
		--	select * from #tempTodosConceptos

		MERGE @dtDetallePeriodoLocal AS TARGET            
		USING #tempTodosConceptos AS SOURCE            
			ON TARGET.IDPeriodo = SOURCE.IDPeriodo            
			and TARGET.IDConcepto = SOURCE.IDConcepto            
			and TARGET.IDEmpleado = SOURCE.IDEmpleado            
		WHEN MATCHED Then            
		update            
			Set                 
			TARGET.ImporteTotal1  = case when SOURCE.CantidadOtro2 = -1 then 0 else SOURCE.Total  end              
			,TARGET.CantidadOtro2 = SOURCE.CantidadOtro2  
		WHEN NOT MATCHED BY TARGET THEN             
			INSERT(IDEmpleado,IDPeriodo,IDConcepto,ImporteTotal1,CantidadOtro2)            
			VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,SOURCE.IDConcepto,case when SOURCE.CantidadOtro2 = -1 then 0 else SOURCE.Total  end,Source.CantidadOtro2)            
		WHEN NOT MATCHED BY SOURCE THEN             
			DELETE;     
			
			
		update dpl	
			set dpl.ImporteTotal1 = CASE WHEN isnull(dpl.CantidadMonto,0) <> 0 then  isnull(dpl.CantidadMonto,0) else   dpl.ImporteTotal1  end      
		from @dtDetallePeriodoLocal dpl            
			
		--	left join @dtDetallePeriodo dp on dpl.IDConcepto = dp.IDConcepto and dpl.IDEmpleado = dp.IDConcepto       
		--where dpl.ImporteTotal1 > 0            
	--	order by dpl.IDEmpleado asc, c.OrdenCalculo asc;  	       
        
		Select dpl.*            
		from @dtDetallePeriodoLocal dpl            
			join [Nomina].[tblCatConceptos] c on dpl.IDConcepto = c.IDConcepto            
		--where dpl.ImporteTotal1 > 0            
		order by dpl.IDEmpleado asc, c.OrdenCalculo asc;      
	END  
	ELSE IF(@Especial = 1)
	BEGIN
		IF object_ID('TEMPDB..#TempValoresEspeciales') IS NOT NULL DROP TABLE #TempValoresEspeciales
 
		SELECT
			Empleados.IDEmpleado,
			@IDPeriodo as IDPeriodo,
			@Concepto_IDConcepto as IDConcepto,
			CASE WHEN @Concepto_bCantidadMonto  = 1 and ISNULL(DTLocal.CantidadMonto,0) > 0 THEN ISNULL(DTLocal.CantidadMonto,0)		  
						WHEN @Concepto_bCantidadDias  = 1 and ISNULL(DTLocal.CantidadDias,0)  > 0 THEN ISNULL(DTLocal.CantidadDias,0)	  
						WHEN @Concepto_bCantidadVeces = 1 and ISNULL(DTLocal.CantidadVeces,0) > 0 THEN ISNULL(DTLocal.CantidadVeces,0)	  
						WHEN @Concepto_bCantidadOtro1 = 1 and ISNULL(DTLocal.CantidadOtro1,0) > 0 THEN ISNULL(DTLocal.CantidadOtro1,0)	  
						WHEN @Concepto_bCantidadOtro2 = 1 and ISNULL(DTLocal.CantidadOtro2,0) > 0 THEN ISNULL(DTLocal.CantidadOtro2,0)	  
				ELSE 0
				END Valor																							  
			INTO #TempValoresEspeciales
			FROM @dtempleados Empleados
				inner Join @dtDetallePeriodoLocal DTLocal
					on Empleados.IDEmpleado = DTLocal.IDEmpleado

		--SELECT * FROM #TempValoresEspeciales
		MERGE @dtDetallePeriodoLocal AS TARGET  
		USING #TempValoresEspeciales AS SOURCE  
		ON TARGET.IDPeriodo = SOURCE.IDPeriodo  
			and TARGET.IDConcepto = @Concepto_IDConcepto  
			and TARGET.IDEmpleado = SOURCE.IDEmpleado  
		WHEN MATCHED Then  
		update  
			Set TARGET.ImporteTotal1  = SOURCE.Valor  
		WHEN NOT MATCHED BY TARGET THEN   
			INSERT(IDEmpleado,IDPeriodo,IDConcepto,ImporteTotal1, ImporteGravado, ImporteExcento)  
			VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,@Concepto_IDConcepto,Source.Valor,0,0)  
		WHEN NOT MATCHED BY SOURCE THEN   
		DELETE;
	END         
END;
GO
