USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: PRIMA VACACIONAL
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
CREATE PROC [Nomina].[spConcepto_121]
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
		,@Codigo varchar(20) = '121' 
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
		,@UMA decimal(18,2)  
		,@SalarioMinimo Decimal(18,2)  
		,@IDConcepto120 int --Concepto de Vacaciones  
		,@IDConcepto002 int --Concepto de DIAS Vacaciones  
		,@ExentoPrimaVacacional int = 15 -- Cantidad de umas exentas por año de la prima vacacional  
		,@ConfigPrimaVacaciónal varchar(255)
		,@PagarFondo BIT
	;

	select top 1 
		@IDPeriodo = IDPeriodo ,@IDTipoNomina= IDTipoNomina,@Ejercicio = Ejercicio,@ClavePeriodo	= ClavePeriodo,@DescripcionPeriodo =  Descripcion 
		,@FechaInicioPago = FechaInicioPago,@FechaFinPago	= FechaFinPago,@FechaInicioIncidencia = FechaInicioIncidencia,@FechaFinIncidencia=	 FechaFinIncidencia 
		,@Dias = Dias,@AnioInicio = AnioInicio,@AnioFin = AnioFin,@MesInicio = MesInicio,@MesFin = MesFin 
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin 
		,@General = General,@Finiquito = Finiquito,@Especial = Especial,@Cerrado = Cerrado 
	from @dtPeriodo 
 
	select top 1 @IDConcepto=IDConcepto from @dtConceptos where Codigo=@Codigo; 
	select top 1 @IDConcepto120=IDConcepto from @dtConceptos where Codigo='120';   
	select top 1 @IDConcepto002=IDConcepto from @dtConceptos where Codigo='002';   

	SELECT @PagarFondo = CASE WHEN CAST(ISNULL(Valor,0) AS BIT) = 1 THEN 1 ELSE 0 END FROM App.tblValoresDatosExtras WHERE IDDatoExtra = 4 AND IDReferencia = @IDPeriodo


	-- Glass firma utiliza el calculo de prima vacacional cada que se pagan vacaciones, favor de no borrar de aqui-----

	if @IDTipoNomina = 3 -- Tipo de nomina 3 es TODO glassfirma
		select top 1 @ConfigPrimaVacaciónal= cast(Valor as int) from @dtconfigs where Configuracion='PagoPrimaVacacional';
	else
		select top 1 @ConfigPrimaVacaciónal=cast(Valor as int) from @dtconfigs where Configuracion='PagoPrimaVacacional';    -- Instruccion ORIGINAL

	-- Hasta aqui--- Arturo Guajardo ¡¡¡¡
   
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
	      
	select top 1 @UMA = UMA , @SalarioMinimo = SalarioMinimo -- Aqui se obtiene el valor de la UMA del catalogo de Salarios minimos  
	from Nomina.tblSalariosMinimos  
	where Year(Fecha) = @Ejercicio  
	ORder by Fecha Desc  

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
	
	IF @UMA is null OR ISNULL(@UMA,0) = 0  
    BEGIN  
		RAISERROR ('El valor de la UMA para este ejercicio no ha sido capturado', 16, 1);  
		RETURN 1;  
    END   
  
      
    IF @SalarioMinimo is null OR ISNULL(@SalarioMinimo,0) = 0  
    BEGIN  
		RAISERROR ('El valor del Salario Mínimo para este ejercicio no ha sido capturado', 16, 1);  
		RETURN 1;  
    END

	IF object_ID('TEMPDB..#TempDetalle') IS NOT NULL DROP TABLE #TempDetalle  
    
     
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

 
	IF(@General = 1 OR (@Finiquito = 1))
	BEGIN
		IF object_ID('TEMPDB..#TempValores') IS NOT NULL DROP TABLE #TempValores
 
		  select Empleados.IDEmpleado,  
			   @IDPeriodo as IDPeriodo,  
			   @Concepto_IDConcepto as IDConcepto  
			   ,CASE WHEN ((isnull(DTLocal.CantidadMonto,0) >0) ) THEN DTLocal.CantidadMonto
			         WHEN ((isnull(DTLocal.CantidadOtro2,0) = -1) ) THEN 0  
				ELSE 
					CASE WHEN @PagarFondo = 1 THEN 0
						 WHEN @ConfigPrimaVacaciónal = 0 THEN 
							CASE WHEN ((isnull(DTLocal.CantidadMonto,0) >0) ) THEN DTLocal.CantidadMonto
								 WHEN ((isnull(DTLocal.CantidadDias,0) >0) ) THEN ((CASE WHEN @isPreviewFiniquito = 0 THEN Empleados.SalarioDiario
																					ELSE ISNULL(cf.SueldoFiniquito,0) END)*isnull(PD.PrimaVacacional,0)) *isnull(DTLocal.CantidadDias,0)  
								 WHEN ((isnull(DT120.ImporteTotal1,0) >0) ) THEN ((CASE WHEN @isPreviewFiniquito = 0 THEN Empleados.SalarioDiario
																				ELSE ISNULL(cf.SueldoFiniquito,0) END)*isnull(PD.PrimaVacacional,0)) *ISNULL(DT002.ImporteTotal1,0)
							  -- Cuando se tenga que configurar un cliente se tiene que ver la formulacion de la forma de manejar su prima vacacional  
							  -- en base a su formula. Por el momento esta formula es el default.  
        
							  ELSE 0  
							  END  
				    WHEN @ConfigPrimaVacaciónal = 1 THEN 
							 CASE WHEN Empleados.FechaAntiguedad is not null 

                                    THEN  
                                    CASE WHEN  ( DATEPART(MONTH ,Empleados.FechaAntiguedad ) = 2 and DATEPART(DAY , Empleados.FechaAntiguedad ) = 29 ) AND NOT ((DATEPART(YEAR , @FechaFinPago ) % 4 = 0 AND DATEPART(YEAR , @FechaFinPago ) % 100 <> 0) OR DATEPART(YEAR , @FechaFinPago ) % 400 = 0) 
                                        THEN
                                        CASE WHEN 
                                            ( ( DATEFROMPARTS ( DATEPART(YEAR , @FechaInicioPago ) , DATEPART(MONTH , Empleados.FechaAntiguedad ),  DATEPART( DAY , DATEADD (DAY,-1,Empleados.FechaAntiguedad) )  ) )
                                                BETWEEN  @FechaInicioPago AND  @FechaFinPago ) AND  ( ( DATEPART(YEAR , @FechaInicioPago) - DATEPART(YEAR , Empleados.FechaAntiguedad  )  ) > 0 )  
                                                OR 
                                            ( ( (DATEFROMPARTS ( DATEPART(YEAR , @FechaFinPago ) , DATEPART(MONTH , Empleados.FechaAntiguedad),  DATEPART( DAY , DATEADD (DAY,-1,Empleados.FechaAntiguedad)  )  ) )
                                                BETWEEN  @FechaInicioPago AND  @FechaFinPago ) AND  ( ( DATEPART(YEAR , @FechaFinPago) - DATEPART(YEAR , Empleados.FechaAntiguedad  )  ) > 0 ) )
                                            THEN  ((CASE WHEN @isPreviewFiniquito = 0 THEN Empleados.SalarioDiario
																				ELSE ISNULL(cf.SueldoFiniquito,0) END)*isnull(PD.PrimaVacacional,0)) *ISNULL(pd.DiasVacaciones,0)
                                            ELSE 0
                                        END

                                    ELSE 
                                                                    
                                        CASE WHEN	
                                            ( ( ( DATEFROMPARTS ( DATEPART(YEAR , @FechaInicioPago ) , DATEPART(MONTH , Empleados.FechaAntiguedad ),  DATEPART( DAY , Empleados.FechaAntiguedad)  ) )
                                                BETWEEN  @FechaInicioPago AND  @FechaFinPago ) AND  ( ( DATEPART(YEAR , @FechaInicioPago) - DATEPART(YEAR , Empleados.FechaAntiguedad  )  ) > 0 ) ) 
                                                OR 
                                            ( ( ( DATEFROMPARTS ( DATEPART(YEAR , @FechaFinPago ) , DATEPART(MONTH , Empleados.FechaAntiguedad),  DATEPART( DAY , Empleados.FechaAntiguedad)  ) )
                                                BETWEEN  @FechaInicioPago AND  @FechaFinPago ) AND  ( ( DATEPART(YEAR , @FechaFinPago) - DATEPART(YEAR , Empleados.FechaAntiguedad  )  ) > 0 ) )
                                            THEN  ((CASE WHEN @isPreviewFiniquito = 0 THEN Empleados.SalarioDiario
																				ELSE ISNULL(cf.SueldoFiniquito,0) END)*isnull(PD.PrimaVacacional,0)) *ISNULL(pd.DiasVacaciones,0)
                                            ELSE 0
                                        END
                                    END
        
                            END	
					ELSE 0
					END
			   END AS Valor,  
				
				CASE WHEN ((isnull(DTLocal.CantidadOtro2,0) = -1) ) THEN NULL 
				ELSE 
					CASE WHEN   @ConfigPrimaVacaciónal = 0 THEN 
							CASE WHEN ((isnull(DTLocal.CantidadMonto,0) >0) ) THEN NULL 
							  WHEN ((isnull(DT120.ImporteTotal1,0) >0) ) THEN  Cast( Cast(ISNULL(DT002.ImporteTotal1,0)  as int)  as Varchar(MAX)) + '  Prima(s)'
	 
							  -- Cuando se tenga que configurar un cliente se tiene que ver la formulacion de la forma de manejar su prima vacacional  
							  -- en base a su formula. Por el momento esta formula es el default.  
        
							  ELSE NULL 
							  END  
						 WHEN  @ConfigPrimaVacaciónal = 1 THEN
								CASE WHEN ((isnull(DTLocal.CantidadMonto,0) >0) ) THEN NULL 
								      WHEN Empleados.FechaAntiguedad is not null 

                                    THEN  
                                    CASE WHEN  ( DATEPART(MONTH ,Empleados.FechaAntiguedad ) = 2 and DATEPART(DAY , Empleados.FechaAntiguedad ) = 29 ) AND NOT ((DATEPART(YEAR , @FechaFinPago ) % 4 = 0 AND DATEPART(YEAR , @FechaFinPago ) % 100 <> 0) OR DATEPART(YEAR , @FechaFinPago ) % 400 = 0) 
                                        THEN
                                        CASE WHEN 
                                            ( ( DATEFROMPARTS ( DATEPART(YEAR , @FechaInicioPago ) , DATEPART(MONTH , Empleados.FechaAntiguedad ),  DATEPART( DAY , DATEADD (DAY,-1,Empleados.FechaAntiguedad) )  ) )
                                                BETWEEN  @FechaInicioPago AND  @FechaFinPago ) AND  ( ( DATEPART(YEAR , @FechaInicioPago) - DATEPART(YEAR , Empleados.FechaAntiguedad  )  ) > 0 )  
                                                OR 
                                            ( ( (DATEFROMPARTS ( DATEPART(YEAR , @FechaFinPago ) , DATEPART(MONTH , Empleados.FechaAntiguedad),  DATEPART( DAY , DATEADD (DAY,-1,Empleados.FechaAntiguedad)  )  ) )
                                                BETWEEN  @FechaInicioPago AND  @FechaFinPago ) AND  ( ( DATEPART(YEAR , @FechaFinPago) - DATEPART(YEAR , Empleados.FechaAntiguedad  )  ) > 0 ) )
                                            THEN Cast( Cast(ISNULL(pd.DiasVacaciones,0)  as int)  as Varchar(MAX)) + ' Prima(s)'
                                            ELSE NULL
                                        END

                                    ELSE 
                                                                    
                                        CASE WHEN	
                                            ( ( ( DATEFROMPARTS ( DATEPART(YEAR , @FechaInicioPago ) , DATEPART(MONTH , Empleados.FechaAntiguedad ),  DATEPART( DAY , Empleados.FechaAntiguedad)  ) )
                                                BETWEEN  @FechaInicioPago AND  @FechaFinPago ) AND  ( ( DATEPART(YEAR , @FechaInicioPago) - DATEPART(YEAR , Empleados.FechaAntiguedad  )  ) > 0 ) ) 
                                                OR 
                                            ( ( ( DATEFROMPARTS ( DATEPART(YEAR , @FechaFinPago ) , DATEPART(MONTH , Empleados.FechaAntiguedad),  DATEPART( DAY , Empleados.FechaAntiguedad)  ) )
                                                BETWEEN  @FechaInicioPago AND  @FechaFinPago ) AND  ( ( DATEPART(YEAR , @FechaFinPago) - DATEPART(YEAR , Empleados.FechaAntiguedad  )  ) > 0 ) )
                                            THEN Cast( Cast(ISNULL(pd.DiasVacaciones,0)  as int)  as Varchar(MAX)) + ' Prima(s)'
                                            ELSE NULL
                                        END
                                    END
						 		END
						 ELSE NULL
					END
						   
			   END AS Descripcion, 
				  Acumulado.ImporteGravado AImporteGravado,  
				  Acumulado.ImporteExento AImporteExento,  
				  Acumulado.ImporteTotal1 AImporteTotal1,  
				  Acumulado.ImporteTotal2 AImporteTotal2,  
				  PD.PrimaVacacional  
			   ,@FechaInicioPago as FechaInicioPeriodo  
			   ,@FechaFinPago as FechaFinPeriodo  
			   ,ISNULL(DTLocal.CantidadMonto,0) as CantidadMonto  
			   ,ISNULL(DTLocal.CantidadDias ,0) as CantidadDias  
			   ,ISNULL(DTLocal.CantidadVeces,0) as CantidadVeces  
			   ,ISNULL(DTLocal.CantidadOtro1,0) as CantidadOtro1  
			   ,ISNULL(DTLocal.CantidadOtro2,0) as CantidadOtro2   
			into #TempValores  
			from @dtempleados Empleados  
			left join @dtDetallePeriodoLocal DTLocal  
				on DTLocal.IDEmpleado = Empleados.IDEmpleado  
				and DTLocal.IDConcepto = @IDConcepto  
				and DTLocal.IDPeriodo = @IDPeriodo  
			left join @dtDetallePeriodo DT120  
				on DT120.IDEmpleado = Empleados.IDEmpleado  
				and DT120.IDConcepto = @IDConcepto120 
				and DT120.IDPeriodo = @IDPeriodo  
			left join @dtDetallePeriodo DT002  
			on DT002.IDEmpleado = Empleados.IDEmpleado  
			and DT002.IDConcepto = @IDConcepto002  
			and DT002.IDPeriodo = @IDPeriodo 
			Left Join RH.tblCatTiposPrestacionesDetalle PD  
			on Empleados.IDTipoPrestacion = PD.IDTipoPrestacion  
			and PD.Antiguedad = CASE WHEN DATEDIFF(YEAR,Empleados.FechaAntiguedad,@FechaFinPago) < 1 THEN 1  
						ELSE DATEDIFF(YEAR,Empleados.FechaAntiguedad,@FechaFinPago)  
					END  
			CROSS APPLY Nomina.fnObtenerAcumuladoPorConcepto(Empleados.IDEmpleado,@IDConcepto,@Ejercicio) as Acumulado  
			left join Nomina.tblControlFiniquitos cf
				on cf.IDEmpleado = Empleados.IDEmpleado
				and cf.IDPeriodo = @IDPeriodo
 
 
		/* Inicio de segmento para programar las opciones de LFT, Personalizada, Doble Paga*/
		/* @Concepto_LFT, @Concepto_Personalizada, @Concepto_ConDoblePago*/
		
		IF(ISNULL(@Concepto_LFT,0) = 1)  
		   BEGIN  
				insert into #TempDetalle(IDEmpleado,IDPeriodo,IDConcepto,CantidadDias,CantidadMonto,CantidadVeces,CantidadOtro1,CantidadOtro2,ImporteGravado,ImporteExcento,ImporteTotal1,ImporteTotal2,Descripcion,IDReferencia)  
				Select IDEmpleado,   
				  IDPeriodo,  
				  IDConcepto,  
				  CantidadDias ,  
				  CantidadMonto,  
				  CantidadVeces,  
				  CantidadOtro1,  
				  CantidadOtro2,  
				  ImporteGravado =  CASE WHEN AImporteExento >= (@ExentoPrimaVacacional*@UMA) THEN Valor	
							   WHEN Valor <= ((@ExentoPrimaVacacional*@UMA) - AImporteExento) THEN 0
							   WHEN Valor >= ((@ExentoPrimaVacacional*@UMA) - AImporteExento) then Valor - ((@ExentoPrimaVacacional*@UMA) - AImporteExento)
						ELSE 0
						END,  
					ImporteExcento = CASE WHEN AImporteExento >= (@ExentoPrimaVacacional*@UMA) THEN 0	
							   WHEN Valor <= ((@ExentoPrimaVacacional*@UMA) - AImporteExento) THEN Valor
							   WHEN Valor >= ((@ExentoPrimaVacacional*@UMA) - AImporteExento) then ((@ExentoPrimaVacacional*@UMA) - AImporteExento)
						ELSE 0
						END,  
				  ImporteTotal1 = Valor,  
				  ImporteTotal2 = 0.00,  
				  Descripcion,  
				  IDReferencia = NULL  
				FROM #TempValores  
   END

		/* FIN de segmento para programar las opciones de LFT, Personalizada, Doble Paga*/
		/* Fin de segmento para programar el cuerpo del concepto*/
 

	END ELSE
	IF (@Especial = 1)
	BEGIN
		/* AGREGAR CÓDIGO PARA ESPECIALES AQUÍ */

		/*
		MERGE @dtDetallePeriodoLocal AS TARGET
		USING #TempValoresEspeciales AS SOURCE
			ON TARGET.IDPeriodo = SOURCE.IDPeriodo
				and TARGET.IDConcepto = @Concepto_IDConcepto
				and TARGET.IDEmpleado = SOURCE.IDEmpleado
		WHEN MATCHED Then
			update
				Set TARGET.ImporteTotal1  = SOURCE.Valor
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(IDEmpleado,IDPeriodo,IDConcepto,ImporteTotal1)
			VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,@Concepto_IDConcepto,Source.Valor)
		WHEN NOT MATCHED BY SOURCE THEN 
			DELETE;
		*/

		PRINT 0
	END;
 

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
		(isnull(CantidadMonto,0) <> 0 OR		 
		isnull(CantidadDias,0)  <> 0 OR		 
		isnull(CantidadVeces,0) <> 0 OR		 
		isnull(CantidadOtro1,0) <> 0 OR		 
		isnull(CantidadOtro2,0) <> 0 OR		 
		isnull(ImporteGravado,0) <> 0 OR		 
		isnull(ImporteExcento,0) <> 0 OR		 
		isnull(ImporteOtro,0) <> 0 OR		 
		isnull(ImporteTotal1,0) <> 0 OR		 
		isnull(ImporteTotal2,0) <> 0  )  	 
END;
GO
