USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Template para crear los procedimientos nuevos
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-08-12
** Paremetros		:              

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
CREATE PROC [Nomina].[spCoreConcepto_001]
( @dtconfigs [Nomina].[dtConfiguracionNomina] READONLY 
 ,@dtempleados [RH].[dtEmpleados] READONLY 
 ,@dtConceptos [Nomina].[dtConceptos] READONLY 
 ,@dtPeriodo [Nomina].[dtPeriodos] READONLY 
 ,@dtDetallePeriodo [Nomina].[dtDetallePeriodo] READONLY) 
AS 
BEGIN 
 /* Versión 1 */
 /* Descripción del Concepto: DÍAS DE VIGENCIA */
	DECLARE 
		@ClaveEmpleado varchar(20) 
		,@IDEmpleado int 
		,@i int = 0 
		,@Codigo varchar(20) = '001' 
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

	BEGIN /* Determina la fechas de inicio y fin para buscar las incidencias tomando en cuenta los movimientos afiliatorios del colaborador en el periodo */
		IF object_ID('tempdb..#TempMovimientos') IS NOT NULL DROP TABLE #TempMovimientos;  
      
		select m.*,TipoMovimiento.Codigo, ROW_NUMBER()over(partition by m.IDEmpleado order by  m.Fecha desc) as [Row]  
		into #TempMovimientos  
		from @dtempleados e  
			join IMSS.tblMovAfiliatorios m on e.IDEmpleado = m.IDEmpleado  
			left join IMSS.tblCatTipoMovimientos TipoMovimiento on m.IDTipoMovimiento = TipoMovimiento.IDTipoMovimiento  
		where TipoMovimiento.Codigo <>'M' and m.Fecha <= @FechaFinPago  

		--select * from #TempMovimientos			
		delete from #TempMovimientos where [Row] <> 1

		IF object_ID('tempdb..#TempFechasHabiles') IS NOT NULL DROP TABLE #TempFechasHabiles;  

		select Movimientos.IDEmpleado
			,FechaInicio =CASE  WHEN ( Movimientos.Fecha between @FechaInicioIncidencia and @FechaFinIncidencia) AND (Movimientos.Codigo = 'A' OR Movimientos.Codigo = 'R') THEN Movimientos.Fecha
				--WHEN ( Movimientos.Fecha between @FechaInicioIncidencia and @FechaFinIncidencia) AND (Movimientos.Codigo = 'B') THEN @FechaInicioIncidencia
				--WHEN ( Movimientos.Fecha <= @FechaInicioIncidencia) AND (Movimientos.Codigo = 'A' OR Movimientos.Codigo = 'R') THEN @FechaInicioIncidencia
				ELSE @FechaInicioIncidencia  
				END  
			,FechaFin =CASE WHEN ( Movimientos.Fecha between @FechaInicioIncidencia and @FechaFinIncidencia) AND (Movimientos.Codigo = 'B') THEN
					CASE WHEN @isPreviewFiniquito = 0 THEN Movimientos.Fecha
						ELSE cf.FechaBaja
					END
				--WHEN ( Movimientos.Fecha between @FechaInicioIncidencia and @FechaFinIncidencia) AND (Movimientos.Codigo = 'A' OR Movimientos.Codigo = 'R') THEN Movimientos.Fecha
				--WHEN ( Movimientos.Fecha <= @FechaInicioIncidencia) AND (Movimientos.Codigo = 'A' OR Movimientos.Codigo = 'R') THEN @FechaInicioIncidencia
				ELSE @FechaFinIncidencia  
				END  
		INTO #TempFechasHabiles
		from #TempMovimientos Movimientos
			cross apply Nomina.tblControlFiniquitos cf
		where cf.IDPeriodo = @IDPeriodo
			and cf.IDEmpleado = Movimientos.IDEmpleado
	END;
 
	/* Inicio de segmento para programar el cuerpo del concepto*/
 
	IF(@General = 1 OR @Finiquito = 1)
	BEGIN
		IF object_ID('TEMPDB..#TempValores') IS NOT NULL DROP TABLE #TempValores
 
		SELECT  
			Empleados.IDEmpleado,  
			@Concepto_IDConcepto as IDConcepto,  
			Movimientos.Fecha,  
			TipoMovimiento.Codigo,  
			CASE WHEN ((isnull(DTLocal.CantidadOtro2,0) = -1) ) THEN 0  
			ELSE  
				CASE WHEN @Concepto_bCantidadMonto  = 1 and ISNULL(DTLocal.CantidadMonto,0) > 0 THEN ISNULL(DTLocal.CantidadMonto,0)      
					 WHEN @Concepto_bCantidadDias  = 1 and ISNULL(DTLocal.CantidadDias,0)  > 0 THEN ISNULL(DTLocal.CantidadDias,0)     
					 WHEN @Concepto_bCantidadVeces = 1 and ISNULL(DTLocal.CantidadVeces,0) > 0 THEN ISNULL(DTLocal.CantidadVeces,0)     
					 WHEN @Concepto_bCantidadOtro1 = 1 and ISNULL(DTLocal.CantidadOtro1,0) > 0 THEN ISNULL(DTLocal.CantidadOtro1,0)     
					 WHEN @Concepto_bCantidadOtro2 = 1 and ISNULL(DTLocal.CantidadOtro2,0) > 0 THEN ISNULL(DTLocal.CantidadOtro2,0)     
				ELSE   
				CASE  
					WHEN ( Movimientos.Fecha between @FechaInicioPago and @FechaFinPago) AND (TipoMovimiento.Codigo = 'A' OR TipoMovimiento.Codigo = 'R') THEN 
																																							case when DATEDIFF(DAY,Movimientos.Fecha, @FechaFinPago)+1  > @Dias then @dias 
																																								else  DATEDIFF(DAY,Movimientos.Fecha, @FechaFinPago)+1 
																																							end
					 WHEN ( Movimientos.Fecha between @FechaInicioPago and @FechaFinPago) AND (TipoMovimiento.Codigo = 'B') THEN DATEDIFF(DAY,@FechaInicioPago,Movimientos.Fecha)+1  
					 WHEN ( Movimientos.Fecha <= @FechaInicioPago) AND (TipoMovimiento.Codigo = 'A' OR TipoMovimiento.Codigo = 'R') THEN @Dias --DATEDIFF(DAY,@FechaInicioPago, @FechaFinPago)  
					 ELSE @Dias  
					 END  
			 END   
			END  
			Valor,  
			@FechaInicioPago as FechaInicioPeriodo,  
			@FechaFinPago as FechaFinPeriodo,  
			@IDPeriodo as IDPeriodo,  
			ISNULL(DTLocal.CantidadMonto,0) as CantidadMonto  
		   ,ISNULL(DTLocal.CantidadDias ,0) as CantidadDias  
		   ,ISNULL(DTLocal.CantidadVeces,0) as CantidadVeces  
		   ,ISNULL(DTLocal.CantidadOtro1,0) as CantidadOtro1  
		   ,ISNULL(DTLocal.CantidadOtro2,0) as CantidadOtro2                 
		INTO #TempValores  
		FROM @dtempleados Empleados  
			Left join (select *  
				from #TempMovimientos  
				where [Row] = 1) Movimientos  
					on Empleados.IDEmpleado = Movimientos.IDEmpleado  
			left join IMSS.tblCatTipoMovimientos TipoMovimiento with (nolock)
				on Movimientos.IDTipoMovimiento = TipoMovimiento.IDTipoMovimiento  
					and TipoMovimiento.Codigo <>'M'   
					and Movimientos.Fecha <= @FechaFinPago  
			left join @dtDetallePeriodoLocal DTLocal  
				on DTLocal.IDEmpleado = Empleados.IDEmpleado  
				and DTLocal.IDConcepto = @IDConcepto  
				and DTLocal.IDPeriodo = @IDPeriodo 
			left join Nomina.tblControlFiniquitos cf with (nolock)
				on cf.IDPeriodo = @IDPeriodo
					and cf.IDEmpleado= Empleados.IDEmpleado

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
			Set TARGET.ImporteTotal1  = SOURCE.Valor,  
			TARGET.CantidadMonto  = isnull(SOURCE.CantidadMonto ,0)  
			,TARGET.CantidadDias   = isnull(SOURCE.CantidadDias  ,0)  
			,TARGET.CantidadVeces  = isnull(SOURCE.CantidadVeces ,0)  
			,TARGET.CantidadOtro1  = isnull(SOURCE.CantidadOtro1 ,0)  
			,TARGET.CantidadOtro2  = isnull(SOURCE.CantidadOtro2 ,0)
		WHEN NOT MATCHED BY TARGET THEN   
		INSERT(IDEmpleado,IDPeriodo,IDConcepto,ImporteTotal1,CantidadMonto,CantidadDias ,CantidadVeces,CantidadOtro1,CantidadOtro2)  
		VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,@Concepto_IDConcepto,Source.Valor,isnull(SOURCE.CantidadMonto ,0),isnull(SOURCE.CantidadDias  ,0),isnull(SOURCE.CantidadVeces ,0),isnull(SOURCE.CantidadOtro1 ,0),isnull(SOURCE.CantidadOtro2 ,0))  
		WHEN NOT MATCHED BY SOURCE THEN   
		DELETE; 

	END ELSE
	IF (@Especial = 1)
	BEGIN
		IF object_ID('TEMPDB..#TempValoresEspeciales') IS NOT NULL DROP TABLE #TempValoresEspeciales;
	
		SELECT  
			Empleados.IDEmpleado,  
			@Concepto_IDConcepto as IDConcepto,  
			CASE WHEN ((isnull(DTLocal.CantidadOtro2,0) = -1) ) THEN 0  
			ELSE  
			 CASE WHEN @Concepto_bCantidadMonto  = 1 and ISNULL(DTLocal.CantidadMonto,0) > 0 THEN ISNULL(DTLocal.CantidadMonto,0)      
				 WHEN @Concepto_bCantidadDias  = 1 and ISNULL(DTLocal.CantidadDias,0)  > 0 THEN ISNULL(DTLocal.CantidadDias,0)     
				 WHEN @Concepto_bCantidadVeces = 1 and ISNULL(DTLocal.CantidadVeces,0) > 0 THEN ISNULL(DTLocal.CantidadVeces,0)     
				 WHEN @Concepto_bCantidadOtro1 = 1 and ISNULL(DTLocal.CantidadOtro1,0) > 0 THEN ISNULL(DTLocal.CantidadOtro1,0)     
				 WHEN @Concepto_bCantidadOtro2 = 1 and ISNULL(DTLocal.CantidadOtro2,0) > 0 THEN ISNULL(DTLocal.CantidadOtro2,0)     
				 ELSE   0   
			 END   
			END  
			Valor,  
			@FechaInicioPago as FechaInicioPeriodo,  
			@FechaFinPago as FechaFinPeriodo,  
			@IDPeriodo as IDPeriodo,  
			ISNULL(DTLocal.CantidadMonto,0) as CantidadMonto  
		   ,ISNULL(DTLocal.CantidadDias ,0) as CantidadDias  
		   ,ISNULL(DTLocal.CantidadVeces,0) as CantidadVeces  
		   ,ISNULL(DTLocal.CantidadOtro1,0) as CantidadOtro1  
		   ,ISNULL(DTLocal.CantidadOtro2,0) as CantidadOtro2                 
		INTO #TempValoresEspeciales  
		FROM @dtempleados Empleados  
			inner join @dtDetallePeriodoLocal DTLocal on DTLocal.IDEmpleado = Empleados.IDEmpleado  
				and DTLocal.IDConcepto = @IDConcepto  
				and DTLocal.IDPeriodo = @IDPeriodo  

		MERGE @dtDetallePeriodoLocal AS TARGET  
		USING #TempValoresEspeciales AS SOURCE  
		ON TARGET.IDPeriodo = SOURCE.IDPeriodo  
			and TARGET.IDConcepto = @Concepto_IDConcepto  
			and TARGET.IDEmpleado = SOURCE.IDEmpleado  
		WHEN MATCHED Then  
		update  
			Set TARGET.ImporteTotal1  = SOURCE.Valor,  
			TARGET.CantidadMonto  = isnull(SOURCE.CantidadMonto ,0)  
			,TARGET.CantidadDias   = isnull(SOURCE.CantidadDias  ,0)  
			,TARGET.CantidadVeces  = isnull(SOURCE.CantidadVeces ,0)  
			,TARGET.CantidadOtro1  = isnull(SOURCE.CantidadOtro1 ,0)  
			,TARGET.CantidadOtro2  = isnull(SOURCE.CantidadOtro2 ,0)
		WHEN NOT MATCHED BY TARGET THEN   
			INSERT(IDEmpleado,IDPeriodo,IDConcepto,ImporteTotal1,CantidadMonto,CantidadDias ,CantidadVeces,CantidadOtro1,CantidadOtro2)  
			VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,@Concepto_IDConcepto,Source.Valor,isnull(SOURCE.CantidadMonto ,0),isnull(SOURCE.CantidadDias  ,0),isnull(SOURCE.CantidadVeces ,0),isnull(SOURCE.CantidadOtro1 ,0),isnull(SOURCE.CantidadOtro2 ,0))  
		WHEN NOT MATCHED BY SOURCE THEN   
		DELETE;

	END;
 
	Select * from @dtDetallePeriodoLocal  
 	where 
		(isnull(CantidadMonto,0)+		 
		isnull(CantidadDias,0)+		 
		isnull(CantidadVeces,0)+		 
		isnull(CantidadOtro1,0)+		 
		isnull(CantidadOtro2,0)+		 
		isnull(ImporteGravado,0)+		 
		isnull(ImporteExcento,0)+		 
		isnull(ImporteOtro,0)+		 
		isnull(ImporteTotal1,0)+		 
		isnull(ImporteTotal2,0) ) <> 0	 
END;
GO
