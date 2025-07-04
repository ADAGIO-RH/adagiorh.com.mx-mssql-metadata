USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: AFP
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
CREATE PROC [Nomina].[spConcepto_RD302]
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
		,@Codigo varchar(20) = 'RD302' 
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
        ,@IDConceptoRD550 INT --TOTAL INCOMES
        ,@IDConceptoRD134 INT --INCENTIVES
        ,@IDConceptoRD135 INT --THIRD INCENTIVES
        ,@IDConceptoRD136 INT --PREPAID
        ,@IDConceptoRD142 INT --SALARIO NAVIDEÑO
        ,@IDConceptoRD152 INT --CESANTIA
        ,@IDConceptoRD153 INT --PREAVISO
        ,@IDConceptoRD122 INT --REEMBOLSO
        ,@TopeMensual decimal(18,4)
        ,@Porcentaje decimal(18,4)
        ,@TopePago decimal(18,4)
	;

	   SELECT @IDConceptoRD550=IDConcepto FROM NOMINA.tblCatConceptos WHERE Codigo='RD550'
       SELECT @IDConceptoRD134=IDConcepto FROM NOMINA.tblCatConceptos WHERE Codigo='RD134'
       SELECT @IDConceptoRD135=IDConcepto FROM NOMINA.tblCatConceptos WHERE Codigo='RD135'
       SELECT @IDConceptoRD136=IDConcepto FROM NOMINA.tblCatConceptos WHERE Codigo='RD136'
       SELECT @IDConceptoRD142=IDConcepto FROM NOMINA.tblCatConceptos WHERE Codigo='RD142'
       SELECT @IDConceptoRD152=IDConcepto FROM NOMINA.tblCatConceptos WHERE Codigo='RD152'
       SELECT @IDConceptoRD153=IDConcepto FROM NOMINA.tblCatConceptos WHERE Codigo='RD153'
       SELECT @IDConceptoRD122=IDConcepto FROM NOMINA.tblCatConceptos WHERE Codigo='RD122'


       --SET @TopeMensual = 374040
       --SET @TopeMensual = 387050.00  -- Actualización tope 01 de Febrero 2024  Tope - Seguro de vejez Discapacidad y Sobrevivencia 
	   SET @TopeMensual = 433496.00  -- Actualización tope 01 de Abril 2025  Tope - Seguro de vejez Discapacidad y Sobrevivencia 
       SET @Porcentaje = 0.0287
       SET @TopePago = @TopeMensual * @Porcentaje
    
    select top 1 
		@IDPeriodo = IDPeriodo ,@IDTipoNomina= IDTipoNomina,@Ejercicio = Ejercicio,@ClavePeriodo	= ClavePeriodo,@DescripcionPeriodo =  Descripcion 
		,@FechaInicioPago = FechaInicioPago,@FechaFinPago	= FechaFinPago,@FechaInicioIncidencia = FechaInicioIncidencia,@FechaFinIncidencia=	 FechaFinIncidencia 
		,@Dias = Dias,@AnioInicio = AnioInicio,@AnioFin = AnioFin,@MesInicio = MesInicio,@MesFin = MesFin 
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin 
		,@General = General,@Finiquito = Finiquito,@Especial = Especial,@Cerrado = Cerrado 
	from @dtPeriodo 
 
	select top 1 @IDConcepto=IDConcepto from @dtConceptos where Codigo=@Codigo; 
 
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
		IF object_ID('TEMPDB..#TempValores') IS NOT NULL DROP TABLE #TempValores
		SELECT
			Empleados.IDEmpleado,
			@IDPeriodo as IDPeriodo,
			@Concepto_IDConcepto as IDConcepto,
			CASE		WHEN ISNULL(DTLocal.CantidadOtro2 , 0) = -1 THEN 0
						WHEN ( ( @Concepto_bCantidadMonto  = 1 ) and ( ISNULL(DTLocal.CantidadMonto,0) > 0 ) ) THEN ISNULL(DTLocal.CantidadMonto,0)		
						WHEN @Concepto_bCantidadVeces = 1 and ISNULL(DTLocal.CantidadVeces,0) > 0 THEN ISNULL(DTLocal.CantidadVeces,0)	 
						WHEN @Concepto_bCantidadOtro1 = 1 and ISNULL(DTLocal.CantidadOtro1,0) > 0 THEN ISNULL(DTLocal.CantidadOtro1,0)	 
						WHEN @Concepto_bCantidadOtro2 = 1 and ISNULL(DTLocal.CantidadOtro2,0) > 0 THEN ISNULL(DTLocal.CantidadOtro2,0)	 
				ELSE
                CASE WHEN @MesFin = 0 THEN --Primer quincena
                        CASE WHEN (ISNULL(TI550.ImporteTotal1, 0)
                                   - ISNULL(R122.ImporteTotal1, 0)
                                   - ISNULL(I134.ImporteTotal1, 0) - ISNULL(TI135.ImporteTotal1, 0)
                                   - ISNULL(P136.ImporteTotal1, 0) - ISNULL(SN142.ImporteTotal1, 0)
                                   - ISNULL(C152.ImporteTotal1, 0)
                                   - ISNULL(P153.ImporteTotal1, 0)
                                  ) < @TopeMensual 
                                  THEN 
                                    (ISNULL(TI550.ImporteTotal1, 0)
                                   - ISNULL(R122.ImporteTotal1, 0)
                                   - ISNULL(I134.ImporteTotal1, 0) - ISNULL(TI135.ImporteTotal1, 0)
                                   - ISNULL(P136.ImporteTotal1, 0) - ISNULL(SN142.ImporteTotal1, 0)
                                   - ISNULL(C152.ImporteTotal1, 0)
                                   - ISNULL(P153.ImporteTotal1, 0)
                                  )*@Porcentaje 
                                ELSE
                                      @TopeMensual*@Porcentaje
                        END
                        ELSE --Ajuste Mensual
                            CASE WHEN 
                                    (CASE WHEN ISNULL(TI550.ImporteTotal1, 0)- ISNULL(R122.ImporteTotal1, 0) - ISNULL(I134.ImporteTotal1, 0) - ISNULL(TI135.ImporteTotal1, 0)
                                            - ISNULL(P136.ImporteTotal1, 0) - ISNULL(SN142.ImporteTotal1, 0)
                                            - ISNULL(C152.ImporteTotal1, 0)
                                            - ISNULL(P153.ImporteTotal1, 0)
                                             < @TopeMensual 
                                            THEN 
                                                (ISNULL(TI550.ImporteTotal1, 0)- ISNULL(R122.ImporteTotal1, 0)
                                   - ISNULL(I134.ImporteTotal1, 0) - ISNULL(TI135.ImporteTotal1, 0)
                                   - ISNULL(P136.ImporteTotal1, 0) - ISNULL(SN142.ImporteTotal1, 0)
                                   - ISNULL(C152.ImporteTotal1, 0)
                                   - ISNULL(P153.ImporteTotal1, 0)
                                  )*@Porcentaje 
                                            ELSE
                                                @TopeMensual*@Porcentaje
                                    END)  + isnull(AcumAFP.ImporteTotal1,0) >= @TopePago THEN 
                                                                                            CASE WHEN @TopePago - isnull(AcumAFP.ImporteTotal1,0) < 0.10 THEN 0 
                                                                                                ELSE @TopePago - isnull(AcumAFP.ImporteTotal1,0) 
                                                                                                END
                                            
                            ELSE 
                                CASE WHEN (ISNULL(TI550.ImporteTotal1, 0)
                                   - ISNULL(R122.ImporteTotal1, 0)
                                   - ISNULL(I134.ImporteTotal1, 0) - ISNULL(TI135.ImporteTotal1, 0)
                                   - ISNULL(P136.ImporteTotal1, 0) - ISNULL(SN142.ImporteTotal1, 0)
                                   - ISNULL(C152.ImporteTotal1, 0)
                                   - ISNULL(P153.ImporteTotal1, 0)
                                  )
                                         < @TopeMensual 
                                        THEN 
                                        (ISNULL(TI550.ImporteTotal1, 0)
                                   - ISNULL(R122.ImporteTotal1, 0)
                                   - ISNULL(I134.ImporteTotal1, 0) - ISNULL(TI135.ImporteTotal1, 0)
                                   - ISNULL(P136.ImporteTotal1, 0) - ISNULL(SN142.ImporteTotal1, 0)
                                   - ISNULL(C152.ImporteTotal1, 0)
                                   - ISNULL(P153.ImporteTotal1, 0)
                                  )*@Porcentaje 
                                        ELSE
                                            @TopeMensual*@Porcentaje
                                END
                            END   
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
            Left join @dtDetallePeriodo TI550
                ON Empleados.IDEmpleado=TI550.IDEmpleado
                AND TI550.IDConcepto=@IDConceptoRD550
                AND TI550.IDPeriodo=@IDPeriodo
            Left join @dtDetallePeriodo I134
                ON Empleados.IDEmpleado=I134.IDEmpleado
                AND I134.IDConcepto=@IDConceptoRD134
                AND I134.IDPeriodo=@IDPeriodo
            Left join @dtDetallePeriodo TI135
                ON Empleados.IDEmpleado=TI135.IDEmpleado
                AND TI135.IDConcepto=@IDConceptoRD135
                AND TI135.IDPeriodo=@IDPeriodo
            Left join @dtDetallePeriodo P136
                ON Empleados.IDEmpleado=P136.IDEmpleado
                AND P136.IDConcepto=@IDConceptoRD136
                AND P136.IDPeriodo=@IDPeriodo   
            Left join @dtDetallePeriodo SN142
                ON Empleados.IDEmpleado=SN142.IDEmpleado
                AND SN142.IDConcepto=@IDConceptoRD142
                AND SN142.IDPeriodo=@IDPeriodo                    
            Left join @dtDetallePeriodo C152
                ON Empleados.IDEmpleado=C152.IDEmpleado
                AND C152.IDConcepto=@IDConceptoRD152
                AND C152.IDPeriodo=@IDPeriodo
            Left join @dtDetallePeriodo P153
                ON Empleados.IDEmpleado=P153.IDEmpleado
                AND P153.IDConcepto=@IDConceptoRD153
                AND P153.IDPeriodo=@IDPeriodo
            Left join @dtDetallePeriodo R122
                ON Empleados.IDEmpleado=R122.IDEmpleado
                AND R122.IDConcepto=@IDConceptoRD122
                AND R122.IDPeriodo=@IDPeriodo    
            CROSS APPLY Nomina.fnObtenerAcumuladoPorConceptoPorMes(Empleados.IDEmpleado,@IDConcepto,@IDMes,@Ejercicio)  as AcumAFP                      
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
	END ELSE
	IF (@Finiquito = 1)
	BEGIN
		/* AGREGAR CÓDIGO PARA FINIQUITOS AQUÍ */
		
		/*
		MERGE @dtDetallePeriodoLocal AS TARGET
		USING #TempValoresFiniquito AS SOURCE
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
