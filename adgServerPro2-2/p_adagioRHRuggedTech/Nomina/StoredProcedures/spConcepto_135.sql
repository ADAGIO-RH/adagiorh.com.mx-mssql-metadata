USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: VALES DE DESPENSA
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
CREATE PROC [Nomina].[spConcepto_135]
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
		,@Codigo varchar(20) = '135' 
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
		,@StartYear date  
		,@Finiquito bit 
		,@Especial bit 
		,@DiasBismestre int   
		,@Cerrado bit 
		,@PeriodicidadPago Varchar(100)
		,@isPreviewFiniquito bit 
		,@ValorUMA Decimal(18,2)
		,@IDConcepto101 int  /*Sueldo*/
		,@IDConcepto004 int  /*Ausentismo*/
		,@IDConcepto003 int  /*Incapacidades*/
		,@IDConcepto120 int  /*Vacaciones*/
		,@porcentaje Decimal(18,2) = 0.11
		,@AcumuladoSalarios decimal(10,4)
	;

	select top 1 
		@IDPeriodo = IDPeriodo ,@IDTipoNomina= IDTipoNomina,@Ejercicio = Ejercicio,@ClavePeriodo	= ClavePeriodo,@DescripcionPeriodo =  Descripcion 
		,@FechaInicioPago = FechaInicioPago,@FechaFinPago	= FechaFinPago,@FechaInicioIncidencia = FechaInicioIncidencia,@FechaFinIncidencia=	 FechaFinIncidencia 
		,@Dias = Dias,@AnioInicio = AnioInicio,@AnioFin = AnioFin,@MesInicio = MesInicio,@MesFin = MesFin 
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin 
		,@General = General,@Finiquito = Finiquito,@Especial = Especial,@Cerrado = Cerrado 
	from @dtPeriodo 
 
	select top 1 @IDConcepto=IDConcepto from @dtConceptos where Codigo=@Codigo; 
	select @IDConcepto101=IDConcepto from @dtConceptos where Codigo = '101'

	select @IDConcepto004=IDConcepto from @dtConceptos where Codigo = '004'
	select @IDConcepto003=IDConcepto from @dtConceptos where Codigo = '003'
	select @IDConcepto120=IDConcepto from @dtConceptos where Codigo = '120'
 
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
     
		set @StartYear = cast(cast(@Ejercicio as varchar)+'-01-01' as date)  

	 	select @DiasBismestre = CASE   -- WHEN DATEPART(MONTH,@FechaInicioPago) in (1) AND  ( @Ejercicio = 2022 ) then  15 
										WHEN DATEPART(MONTH,@FechaInicioPago) in (1)   then  DateDiff(day,DATEADD(MONTH,0,@StartYear), EOMONTH( DATEADD(MONTH,0,@StartYear)))+1  
										WHEN DATEPART(MONTH,@FechaInicioPago) in (2)   then  DateDiff(day,DATEADD(MONTH,1,@StartYear), EOMONTH( DATEADD(MONTH,1,@StartYear)))+1    
										WHEN DATEPART(MONTH,@FechaInicioPago) in (3)   then  DateDiff(day,DATEADD(MONTH,2,@StartYear), EOMONTH( DATEADD(MONTH,2,@StartYear)))+1    
										WHEN DATEPART(MONTH,@FechaInicioPago) in (4)   then  DateDiff(day,DATEADD(MONTH,3,@StartYear), EOMONTH( DATEADD(MONTH,3,@StartYear)))+1    
										WHEN DATEPART(MONTH,@FechaInicioPago) in (5)   then  DateDiff(day,DATEADD(MONTH,4,@StartYear), EOMONTH( DATEADD(MONTH,4,@StartYear)))+1    
										WHEN DATEPART(MONTH,@FechaInicioPago) in (6)   then  DateDiff(day,DATEADD(MONTH,5,@StartYear), EOMONTH( DATEADD(MONTH,5,@StartYear)))+1   
										WHEN DATEPART(MONTH,@FechaInicioPago) in (7)   then  DateDiff(day,DATEADD(MONTH,6,@StartYear), EOMONTH( DATEADD(MONTH,6,@StartYear)))+1  
										WHEN DATEPART(MONTH,@FechaInicioPago) in (8)   then  DateDiff(day,DATEADD(MONTH,7,@StartYear), EOMONTH( DATEADD(MONTH,7,@StartYear)))+1  
										WHEN DATEPART(MONTH,@FechaInicioPago) in (9)   then  DateDiff(day,DATEADD(MONTH,8,@StartYear), EOMONTH( DATEADD(MONTH,8,@StartYear)))+1  
										WHEN DATEPART(MONTH,@FechaInicioPago) in (10)  then  DateDiff(day,DATEADD(MONTH,9,@StartYear),EOMONTH( DATEADD(MONTH,9,@StartYear)))+1  
										WHEN DATEPART(MONTH,@FechaInicioPago) in (11)  then  DateDiff(day,DATEADD(MONTH,10,@StartYear),EOMONTH( DATEADD(MONTH,10,@StartYear)))+1  
										WHEN DATEPART(MONTH,@FechaInicioPago) in (12)  then  DateDiff(day,DATEADD(MONTH,11,@StartYear),EOMONTH( DATEADD(MONTH,11,@StartYear)))+1  
               else 0 END 
     

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

 
	IF(@General = 1 OR @Finiquito = 1)
	BEGIN

		 select top 1 @ValorUMA = isnull(UMA,0) -- Aqui se obtiene el valor del Salario Minimo del catalogo de Salarios minimos
		 from Nomina.tblSalariosMinimos
		 where Year(Fecha) = @Ejercicio
		 ORder by Fecha Desc

		 IF @ValorUMA is null OR ISNULL(@ValorUMA,0) = 0
		 BEGIN
			RAISERROR ('El valor de la UMA para este ejercicio no ha sido capturado', 16, 1);
			RETURN 1;
		 END

		IF object_ID('TEMPDB..#TempValores') IS NOT NULL DROP TABLE #TempValores

		SELECT
			Empleados.IDEmpleado,
		
			@IDPeriodo as IDPeriodo,
			@Concepto_IDConcepto as IDConcepto,
			CASE		WHEN ISNULL(DTLocal.CantidadOtro2,0) = -1 then 0
						WHEN @Concepto_bCantidadMonto  = 1 and ISNULL(DTLocal.CantidadMonto,0) > 0 THEN ISNULL(DTLocal.CantidadMonto,0)		  
						WHEN @Concepto_bCantidadDias  = 1 and ISNULL(DTLocal.CantidadDias,0)  > 0 THEN ISNULL(DTLocal.CantidadDias,0)	  
						WHEN @Concepto_bCantidadVeces = 1 and ISNULL(DTLocal.CantidadVeces,0) > 0 THEN ISNULL(DTLocal.CantidadVeces,0)	  
						WHEN @Concepto_bCantidadOtro1 = 1 and ISNULL(DTLocal.CantidadOtro1,0) > 0 THEN ISNULL(DTLocal.CantidadOtro1,0)	  
						WHEN @Concepto_bCantidadOtro2 = 1 and ISNULL(DTLocal.CantidadOtro2,0) > 0 THEN ISNULL(DTLocal.CantidadOtro2,0)	  
				ELSE
					CASE WHEN @MesFin=1 THEN
						CASE WHEN (( ( ISNULL( AcumuladoPeriodoAnterior.ImporteTotal1,0) + isnull(dtSueldo.ImporteTotal1,0) + isnull( AcumuladoPeriodoAnteriorVaca.ImporteTotal1,0) + isnull(dtVacaciones.ImporteTotal1  , 0 )) * @porcentaje ) < ( ( @DiasBismestre  ) * @ValorUMA ) ) THEN
							(( ISNULL( AcumuladoPeriodoAnterior.ImporteTotal1,0) + isnull(dtSueldo.ImporteTotal1,0) + isnull(AcumuladoPeriodoAnteriorVaca.ImporteTotal1,0) + isnull(dtVacaciones.ImporteTotal1, 0 )) * @porcentaje ) 
						ELSE
							( ( @DiasBismestre ) * @ValorUMA ) 
						END





					END 
				END Valor 
			,ISNULL(DTLocal.CantidadMonto,0) as CantidadMonto  
			,ISNULL(DTLocal.CantidadDias ,0) as CantidadDias  
			,ISNULL(DTLocal.CantidadVeces,0) as CantidadVeces  																							  
			,ISNULL(DTLocal.CantidadOtro1,0) as CantidadOtro1  																							  
			,ISNULL(DTLocal.CantidadOtro2,0) as CantidadOtro2
			,Isnull(DTLocal.ImporteExcento,0)as AcumValesExcento 																							  
		INTO #TempValores
		FROM @dtempleados Empleados
			Left Join @dtDetallePeriodoLocal DTLocal
				on Empleados.IDEmpleado = DTLocal.IDEmpleado
			Left Join @dtDetallePeriodo dtSueldo
				 on Empleados.IDEmpleado = dtSueldo.IDEmpleado
					 and dtSueldo.IDConcepto = @IDConcepto101 -- DIAS PAGADOS
						 and dtSueldo.IDPeriodo = @IDPeriodo
					--	 Left Join @dtDetallePeriodo dtAusentismos
				 --on Empleados.IDEmpleado = dtAusentismos.IDEmpleado
					-- and dtAusentismos.IDConcepto = @IDConcepto003 -- DIAS PAGADOS
					--	 and dtAusentismos.IDPeriodo = @IDPeriodo

						 	 Left Join @dtDetallePeriodo dtVacaciones
				 on Empleados.IDEmpleado = dtVacaciones.IDEmpleado
					 and dtVacaciones.IDConcepto = @IDConcepto120 -- VACACIONES
						 and dtVacaciones.IDPeriodo = @IDPeriodo

			Cross Apply Nomina.fnObtenerAcumuladoPorConceptoPorMes(Empleados.IDEmpleado, @IDConcepto003,@IDMes,@Ejercicio) Incapacidades
				Cross Apply Nomina.fnObtenerAcumuladoPorConceptoPorMes(Empleados.IDEmpleado, @IDConcepto004,@IDMes,@Ejercicio) Ausentismos
								Cross Apply Nomina.fnObtenerAcumuladoPorConceptoPorMes(Empleados.IDEmpleado, @IDConcepto101,@IDMes,@Ejercicio) AcumuladoPeriodoAnterior
								Cross Apply Nomina.fnObtenerAcumuladoPorConceptoPorMes(Empleados.IDEmpleado, @IDConcepto120,@IDMes,@Ejercicio) AcumuladoPeriodoAnteriorVaca


	
		/* Inicio de segmento para programar las opciones de LFT, Personalizada, Doble Paga*/
		/* @Concepto_LFT, @Concepto_Personalizada, @Concepto_ConDoblePago*/
		
			IF(ISNULL(@Concepto_LFT,0) = 1)
			BEGIN
				insert into #TempDetalle(IDEmpleado,IDPeriodo,IDConcepto,CantidadDias,CantidadMonto,CantidadVeces,CantidadOtro1,CantidadOtro2,ImporteGravado,ImporteExcento,ImporteTotal1,ImporteTotal2,Descripcion,IDReferencia)
				Select	IDEmpleado, 
						IDPeriodo,
						IDConcepto,
						CantidadDias ,
						CantidadMonto,
						CantidadVeces,
						CantidadOtro1,
						CantidadOtro2,
						ImporteGravado = CASE WHEN @MesFin=1 THEN CASE WHEN Valor  >= (@ValorUMA * @DiasBismestre) then(Valor ) - (@ValorUMA * @DiasBismestre)  else 0 END END,
						ImporteExcento = CASE WHEN @MesFin=1 THEN CASE WHEN Valor  <= (@ValorUMA * @DiasBismestre) then Valor else (@ValorUMA * @DiasBismestre)  END END,
						--ImporteGravado = 0.00 ,
						--ImporteExcento = Valor,
						ImporteTotal1 = Valor,
						ImporteTotal2 = 0.00,
						Descripcion = '',
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
		(isnull(CantidadMonto,0)<> 0 OR		 
		isnull(CantidadDias,0)<> 0 OR		 		 
		isnull(CantidadVeces,0)<> 0 OR		 		 
		isnull(CantidadOtro1,0)<> 0 OR		 		 
		isnull(CantidadOtro2,0)<> 0 OR		 		 
		isnull(ImporteGravado,0)<> 0 OR		 		 
		isnull(ImporteExcento,0)<> 0 OR		 		 
		isnull(ImporteOtro,0)<> 0 OR		 		 
		isnull(ImporteTotal1,0)<> 0 OR		 		 
		isnull(ImporteTotal2,0)<> 0 		  )	 
END;
GO
