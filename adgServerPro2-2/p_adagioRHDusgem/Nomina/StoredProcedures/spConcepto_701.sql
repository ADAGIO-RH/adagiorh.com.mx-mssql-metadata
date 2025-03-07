USE [p_adagioRHDusgem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: SUELDOS
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
CREATE PROC [Nomina].[spConcepto_701]
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
		,@Codigo varchar(20) = '701' 
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
		,@idConcepto101 int
		,@json nvarchar(max)
		,@json2 nvarchar(max)
		,@IDConcepto005 int
		,@IDconcepto120 int
	;

	select top 1 
		@IDPeriodo = IDPeriodo ,@IDTipoNomina= IDTipoNomina,@Ejercicio = Ejercicio,@ClavePeriodo	= ClavePeriodo,@DescripcionPeriodo =  Descripcion 
		,@FechaInicioPago = FechaInicioPago,@FechaFinPago	= FechaFinPago,@FechaInicioIncidencia = FechaInicioIncidencia,@FechaFinIncidencia=	 FechaFinIncidencia 
		,@Dias = Dias,@AnioInicio = AnioInicio,@AnioFin = AnioFin,@MesInicio = MesInicio,@MesFin = MesFin 
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin 
		,@General = General,@Finiquito = Finiquito,@Especial = Especial,@Cerrado = Cerrado 
	from @dtPeriodo 
 
	select top 1 @IDConcepto=IDConcepto from @dtConceptos where Codigo=@Codigo; 
	select top 1 @IDConcepto101=IDConcepto from @dtConceptos where Codigo='101'; 
	select top 1 @IDConcepto005=IDConcepto from @dtConceptos where Codigo = '005'
	select top 1 @IDconcepto120=IDConcepto from @dtConceptos where Codigo = '120'
 
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

	DECLARE @Descripcion AS TABLE (IDEmpleado INT, Des_101 DECIMAL(18,2), Des_120 DECIMAL(18,2), Total AS Des_101 + Des_120)

	INSERT INTO @Descripcion
	SELECT
		 E.IDEmpleado
		,ISNULL(CAST(REPLACE(C101.Descripcion,' Dia(s)','') AS DECIMAL(18,2)),0)
		,ISNULL(CAST(REPLACE(C120.Descripcion,' Dia(s)','') AS DECIMAL(18,2)),0)
	FROM @dtempleados E
		LEFT JOIN @dtDetallePeriodo C101
			ON E.IDEmpleado = C101.IDEmpleado
			AND C101.IDConcepto = @idConcepto101
			AND C101.IDPeriodo = @IDPeriodo
		LEFT JOIN @dtDetallePeriodo C120
			ON E.IDEmpleado = C120.IDEmpleado
			AND C120.IDConcepto = @IDconcepto120
			AND C120.IDPeriodo = @IDPeriodo
		

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


        IF object_ID('TEMPDB..#PrestacionesSuperiores') IS NOT NULL DROP TABLE #PrestacionesSuperiores;
		IF object_ID('TEMPDB..#PrestacionesSuperioresEmpleado') IS NOT NULL DROP TABLE #PrestacionesSuperioresEmpleado;

		select top 1
			@json = [Data]
			from App.tblCatDatosExtras 
			where JSON_VALUE ( Traduccion,'$.esmx.Nombre') = 'prestaciones_superiores'     
				and IDTipoDatoExtra = 'centrosCostos'
			
			select *
			into #PrestacionesSuperiores
			from OPENJSON(@json) with (
				ID varchar (max) '$.ID',
				PrestacionesSuperiores varchar(10) '$.Nombre'
			);

			select 
			 em.IDEmpleado
			,ps.PrestacionesSuperiores PrestacionesSuperiores
			into #PrestacionesSuperioresEmpleado
			from @dtempleados em
				inner join [App].[tblValoresDatosExtras] vde
					on vde.IDReferencia = em.IDCentroCosto
				inner join #PrestacionesSuperiores ps
					on ps.ID = vde.Valor

------------------------------------------------------------------------------------------------

        IF object_ID('TEMPDB..#PagoFiscal') IS NOT NULL DROP TABLE #PagoFiscal;
		IF object_ID('TEMPDB..#PagoFiscalEmpleado') IS NOT NULL DROP TABLE #PagoFiscalEmpleado;

		select top 1
			@json2 = [Data]
			from App.tblCatDatosExtras 
			where JSON_VALUE ( Traduccion,'$.esmx.Nombre') = 'FISCAL 100%'   
				and IDTipoDatoExtra = 'centrosCostos'
			
			select *
			into #PagoFiscal
			from OPENJSON(@json2) with (
				ID varchar (max) '$.ID',
				PagoFiscal varchar(10) '$.Nombre'
			);

			select 
			 em.IDEmpleado
			,pf.PagoFiscal PagoFiscal
			into #PagoFiscalEmpleado
			from @dtempleados em
				inner join [App].[tblValoresDatosExtras] vde
					on vde.IDReferencia = em.IDCentroCosto
				inner join #PagoFiscal pf
					on pf.ID = vde.Valor

	Declare
		@IDTipoNominaQuincenal int
	;

	select @IDTipoNominaQuincenal = IDTipoNomina from Nomina.tblCatTipoNomina where Descripcion = 'PROYECTOS QUINCENAL'
	
	IF( ( @General = 1) and (@IDTipoNomina <> @IDTipoNominaQuincenal ) )
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
				ELSE
					case when PSE.PrestacionesSuperiores = 'SI' and pfe.PagoFiscal = 'NO' then 
						ISNULL(sueldo101.ImporteTotal1, 0) + ISNULL(Vacaciones.ImporteTotal1,0)
					else 0
					end-- Función personalizada	

				END Valor
			,case when PSE.PrestacionesSuperiores = 'SI' and pfe.PagoFiscal = 'NO' then 
						ISNULL(DE.Total,0)
					else 0
					end AS Descripcion-- Función personalizada	
			,ISNULL(DTLocal.CantidadMonto,0) as CantidadMonto
			,ISNULL(DTLocal.CantidadDias ,0) as CantidadDias
			,ISNULL(DTLocal.CantidadVeces,0) as CantidadVeces  																							 
			,ISNULL(DTLocal.CantidadOtro1,0) as CantidadOtro1  																							 
			,ISNULL(DTLocal.CantidadOtro2,0) as CantidadOtro2  																							 
		INTO #TempValores
		FROM @dtempleados Empleados
			Left Join @dtDetallePeriodoLocal DTLocal
				on Empleados.IDEmpleado = DTLocal.IDEmpleado
			Left Join @dtDetallePeriodo sueldo101
				on Empleados.IDEmpleado = sueldo101.IDEmpleado
					and sueldo101.IDConcepto = @idConcepto101
						and sueldo101.IDPeriodo = @IDPeriodo
		     left join #PrestacionesSuperioresEmpleado PSE
				on PSE.IDEmpleado = Empleados.IDEmpleado
			left join #PagoFiscalEmpleado pfe
				on pfe.IDEmpleado = Empleados.IDEmpleado
			left join @dtDetallePeriodo Vacaciones
				on Vacaciones.IDEmpleado = Empleados.IDEmpleado
				and Vacaciones.IDConcepto = @IDconcepto120
				and Vacaciones.IDPeriodo = @IDPeriodo
			LEFT JOIN @Descripcion DE 
				ON DE.IDEmpleado = Empleados.IDEmpleado
            
		/* Inicio de segmento para programar las opciones de LFT, Personalizada, Doble Paga*/
		/* @Concepto_LFT, @Concepto_Personalizada, @Concepto_ConDoblePago*/
		
		--IF(ISNULL(@Concepto_LFT,0) = 1)
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
				Descripcion ,
				IDReferencia = NULL
			FROM #TempValores
		END
		/* FIN de segmento para programar las opciones de LFT, Personalizada, Doble Paga*/
		/* Fin de segmento para programar el cuerpo del concepto*/
	END ELSE
	IF (@Finiquito = 1 )
	BEGIN
		/* AGREGAR CÓDIGO PARA FINIQUITOS AQUÍ */

		DECLARE
			@IDDatoExtraSueldoRealMensual int
		;

		select @IDDatoExtraSueldoRealMensual = IDDatoExtra from RH.tblCatDatosExtra with (nolock) where Nombre = 'SALARIO_REAL'

		IF object_ID('TEMPDB..#TempValoresFiniquitos') IS NOT NULL DROP TABLE #TempValoresFiniquitos
		SELECT
				Empleados.IDEmpleado,
				@IDPeriodo as IDPeriodo,
				@Concepto_IDConcepto as IDConcepto,
				CASE WHEN ((isnull(DTLocal.CantidadOtro2,0) = -1) ) THEN 0
					 ELSE
					CASE WHEN @Concepto_bCantidadMonto  = 1 and ISNULL(DTLocal.CantidadMonto,0) > 0 THEN ISNULL(DTLocal.CantidadMonto,0)		  
							 WHEN @Concepto_bCantidadDias  = 1 and ISNULL(DTLocal.CantidadDias,0)  > 0 THEN ISNULL(DTLocal.CantidadDias,0)	* CASE WHEN @isPreviewFiniquito = 0 THEN Empleados.SalarioDiario   ELSE cf.SueldoFiniquito END
							 WHEN @Concepto_bCantidadVeces = 1 and ISNULL(DTLocal.CantidadVeces,0) > 0 THEN ISNULL(DTLocal.CantidadVeces,0)	  
							 WHEN @Concepto_bCantidadOtro1 = 1 and ISNULL(DTLocal.CantidadOtro1,0) > 0 THEN ISNULL(DTLocal.CantidadOtro1,0)	  
							 WHEN @Concepto_bCantidadOtro2 = 1 and ISNULL(DTLocal.CantidadOtro2,0) > 0 THEN ISNULL(DTLocal.CantidadOtro2,0)	  
					  ELSE dtDiasPagados.ImporteTotal1 * CASE WHEN ISNULL( @isPreviewFiniquito , 0 ) = 0 THEN Empleados.SalarioDiario   
															  ELSE CASE WHEN (@IDTipoNomina = @IDTipoNominaQuincenal ) THEN CAST ( isnull(dee.Valor,0.00) as decimal (18,2)) / 30.4166
																		ELSE cf.SueldoFiniquito 
																   END
														 END
					  -- Función personalizada																			  
					  END
				  END Valor,

		  			CASE WHEN ((isnull(DTLocal.CantidadOtro2,0) = -1) ) THEN NULL
					 ELSE
					CASE WHEN @Concepto_bCantidadMonto  = 1 and ISNULL(DTLocal.CantidadMonto,0) > 0 THEN NULL		  
							 WHEN @Concepto_bCantidadDias  = 1 and ISNULL(DTLocal.CantidadDias,0)  > 0 THEN Cast(cast(ISNULL(DTLocal.CantidadDias,0) as int) as Varchar(MAX)) + ' Dia(s)' 
							 WHEN @Concepto_bCantidadVeces = 1 and ISNULL(DTLocal.CantidadVeces,0) > 0 THEN NULL	  
							 WHEN @Concepto_bCantidadOtro1 = 1 and ISNULL(DTLocal.CantidadOtro1,0) > 0 THEN NULL	  
							 WHEN @Concepto_bCantidadOtro2 = 1 and ISNULL(DTLocal.CantidadOtro2,0) > 0 THEN NULL	  
					  ELSE Cast(cast(dtDiasPagados.ImporteTotal1 as int) as Varchar(MAX)) + ' Dia(s)'
					  -- Función personalizada																			  
					  END
				  END Descripcion,

					 ISNULL(DTLocal.CantidadMonto,0) as CantidadMonto
					,ISNULL(DTLocal.CantidadDias ,0) as CantidadDias
					,ISNULL(DTLocal.CantidadVeces,0) as CantidadVeces
					,ISNULL(DTLocal.CantidadOtro1,0) as CantidadOtro1
					,ISNULL(DTLocal.CantidadOtro2,0) as CantidadOtro2		
				INTO #TempValoresFiniquitos
				FROM @dtempleados Empleados
					Left Join @dtDetallePeriodoLocal DTLocal
						on Empleados.IDEmpleado = DTLocal.IDEmpleado
					Left Join @dtDetallePeriodo dtDiasPagados
						on Empleados.IDEmpleado = dtDiasPagados.IDEmpleado
						and dtDiasPagados.IDConcepto = @IDConcepto005 -- DIAS PAGADOS
						and dtDiasPagados.IDPeriodo = @IDPeriodo
					left join Nomina.tblControlFiniquitos cf
						on Empleados.IDEmpleado = cf.IDEmpleado
						and cf.IDPeriodo = @IDPeriodo
					left join RH.tblDatosExtraEmpleados dee with (nolock)
						on Empleados.IDEmpleado = dee.IDEmpleado
							and dee.IDDatoExtra = @IDDatoExtraSueldoRealMensual
			
		
		insert into #TempDetalle(IDEmpleado,IDPeriodo,IDConcepto,CantidadDias,CantidadMonto,CantidadVeces,CantidadOtro1,CantidadOtro2,ImporteGravado,ImporteExcento,ImporteTotal1,ImporteTotal2,Descripcion,IDReferencia)
		Select IDEmpleado,
				IDPeriodo,
				IDConcepto,
				CantidadDias ,
				CantidadMonto,
				CantidadVeces,
				CantidadOtro1,
				CantidadOtro2,
				ImporteGravado = valor,
				ImporteExcento = 0.00,
				ImporteTotal1 = Valor,
				ImporteTotal2 = 0.00,
				Descripcion = '',
				IDReferencia = NULL
			FROM #TempValoresFiniquitos
		
		/********************************* FINIQUITOS ********************************/
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
