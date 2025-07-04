USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: ISR AJUSTE MES(NOMBRE OPCIONAL)
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
CREATE PROC [Nomina].[spCoreConcepto_301C]
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
		,@Codigo varchar(20) = '301C' 
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
		,@IDConcepto184 int -- ajust
        ,@IDConcepto078 int -- subsidio casuado
		,@IDCalculoISRSueldos int  
		,@IDPeriodicidadPagoPeriodo int
		,@IDPais int 
		,@UMA decimal(18,2)
		,@PorcentajeUMASubsidio decimal(18,4) 
		,@ValorDiarioUMA decimal(18,4)
		,@TopeMensualSubsidioSalario decimal(18,2)
		,@ConfiguracionReformaSubsidio2024 bit = 0
		,@TopeMensualSubsidio decimal(18,2)
		,@TopeSalarialPorPeriodo decimal(18,2)
	;

	select top 1 
		@IDPeriodo = IDPeriodo ,@IDTipoNomina= IDTipoNomina,@Ejercicio = Ejercicio,@ClavePeriodo	= ClavePeriodo,@DescripcionPeriodo =  Descripcion 
		,@FechaInicioPago = FechaInicioPago,@FechaFinPago	= FechaFinPago,@FechaInicioIncidencia = FechaInicioIncidencia,@FechaFinIncidencia=	 FechaFinIncidencia 
		,@Dias = Dias,@AnioInicio = AnioInicio,@AnioFin = AnioFin,@MesInicio = MesInicio,@MesFin = MesFin 
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin 
		,@General = General,@Finiquito = Finiquito,@Especial = Especial,@Cerrado = Cerrado 
	from @dtPeriodo 
 
 
	IF(isnull(@MesFin,0)= 0)
	BEGIN
		RETURN;
	END


	select top 1 @IDConcepto=IDConcepto from @dtConceptos where Codigo=@Codigo; 
	--select top 1 @IDConcepto184=IDConcepto from @dtConceptos where Codigo='184'; 
	select top 1 @IDConcepto078=IDConcepto from @dtConceptos where Codigo='078'; 

	SELECT top 1 @UMA = isnull(UMA,0.00), @TopeMensualSubsidioSalario = isnull(TopeMensualSubsidioSalario,0.00), @PorcentajeUMASubsidio = isnull(PorcentajeUMASubsidio,0.00)
	FROM Nomina.tblSalariosMinimos with(nolock)
	WHERE YEAR(Fecha) = YEAR( @FechaInicioPago)
	ORDER BY Fecha desc

	SET @ValorDiarioUMA = @UMA * (@PorcentajeUMASubsidio / 100.00)
	SET @TopeMensualSubsidio = @ValorDiarioUMA * 30.4
	SET @TopeSalarialPorPeriodo = ((@TopeMensualSubsidioSalario/30.4)*@Dias)
	--select @ValorDiarioUMA ValorDiarioUMA , @TopeMensualSubsidio

	select @ConfiguracionReformaSubsidio2024 = CAST(isnull((Valor),'0') as bit) 
	from @dtconfigs 
	where Configuracion = 'SUBSIDIOREFORMA2024'

	select top 1 @IDCalculoISRSueldos = IDCalculo       
	from Nomina.tblCatTipoCalculoISR with(nolock)       
	WHERE Codigo = 'ISR_SUELDOS'  

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

	Select TOP 1 @IDPeriodicidadPagoPeriodo = IDPeriodicidadPago , @IDPais = IDPais     
	from Nomina.tblCatTipoNomina  with(nolock)      
	where IDTipoNomina = @IDTipoNomina   
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
    IF(@MesFin= 0)
	 BEGIN
		RETURN ; 
	 END
 
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


	IF(isnull(@ConfiguracionReformaSubsidio2024,0) = 0)
		BEGIN

			IF(@General = 1 OR @Finiquito = 1 OR @Especial = 1)
			BEGIN
				IF object_ID('TEMPDB..#TempValores') IS NOT NULL DROP TABLE #TempValores
 
				SELECT
					Empleados.IDEmpleado,
					@IDPeriodo as IDPeriodo,
					@Concepto_IDConcepto as IDConcepto,
					CASE WHEN @Concepto_bCantidadMonto  = 1 and ISNULL(DTLocal.CantidadMonto,0) > 0 THEN ISNULL(DTLocal.CantidadMonto,0)		  
								WHEN @Concepto_bCantidadDias  = 1 and ISNULL(DTLocal.CantidadDias,0)  > 0 THEN ISNULL(DTLocal.CantidadDias,0)	  
								WHEN @Concepto_bCantidadVeces = 1 and ISNULL(DTLocal.CantidadVeces,0) > 0 THEN ISNULL(DTLocal.CantidadVeces,0)	  
								WHEN @Concepto_bCantidadOtro1 = 1 and ISNULL(DTLocal.CantidadOtro1,0) > 0 THEN ISNULL(DTLocal.CantidadOtro1,0)	  
								WHEN @Concepto_bCantidadOtro2 = 1 and ISNULL(DTLocal.CantidadOtro2,0) > 0 THEN ISNULL(DTLocal.CantidadOtro2,0)	  
						ELSE CASE WHEN isnull(DT184.ImporteTotal1,0) > 0 then 
								--isnull(DT184.ImporteTotal1,0) -- Función personalizada																			  
								isnull(subsidio.ImporteTotal1,0)
								ELSE 0
								END																  
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
					inner Join @dtDetallePeriodo DT184
						on Empleados.IDEmpleado = DT184.IDEmpleado
						and DT184.IDConcepto = @IDConcepto184
					CROSS APPLY Nomina.fnObtenerAcumuladoPorConceptoPorMes(Empleados.IDEmpleado,@IDConcepto078,@IDMes,@Ejercicio) subsidio
 
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
						IDReferencia = 0  
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
	END 
	ELSE
	BEGIN
		IF object_ID('TEMPDB..#TempValoresReforma') IS NOT NULL DROP TABLE #TempValoresReforma
	    
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
					CASE WHEN (((ISNULL(s.SumImporteGravado,0.00)+(ISNULL(s.AcumGravPeriodosAnteriores,0)))) <= @TopeMensualSubsidioSalario) THEN
								    0
							ELSE
								isnull(AcumSub.ImporteTotal1,0)
							END
			 END       
		   END Valor 
		   , @ValorDiarioUMA as UMADiaria
		   , ( @ValorDiarioUMA * 15) as valor2
			,ISNULL(DTLocal.CantidadMonto,0) as CantidadMonto      
			,ISNULL(DTLocal.CantidadDias ,0) as CantidadDias      
			,ISNULL(DTLocal.CantidadVeces,0) as CantidadVeces      
			,ISNULL(DTLocal.CantidadOtro1,0) as CantidadOtro1      
			,ISNULL(DTLocal.CantidadOtro2,0) as CantidadOtro2   
			,ISNULL(AcumSub.ImporteTotal1,0) as AcumuladoSubsidio
			,ISNULL(s.SumImporteGravado,0.00) GravadoPeriodoActual
			,ISNULL(s.AcumGravPeriodosAnteriores,0) as GravadoPeriodoAnteriores
		  INTO #TempValoresReforma      
		  FROM @dtempleados Empleados      
		   Left Join @dtDetallePeriodoLocal DTLocal      
			on Empleados.IDEmpleado = DTLocal.IDEmpleado      
			  Left Join #TempSUBSIDIOSUM s      
			on s.IDEmpleado = Empleados.IDEmpleado      
			  and s.IDConcepto = @IDConcepto      
			  and s.IDPeriodo = @IDPeriodo 
			Cross apply Nomina.[fnObtenerAcumuladoPorConceptoPorMes](Empleados.IDEmpleado,@IDConcepto078,@IDMes,@Ejercicio)  as AcumSub
			left join #TempIndemnizacion indemnizacion
			on indemnizacion.IDEmpleado = Empleados.IDEmpleado
	--select * from #TempValoresReforma 

	IF object_ID('TEMPDB..#TempValoresFinalesReforma') IS NOT NULL DROP TABLE #TempValoresFinalesReforma

		--select @TopeMensualSubsidioSalario

		select V.*,
			SubsidioFinal = CASE WHEN ((ISNULL(v.GravadoPeriodoActual,0.00)+(ISNULL(v.GravadoPeriodoAnteriores,0)) > @TopeMensualSubsidioSalario)) THEN V.AcumuladoSubsidio
								 WHEN ((ISNULL(v.GravadoPeriodoActual,0.00)+(ISNULL(v.GravadoPeriodoAnteriores,0)) <= @TopeMensualSubsidioSalario)) THEN 0
								END
			
		INTO #TempValoresFinalesReforma 
		from #TempValoresReforma V

		--select * from #TempValoresFinalesReforma
				
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
			ImporteTotal1 = SubsidioFinal,
			ImporteTotal2 = 0.00      
		FROM #TempValoresFinalesReforma  

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
 	where 
		(isnull(CantidadMonto,0)<> 0 OR		 
		isnull(CantidadDias,0)<> 0 OR		 		 
		isnull(CantidadVeces,0)<> 0 OR		 		 
		isnull(CantidadOtro1,0)<> 0 OR		 		 
		isnull(CantidadOtro2,0)<> 0 OR		 		 
		isnull(ImporteGravado,0)<> 0 OR		 		 
		isnull(ImporteExcento,0)<> 0 OR		 		 
		isnull(ImporteOtro,0)<> 0 OR		 		 
		isnull(ImporteTotal1,0)<> 0 OR		 		 
		isnull(ImporteTotal2,0) <> 0 		 ) 
END;
GO
