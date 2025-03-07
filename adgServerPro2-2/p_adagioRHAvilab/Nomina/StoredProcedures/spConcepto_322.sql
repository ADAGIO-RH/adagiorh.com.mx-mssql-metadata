USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
MODIFICACION PARA AVILAB
SP IMPORTANTE
NO MOVER
MODIFICADO POR DIANA
*/
/**************************************************************************************************** 
** Descripción		: INTERES PRÉSTAMO CAJA DE AHORRO
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
CREATE PROC [Nomina].[spConcepto_322]
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
		,@Codigo varchar(20) = '322' 
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
		,@IDConcepto321 int
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
	Select top 1 @IDConcepto321 = IDConcepto from @dtConceptos where Codigo = '321'
 
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

	select top 1 @PeriodicidadPago = PP.Descripcion from Nomina.tblCatTipoNomina TN
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

	/*IF object_ID('TEMPDB..#TempAbonos') IS NOT NULL  
	DROP TABLE #TempAbonos 		
		
	select 
		dp.IDEmpleado as idEmpleado,
		p.MontoPrestamo as MontoPrestamo,
		sum(ISNULL(dp.ImporteTotal1,0))  as ImporteTotal,
		SUM(ISNULL(PD.MontoCuota,0 )) as MontoCuota,
		p.IDPrestamo as IDPrestamo,
		dp.IDReferencia as IDReferencia
	into #TempAbonos 
	from nomina.tblDetallePeriodo DP
	inner join nomina.tblcatperiodos pe
		on DP.IDPeriodo = Pe.IDPeriodo
	inner join nomina.tblPrestamos P
		on P.IDEmpleado =  dp.IDEmpleado
	inner join Nomina.tblPrestamosDetalles PD
		on PD.IDPrestamo = p.IDPrestamo
	 where DP.IDConcepto = 22 and PE.Cerrado = 1 and (p.IDEstatusPrestamo = 1 or p.IDEstatusPrestamo = 2)
	 group by dp.IDEmpleado, dp.IDReferencia, p.IDPrestamo, p.MontoPrestamo*/

---------------------------------------------------------
/*Saca prestamos activos  y abonos a prestamos generados fuera de periodos de nómina*/	 
IF object_ID('TEMPDB..#TempDetallePrestamos') IS NOT NULL  
	DROP TABLE #TempDetallePrestamos 

select P.IDEmpleado
	  ,E.ClaveEmpleado
	  ,P.IDPrestamo
	  ,P.MontoPrestamo 
	  ,sum(ISNULL(PD.MontoCuota,0)) as MontoCuota
	  ,P.IDEstatusPrestamo
	into #TempDetallePrestamos
from Nomina.tblPrestamos P
	 left join Nomina.tblPrestamosDetalles PD
		on PD.IDPrestamo = P.IDPrestamo
	inner join rh.tblEmpleadosMaster E
		on E.IDEmpleado = P.IDEmpleado
where (P.IDEstatusPrestamo = 1 or P.IDEstatusPrestamo = 2 )and P.IDTipoPrestamo = 7
group by P.IDEmpleado,E.ClaveEmpleado,P.IDPrestamo,P.MontoPrestamo,P.IDEstatusPrestamo



/*Saca del Detalle de periodos los abonos a los prestamos activos*/
IF object_ID('TEMPDB..#TempAbonosPrestamo') IS NOT NULL  
DROP TABLE #TempAbonosPrestamo 
select DP.IDEmpleado
	  ,sum (isnull(DP.ImporteTotal1,0)) as ImporteTotal
	  ,pr.IDPrestamo
	  ,DP.IDReferencia
	  ,P.Cerrado
into #TempAbonosPrestamo
from Nomina.tblDetallePeriodo DP
inner join Nomina.tblPrestamos Pr
	on Pr.IDEmpleado = DP.IDEmpleado
		and Pr.IDPrestamo = DP.IDReferencia
inner join Nomina.tblCatPeriodos P
	on P.IDPeriodo = DP.IDPeriodo
where DP.IDConcepto = 22 and P.Cerrado = 1 and ((Pr.IDEstatusPrestamo = 1 or Pr.IDEstatusPrestamo = 2 )and Pr.IDTipoPrestamo = 7)
group by DP.IDEmpleado,DP.IDReferencia,pr.IDPrestamo,P.Cerrado
order by IDReferencia




/*Unifica las aportaciones*/
IF object_ID('TEMPDB..#TempAbonos') IS NOT NULL  
DROP TABLE #TempAbonos 
select 
	DP.IDEmpleado as IDEmpleado
   --,DP.IDPrestamo as IDPrestamo
   ,SUM(isnull(DP.MontoPrestamo,0)) as MontoPrestamo
   ,SUM(isnull(DP.MontoCuota,0)) as MontoCuota
   ,SUM(ISNULL(TP.ImporteTotal,0)) as ImporteTotal
Into #TempAbonos
from  #TempDetallePrestamos DP
left join #TempAbonosPrestamo TP
	on TP.IDEmpleado = DP.IDEmpleado
		and TP.IDPrestamo = DP.IDPrestamo
GROUP BY DP.IDEmpleado
	
--IF object_ID('TEMPDB..#TempAbonos') IS NOT NULL  
--DROP TABLE #TempAbonos 
--select 
--	DP.IDEmpleado as IDEmpleado
--   ,DP.IDPrestamo as IDPrestamo
--   ,isnull(DP.MontoPrestamo,0) as MontoPrestamo
--   ,isnull(DP.MontoCuota,0) as MontoCuota
--   ,ISNULL(TP.ImporteTotal,0) as ImporteTotal
--Into #TempAbonos
--from  #TempDetallePrestamos DP
--left join #TempAbonosPrestamo TP
--	on TP.IDEmpleado = DP.IDEmpleado
--		and TP.IDPrestamo = DP.IDPrestamo


   
--------------------------------------------------------	



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
		IF object_ID('TEMPDB..#TempValores') IS NOT NULL DROP TABLE #TempValores
 
		SELECT
			Empleados.IDEmpleado,
			@IDPeriodo as IDPeriodo,
			@Concepto_IDConcepto as IDConcepto,
			CASE WHEN ISNULL(DTLocal.CantidadOtro2,0) = -1 THEN 0
				 WHEN @Concepto_bCantidadMonto  = 1 and ISNULL(DTLocal.CantidadMonto,0) > 0 THEN ISNULL(DTLocal.CantidadMonto,0)		  
				 WHEN @Concepto_bCantidadDias  = 1 and ISNULL(DTLocal.CantidadDias,0)  > 0 THEN ISNULL(DTLocal.CantidadDias,0)	  
				 WHEN @Concepto_bCantidadVeces = 1 and ISNULL(DTLocal.CantidadVeces,0) > 0 THEN ISNULL(DTLocal.CantidadVeces,0)	  
				 WHEN @Concepto_bCantidadOtro1 = 1 and ISNULL(DTLocal.CantidadOtro1,0) > 0 THEN ISNULL(DTLocal.CantidadOtro1,0)	  
				 WHEN @Concepto_bCantidadOtro2 = 1 and ISNULL(DTLocal.CantidadOtro2,0) > 0 THEN ISNULL(DTLocal.CantidadOtro2,0)	  
			ELSE CASE WHEN ISNULL (dtCaja.ImporteTotal1,0) <> 0 then
						CASE WHEN ISNULL(DEE.Valor,'FALSE') = 'FALSE' THEN -- ES SOCIO
							CASE WHEN Empleados.IDTipoNomina = 16 THEN
								(ISNULL(ta.MontoPrestamo,0) - ( isnull(TA.ImporteTotal,0) + ISNULL(TA.MontoCuota,0))) * 0.0028
								-- ASI TENIA EL CALCULO A LA FECHA 21/02/2025 FER CHAVEZ * 0.00230
							WHEN Empleados.IDTipoNomina = 17 THEN
								(ISNULL(ta.MontoPrestamo,0) - ( isnull(TA.ImporteTotal,0) + ISNULL(TA.MontoCuota,0))) * 0.0060
								--* 0.0050 
							ELSE 0
							END
						WHEN ISNULL(DEE.Valor,'FALSE') = 'TRUE' THEN
							CASE WHEN Empleados.IDTipoNomina = 16 THEN
								(ISNULL(ta.MontoPrestamo,0) - ( isnull(TA.ImporteTotal,0) + ISNULL(TA.MontoCuota,0))) * 0.015
							-- ASI TENIA EL CALCULO A LA FECHA 21/02/2025 FER CHAVEZ	* 0.0046
							WHEN Empleados.IDTipoNomina = 17 THEN
								(ISNULL(ta.MontoPrestamo,0) - ( isnull(TA.ImporteTotal,0) + ISNULL(TA.MontoCuota,0))) * 0.015
								--* 0.0999 
							ELSE 0
							END
						END
						ELSE 0
					 END -- Función personalizada 																		  
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
			Left Join @dtDetallePeriodo dtCaja
				on Empleados.IDEmpleado = dtCaja.IDempleado
					and dtCaja.IDConcepto = @IDConcepto321
						and dtCaja.IDPeriodo = @IDPeriodo
			left join #TempAbonos TA
				on TA.idEmpleado = Empleados.IDEmpleado
			left join RH.tblDatosExtraEmpleados DEE
				on Empleados.IDEmpleado = DEE.IDEmpleado
					and DEE.IDDatoExtra = 3

    



 
	/*	MERGE @dtDetallePeriodoLocal AS TARGET
			USING #TempValores AS SOURCE
				ON TARGET.IDPeriodo = SOURCE.IDPeriodo
					and TARGET.IDConcepto = @Concepto_IDConcepto
					and TARGET.IDEmpleado = SOURCE.IDEmpleado
			WHEN MATCHED Then
				update
					SET TARGET.ImporteTotal1  = SOURCE.Valor,
						TARGET.ImporteExcento  = 0.00,
						TARGET.ImporteGravado  = 0.00
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(IDEmpleado,IDPeriodo,IDConcepto,ImporteTotal1,ImporteExcento,ImporteGravado)
				VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,@Concepto_IDConcepto,Source.Valor,0.00,0.00)
			WHEN NOT MATCHED BY SOURCE THEN 
				DELETE;*/
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
				ImporteGravado = 0.00,  
				ImporteExcento = 0.00,  
				ImporteTotal1 = Valor,  
				ImporteTotal2 = 0.00,  
				Descripcion = '',  
				IDReferencia = NULL  
			FROM #TempValores  
		END
      

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
