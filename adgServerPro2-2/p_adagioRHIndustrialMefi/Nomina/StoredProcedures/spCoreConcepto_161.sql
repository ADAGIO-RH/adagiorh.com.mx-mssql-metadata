USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: FONDO DE AHORRO EMPRESA
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
CREATE PROC [Nomina].[spCoreConcepto_161]
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
		,@Codigo varchar(20) = '161' 
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
		,@SalarioMinimo Decimal(18,2) 
		,@UMA Decimal(18,2) 
		,@IDConcepto005 int -- Concepto de Dias Pagados
		,@TopesVecesSMG float -- Para fodo de ahorro
		,@TopeFondoAhorro Decimal(18,2) -- = 1727.7 Tope Real Fondo Ahorro
		,@CodigosConceptosPercepcionesParaFondoAhorro varchar(max) = '101,103,120,140,141,135'
	;

	select top 1 
		@IDPeriodo = IDPeriodo ,@IDTipoNomina= IDTipoNomina,@Ejercicio = Ejercicio,@ClavePeriodo	= ClavePeriodo,@DescripcionPeriodo =  Descripcion 
		,@FechaInicioPago = FechaInicioPago,@FechaFinPago	= FechaFinPago,@FechaInicioIncidencia = FechaInicioIncidencia,@FechaFinIncidencia=	 FechaFinIncidencia 
		,@Dias = Dias,@AnioInicio = AnioInicio,@AnioFin = AnioFin,@MesInicio = MesInicio,@MesFin = MesFin 
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin 
		,@General = General,@Finiquito = Finiquito,@Especial = Especial,@Cerrado = Cerrado 
	from @dtPeriodo 
 
	select top 1 @IDConcepto=IDConcepto from @dtConceptos where Codigo=@Codigo; 
    select top 1 @IDConcepto005=IDConcepto	from @dtConceptos where Codigo='005';  -- Concepto de Dias pagados
	
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


		select @TopesVecesSMG = cast(valor as float)
		from @dtconfigs
		where Configuracion = 'TopesVecesSMG' -- Se multiplica este valor por el Salario mínumo general para terminar el tope del fondo de ahorro.

		Select top 1 
			@SalarioMinimo = SalarioMinimo
			,@UMA = UMA
		From Nomina.tblSalariosMinimos
		where YEAR(Fecha) <= @Ejercicio
		ORDER BY Fecha Desc

		set @TopeFondoAhorro = (@UMA * @Dias) * @TopesVecesSMG
 

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

		IF object_ID('TEMPDB..#TempTotalSueldo') IS NOT NULL DROP TABLE #TempTotalSueldo


		select Empleados.IDEmpleado
			,SUM(isnull(dp.ImporteTotal1,0)) as Total
		INTO #TempTotalSueldo
		from @dtempleados Empleados
			 Join @dtDetallePeriodo dp on Empleados.IDEmpleado = dp.IDEmpleado AND dp.IDPeriodo = @IDPeriodo
			 join [Nomina].[tblCatConceptos] c on dp.IDConcepto = c.IDConcepto
			 join [RH].tblCatTiposPrestaciones tp on Empleados.IDTipoPrestacion = tp.IDTipoPrestacion
		where c.IDConcepto in (select cast(item as int) from app.Split(tp.IDsConceptosFondoAhorro,','))
		group by Empleados.IDEmpleado

		IF object_ID('TEMPDB..#TempValores') IS NOT NULL DROP TABLE #TempValores
 
		SELECT
		Empleados.IDEmpleado,
		@IDPeriodo as IDPeriodo,
		@Concepto_IDConcepto as IDConcepto,
		CASE WHEN ((isnull(DTLocal.CantidadOtro2,0) = -1) ) THEN 0
			 ELSE
			CASE WHEN @Concepto_bCantidadMonto  = 1 and ISNULL(DTLocal.CantidadMonto,0) > 0 THEN ISNULL(DTLocal.CantidadMonto,0)		  
					 WHEN @Concepto_bCantidadDias  = 1 and ISNULL(DTLocal.CantidadDias,0)  > 0 THEN ISNULL(DTLocal.CantidadDias,0)	  
					 WHEN @Concepto_bCantidadVeces = 1 and ISNULL(DTLocal.CantidadVeces,0) > 0 THEN ISNULL(DTLocal.CantidadVeces,0)	  
					 WHEN @Concepto_bCantidadOtro1 = 1 and ISNULL(DTLocal.CantidadOtro1,0) > 0 THEN ISNULL(DTLocal.CantidadOtro1,0)	  
					 WHEN @Concepto_bCantidadOtro2 = 1 and ISNULL(DTLocal.CantidadOtro2,0) > 0 THEN ISNULL(DTLocal.CantidadOtro2,0)	  
			  ELSE 
					CASE WHEN ISNULL(tp.PorcentajeFondoAhorro,0) > 0 THEN sueldo.Total * tp.PorcentajeFondoAhorro ELSE 0 END
			  END
		  END Valor	
		  ,cast(0.0 as decimal(18,2)) Excento
		  ,cast(0.0 as decimal(18,2)) Gravado
		  ,DP.ImporteTotal1 as DiasPagados
		  ,cast(ISNULL(tp.PorcentajeFondoAhorro,0) as decimal(10,2)) as  PorcentajeFondoAhorro
		  ,ISNULL(DTLocal.CantidadMonto,0) as CantidadMonto
			,ISNULL(DTLocal.CantidadDias ,0) as CantidadDias
			,ISNULL(DTLocal.CantidadVeces,0) as CantidadVeces
			,ISNULL(DTLocal.CantidadOtro1,0) as CantidadOtro1
			,ISNULL(DTLocal.CantidadOtro2,0) as CantidadOtro2
		INTO #TempValores
		FROM @dtempleados Empleados
			Left Join @dtDetallePeriodoLocal DTLocal
				on Empleados.IDEmpleado = DTLocal.IDEmpleado
			left join #TempTotalSueldo sueldo on Empleados.IDEmpleado = sueldo.IDEmpleado
			left join RH.tblCatTiposPrestaciones tp on tp.IDTipoPrestacion = Empleados.IDTipoPrestacion
			Left Join @dtDetallePeriodo DP
				on Empleados.IDEmpleado = DP.IDEmpleado
				AND DP.IDConcepto = @IDConcepto005
				AND DP.IDPeriodo = @IDPeriodo
		WHERE ISNULL(tp.PorcentajeFondoAhorro,0) > 0
 
		--select *, @TopeFondoAhorro from #TempValores

		--select TP.ToparFondoAhorro
		--from @dtempleados Empleados 
		--	join RH.tblCatTiposPrestaciones tp on tp.IDTipoPrestacion = Empleados.IDTipoPrestacion
 
		UPDATE v
			--SET v.Valor = CASE WHEN ISNULL(TP.ToparFondoAhorro,0) = 1 THEN
			--					 CASE WHEN v.Valor > @TopeFondoAhorro then @TopeFondoAhorro else v.Valor end 
			--			  ELSE v.Valor END
			set v.Excento = CASE WHEN ISNULL(TP.ToparFondoAhorro,0) = 1 THEN
								 CASE WHEN v.Valor > @TopeFondoAhorro then v.Valor - @TopeFondoAhorro else v.Valor end 
						  ELSE
								CASE WHEN v.Valor > @TopeFondoAhorro then @TopeFondoAhorro else v.Valor end 
						  END
			,v.Gravado = CASE WHEN ISNULL(TP.ToparFondoAhorro,0) = 1 THEN
								 CASE WHEN v.Valor > @TopeFondoAhorro then @TopeFondoAhorro else 0 end 
						  ELSE 0 
						  
						  END
		from #TempValores v
			join @dtempleados Empleados on Empleados.IDEmpleado = v.IDEmpleado
			join RH.tblCatTiposPrestaciones tp on tp.IDTipoPrestacion = Empleados.IDTipoPrestacion

		UPDATE v
			SET v.Valor = v.Excento + v.Gravado 
		from #TempValores v

		--UPDATE v
		--	SET v.Valor = CASE WHEN ISNULL(TP.ToparFondoAhorro,0) = 1 THEN
		--						 CASE WHEN v.Valor > @TopeFondoAhorro then @TopeFondoAhorro else v.Valor end 
		--				  ELSE v.Valor END
		--	,v.Excento = CASE WHEN ISNULL(TP.ToparFondoAhorro,0) = 0 THEN
		--						 CASE WHEN v.Valor > @TopeFondoAhorro then v.Valor - @TopeFondoAhorro else v.Valor end 
		--				  ELSE
		--						CASE WHEN v.Valor > @TopeFondoAhorro then @TopeFondoAhorro else v.Valor end 
		--				  END
		--	,v.Gravado = CASE WHEN ISNULL(TP.ToparFondoAhorro,0) = 0 THEN
		--						 CASE WHEN v.Valor > @TopeFondoAhorro then v.Valor - @TopeFondoAhorro else v.Valor end 
		--				  ELSE 0 END
		--from #TempValores v
		--	join @dtempleados Empleados on Empleados.IDEmpleado = v.IDEmpleado
		--	join RH.tblCatTiposPrestaciones tp on tp.IDTipoPrestacion = Empleados.IDTipoPrestacion
 


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
						Gravado,
						Excento, 
						--ImporteGravado = CASE WHEN Valor >= (@UMA * @ExcentoFondoAhorro * PorcentajeFondoAhorro * DiasPagados) THEN Valor - (@UMA * @ExcentoFondoAhorro * PorcentajeFondoAhorro * DiasPagados)
						--						ELSE 0.00
						--						END,
						--ImporteExcento = CASE WHEN Valor >= (@UMA * @ExcentoFondoAhorro * PorcentajeFondoAhorro * DiasPagados) THEN (@UMA * @ExcentoFondoAhorro * PorcentajeFondoAhorro * DiasPagados)
						--						ELSE Valor 
						--						END,
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
		(isnull(CantidadMonto,0)+		 
		isnull(CantidadDias,0)+		 
		isnull(CantidadVeces,0)+		 
		isnull(CantidadOtro1,0)+		 
		isnull(CantidadOtro2,0)+		 
		isnull(ImporteGravado,0)+		 
		isnull(ImporteExcento,0)+		 
		isnull(ImporteOtro,0)+		 
		isnull(ImporteTotal1,0)+		 
		isnull(ImporteTotal2,0) ) > 0	 
END;
GO
