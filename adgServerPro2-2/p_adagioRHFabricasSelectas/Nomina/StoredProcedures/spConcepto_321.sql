USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [Nomina].[spConcepto_321]
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
		,@Codigo varchar(20) = '321' 
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
	;

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
		,@Concepto_ConDoblePago bit
		;
		
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
 
 		if object_id('tempdb..#TempTotalPercepciones') is not null      
		drop table #TempTotalPercepciones;       
  
		select 
			dp.IDEmpleado as IDEmpleado
			,isnull(SUM(dp.ImporteTotal1),0) as SumImporteTotal1  
		into #TempTotalPercepciones      
		from @dtempleados e
			left join @dtDetallePeriodo dp      
			on e.IDEmpleado = dp.IDEmpleado
			inner join @dtConceptos c      
				on dp.IDConcepto = c.IDConcepto      
			-- inner join Nomina.tblCatTipoCalculoISR ti      
			-- 	on ti.IDCalculo = c.IDCalculo      

		where  C.IDTipoConcepto = 1 -- PERCEPCIONES     
		Group by dp.IDEmpleado   
		
		  if object_id('tempdb..#TempTotalDeducciones') is not null      
		drop table #TempTotalDeducciones;       
  
		select 
			dp.IDEmpleado as IDEmpleado
			,isnull(SUM(dp.ImporteTotal1),0) as SumImporteTotal1  
			
		into #TempTotalDeducciones      
		from @dtempleados e
			left join @dtDetallePeriodo dp      
			on e.IDEmpleado = dp.IDEmpleado
			inner join @dtConceptos c      
				on dp.IDConcepto = c.IDConcepto      
			-- inner join Nomina.tblCatTipoCalculoISR ti      
			-- 	on ti.IDCalculo = c.IDCalculo      
		where  C.IDTipoConcepto = 2 -- DEDUCCIONES     
			and c.OrdenCalculo < @Concepto_OrdenCalculo
		Group by dp.IDEmpleado    

		IF object_ID('TEMPDB..#TempValidaCobroPrestamo') IS NOT NULL DROP TABLE #TempValidaCobroPrestamo
		IF object_ID('TEMPDB..#TempValidaCobroPrestamoFiniquito') IS NOT NULL DROP TABLE #TempValidaCobroPrestamoFiniquito
     
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

 
	IF(@General = 1)
	BEGIN
		IF object_ID('TEMPDB..#tmpPagosPrestamo') IS NOT NULL DROP TABLE #tmpPagosPrestamo
 
		 select e.IDEmpleado,
			   c.IDConcepto,
			   @IDPeriodo as IDPeriodo,
			   p.IDPrestamo,
			   p.Codigo,
			   p.Descripcion,
			   TP.Descripcion TipoPrestamo,
			   p.MontoPrestamo,
			   p.Cuotas,
			   isnull((Select SUM(MontoCuota) from Nomina.fnPagosPrestamo(p.IDPrestamo)),0) as Balance,

			--    CASE WHEN ISNULL(DP.CantidadMonto,0) = 0 THEN CASE WHEN isnull((Select SUM(MontoCuota) from Nomina.fnPagosPrestamo(p.IDPrestamo)),0) + p.Cuotas > p.MontoPrestamo then p.MontoPrestamo - isnull((Select SUM(MontoCuota) from Nomina.fnPagosPrestamo(p.IDPrestamo)),0)
			-- 												ELSE p.Cuotas
			-- 												END  
			-- 		ELSE ISNULL(DP.CantidadMonto,0)
			-- 		END AS PAGO
            CASE WHEN ISNULL(DP.CantidadMonto,0) = 0 THEN CASE WHEN (ISNULL((SELECT COUNT(*) 
                                                                              FROM Nomina.fnPagosPrestamo(p.IDPrestamo)),0)+1=P.CantidadCuotas )----Se valida que si esta en la ultima cuota liquide el prestamo aunque falten unos pesos o centavos
                                                                                                                                               THEN (ISNULL(p.MontoPrestamo,0)+ISNULL(p.Intereses,0)) - isnull((Select SUM(MontoCuota) from Nomina.fnPagosPrestamo(p.IDPrestamo)),0) 
                                                                  WHEN ((ISNULL((SELECT SUM(MontoCuota) 
                                                                                FROM Nomina.fnPagosPrestamo(p.IDPrestamo)),0) + p.Cuotas) > p.MontoPrestamo) --- Se valida que si con una cuota más supera el monto del prestamo solo le descuente el faltante
                                                                                                                                                THEN (ISNULL(p.MontoPrestamo,0)+ISNULL(p.Intereses,0)) - isnull((Select SUM(MontoCuota) from Nomina.fnPagosPrestamo(p.IDPrestamo)),0)															      
                                                            ELSE p.Cuotas ---Solo descuenta la cuota correspondiente
															END  
					ELSE ISNULL(DP.CantidadMonto,0)
					END AS PAGO
			INTO #tmpPagosPrestamo
		From Nomina.tblPrestamos p 
			inner join @dtempleados e
				on p.IDEmpleado = e.IDEmpleado
					and e.IDTipoNomina = @IDTipoNomina
			inner join Nomina.tblCatEstatusPrestamo EP
				on EP.IDEstatusPrestamo = p.IDEstatusPrestamo
			Inner join Nomina.tblCatTiposPrestamo TP
				on TP.IDTipoPrestamo = p.IDTipoPrestamo
			Inner join Nomina.tblCatConceptos c
				on TP.IDConcepto = c.IDConcepto
			Left Join @dtDetallePeriodoLocal DP
				on DP.IDEmpleado = e.IDEmpleado
				and DP.IDConcepto = C.IDConcepto
				AND DP.IDPeriodo = @IDPeriodo
				AND DP.IDReferencia = P.IDPrestamo
		WHERE EP.Descripcion in ('ACTIVO')
			and p.FechaInicioPago <= @FechaFinPago
			and c.IDConcepto = @IDConcepto

	
		select E.IDEmpleado
			, SUM(ISNULL(Percep.SumImporteTotal1,0)) as TotalPercepciones
			, SUM(ISNULL(Deduc.SumImporteTotal1,0)) as TotalDeduciones
			, SUM(ISNULL(Prestamos.PAGO,0)) as TotalPrestamos
		  into #TempValidaCobroPrestamo
		from @dtempleados e
		inner join #tmpPagosPrestamo Prestamos on e.IDEmpleado = Prestamos.IDEmpleado
		left join #TempTotalPercepciones Percep on E.IDEmpleado = Percep.IDEmpleado
		left join #TempTotalDeducciones Deduc on e.IDEmpleado = Deduc.IDEmpleado
		GROUP By E.IDEmpleado
		
		--select * from #TempValidaCobroPrestamo

		Delete #tmpPagosPrestamo
		where IDEmpleado in (Select IDEmpleado from #TempValidaCobroPrestamo WHERE (TotalPercepciones <= TotalDeduciones) OR ((TotalPercepciones - TotalDeduciones)-TotalPrestamos) <= 0 )




	MERGE @dtDetallePeriodoLocal AS TARGET
	   USING #tmpPagosPrestamo AS SOURCE
		  ON TARGET.IDPeriodo = SOURCE.IDPeriodo
				and TARGET.IDConcepto = @IDConcepto
				and TARGET.IDEmpleado = SOURCE.IDEmpleado
				and TARGET.IDReferencia = SOURCE.IDPrestamo
    WHEN MATCHED Then
	   update
		  Set 				
			 TARGET.ImporteTotal1  = SOURCE.PAGO
			 ,TARGET.IDReferencia = SOURCE.IDPrestamo
			 ,TARGET.Descripcion = SOURCE.TipoPrestamo
			
		  WHEN NOT MATCHED BY TARGET THEN 
			 INSERT(IDEmpleado,IDPeriodo,IDConcepto,ImporteTotal1,IDReferencia,Descripcion)
			 VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,@IDConcepto,Source.PAGO,SOURCE.IDPrestamo,SOURCE.TipoPrestamo)
		  WHEN NOT MATCHED BY SOURCE THEN 
		  DELETE;


		/* Inicio de segmento para programar las opciones de LFT, Personalizada, Doble Paga*/
		/* @Concepto_LFT, @Concepto_Personalizada, @Concepto_ConDoblePago*/
		
		/*IF(ISNULL(@Concepto_LFT,0) = 1)  
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
				ImporteGravado = Valor,  
				ImporteExcento = 0.00,  
				ImporteTotal1 = Valor,  
				ImporteTotal2 = 0.00,  
				Descripcion = '',  
				IDReferencia = NULL  
			FROM #TempValores  
		END*/

		/* FIN de segmento para programar las opciones de LFT, Personalizada, Doble Paga*/
		/* Fin de segmento para programar el cuerpo del concepto*/
 

	END ELSE
	IF (@Finiquito = 1)
	BEGIN
		/* AGREGAR CÓDIGO PARA FINIQUITOS AQUÍ */
		
		IF object_ID('TEMPDB..#tmpPagosPrestamoFiniquito') IS NOT NULL DROP TABLE #tmpPagosPrestamoFiniquito
 
		 select e.IDEmpleado,
			   c.IDConcepto,
			   @IDPeriodo as IDPeriodo,
			   p.IDPrestamo,
			   p.Codigo,
			   p.Descripcion,
			   TP.Descripcion TipoPrestamo,
			   p.MontoPrestamo,
			   p.Cuotas,
			   isnull((Select SUM(MontoCuota) from Nomina.fnPagosPrestamo(p.IDPrestamo)),0) as Balance,

			  
			CASE WHEN ISNULL(DP.CantidadMonto,0) = 0 THEN  (ISNULL(p.MontoPrestamo,0)+ISNULL(p.Intereses,0)) - isnull((Select SUM(MontoCuota) from Nomina.fnPagosPrestamo(p.IDPrestamo)),0) ---Liquida el préstamo
					ELSE ISNULL(DP.CantidadMonto,0)
					END AS PAGO
			INTO #tmpPagosPrestamoFiniquito
		From Nomina.tblPrestamos p 
			inner join @dtempleados e
				on p.IDEmpleado = e.IDEmpleado
					and e.IDTipoNomina = @IDTipoNomina
			inner join Nomina.tblCatEstatusPrestamo EP
				on EP.IDEstatusPrestamo = p.IDEstatusPrestamo
			Inner join Nomina.tblCatTiposPrestamo TP
				on TP.IDTipoPrestamo = p.IDTipoPrestamo
			Inner join Nomina.tblCatConceptos c
				on TP.IDConcepto = c.IDConcepto
			Left Join @dtDetallePeriodoLocal DP
				on DP.IDEmpleado = e.IDEmpleado
				and DP.IDConcepto = C.IDConcepto
				AND DP.IDPeriodo = @IDPeriodo
				AND DP.IDReferencia = P.IDPrestamo
		WHERE EP.Descripcion in ('ACTIVO')
			--and p.FechaInicioPago <= @FechaFinPago
			and c.IDConcepto = @IDConcepto

	MERGE @dtDetallePeriodoLocal AS TARGET
	   USING #tmpPagosPrestamoFiniquito AS SOURCE
		  ON TARGET.IDPeriodo = SOURCE.IDPeriodo
				and TARGET.IDConcepto = @IDConcepto
				and TARGET.IDEmpleado = SOURCE.IDEmpleado
				and TARGET.IDReferencia = SOURCE.IDPrestamo
    WHEN MATCHED Then
	   update
		  Set 				
			 TARGET.ImporteTotal1  = SOURCE.PAGO
			 ,TARGET.IDReferencia = SOURCE.IDPrestamo
			 ,TARGET.Descripcion = SOURCE.TipoPrestamo
			
		  WHEN NOT MATCHED BY TARGET THEN 
			 INSERT(IDEmpleado,IDPeriodo,IDConcepto,ImporteTotal1,IDReferencia,Descripcion)
			 VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,@IDConcepto,Source.PAGO,SOURCE.IDPrestamo,SOURCE.TipoPrestamo)
		  WHEN NOT MATCHED BY SOURCE THEN 
		  DELETE;


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
 

		--MERGE @dtDetallePeriodoLocal AS TARGET
		--USING #TempDetalle AS SOURCE
		--	ON TARGET.IDPeriodo = SOURCE.IDPeriodo
		--		and TARGET.IDConcepto = @Concepto_IDConcepto
		--		and TARGET.IDEmpleado = SOURCE.IDEmpleado
		--WHEN MATCHED Then
		--	update
		--		Set TARGET.CantidadMonto  = isnull(SOURCE.CantidadMonto ,0)  
		--	 ,TARGET.CantidadDias   = isnull(SOURCE.CantidadDias  ,0)  
		--	 ,TARGET.CantidadVeces  = isnull(SOURCE.CantidadVeces ,0)  
		--	 ,TARGET.CantidadOtro1  = isnull(SOURCE.CantidadOtro1 ,0)  
		--	 ,TARGET.CantidadOtro2  = isnull(SOURCE.CantidadOtro2 ,0)  
		--	 ,TARGET.ImporteTotal1  = ISNULL(SOURCE.ImporteTotal1 ,0)
		--	 ,TARGET.ImporteTotal2  = ISNULL(SOURCE.ImporteTotal2 ,0)
		--	 ,TARGET.ImporteGravado = ISNULL(SOURCE.ImporteGravado,0)
		--	 ,TARGET.ImporteExcento = ISNULL(SOURCE.ImporteExcento,0)
		--	 ,TARGET.Descripcion	= SOURCE.Descripcion
		--	 ,TARGET.IDReferencia	= NULL


		--WHEN NOT MATCHED BY TARGET THEN 
		--	INSERT(IDEmpleado,IDPeriodo,IDConcepto,  
		--	CantidadMonto,CantidadDias ,CantidadVeces,CantidadOtro1,CantidadOtro2,
		--	ImporteTotal1,ImporteTotal2, ImporteGravado,ImporteExcento,Descripcion,IDReferencia
			  
		--	)  
		--	VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,@Concepto_IDConcepto,  
		--	isnull(SOURCE.CantidadMonto ,0),isnull(SOURCE.CantidadDias  ,0),isnull(SOURCE.CantidadVeces ,0)  
		--	,isnull(SOURCE.CantidadOtro1 ,0),isnull(SOURCE.CantidadOtro2 ,0),
		--	ISNULL(SOURCE.ImporteTotal1 ,0),ISNULL(SOURCE.ImporteTotal2 ,0),ISNULL(SOURCE.ImporteGravado,0)
		--	,ISNULL(SOURCE.ImporteExcento,0),SOURCE.Descripcion, NULL
		--	)
		--WHEN NOT MATCHED BY SOURCE THEN 
		--DELETE;

	Select * from @dtDetallePeriodoLocal  
 	where 
		(isnull(CantidadMonto,0) <> 0 OR		 
		isnull(CantidadDias,0) <> 0 OR		 
		isnull(CantidadVeces,0) <> 0 OR		 
		isnull(CantidadOtro1,0) <> 0 OR		 
		isnull(CantidadOtro2,0) <> 0 OR		 
		isnull(ImporteGravado,0) <> 0 OR		 
		isnull(ImporteExcento,0) <> 0 OR		 
		isnull(ImporteOtro,0) <> 0 OR		 
		isnull(ImporteTotal1,0) <> 0 OR		 
		isnull(ImporteTotal2,0)  <> 0 ) 	 
END;
GO
