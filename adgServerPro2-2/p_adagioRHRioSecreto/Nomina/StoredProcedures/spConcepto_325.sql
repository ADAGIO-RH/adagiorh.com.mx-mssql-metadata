USE [p_adagioRHRioSecreto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [Nomina].[spConcepto_325]
( @dtconfigs [Nomina].[dtConfiguracionNomina] READONLY 
 ,@dtempleados [RH].[dtEmpleados] READONLY 
 ,@dtConceptos [Nomina].[dtConceptos] READONLY 
 ,@dtPeriodo [Nomina].[dtPeriodos] READONLY 
 ,@dtDetallePeriodo [Nomina].[dtDetallePeriodo] READONLY) 
AS 
BEGIN 
 /* Versión 0.2 BETA */
 /* Descripción del Concepto: otras deducciones*/
	   DECLARE 
       @ClaveEmpleado varchar(20) 
      ,@IDEmpleado int 
      ,@i int = 0 
      ,@Codigo varchar(20) ='325' 
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
	    ,@Aguinaldo bit 
	    ,@PTU bit 
	    ,@Cerrado bit 
		,@IDConcepto401 int  /*Cafeteria NF*/
		,@IDConcepto402 int  /*Celular NF*/
		,@IDConcepto403 int  /*Desc Empleado NF*/
		,@IDConcepto406 int  /*Permisos sin goce NF*/
		,@IDConcepto407 int  /*Faltas NF*/
		,@IDConcepto410 int  /*Incapacidad NF*/
		,@IDConcepto330 int  /*Permisos sin goce Fisca*/
		,@IDConcepto331 int  /*Faltas Fiscal*/
		,@IDConcepto332 int  /*Inc general*/

		select @IDConcepto401=IDConcepto from @dtConceptos where Codigo = '401'
		select @IDConcepto402=IDConcepto from @dtConceptos where Codigo = '402'
		select @IDConcepto403=IDConcepto from @dtConceptos where Codigo = '403'
		select @IDConcepto406=IDConcepto from @dtConceptos where Codigo = '406'
		select @IDConcepto407=IDConcepto from @dtConceptos where Codigo = '407'
		select @IDConcepto410=IDConcepto from @dtConceptos where Codigo = '410'
		select @IDConcepto330=IDConcepto from @dtConceptos where Codigo = '330'
		select @IDConcepto331=IDConcepto from @dtConceptos where Codigo = '331'
		select @IDConcepto332=IDConcepto from @dtConceptos where Codigo = '332'


	    select top 1 
	    @IDPeriodo = IDPeriodo ,@IDTipoNomina= IDTipoNomina,@Ejercicio = Ejercicio,@ClavePeriodo	= ClavePeriodo,@DescripcionPeriodo =  Descripcion 
	    ,@FechaInicioPago = FechaInicioPago,@FechaFinPago	= FechaFinPago,@FechaInicioIncidencia = FechaInicioIncidencia,@FechaFinIncidencia=	 FechaFinIncidencia 
	    ,@Dias = Dias,@AnioInicio = AnioInicio,@AnioFin = AnioFin,@MesInicio = MesInicio,@MesFin = MesFin 
	    ,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin 
	    ,@General = General,@Finiquito = Finiquito
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
		

		DECLARE @var nvarchar(max);
		
		SELECT @var = STUFF( (
		   SELECT ',' + Codigo
		      FROM [Nomina].[tblCatConceptos]
			     WHERE Codigo IN ( '401','402' ,'403' ,'406','407','410') FOR XML PATH('') ) , 1  ,1 ,'' ) 
		--WHERE Codigo IN ('401','402','403','410') FOR XML PATH('') ) , 1  ,1 ,'' ) 
		
		
	    insert into @dtDetallePeriodoLocal 
	    select * from @dtDetallePeriodo where IDConcepto=@IDConcepto 
 
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
 
	  /* Inicio de segmento para programar el cuerpo del concepto*/
 
 
	IF object_ID('TEMPDB..#TempValores') IS NOT NULL
		DROP TABLE #TempValores
 
	SELECT
		Empleados.IDEmpleado,
		@IDPeriodo as IDPeriodo,
		@Concepto_IDConcepto as IDConcepto,
		CASE WHEN ((isnull(DTLocal.CantidadOtro2,0) = -1) ) THEN 0
		WHEN @Concepto_bCantidadMonto  = 1 and ISNULL(DTLocal.CantidadMonto,0) > 0 THEN ISNULL(DTLocal.CantidadMonto,0)
			 ELSE   
				( isnull(dtCafeteriaNf.ImporteTotal1,0) +
				isnull(dtCelularNf.ImporteTotal1,0)   +
				isnull(dtDescEmpNf.ImporteTotal1,0)   +
				isnull(dtPSGNf.ImporteTotal1,0)		  +
				isnull(gtfaltasNF.ImporteTotal1,0)	  +
				isnull(incGeneralNF.ImporteTotal1,0) ) -

				(isnull(gtPSGF.ImporteTotal1,0) +
				 isnull(gtFaltaF.ImporteTotal1,0)+
				 isnull(incGeneral.ImporteTotal1,0)  )


				--dtCafeteriaNf.ImporteTotal1 + dtCelularNf.ImporteTotal1
					  
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

			Left Join @dtDetallePeriodo dtCafeteriaNf
						on Empleados.IDEmpleado = dtCafeteriaNf.IDEmpleado
						and dtCafeteriaNf.IDConcepto = @IDConcepto401
						and dtCafeteriaNf.IDPeriodo = @IDPeriodo
			Left Join @dtDetallePeriodo dtCelularNf
						on Empleados.IDEmpleado = dtCelularNf.IDEmpleado
						and dtCelularNf.IDConcepto = @IDConcepto402
						and dtCelularNf.IDPeriodo = @IDPeriodo
			Left Join @dtDetallePeriodo dtDescEmpNf
						on Empleados.IDEmpleado = dtDescEmpNf.IDEmpleado
						and dtDescEmpNf.IDConcepto = @IDConcepto403
						and dtDescEmpNf.IDPeriodo = @IDPeriodo
			Left Join @dtDetallePeriodo dtPSGNf
						on Empleados.IDEmpleado = dtPSGNf.IDEmpleado
						and dtPSGNf.IDConcepto = @IDConcepto406
						and dtPSGNf.IDPeriodo = @IDPeriodo
			Left Join @dtDetallePeriodo gtfaltasNF
						on Empleados.IDEmpleado = gtfaltasNF.IDEmpleado
						and gtfaltasNF.IDConcepto = @IDConcepto407
						and gtfaltasNF.IDPeriodo = @IDPeriodo
			Left Join @dtDetallePeriodo gtPSGF
						on Empleados.IDEmpleado = gtPSGF.IDEmpleado
						and gtPSGF.IDConcepto = @IDConcepto330
						and gtPSGF.IDPeriodo = @IDPeriodo
			Left Join @dtDetallePeriodo gtFaltaF
						on Empleados.IDEmpleado = gtFaltaF.IDEmpleado
						and gtFaltaF.IDConcepto = @IDConcepto331
						and gtFaltaF.IDPeriodo = @IDPeriodo
			Left Join @dtDetallePeriodo incGeneral
						on Empleados.IDEmpleado = incGeneral.IDEmpleado
						and incGeneral.IDConcepto = @IDConcepto332
						and incGeneral.IDPeriodo = @IDPeriodo
			Left Join @dtDetallePeriodo incGeneralNF
						on Empleados.IDEmpleado = incGeneralNF.IDEmpleado
						and incGeneralNF.IDConcepto = @IDConcepto410
						and incGeneralNF.IDPeriodo = @IDPeriodo

		where isnull(Empleados.SalarioDiarioReal,0) > 0
		--group by Empleados.IDEmpleado
		--,ISNULL(DTLocal.CantidadMonto,0)
		--,ISNULL(DTLocal.CantidadDias ,0)
		--,ISNULL(DTLocal.CantidadVeces,0)
		--,ISNULL(DTLocal.CantidadOtro1,0)
		--,ISNULL(DTLocal.CantidadOtro2,0)	
 
 
		/* Inicio de segmento para programar las opciones de LFT, Personalizada, Doble Paga*/
		/* @Concepto_LFT, @Concepto_Personalizada, @Concepto_ConDoblePago*/
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


			--IF(ISNULL(@Concepto_LFT,0) = 1)
			--BEGIN
				insert into #TempDetalle(IDEmpleado,IDPeriodo,IDConcepto,CantidadDias,CantidadMonto,CantidadVeces,CantidadOtro1,CantidadOtro2,ImporteGravado,ImporteExcento,ImporteTotal1,ImporteTotal2,Descripcion,IDReferencia)
				Select	IDEmpleado, 
						IDPeriodo,
						IDConcepto,
						CantidadDias,
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
			--END
 
	
 
		/* FIN de segmento para programar las opciones de LFT, Personalizada, Doble Paga*/
 
	  /* Fin de segmento para programar el cuerpo del concepto*/
 
 
	
 
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
						,TARGET.Descripcion  = SOURCE.Descripcion
						,TARGET.IDReferencia  = SOURCE.IDReferencia
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(IDEmpleado,IDPeriodo,IDConcepto,CantidadDias,CantidadMonto,CantidadVeces,CantidadOtro1,CantidadOtro2,ImporteGravado,ImporteExcento,ImporteTotal1,ImporteTotal2,Descripcion,IDReferencia)
				VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,SOURCE.IDConcepto,isnull(SOURCE.CantidadMonto ,0),isnull(SOURCE.CantidadDias  ,0),isnull(SOURCE.CantidadVeces ,0)
				,isnull(SOURCE.CantidadOtro1 ,0),isnull(SOURCE.CantidadOtro2 ,0),SOURCE.ImporteGravado,SOURCE.ImporteExcento,SOURCE.ImporteTotal1,SOURCE.ImporteTotal2,SOURCE.Descripcion,SOURCE.IDReferencia)
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
