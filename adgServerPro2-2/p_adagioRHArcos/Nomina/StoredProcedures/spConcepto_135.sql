USE [p_adagioRHArcos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	NO MOVER SP ARTURO
	SP IMPORTANTE
*/

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
		,@Finiquito bit 
		,@Especial bit 
		,@Cerrado bit 
		,@PeriodicidadPago Varchar(100)
		,@isPreviewFiniquito bit 
		,@ValorUMA Decimal(18,2)
		,@IDConcepto005 int
		,@IDConcepto002 int
		,@IDConcepto007 int
		,@DiasMes INT
	;

	select top 1 
		@IDPeriodo = IDPeriodo ,@IDTipoNomina= IDTipoNomina,@Ejercicio = Ejercicio,@ClavePeriodo	= ClavePeriodo,@DescripcionPeriodo =  Descripcion 
		,@FechaInicioPago = FechaInicioPago,@FechaFinPago	= FechaFinPago,@FechaInicioIncidencia = FechaInicioIncidencia,@FechaFinIncidencia=	 FechaFinIncidencia 
		,@Dias = Dias,@AnioInicio = AnioInicio,@AnioFin = AnioFin,@MesInicio = MesInicio,@MesFin = MesFin 
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin 
		,@General = General,@Finiquito = Finiquito,@Especial = Especial,@Cerrado = Cerrado 
	from @dtPeriodo 
 
	select top 1 @IDConcepto=IDConcepto from @dtConceptos where Codigo=@Codigo; 
	select @IDConcepto005=IDConcepto from @dtConceptos where Codigo = '005'
	select @IDConcepto002=IDConcepto from @dtConceptos where Codigo = '002'
	select @IDConcepto007=IDConcepto from @dtConceptos where Codigo = '007'

	SELECT @DiasMes = DATEDIFF(DAY,DATEFROMPARTS(@Ejercicio,@IDMes,1),EOMONTH(DATEFROMPARTS(@Ejercicio,@IDMes,1)))+1
 
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

 
	IF(@General = 1 OR @Finiquito = 1 OR @Especial = 1 )
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
						--SI ((ACUM_POR_MES (_mes_vales , 'DVIG') + ACUM_POR_MES (_mes_vales , 'DVAC') + TOTAL ('DVIG') + _inc_vales) >= 16) ENTONCES
			CASE        WHEN @Concepto_bCantidadOtro2  = 1 and ISNULL(DTLocal.CantidadOtro2,0) = -1 THEN 0	
						WHEN @Concepto_bCantidadMonto  = 1 and ISNULL(DTLocal.CantidadMonto,0) > 0 THEN ISNULL(DTLocal.CantidadMonto,0)		  
						WHEN @Concepto_bCantidadDias  = 1 and ISNULL(DTLocal.CantidadDias,0)  > 0 THEN ISNULL(DTLocal.CantidadDias,0)	  
						WHEN @Concepto_bCantidadVeces = 1 and ISNULL(DTLocal.CantidadVeces,0) > 0 THEN ISNULL(DTLocal.CantidadVeces,0)	  
						WHEN @Concepto_bCantidadOtro1 = 1 and ISNULL(DTLocal.CantidadOtro1,0) > 0 THEN ISNULL(DTLocal.CantidadOtro1,0)	  
						WHEN @Concepto_bCantidadOtro2 = 1 and ISNULL(DTLocal.CantidadOtro2,0) > 0 THEN ISNULL(DTLocal.CantidadOtro2,0)	  
				ELSE
																		 -- PARA QUE SE PAGUEN VALES DE DESPENSA DEBEN DE CONTAR CON LAS SIGUIENTES CONDICIONES :
					CASE WHEN ( ISNULL ( Empleados.IDEmpresa , 0 ) = 6 OR  --- HOTEL ARCOS
					ISNULL ( Empleados.IDEmpresa , 0 ) = 8 OR -- DIRECCION Y ADMINISTRACION TURISTICA SC
					ISNULL ( Empleados.IDEmpresa , 0 ) = 2) AND  
							  ( ISNULL ( @MesFin, 0 ) = 1 ) AND -- DEBE ESTAR MARCADO EL PERIODO COMO FIN DE MES
							  ( ISNULL (AcumVales.ImporteTotal1 ,0 ) = 0 ) AND		 -- NO DEBE TENER ACUMULADO EN VALES DE DESPENSA
							  ( ( ISNULL ( dtDiasPagados.ImporteTotal1 , 0 ) + ISNULL ( AcumDiasPagados.ImporteTotal1 , 0 ) 
								+ ISNULL ( AcumDiasVacaciones.ImporteTotal1 , 0 ) + ISNULL ( dtDiasVacaciones.ImporteTotal1 , 0 )	
								/*+ ISNULL ( AcumSeptimoDia.ImporteTotal1 , 0 ) + ISNULL ( SeptimoDia.ImporteTotal1 , 0 )*/ ) >= 16 ) --DEBE DE CONTAR CON AL MENOS 16 DIAS DE VIGENCIA
							  THEN
						CASE 
							WHEN tp.Sindical = 0 AND ISNULL ( Empleados.IDEmpresa , 0 ) = 6											   THEN ((1150.00 / @DiasMes) * (ISNULL(dtDiasPagados.ImporteTotal1,0) + ISNULL(dtDiasVacaciones.ImporteTotal1,0) + ISNULL(SeptimoDia.ImporteTotal1,0) + ISNULL(AcumDiasPagados.ImporteTotal1,0) + ISNULL(AcumDiasVacaciones.ImporteTotal1,0) + ISNULL(AcumSeptimoDia.ImporteTotal1,0)) ) --APLICA SOLO PARA HOTELES LOS ARCOSRH.TBLEMPRESA
							WHEN tp.Sindical = 1 AND ISNULL ( Empleados.IDEmpresa , 0 ) = 6											   THEN ((1150.00 / @DiasMes) * (ISNULL(dtDiasPagados.ImporteTotal1,0) + ISNULL(dtDiasVacaciones.ImporteTotal1,0) + ISNULL(SeptimoDia.ImporteTotal1,0) + ISNULL(AcumDiasPagados.ImporteTotal1,0) + ISNULL(AcumDiasVacaciones.ImporteTotal1,0) + ISNULL(AcumSeptimoDia.ImporteTotal1,0)) )	
							WHEN tp.Sindical = 0 AND ISNULL ( Empleados.IDEmpresa , 0 ) = 8											   THEN 1000 -- DIRECCION Y ADMINISTRACION TURISTICA SC
							WHEN tp.Sindical = 1 AND ISNULL ( Empleados.IDEmpresa , 0 ) = 8											   THEN 1000
							WHEN tp.Sindical = 0 AND ISNULL ( Empleados.IDEmpresa , 0 ) = 2 AND ISNULL (Empleados.IDTipoNomina,0) = 16 THEN 400 -- INMOBILIARIA Y OPERADORA FONTANA SA DE CV
							WHEN tp.Sindical = 1 AND ISNULL ( Empleados.IDEmpresa , 0 ) = 2 AND ISNULL (Empleados.IDTipoNomina,0) = 16 THEN 400
							ELSE
								0
						END
					ELSE
						0
					END
				END Valor
			,ISNULL(DTLocal.CantidadMonto,0) as CantidadMonto  
			,ISNULL(DTLocal.CantidadDias ,0) as CantidadDias  
			,ISNULL(DTLocal.CantidadVeces,0) as CantidadVeces  																							  
			,ISNULL(DTLocal.CantidadOtro1,0) as CantidadOtro1  																							  
			,ISNULL(DTLocal.CantidadOtro2,0) as CantidadOtro2
			,Isnull(AcumVales.ImporteExento,0)  as AcumValesExcento 
			,AcumDiasPagados.ImporteTotal1 as AcumDiasPagados
			,AcumDiasVacaciones.ImporteTotal1 as AcumDiasVacaciones
			,AcumSeptimoDia.ImporteTotal1 AS AcumSeptimoDia
			,@DiasMes AS DiasMes
			,1150.00 / @DiasMes AS Diario
			,(ISNULL(dtDiasPagados.ImporteTotal1,0) + ISNULL(dtDiasVacaciones.ImporteTotal1,0) + ISNULL(SeptimoDia.ImporteTotal1,0) + ISNULL(AcumDiasPagados.ImporteTotal1,0) + ISNULL(AcumDiasVacaciones.ImporteTotal1,0) + ISNULL(AcumSeptimoDia.ImporteTotal1,0)) As Sumados
		INTO #TempValores
		FROM @dtempleados Empleados
			left join RH.tblCatTiposPrestaciones TP
				on Empleados.IDTipoPrestacion = TP.IDTipoPrestacion
			Left Join @dtDetallePeriodoLocal DTLocal
				on Empleados.IDEmpleado = DTLocal.IDEmpleado
			Left Join @dtDetallePeriodo dtDiasPagados
				on Empleados.IDEmpleado = dtDiasPagados.IDEmpleado
					and dtDiasPagados.IDConcepto = @IDConcepto005 -- DIAS PAGADOS
						and dtDiasPagados.IDPeriodo = @IDPeriodo
			Left Join @dtDetallePeriodo dtDiasVacaciones
				on Empleados.IDEmpleado = dtDiasVacaciones.IDEmpleado
					and dtDiasVacaciones.IDConcepto = @IDConcepto002 -- DIAS VACACIONES
						and dtDiasVacaciones.IDPeriodo = @IDPeriodo
			LEFT JOIN @dtDetallePeriodo SeptimoDia
				on SeptimoDia.IDEmpleado = Empleados.IDEmpleado
				and SeptimoDia.IDConcepto = @IDConcepto007
				and SeptimoDia.IDPeriodo = @IDPeriodo
			Cross Apply Nomina.fnObtenerAcumuladoPorConceptoPorMes(Empleados.IDEmpleado, @IDConcepto,@IDMes,@Ejercicio) AcumVales
				Cross Apply Nomina.fnObtenerAcumuladoPorConceptoPorMes(Empleados.IDEmpleado, @IDConcepto005,@IDMes,@Ejercicio) AcumDiasPagados
					Cross Apply Nomina.fnObtenerAcumuladoPorConceptoPorMes(Empleados.IDEmpleado, @IDConcepto002,@IDMes,@Ejercicio) AcumDiasVacaciones
						CROSS APPLY Nomina.fnObtenerAcumuladoPorConceptoPorMes(Empleados.IDEmpleado, @IDConcepto007, @IDMes, @Ejercicio) AcumSeptimoDia
	
	--select * from #TempValores
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
						ImporteGravado = 0.00,
						ImporteExcento = Valor,
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
		isnull(ImporteTotal2,0)<> 0 	 ) 	 
END;
GO
