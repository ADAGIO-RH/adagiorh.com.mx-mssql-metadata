USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: AJUSTE DE PRESTAMO INFONAVIT
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
CREATE PROC [Nomina].[spConcepto_306]
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
		,@Codigo varchar(20) = '306' 
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
		,@IDConceptoDiasPagados int 
		,@IDConceptoSeptimoDia int
		,@IDConceptoDiasVacaciones int
		,@VALIDAR_COBRO_PRESTAMO BIT
		,@VALIDAR_CUOTA_PROPORCIONAL_PRESTAMO BIT
	;

	select top 1 
		@IDPeriodo = IDPeriodo ,@IDTipoNomina= IDTipoNomina,@Ejercicio = Ejercicio,@ClavePeriodo	= ClavePeriodo,@DescripcionPeriodo =  Descripcion 
		,@FechaInicioPago = FechaInicioPago,@FechaFinPago	= FechaFinPago,@FechaInicioIncidencia = FechaInicioIncidencia,@FechaFinIncidencia=	 FechaFinIncidencia 
		,@Dias = Dias,@AnioInicio = AnioInicio,@AnioFin = AnioFin,@MesInicio = MesInicio,@MesFin = MesFin 
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin 
		,@General = General,@Finiquito = Finiquito,@Especial = Especial,@Cerrado = Cerrado 
	from @dtPeriodo 
 
	select top 1 @IDConcepto=IDConcepto from @dtConceptos where Codigo=@Codigo; 
	select top 1 @IDConceptoDiasPagados = IDConcepto from @dtConceptos where Codigo = '005';
	select top 1 @IDConceptoSeptimoDia = IDConcepto from @dtConceptos where Codigo = '007';
	select top 1 @IDConceptoDiasVacaciones = IDConcepto from @dtConceptos where Codigo = '002';
 
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


	SELECT TOP 1 @VALIDAR_COBRO_PRESTAMO = CAST(ISNULL(Valor,0) AS BIT)
	FROM Nomina.tblConfiguracionNomina WITH (NOLOCK)
	WHERE Configuracion = 'VALIDAR_COBRO_PRESTAMO'


	SELECT TOP 1 @VALIDAR_CUOTA_PROPORCIONAL_PRESTAMO = CAST(ISNULL(Valor,0) AS BIT)
	FROM Nomina.tblConfiguracionNomina WITH (NOLOCK)
	WHERE Configuracion = 'VALIDAR_CUOTA_PROPORCIONAL_PRESTAMO'


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

			,(((CASE WHEN ISNULL(DP.CantidadMonto,0) = 0 THEN CASE WHEN (ISNULL((SELECT COUNT(*) 
                                                                              FROM Nomina.fnPagosPrestamo(p.IDPrestamo)),0)+1=P.CantidadCuotas )----Se valida que si esta en la ultima cuota liquide el prestamo aunque falten unos pesos o centavos
                                                                                                                                               THEN (ISNULL(p.MontoPrestamo,0)+ISNULL(p.Intereses,0)) - isnull((Select SUM(MontoCuota) from Nomina.fnPagosPrestamo(p.IDPrestamo)),0) 
                                                                  WHEN ((ISNULL((SELECT SUM(MontoCuota) 
                                                                                FROM Nomina.fnPagosPrestamo(p.IDPrestamo)),0) + p.Cuotas) > p.MontoPrestamo) --- Se valida que si con una cuota más supera el monto del prestamo solo le descuente el faltante
                                                                                                                                                THEN (ISNULL(p.MontoPrestamo,0)+ISNULL(p.Intereses,0)) - isnull((Select SUM(MontoCuota) from Nomina.fnPagosPrestamo(p.IDPrestamo)),0)															      
                                                            ELSE p.Cuotas ---Solo descuenta la cuota correspondiente
															END  
					ELSE ISNULL(DP.CantidadMonto,0)
					END) / 7) * (ISNULL(dtDiasPagados.ImporteTotal1,0) + ISNULL(dtSeptimoDia.ImporteTotal1,0) + ISNULL(dtDiasVacaciones.ImporteTotal1,0))) AS PAGO_PROPORCIONAL
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
			Left Join @dtDetallePeriodo dtDiasPagados
				on dtDiasPagados.IDEmpleado = e.IDEmpleado
				and dtDiasPagados.IDConcepto = @IDConceptoDiasPagados
				and dtDiasPagados.IDPeriodo = @IDPeriodo 
			Left Join @dtDetallePeriodo dtSeptimoDia
				on dtSeptimoDia.IDEmpleado = e.IDEmpleado
				and dtSeptimoDia.IDConcepto = @IDConceptoSeptimoDia
				and dtSeptimoDia.IDPeriodo = @IDPeriodo
			Left Join @dtDetallePeriodo dtDiasVacaciones
				on dtDiasVacaciones.IDEmpleado = e.IDEmpleado
				and dtDiasVacaciones.IDConcepto = @IDConceptoDiasVacaciones
				and dtDiasVacaciones.IDPeriodo = @IDPeriodo
		WHERE EP.Descripcion in ('ACTIVO')
			and p.FechaInicioPago <= @FechaFinPago
			and c.IDConcepto = @IDConcepto

			
		IF (@VALIDAR_COBRO_PRESTAMO = 1)
		BEGIN

			PRINT 'VALIDA PRESTAMO'

			IF OBJECT_ID('TempDB..#TempTotalPercepciones') IS NOT NULL  DROP TABLE #TempTotalPercepciones;       
  
			SELECT 
				 DP.IDEmpleado
				,ISNULL(SUM(DP.ImporteTotal1),0) AS ImporteTotal1  
			INTO #TempTotalPercepciones      
			FROM @dtEmpleados E
				LEFT JOIN @dtDetallePeriodo DP      
					ON E.IDEmpleado = DP.IDEmpleado
				INNER JOIN Nomina.tblCatConceptos C 
					ON DP.IDConcepto = C.IDConcepto      
			WHERE C.IDTipoConcepto = 1 --PERCEPCIONES 
			GROUP BY DP.IDEmpleado
		

			IF OBJECT_ID('TempDB..#TempTotalDeducciones') IS NOT NULL DROP TABLE #TempTotalDeducciones;       
  
			SELECT 
				 DP.IDEmpleado 
				,ISNULL(SUM(DP.ImporteTotal1),0) AS ImporteTotal1  
			INTO #TempTotalDeducciones      
			FROM @dtEmpleados E
				LEFT JOIN @dtDetallePeriodo DP      
					ON E.IDEmpleado = DP.IDEmpleado
				INNER JOIN Nomina.tblCatConceptos C 
					ON DP.IDConcepto = C.IDConcepto   
			WHERE  C.IDTipoConcepto = 2 --DEDUCCIONES
				AND  C.OrdenCalculo < @Concepto_OrdenCalculo
			GROUP BY DP.IDEmpleado


			IF OBJECT_ID('TempDB..#TempValidaCobroPrestamo') IS NOT NULL DROP TABLE #TempValidaCobroPrestamo;

			SELECT 
				 ROW_NUMBER() OVER(PARTITION BY Prestamos.IDEmpleado ORDER BY Prestamos.IDPrestamo ASC) AS RN
				,Prestamos.IDEmpleado
				,Prestamos.IDPrestamo
				,(ISNULL(Percep.ImporteTotal1,0) - ISNULL(Deduc.ImporteTotal1,0)) AS Neto
				,ISNULL(Prestamos.PAGO,0) AS Completo									   
				,ISNULL(Prestamos.PAGO_PROPORCIONAL,0) AS Proporcional
				,CAST(0 AS DECIMAL(18,2)) AS Final
			INTO #TempValidaCobroPrestamo
			FROM #tmpPagosPrestamo Prestamos         
				LEFT JOIN #TempTotalPercepciones Percep 
					ON Prestamos.IDEmpleado = Percep.IDEmpleado
				LEFT JOIN #TempTotalDeducciones Deduc 
					ON Prestamos.IDEmpleado = Deduc.IDEmpleado


			DECLARE 
				 @EmpleadoID INT
				,@CounterEmpleado INT
				,@PrestamoID INT
				,@CounterPrestamo INT
				,@Residuo DECIMAL(18,2)

			SELECT @CounterEmpleado = MIN(IDEmpleado) FROM #TempValidaCobroPrestamo

			WHILE @CounterEmpleado <= (SELECT MAX(IDEmpleado) FROM #TempValidaCobroPrestamo)
			BEGIN
				
				SELECT @EmpleadoID = IDEmpleado FROM #TempValidaCobroPrestamo WHERE IDEmpleado = @CounterEmpleado
				SELECT @CounterPrestamo = MIN(IDPrestamo) FROM #TempValidaCobroPrestamo WHERE IDEmpleado = @EmpleadoID
				SELECT @Residuo = MAX(Neto) FROM #TempValidaCobroPrestamo WHERE IDEmpleado = @EmpleadoID

				WHILE @CounterPrestamo <= (SELECT MAX(IDPrestamo) FROM #TempValidaCobroPrestamo WHERE IDEmpleado = @EmpleadoID)
				BEGIN

					SELECT @PrestamoID = IDPrestamo FROM #TempValidaCobroPrestamo WHERE IDEmpleado = @EmpleadoID AND IDPrestamo = @CounterPrestamo

					UPDATE #TempValidaCobroPrestamo
						SET Final = CASE WHEN @VALIDAR_CUOTA_PROPORCIONAL_PRESTAMO = 1 THEN

											 CASE WHEN @Residuo - Completo >= 0 THEN Completo
												  WHEN @Residuo - Proporcional >= 0 THEN Proporcional
											 ELSE 0 END

									 ELSE 
											  CASE WHEN @Residuo - Completo >= 0 THEN Completo
											  ELSE 0 END
									 END

					WHERE IDPrestamo = @PrestamoID AND IDEmpleado = @EmpleadoID


					SELECT @Residuo = @Residuo - (SELECT Final FROM #TempValidaCobroPrestamo WHERE IDEmpleado = @EmpleadoID AND IDPrestamo = @PrestamoID)
					SELECT @CounterPrestamo = MIN(IDPrestamo) FROM #TempValidaCobroPrestamo WHERE IDEmpleado = @EmpleadoID AND IDPrestamo > @CounterPrestamo

					UPDATE #TempValidaCobroPrestamo
						SET Neto = @Residuo
					WHERE IDPrestamo = @CounterPrestamo

				END

				SELECT @CounterEmpleado = MIN(IDEmpleado) FROM #TempValidaCobroPrestamo WHERE IDEmpleado > @CounterEmpleado

			END

					UPDATE T 
						SET T.PAGO = ISNULL(V.Final,0)
					FROM #tmpPagosPrestamo T
						INNER JOIN #TempValidaCobroPrestamo V
							ON T.IDEmpleado = V.IDEmpleado
					WHERE T.IDEmpleado = V.IDEmpleado AND T.IDPrestamo = V.IDPrestamo
			
		END
		

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
			Left Join @dtDetallePeriodo dtDiasPagados
				on dtDiasPagados.IDEmpleado = e.IDEmpleado
				and dtDiasPagados.IDConcepto = @IDConceptoDiasPagados
				and dtDiasPagados.IDPeriodo = @IDPeriodo 
			Left Join @dtDetallePeriodo dtSeptimoDia
				on dtSeptimoDia.IDEmpleado = e.IDEmpleado
				and dtSeptimoDia.IDConcepto = @IDConceptoSeptimoDia
				and dtSeptimoDia.IDPeriodo = @IDPeriodo
			Left Join @dtDetallePeriodo dtDiasVacaciones
				on dtDiasVacaciones.IDEmpleado = e.IDEmpleado
				and dtDiasVacaciones.IDConcepto = @IDConceptoDiasVacaciones
				and dtDiasVacaciones.IDPeriodo = @IDPeriodo
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
		
		PRINT 0
	END ELSE*/

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
		/*MERGE @dtDetallePeriodoLocal AS TARGET
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
		DELETE;*/
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
