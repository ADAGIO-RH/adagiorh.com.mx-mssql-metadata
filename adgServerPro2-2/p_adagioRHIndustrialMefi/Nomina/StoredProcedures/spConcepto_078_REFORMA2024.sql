USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 

** Descripción		: SUBSIDIO CAUSADO WORK AROUND REFORMA 2024
** Autor			: Aneudy Abreu | Jose Romá,
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

***************************************************************************************************/
CREATE PROC [Nomina].[spConcepto_078_REFORMA2024]
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
		,@Codigo varchar(20) = '078' 
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
		,@IDPeriodicidadPagoMensual int      
		,@IDPeriodicidadPagoPeriodo int      
		,@IDCalculo int      
		,@IDConcepto002 int --Dias Vacaciones    
		,@IDConcepto005 int --Dias Pagados   
		,@IDConcepto007 int --Septimo Dia
		,@IDConcepto079 int -- ISR CAUSADO
		,@ISRProporcional int
		,@ISRProporcionalFiniquito int
		,@IDPais int 
		,@IDCalculoISRSueldos int 
		,@UMA decimal(18,2)
		,@PorcentajeUMA decimal(18,4) = 0.1182
		,@ValorDiarioUMA decimal(18,4)
		,@TopeMensualSubsidio decimal(18,2)  = 390.12
	;

	select top 1 
		@IDPeriodo = IDPeriodo ,@IDTipoNomina= IDTipoNomina,@Ejercicio = Ejercicio,@ClavePeriodo	= ClavePeriodo,@DescripcionPeriodo =  Descripcion 
		,@FechaInicioPago = FechaInicioPago,@FechaFinPago	= FechaFinPago,@FechaInicioIncidencia = FechaInicioIncidencia,@FechaFinIncidencia=	 FechaFinIncidencia 
		,@Dias = Dias,@AnioInicio = AnioInicio,@AnioFin = AnioFin,@MesInicio = MesInicio,@MesFin = MesFin 
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin 
		,@General = General,@Finiquito = Finiquito,@Especial = Especial,@Cerrado = Cerrado 
	from @dtPeriodo 
 
	select top 1 @IDConcepto=IDConcepto from @dtConceptos where Codigo=@Codigo; 
	
	select top 1 @IDConcepto002=IDConcepto from @dtConceptos where Codigo='002';     
	select top 1 @IDConcepto005=IDConcepto from @dtConceptos where Codigo='005'; 
	select top 1 @IDConcepto007=IDConcepto from @dtConceptos where Codigo='007';   
	select top 1 @IDConcepto079=IDConcepto from @dtConceptos where Codigo='079';   
	--select top 1 @IDConcepto180=IDConcepto from @dtConceptos where Codigo='180';   
 
	SELECT top 1 @UMA = UMA
	FROM Nomina.tblSalariosMinimos with(nolock)
	WHERE YEAR(Fecha) = YEAR( @FechaInicioPago)
	ORDER BY Fecha desc

	SET @ValorDiarioUMA = @UMA * @PorcentajeUMA

	


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

	select @PeriodicidadPago = PP.Descripcion from Nomina.tblCatTipoNomina TN with(nolock)  
		Inner join [Sat].[tblCatPeriodicidadesPago] PP with(nolock)  
			on TN.IDPEriodicidadPAgo = PP.IDPeriodicidadPago
	Where TN.IDTipoNomina = @IDTipoNomina

	select top 1 @IDPeriodicidadPagoMensual = IDPeriodicidadPago from SAT.tblCatPeriodicidadesPago with(nolock)   where Descripcion = 'Mensual' 
   
	Select TOP 1 @IDPeriodicidadPagoPeriodo = IDPeriodicidadPago , @IDPais = IDPais     
	from Nomina.tblCatTipoNomina  with(nolock)      
	where IDTipoNomina = @IDTipoNomina   
	
	
	Select top 1 @ISRProporcional = cast(isnull(Valor,0) as int)   
	from Nomina.tblConfiguracionNomina with(nolock)   
	where Configuracion = 'ISRProporcional'

	Select top 1 @ISRProporcionalFiniquito = cast(isnull(Valor,0) as int)   
	from Nomina.tblConfiguracionNomina with(nolock)    
	where Configuracion = 'ISRProporcionalFiniquito'

	select top 1 @IDCalculo = IDCalculo       
	from Nomina.tblCatTipoCalculoISR with(nolock)        
	WHERE Codigo = 'CALCULO_SUBSIDIO'    
		
	select top 1 @IDCalculoISRSueldos = IDCalculo       
	from Nomina.tblCatTipoCalculoISR with(nolock)       
	WHERE Codigo = 'ISR_SUELDOS'  
	
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
	)   

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
 
	/* Inicio de segmento para programar el cuerpo del concepto*/

	IF NOT EXISTS(Select * from Nomina.tbltablasImpuestos TI with(nolock) WHERE TI.Ejercicio = @Ejercicio and TI.IDCalculo = @IDCalculo AND TI.IDPeriodicidadPago = @IDPeriodicidadPagoPeriodo)      
	RAISERROR('Tabla de Subsidios para esta periodicidad de pago y Ejercicio no Existe.', 16, 1);      
 
	IF NOT EXISTS(Select * from Nomina.tbltablasImpuestos TI with(nolock) WHERE TI.Ejercicio = @Ejercicio and TI.IDCalculo = @IDCalculo AND TI.IDPeriodicidadPago = @IDPeriodicidadPagoMensual)      
	RAISERROR('Tabla de Subsidios Mensual para este Ejercicio no Existe.', 16, 1);         
      
	IF object_id('tempdb..#TempSUBSIDIO') is not null      
	DROP TABLE #TempSUBSIDIO;           
      
	IF object_id('tempdb..#TempSUBSIDIOSUM') is not null      
	DROP TABLE #TempSUBSIDIOSUM;       

	
  
	SELECT 
		dp.IDEmpleado as IDEmpleado
		,@IDConcepto as IDConcepto
		,@IDPeriodo as IDPeriodo
		,isnull(SUM(dp.ImporteGravado),0) as SumImporteGravado  
		,CAST(0.00 as Decimal(18,2))  as AcumGravPeriodosAnteriores
	INTO #TempSUBSIDIOSUM      
	FROM @dtempleados e
		left join @dtDetallePeriodo dp      
		on e.IDEmpleado = dp.IDEmpleado
		inner join @dtConceptos c      
			on dp.IDConcepto = c.IDConcepto 
			and c.IDPais = @IDPais
		inner join Nomina.tblCatTipoCalculoISR ti      
			on ti.IDCalculo = c.IDCalculo      
	WHERE ti.Codigo = 'ISR_SUELDOS'      
	GROUP BY dp.IDEmpleado      
    
	IF object_id('tempdb..#TempIndemnizacion') is not null      
	DROP TABLE #TempIndemnizacion; 

	SELECT 
		dp.IDEmpleado as IDEmpleado
		,@IDConcepto as IDConcepto
		,@IDPeriodo as IDPeriodo
		,isnull(SUM(dp.ImporteTotal1),0) as ImporteTotal1  
	INTO #TempIndemnizacion      
	FROM @dtempleados e
		left join @dtDetallePeriodo dp      
		on e.IDEmpleado = dp.IDEmpleado
		inner join @dtConceptos c      
			on dp.IDConcepto = c.IDConcepto      
		inner join Nomina.tblCatTipoCalculoISR ti      
			on ti.IDCalculo = c.IDCalculo      
	WHERE ti.Codigo = 'ISR_INDEMNIZACIONES'      
		and C.IDTipoConcepto = 1 -- PERCEPCIONES     
	GROUP BY dp.IDEmpleado  

    
	
	UPDATE GP
		set GP.AcumGravPeriodosAnteriores = Acum.ImporteGravado
	FROM #TempSUBSIDIOSUM GP
		Cross Apply [Nomina].[fnObtenerAcumuladoPorTipoConceptoPorMesTipoISR](GP.IDEmpleado,1,@IDMes,@Ejercicio,@IDCalculoISRSueldos) Acum



 
	IF(@General = 1 OR @Especial = 1 OR @Finiquito = 1)
	BEGIN

		IF object_ID('TEMPDB..#TempValores') IS NOT NULL DROP TABLE #TempValores
	    
		SELECT      
		  Empleados.IDEmpleado,      
		  @IDPeriodo as IDPeriodo,      
		  @Concepto_IDConcepto as IDConcepto,      
		  CASE WHEN ((isnull(DTLocal.CantidadOtro2,0) = -1) ) THEN 0      
			ELSE      
		   CASE WHEN @Concepto_bCantidadMonto  = 1 and ISNULL(DTLocal.CantidadMonto,0) > 0 THEN ISNULL(DTLocal.CantidadMonto,0)          
			  WHEN @Concepto_bCantidadDias  = 1 and ISNULL(DTLocal.CantidadDias,0)  > 0 THEN ISNULL(DTLocal.CantidadDias,0)         
			  WHEN @Concepto_bCantidadVeces = 1 and ISNULL(DTLocal.CantidadVeces,0) > 0 THEN ISNULL(DTLocal.CantidadVeces,0)         
			  WHEN @Concepto_bCantidadOtro1 = 1 and ISNULL(DTLocal.CantidadOtro1,0) > 0 THEN ISNULL(DTLocal.CantidadOtro1,0)         
			  WHEN @Concepto_bCantidadOtro2 = 1 and ISNULL(DTLocal.CantidadOtro2,0) > 0 THEN ISNULL(DTLocal.CantidadOtro2,0)         
			 ELSE 
					CASE WHEN (ISNULL(Empleados.SalarioDiario,0.00) <= 9081.00) THEN
							  (isnull(dtDiasPagados.ImporteTotal1,0)+isnull(dtDiasVacaciones.ImporteTotal1,0)+isnull(dtSeptimoDia.ImporteTotal1,0) ) * @ValorDiarioUMA
						ELSE
							0
						END
					--CASE WHEN @ISRProporcional in(0,1,2,3) THEN
					--						case when s.SumImporteGravado > 0 then Nomina.fnSubsidioEmpleoCalculo(@IDPeriodicidadPagoPeriodo,(s.SumImporteGravado),(isnull(dtDiasPagados.ImporteTotal1,0)+isnull(dtDiasVacaciones.ImporteTotal1,0)+isnull(dtSeptimoDia.ImporteTotal1,0)),@Ejercicio, @MesFin,@IDPais)    else 0 end
					--			WHEN @ISRProporcional = 4 THEN 
					--					CASE WHEN @MesFin = 0 THEN case when s.SumImporteGravado > 0 then Nomina.fnSubsidioEmpleoCalculo(@IDPeriodicidadPagoPeriodo,(s.SumImporteGravado),(isnull(dtDiasPagados.ImporteTotal1,0)+isnull(dtDiasVacaciones.ImporteTotal1,0)+isnull(dtSeptimoDia.ImporteTotal1,0)),@Ejercicio, @MesFin,@IDPais)    else 0 end
					--					ELSE case when s.SumImporteGravado > 0  and Nomina.fnSubsidioEmpleoCalculo(@IDPeriodicidadPagoMensual,(isnull(s.SumImporteGravado,0) + isnull(s.AcumGravPeriodosAnteriores,0)),(isnull(dtDiasPagados.ImporteTotal1,0)+isnull(dtDiasVacaciones.ImporteTotal1,0)+isnull(dtSeptimoDia.ImporteTotal1,0)),@Ejercicio, @MesFin,@IDPais) > 0 then Nomina.fnSubsidioEmpleoCalculo(@IDPeriodicidadPagoMensual,(isnull(s.SumImporteGravado,0) + isnull(s.AcumGravPeriodosAnteriores,0)),(isnull(dtDiasPagados.ImporteTotal1,0)+isnull(dtDiasVacaciones.ImporteTotal1,0)+isnull(dtSeptimoDia.ImporteTotal1,0)),@Ejercicio, @MesFin,@IDPais) - isnull(AcumSub.ImporteTotal1,0)
					--					else 0 end
					--					END
					--			ELSE 0 
					--			END
			 END       
		   END Valor 
		   , @ValorDiarioUMA as UMADiaria
		   , dias = isnull(dtDiasPagados.ImporteTotal1,0)+isnull(dtDiasVacaciones.ImporteTotal1,0)+isnull(dtSeptimoDia.ImporteTotal1,0)
		   , ( @ValorDiarioUMA * 15) as valor2
			,ISNULL(DTLocal.CantidadMonto,0) as CantidadMonto      
			,ISNULL(DTLocal.CantidadDias ,0) as CantidadDias      
			,ISNULL(DTLocal.CantidadVeces,0) as CantidadVeces      
			,ISNULL(DTLocal.CantidadOtro1,0) as CantidadOtro1      
			,ISNULL(DTLocal.CantidadOtro2,0) as CantidadOtro2   
			,ISNULL(AcumSub.ImporteTotal1,0) as AcumuladoSubsidio
		  INTO #TempValores      
		  FROM @dtempleados Empleados      
		   Left Join @dtDetallePeriodoLocal DTLocal      
			on Empleados.IDEmpleado = DTLocal.IDEmpleado      
			  Left Join #TempSUBSIDIOSUM s      
			on s.IDEmpleado = Empleados.IDEmpleado      
			  and s.IDConcepto = @IDConcepto      
			  and s.IDPeriodo = @IDPeriodo 
			left join @dtDetallePeriodo dtDiasPagados
			on dtDiasPagados.IDEmpleado = s.IDEmpleado
				and dtDiasPagados.IDConcepto = @IDConcepto005
			left join @dtDetallePeriodo dtDiasVacaciones
			on dtDiasVacaciones.IDEmpleado = s.IDEmpleado
				and dtDiasVacaciones.IDConcepto = @IDConcepto002
			left join @dtDetallePeriodo dtSeptimoDia
			on dtSeptimoDia.IDEmpleado = s.IDEmpleado
				and dtSeptimoDia.IDConcepto = @IDConcepto007
		
			Cross apply Nomina.[fnObtenerAcumuladoPorConceptoPorMes](Empleados.IDEmpleado,@IDConcepto,@IDMes,@Ejercicio)  as AcumSub
			left join #TempIndemnizacion indemnizacion
			on indemnizacion.IDEmpleado = Empleados.IDEmpleado

	--select * from #TempValores

	IF object_ID('TEMPDB..#TempValoresFinales') IS NOT NULL DROP TABLE #TempValoresFinales

		--select @TopeMensualSubsidio

		select V.*,
			SubsidioFinal = CASE WHEN (V.AcumuladoSubsidio >= @TopeMensualSubsidio) THEN 0
								 WHEN (V.AcumuladoSubsidio + V.Valor <= @TopeMensualSubsidio) THEN V.Valor
								 WHEN (V.AcumuladoSubsidio + V.Valor > @TopeMensualSubsidio ) THEN 
												CASE WHEN (@TopeMensualSubsidio - V.AcumuladoSubsidio) >= V.Valor THEN V.Valor
													 ELSE  (@TopeMensualSubsidio - V.AcumuladoSubsidio)
													 END
								END
			,ISRCausado =  isnull(dtISR.ImporteTotal1,0)
		INTO #TempValoresFinales 
		from #TempValores V
			left join @dtDetallePeriodo dtISR
				on V.IDEmpleado = dtISR.IDEmpleado
				and dtISR.IDConcepto = @IDConcepto079

		--select * from #TempValoresFinales


		
		INSERT INTO #TempDetalle(IDEmpleado,IDPeriodo,IDConcepto,CantidadDias,CantidadMonto,CantidadVeces,CantidadOtro1,CantidadOtro2,ImporteGravado,ImporteExcento,ImporteTotal1,ImporteTotal2)      
		SELECT IDEmpleado,       
			IDPeriodo,      
			IDConcepto,      
			CantidadDias,      
			CantidadMonto,      
			CantidadVeces,      
			CantidadOtro1,      
			CantidadOtro2,      
			ImporteGravado =0.00,    
			ImporteExcento = 0.00,      
			ImporteTotal1 = CASE WHEN ISRCausado <= SubsidioFinal THEN ISRCausado
								 ELSE SubsidioFinal
								END,
			ImporteTotal2 = 0.00      
		FROM #TempValoresFinales  


		MERGE @dtDetallePeriodoLocal AS TARGET      
		USING #TempDetalle AS SOURCE      
		ON TARGET.IDPeriodo = SOURCE.IDPeriodo      
			and TARGET.IDConcepto = @Concepto_IDConcepto      
			and TARGET.IDEmpleado = SOURCE.IDEmpleado      
		WHEN MATCHED Then      
		update      
			Set  TARGET.CantidadMonto  = isnull(SOURCE.CantidadMonto ,0)      
			,TARGET.CantidadDias   = isnull(SOURCE.CantidadDias  ,0)      
			,TARGET.CantidadVeces  = isnull(SOURCE.CantidadVeces ,0)      
			,TARGET.CantidadOtro1  = isnull(SOURCE.CantidadOtro1 ,0)      
			,TARGET.CantidadOtro2  = isnull(SOURCE.CantidadOtro2 ,0)      
			,TARGET.ImporteGravado  = SOURCE.ImporteGravado      
			,TARGET.ImporteExcento  = SOURCE.ImporteExcento      
			,TARGET.ImporteTotal1  = SOURCE.ImporteTotal1      
			,TARGET.ImporteTotal2  = SOURCE.ImporteTotal2      
         
		WHEN NOT MATCHED BY TARGET THEN       
		INSERT(IDEmpleado,IDPeriodo,IDConcepto,CantidadDias,CantidadMonto,CantidadVeces,CantidadOtro1,CantidadOtro2,ImporteGravado,ImporteExcento,ImporteTotal1,ImporteTotal2)      
		VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,SOURCE.IDConcepto,isnull(SOURCE.CantidadMonto ,0),isnull(SOURCE.CantidadDias  ,0),isnull(SOURCE.CantidadVeces ,0)      
		,isnull(SOURCE.CantidadOtro1 ,0),isnull(SOURCE.CantidadOtro2 ,0),SOURCE.ImporteGravado,SOURCE.ImporteExcento,SOURCE.ImporteTotal1,SOURCE.ImporteTotal2)      
		WHEN NOT MATCHED BY SOURCE THEN       
		DELETE; 

 

	END
	

 

	Select * from @dtDetallePeriodoLocal  
 	--where 
		--(isnull(CantidadMonto,0)+		 
		--isnull(CantidadDias,0)+		 
		--isnull(CantidadVeces,0)+		 
		--isnull(CantidadOtro1,0)+		 
		--isnull(CantidadOtro2,0)+		 
		--isnull(ImporteGravado,0)+		 
		--isnull(ImporteExcento,0)+		 
		--isnull(ImporteOtro,0)+		 
		--isnull(ImporteTotal1,0)+		 
		--isnull(ImporteTotal2,0) ) <> 0	 
END;
GO
