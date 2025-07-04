USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: ISR
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
2024-08-19			ANEUDY ABREU		Excluye los conceptos 101, 102 y 120 de las perceipciones
										adicionales.
***************************************************************************************************/
CREATE PROC [Nomina].[spConcepto_350]
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
		,@Codigo varchar(20) = '350' 
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
		,@Concepto_078 varchar(20) = '078' --SUBISIDIO CAUSADO
		,@Concepto_079 varchar(20) = '079' --ISR CAUSADO
		,@Concepto_005 varchar(20) = '005' --DIAS PAGADOS
		,@Concepto_007 varchar(20) = '007' --DIAS PAGADOS
		,@Concepto_002 varchar(20) = '002' --DIAS PAGADOS
		,@IDConcepto_078 int
		,@IDConcepto_079 int
		,@IDConcepto_005 int
		,@IDConcepto_007 int
		,@IDConcepto_002 int
		,@SalarioMinimo Decimal(18,2)
		,@SalarioMinimoFronterizo Decimal(18,2)
		,@IDCalculoISRSueldos int

	;

	select top 1 
		@IDPeriodo = IDPeriodo ,@IDTipoNomina= IDTipoNomina,@Ejercicio = Ejercicio,@ClavePeriodo	= ClavePeriodo,@DescripcionPeriodo =  Descripcion 
		,@FechaInicioPago = FechaInicioPago,@FechaFinPago	= FechaFinPago,@FechaInicioIncidencia = FechaInicioIncidencia,@FechaFinIncidencia=	 FechaFinIncidencia 
		,@Dias = Dias,@AnioInicio = AnioInicio,@AnioFin = AnioFin,@MesInicio = MesInicio,@MesFin = MesFin 
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin 
		,@General = General,@Finiquito = Finiquito,@Especial = Especial,@Cerrado = Cerrado 
	from @dtPeriodo 
 
	select top 1 @IDConcepto=IDConcepto from @dtConceptos where Codigo=@Codigo; 
    select top 1 @IDConcepto_078=IDConcepto from @dtConceptos where Codigo=@Concepto_078; 
	select top 1 @IDConcepto_079=IDConcepto from @dtConceptos where Codigo=@Concepto_079; 
	select top 1 @IDConcepto_005=IDConcepto from @dtConceptos where Codigo=@Concepto_005; 
	select top 1 @IDConcepto_007=IDConcepto from @dtConceptos where Codigo=@Concepto_007; 
	select top 1 @IDConcepto_002=IDConcepto from @dtConceptos where Codigo=@Concepto_002; 
	


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

	select top 1 @IDCalculoISRSueldos = IDCalculo       
		from Nomina.tblCatTipoCalculoISR      
		WHERE Codigo = 'ISR_SUELDOS'   

	   select top 1 @SalarioMinimo = isnull(SalarioMinimo,0)-- Aqui se obtiene el valor del Salario Minimo del catalogo de Salarios minimos  
			,@SalarioMinimoFronterizo = isnull(SalarioMinimoFronterizo,0)
	   From Nomina.tblSalariosMinimos  
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

	IF object_ID('TEMPDB..#TempValores') IS NOT NULL
		DROP TABLE #TempValores
	IF object_ID('TEMPDB..#TempTotalesEmpleados') IS NOT NULL
		DROP TABLE #TempTotalesEmpleados
	IF object_ID('TEMPDB..#TempEmpleadosConPercepcionAdicional') IS NOT NULL
		DROP TABLE #TempEmpleadosConPercepcionAdicional

	SELECT
		Empleados.IDEmpleado
		,SUM(DT.ImporteGravado) Total
		,CAST(0.00 as Decimal(18,2))  as AcumPeriodosAnteriores
		INTO #TempTotalesEmpleados
		FROM @dtempleados Empleados
			Left Join @dtDetallePeriodo DT
				on Empleados.IDEmpleado = DT.IDEmpleado
			inner join Nomina.tblCatConceptos C
				on c.IDConcepto = DT.IDConcepto
		WHERE C.IDTipoConcepto = 1
		GROUP BY Empleados.IDEmpleado

		update GP
			set GP.AcumPeriodosAnteriores = Acum.ImporteTotal1
		From #TempTotalesEmpleados GP
			Cross Apply [Nomina].[fnObtenerAcumuladoPorTipoConceptoPorMesTipoISR](GP.IDEmpleado,1,@IDMes,@Ejercicio,@IDCalculoISRSueldos) Acum

	SELECT
		Empleados.IDEmpleado,
		CASE WHEN SUM(ISNULL(DT.ImporteGravado,0)) > 0 THEN 1 ELSE 0 END PercepcionAdicional,
	    CAST(0 AS bit) PercepcionAdicionalAnteriores
		INTO #TempEmpleadosConPercepcionAdicional
		FROM @dtempleados Empleados
			Left Join @dtDetallePeriodo DT
				on Empleados.IDEmpleado = DT.IDEmpleado
			inner join Nomina.tblCatConceptos C with(nolock)	
				on c.IDConcepto = DT.IDConcepto
		WHERE C.IDTipoConcepto = 1
		and C.IDConcepto not in (Select IDConcepto from @dtConceptos where Codigo in ('101', '120', '102'))
		GROUP BY Empleados.IDEmpleado
		
		
		
		update GP
			set GP.PercepcionAdicionalAnteriores = CASE WHEN (SELECT SUM(isnull(dp.ImporteGravado,0))
															 FROM Nomina.tblDetallePeriodo dp with(nolock)	
															Left join Nomina.tblCatPeriodos p with(nolock)	
																on p.IDPeriodo = dp.IDPeriodo
															inner join Nomina.tblCatConceptos C with(nolock)	
																on c.IDConcepto = dp.IDConcepto
																and C.IDTipoConcepto = 1
																and C.IDConcepto not in (Select IDConcepto from @dtConceptos where Codigo  in ('101', '120', '102'))
														WHERE p.IDTipoNomina = @IDTipoNomina
															and p.Cerrado = 1
															and p.IDMes = @IDMes
														and dp.IDEmpleado = GP.IDEmpleado) > 0 THEN 1
			ELSE 
				0
			END
		From #TempEmpleadosConPercepcionAdicional GP
		
		--select * from #TempEmpleadosConPercepcionAdicional
		--select * from #TempTotalesEmpleados

	
	SELECT
		Empleados.IDEmpleado,
		@IDPeriodo as IDPeriodo,
		@Concepto_IDConcepto as IDConcepto,
		CASE WHEN @Concepto_bCantidadMonto  = 1 and ISNULL(DTLocal.CantidadMonto,0) > 0 THEN ISNULL(DTLocal.CantidadMonto,0)		  
				 WHEN @Concepto_bCantidadDias  = 1 and ISNULL(DTLocal.CantidadDias,0)  > 0 THEN ISNULL(DTLocal.CantidadDias,0)	  
				 WHEN @Concepto_bCantidadVeces = 1 and ISNULL(DTLocal.CantidadVeces,0) > 0 THEN ISNULL(DTLocal.CantidadVeces,0)	  
				 WHEN @Concepto_bCantidadOtro1 = 1 and ISNULL(DTLocal.CantidadOtro1,0) > 0 THEN ISNULL(DTLocal.CantidadOtro1,0)	  
				 WHEN @Concepto_bCantidadOtro2 = 1 and ISNULL(DTLocal.CantidadOtro2,0) > 0 THEN ISNULL(DTLocal.CantidadOtro2,0)	  
		  ELSE 
				CASE WHEN ISNULL(@MesFin,0) = 0 THEN
					CASE WHEN (ISNULL(PercepAdicional.PercepcionAdicional,0) = 0)
						AND (ISNULL(TotalEmpleado.Total,0) <= ((CASE WHEN isnull(S.Fronterizo,0) = 1 THEN @SalarioMinimoFronterizo 
																	ELSE @SalarioMinimo END) * 
																								CASE WHEN (ISNULL(dp005.ImporteTotal1,0)+ ISNULL(dp007.ImporteTotal1,0)+ ISNULL(dp002.ImporteTotal1,0)) > 0 THEN (ISNULL(dp005.ImporteTotal1,0)+ ISNULL(dp007.ImporteTotal1,0)+ ISNULL(dp002.ImporteTotal1,0)) 
																									ELSE @Dias END )) THEN 0
						ELSE
							CASE WHEN isnull(dpSubsidio.ImporteTotal1,0) = 0 THEN ISNULL(dpISR.ImporteTotal1,0)
							ELSE
							case when  isnull(dpISR.ImporteTotal1,0) >= isnull(dpSubsidio.ImporteTotal1,0)  then isnull(dpISR.ImporteTotal1,0) - isnull(dpSubsidio.ImporteTotal1,0) 
								 else 0
								 end  -- Función personalizada																			  
							END
					END
				ELSE
					CASE WHEN (ISNULL(PercepAdicional.PercepcionAdicional,0) = 0 and ISNULL(PercepAdicional.PercepcionAdicionalAnteriores,0) = 0)
						AND ((ISNULL(TotalEmpleado.Total,0) + ISNULL(TotalEmpleado.AcumPeriodosAnteriores,0)) <= ((CASE WHEN isnull(S.Fronterizo,0) = 1 THEN @SalarioMinimoFronterizo 
																	ELSE @SalarioMinimo END) * 
																								CASE WHEN (ISNULL(dp005.ImporteTotal1,0) + ISNULL(ACUM005.ImporteTotal1,0)+ ISNULL(dp007.ImporteTotal1,0) + ISNULL(ACUM007.ImporteTotal1,0)+ ISNULL(dp002.ImporteTotal1,0) + ISNULL(ACUM002.ImporteTotal1,0)) > 0 THEN ISNULL(dp005.ImporteTotal1,0) + ISNULL(ACUM005.ImporteTotal1,0)+ ISNULL(dp007.ImporteTotal1,0) + ISNULL(ACUM007.ImporteTotal1,0)+ ISNULL(dp002.ImporteTotal1,0) + ISNULL(ACUM002.ImporteTotal1,0)
																									ELSE @Dias + ISNULL(ACUM005.ImporteTotal1,0) END )) THEN 0
						ELSE
							CASE WHEN isnull(dpSubsidio.ImporteTotal1,0) = 0 THEN ISNULL(dpISR.ImporteTotal1,0)
							ELSE
							case when  isnull(dpISR.ImporteTotal1,0) >= isnull(dpSubsidio.ImporteTotal1,0)  then isnull(dpISR.ImporteTotal1,0) - isnull(dpSubsidio.ImporteTotal1,0) 
								 else 0
								 end  -- Función personalizada																			  
							END
					END
				END
		  END Valor	
		  --,ISNULL(PercepAdicional.PercepcionAdicional,0)PercepcionesAdicionales
		  --,ISNULL(PercepAdicional.PercepcionAdicionalAnteriores,0)PercepcionAdicionalAnteriores
		  --,isnull(S.Fronterizo,0) Fronterizo
		  --,@SalarioMinimoFronterizo as SalarioMinimoFronterizo
		  --,@SalarioMinimo as SalarioMinimo
		  --,ISNULL(TotalEmpleado.Total,0) as TotalEmpleado
		  --, ((CASE WHEN isnull(S.Fronterizo,0) = 1 THEN @SalarioMinimoFronterizo 
				--													ELSE @SalarioMinimo END) * 
				--																				CASE WHEN ISNULL(dp005.ImporteTotal1,0) > 0 THEN ISNULL(dp005.ImporteTotal1,0) 
				--																					ELSE @Dias END ) SalarioMinimoCalculado
		INTO #TempValores
		FROM @dtempleados Empleados
			Left Join @dtDetallePeriodoLocal DTLocal
				on Empleados.IDEmpleado = DTLocal.IDEmpleado
			left join @dtDetallePeriodo dpSubsidio
				on Empleados.IDEmpleado = dpSubsidio.IDEmpleado and dpSubsidio.IDConcepto = @IDConcepto_078
			left join @dtDetallePeriodo dpISR
				on Empleados.IDEmpleado = dpISR.IDEmpleado and dpISR.IDConcepto = @IDConcepto_079
			left join @dtDetallePeriodo dp005
				on Empleados.IDEmpleado = dp005.IDEmpleado and dp005.IDConcepto = @IDConcepto_005
			left join @dtDetallePeriodo dp007
				on Empleados.IDEmpleado = dp007.IDEmpleado and dp007.IDConcepto = @IDConcepto_007
			left join @dtDetallePeriodo dp002
				on Empleados.IDEmpleado = dp002.IDEmpleado and dp002.IDConcepto = @IDConcepto_002
			left join RH.tblCatSucursales S with(nolock)
				on S.IDSucursal = Empleados.IDSucursal
			left join #TempEmpleadosConPercepcionAdicional PercepAdicional
				on PercepAdicional.IDEmpleado = Empleados.IDEmpleado
			left join #TempTotalesEmpleados TotalEmpleado
				on TotalEmpleado.IDEmpleado = Empleados.IDEmpleado
			Cross apply Nomina.[fnObtenerAcumuladoPorConceptoPorMes](Empleados.IDEmpleado,@IDConcepto_005,@IDMes,@Ejercicio) ACUM005
			Cross apply Nomina.[fnObtenerAcumuladoPorConceptoPorMes](Empleados.IDEmpleado,@IDConcepto_007,@IDMes,@Ejercicio) ACUM007
			Cross apply Nomina.[fnObtenerAcumuladoPorConceptoPorMes](Empleados.IDEmpleado,@IDConcepto_002,@IDMes,@Ejercicio) ACUM002
 --select * from #TempValores
 
		/* Inicio de segmento para programar las opciones de LFT, Personalizada, Doble Paga*/
		/* @Concepto_LFT, @Concepto_Personalizada, @Concepto_ConDoblePago*/
 
 
 
		/* FIN de segmento para programar las opciones de LFT, Personalizada, Doble Paga*/
 
	  /* Fin de segmento para programar el cuerpo del concepto*/
 
 
		MERGE @dtDetallePeriodoLocal AS TARGET
			USING #TempValores AS SOURCE
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
		isnull(ImporteTotal2,0)<> 0 	 )
END;
GO
