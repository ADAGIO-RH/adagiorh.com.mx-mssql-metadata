USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: PAYE
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
CREATE PROC [Nomina].[spConcepto_JM304]
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
		,@Codigo varchar(20) = 'JM304' 
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
		,@IDConceptoJM301 int  /*NIS*/
		
		,@minimoPayeL1 decimal(18,2) = 0
		,@maximoPayeL1 decimal(18,2) = 149948.00    --125008.00 (antes de 2024) -- 141674 (2024) 149948 (2025)
		,@TasaPayeL1 decimal(18,2) = 0

		,@minimoPayeL2 decimal(18,2) = 149948.01	--125008.01 (antes de 2024)  141674.01 (2024) 149948.01 (2025)
		,@maximoPayeL2 decimal(18,2) = 500000.00
		,@TasaPayeL2 decimal(18,2) = 0.25
		
		,@minimoPayeL3 decimal(18,2) = 500000.01
		,@maximoPayeL3 decimal(18,2) = 999999999.00
		,@TasaPayeL3 decimal(18,2) = 0.30
	;

	select top 1 
		@IDPeriodo = IDPeriodo ,@IDTipoNomina= IDTipoNomina,@Ejercicio = Ejercicio,@ClavePeriodo	= ClavePeriodo,@DescripcionPeriodo =  Descripcion 
		,@FechaInicioPago = FechaInicioPago,@FechaFinPago	= FechaFinPago,@FechaInicioIncidencia = FechaInicioIncidencia,@FechaFinIncidencia=	 FechaFinIncidencia 
		,@Dias = Dias,@AnioInicio = AnioInicio,@AnioFin = AnioFin,@MesInicio = MesInicio,@MesFin = MesFin 
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin 
		,@General = General,@Finiquito = Finiquito,@Especial = Especial,@Cerrado = Cerrado 
	from @dtPeriodo 
 
	select top 1 @IDConcepto=IDConcepto from @dtConceptos where Codigo=@Codigo; 
	select top 1 @IDConceptoJM301=IDConcepto from @dtConceptos where Codigo='JM301'; 

		set @minimoPayeL1  = @minimoPayeL1 * @IDMes
		set @maximoPayeL1  = @maximoPayeL1 * @IDMes
		set @minimoPayeL2  = @minimoPayeL2 * @IDMes
		set @maximoPayeL2  = @maximoPayeL2 * @IDMes
		set @minimoPayeL3  = @minimoPayeL3 * @IDMes
		set @maximoPayeL3  = @maximoPayeL3 * @IDMes
 
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

       if object_id('tempdb..#TempSUMPERCEPCIONES') is not null      
		drop table #TempSUMPERCEPCIONES;       
  
		select 
			dp.IDEmpleado as IDEmpleado
			,isnull(SUM(dp.ImporteTotal1),0) as SumImporteTotal 
		into #TempSUMPERCEPCIONES      
		from @dtempleados e
			inner join Nomina.tblDetallePeriodo dp WITH(NOLOCK)     
			on e.IDEmpleado = dp.IDEmpleado
			inner join @dtConceptos c      
				on dp.IDConcepto = c.IDConcepto      
			inner join Nomina.tblCatPeriodos p WITH(NOLOCK) 
				on p.IDPeriodo = dp.IDPeriodo

		where  C.IDTipoConcepto = 1 -- PERCEPCIONES   
		 and c.Codigo not in ('JM111')
		and p.IDTipoNomina = @IDTipoNomina
		and p.Ejercicio = @Ejercicio
		and p.Cerrado = 1
		Group by dp.IDEmpleado  

		--select * from #TempSUMPERCEPCIONES

			if object_id('tempdb..#TempSUMPERCEPCIONESActual') is not null      
		drop table #TempSUMPERCEPCIONESActual;       
  
		select 
			dp.IDEmpleado as IDEmpleado
			,@IDConcepto as IDConcepto
			,@IDPeriodo as IDPeriodo
			,isnull(SUM(dp.ImporteTotal1),0) as SumImporteTotal 
		into #TempSUMPERCEPCIONESActual      
		from @dtempleados e
			left join @dtDetallePeriodo dp      
			on e.IDEmpleado = dp.IDEmpleado
			inner join @dtConceptos c      
				on dp.IDConcepto = c.IDConcepto      
		where  C.IDTipoConcepto = 1 -- PERCEPCIONES   
		 and c.Codigo not in ('JM111')
		Group by dp.IDEmpleado  

		--select * from #TempSUMPERCEPCIONESActual

		if object_id('tempdb..#TempSUMNIS') is not null      
		drop table #TempSUMNIS;       
  
		select 
			dp.IDEmpleado as IDEmpleado
			,isnull(SUM(dp.ImporteTotal1),0) as SumImporteTotal 
		into #TempSUMNIS      
		from @dtempleados e
			inner join Nomina.tblDetallePeriodo dp WITH(NOLOCK)     
			on e.IDEmpleado = dp.IDEmpleado
			inner join @dtConceptos c      
				on dp.IDConcepto = c.IDConcepto      
			inner join Nomina.tblCatPeriodos p WITH(NOLOCK) 
				on p.IDPeriodo = dp.IDPeriodo

		where  C.IDConcepto= @IDConceptoJM301 -- NIS     
		and p.IDTipoNomina = @IDTipoNomina
		and p.Ejercicio = @Ejercicio
		and p.Cerrado = 1
		Group by dp.IDEmpleado  

		--select * from #TempSUMNIS
		if object_id('tempdb..#TempSUMPAYE') is not null      
		drop table #TempSUMPAYE;       
  
		select 
			dp.IDEmpleado as IDEmpleado
			,isnull(SUM(dp.ImporteTotal1),0) as SumImporteTotal 
		into #TempSUMPAYE      
		from @dtempleados e
			inner join Nomina.tblDetallePeriodo dp WITH(NOLOCK)     
			on e.IDEmpleado = dp.IDEmpleado
			inner join @dtConceptos c      
				on dp.IDConcepto = c.IDConcepto         
			inner join Nomina.tblCatPeriodos p WITH(NOLOCK) 
				on p.IDPeriodo = dp.IDPeriodo

		where  C.IDConcepto= @IDConcepto -- PAYE     
		and p.IDTipoNomina = @IDTipoNomina
		and p.Ejercicio = @Ejercicio
		and p.Cerrado = 1
		Group by dp.IDEmpleado 
		
		--select * from #TempSUMPAYE
	IF( @General = 1 OR @Finiquito = 1 )
	BEGIN
		IF object_ID('TEMPDB..#TempValores') IS NOT NULL DROP TABLE #TempValores
		SELECT
			Empleados.IDEmpleado,
			@IDPeriodo as IDPeriodo,
			@Concepto_IDConcepto as IDConcepto,
			CASE		WHEN ISNULL(DTLocal.CantidadOtro2 , 0) = -1 THEN 0
						WHEN ( ( @Concepto_bCantidadMonto  = 1 ) and ( ISNULL(DTLocal.CantidadMonto,0) > 0 ) ) OR
							 ( ( @Concepto_bCantidadDias   = 1 ) and ( ISNULL(DTLocal.CantidadDias,0)  > 0 ) )
							
							THEN ( ISNULL(DTLocal.CantidadDias,0) * ISNULL ( Empleados.SalarioDiario , 0 ) ) + ISNULL(DTLocal.CantidadMonto,0)		
						WHEN @Concepto_bCantidadVeces = 1 and ISNULL(DTLocal.CantidadVeces,0) > 0 THEN ISNULL(DTLocal.CantidadVeces,0)	 
						WHEN @Concepto_bCantidadOtro1 = 1 and ISNULL(DTLocal.CantidadOtro1,0) > 0 THEN ISNULL(DTLocal.CantidadOtro1,0)	 
						WHEN @Concepto_bCantidadOtro2 = 1 and ISNULL(DTLocal.CantidadOtro2,0) > 0 THEN ISNULL(DTLocal.CantidadOtro2,0)	 
				ELSE CASE WHEN 
						((ISNULL(PercepActual.SumImporteTotal,0) + isnull(Percep.SumImporteTotal,0)) - (isnull(NIS.SumImporteTotal,0) + isnull(NISActual.ImporteTotal1,0))	)	BETWEEN @minimoPayeL1 and @maximoPayeL1 THEN 		
										(((((ISNULL(PercepActual.SumImporteTotal,0) + isnull(Percep.SumImporteTotal,0)) - (isnull(NIS.SumImporteTotal,0) + isnull(NISActual.ImporteTotal1,0))	) - @minimoPayeL1) * @TasaPayeL1))
						 WHEN 
						((ISNULL(PercepActual.SumImporteTotal,0) + isnull(Percep.SumImporteTotal,0)) - (isnull(NIS.SumImporteTotal,0) + isnull(NISActual.ImporteTotal1,0))	)	BETWEEN @minimoPayeL2 and @maximoPayeL2 THEN 		
										CASE WHEN ((ISNULL(PercepActual.SumImporteTotal,0) + isnull(Percep.SumImporteTotal,0)) - (isnull(NIS.SumImporteTotal,0) + isnull(NISActual.ImporteTotal1,0))) >  @maximoPayeL2 THEN ((@maximoPayeL2 - @maximoPayeL1)*@TasaPayeL2)
											ELSE ((((ISNULL(PercepActual.SumImporteTotal,0) + isnull(Percep.SumImporteTotal,0)) - (isnull(NIS.SumImporteTotal,0) + isnull(NISActual.ImporteTotal1,0))	) ) * @TasaPayeL2)
											END
						 WHEN 
						((ISNULL(PercepActual.SumImporteTotal,0) + isnull(Percep.SumImporteTotal,0)) - (isnull(NIS.SumImporteTotal,0) + isnull(NISActual.ImporteTotal1,0))	)-@minimoPayeL1	BETWEEN @minimoPayeL3 and @maximoPayeL3 THEN 		
										CASE WHEN ((ISNULL(PercepActual.SumImporteTotal,0) + isnull(Percep.SumImporteTotal,0)) - (isnull(NIS.SumImporteTotal,0) + isnull(NISActual.ImporteTotal1,0))) < @minimoPayeL3 THEN 0
											ELSE (((((ISNULL(PercepActual.SumImporteTotal,0) + isnull(Percep.SumImporteTotal,0)) - (isnull(NIS.SumImporteTotal,0) + isnull(NISActual.ImporteTotal1,0))	) - @minimoPayeL3) * @TasaPayeL3) )
											end
						 ELSE 0
						 END
				END Valor
			,ISNULL(DTLocal.CantidadMonto,0) as CantidadMonto
			,ISNULL(DTLocal.CantidadDias ,0) as CantidadDias
			,ISNULL(DTLocal.CantidadVeces,0) as CantidadVeces  																							 
			,ISNULL(DTLocal.CantidadOtro1,0) as CantidadOtro1  																							 
			,ISNULL(DTLocal.CantidadOtro2,0) as CantidadOtro2  		
			,ISNULL(PercepActual.SumImporteTotal,0) as percepcionActual
			,isnull(Percep.SumImporteTotal,0)as PercepcionAcumulada
			,isnull(NIS.SumImporteTotal,0) as NISAcumulado
			,isnull(NISActual.ImporteTotal1,0) as NISActual
			,@minimoPayeL3 LimiteInferiorL3
			,@maximoPayeL3 LimiteSuperiorL3
			,@minimoPayeL2 LimiteInferiorL2
			,@maximoPayeL2 LimiteSuperiorL2
			,@minimoPayeL1 LIMITEINFERIORL1
			,@maximoPayeL1 LIMITESUPERIORL1
			,isnull(PAYE.SumImporteTotal,0) ACUMPAYE
			,CASE WHEN ((ISNULL(PercepActual.SumImporteTotal,0) + isnull(Percep.SumImporteTotal,0)) - (isnull(NIS.SumImporteTotal,0) + isnull(NISActual.ImporteTotal1,0))	)	> @minimoPayeL1  THEN 		
										(((((ISNULL(PercepActual.SumImporteTotal,0) + isnull(Percep.SumImporteTotal,0)) - (isnull(NIS.SumImporteTotal,0) + isnull(NISActual.ImporteTotal1,0))	) - @minimoPayeL1) * @TasaPayeL1))
										ELSE 0
										END CalculoL1
			, CASE WHEN ((ISNULL(PercepActual.SumImporteTotal,0) + isnull(Percep.SumImporteTotal,0)) - (isnull(NIS.SumImporteTotal,0) + isnull(NISActual.ImporteTotal1,0))	)	> @minimoPayeL2  THEN 		
										CASE WHEN ((ISNULL(PercepActual.SumImporteTotal,0) + isnull(Percep.SumImporteTotal,0)) - (isnull(NIS.SumImporteTotal,0) + isnull(NISActual.ImporteTotal1,0))) >  @maximoPayeL2 THEN ((@maximoPayeL2 - @maximoPayeL1)*@TasaPayeL2)
											ELSE ((((ISNULL(PercepActual.SumImporteTotal,0) + isnull(Percep.SumImporteTotal,0)) - (isnull(NIS.SumImporteTotal,0) + isnull(NISActual.ImporteTotal1,0))	) - @maximoPayeL1 ) * @TasaPayeL2)
											END
						ELSE 0
						END CalculoL2
			,CASE WHEN ((ISNULL(PercepActual.SumImporteTotal,0) + isnull(Percep.SumImporteTotal,0)) - (isnull(NIS.SumImporteTotal,0) + isnull(NISActual.ImporteTotal1,0))	)-@minimoPayeL1	BETWEEN @minimoPayeL3 and @maximoPayeL3 THEN 		
										CASE WHEN ((ISNULL(PercepActual.SumImporteTotal,0) + isnull(Percep.SumImporteTotal,0)) - (isnull(NIS.SumImporteTotal,0) + isnull(NISActual.ImporteTotal1,0))) < @minimoPayeL3 THEN 0
											ELSE (((((ISNULL(PercepActual.SumImporteTotal,0) + isnull(Percep.SumImporteTotal,0)) - (isnull(NIS.SumImporteTotal,0) + isnull(NISActual.ImporteTotal1,0))	) - @minimoPayeL3) * @TasaPayeL3) )
											end
						 ELSE 0
						 END CalculoL3

		INTO #TempValores
		FROM @dtempleados Empleados
			Left Join @dtDetallePeriodoLocal DTLocal
				on Empleados.IDEmpleado = DTLocal.IDEmpleado
			left join #TempSUMPERCEPCIONESActual PercepActual
				on PercepActual.IDEmpleado = Empleados.IDEmpleado
			left join #TempSUMPERCEPCIONES Percep
				on Percep.IDEmpleado = Empleados.IDEmpleado
			left join #TempSUMNIS NIS
				on NIS.IDEmpleado = Empleados.IDEmpleado
			left join @dtDetallePeriodo NISActual
				on NISActual.IDEmpleado = Empleados.IDEmpleado
				and NISActual.IDConcepto = @IDConceptoJM301
			left join #TempSUMPAYE PAYE
				on PAYE.IDEmpleado = Empleados.IDEmpleado

		--select * from #TempValores
		
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
				ImporteTotal1 = CASE WHEN ISNULL(CantidadMonto,0) <> 0 THEN ISNULL(CantidadMonto,0)
									 WHEN ISNULL(CantidadOtro2,0) = -1 THEN 0
									 ELSE
										CASE WHEN (isnull(CalculoL1,0)+isnull(CalculoL2,0)+isnull(CalculoL3,0)) > 0 and (isnull(CalculoL1,0)+isnull(CalculoL2,0)+isnull(CalculoL3,0)) >= isnull(ACUMPAYE,0) THEN ((isnull(CalculoL1,0)+isnull(CalculoL2,0)+isnull(CalculoL3,0))-isnull(ACUMPAYE,0))
											ELSE 0 
											END
									END,
				ImporteTotal2 = 0.00,
				Descripcion = '',
				IDReferencia = NULL
			FROM #TempValores
		
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
