USE [p_adagioRHDusgem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: TOTAL A PAGAR TIMBRAR
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
------------------- ------------------- ------------------------------------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
2024-02-22			Víctor Martínez		Se configura concepto para tomar la información del total a pagar del cliente DUSGEM TIMBRAR		
										y para calcular el SDI de acuerdo a las percepciones gravadas, si este es diferente al SDI actual,
										se actualiza. 

***********************************************************************************************************************************/
CREATE PROC [Nomina].[spConcepto_168]
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
		,@Codigo varchar(20) = '168' 
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
		,@IDTipoNominaTimbrar int
		,@IDPeriodoTimbrar	int
		,@IDClienteTimbrar	int
		,@IDClientePagar	int
		,@IDClienteActual	int
		,@IDConcepto005		int	--Dias pagados
		,@IDConcepto007		int --Septimo día
		,@IDDatoExtraConceptosPagar int
		,@json nvarchar(max)
	;

	select top 1 
		@IDPeriodo = IDPeriodo ,@IDTipoNomina= IDTipoNomina,@Ejercicio = Ejercicio,@ClavePeriodo	= ClavePeriodo,@DescripcionPeriodo =  Descripcion 
		,@FechaInicioPago = FechaInicioPago,@FechaFinPago	= FechaFinPago,@FechaInicioIncidencia = FechaInicioIncidencia,@FechaFinIncidencia=	 FechaFinIncidencia 
		,@Dias = Dias,@AnioInicio = AnioInicio,@AnioFin = AnioFin,@MesInicio = MesInicio,@MesFin = MesFin 
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin 
		,@General = General,@Finiquito = Finiquito,@Especial = Especial,@Cerrado = Cerrado 
	from @dtPeriodo 

	select top 1 @IDClienteTimbrar	= IDCliente from RH.tblCatClientes where NombreComercial = 'DUSGEM TIMBRAR'
	select top 1 @IDClientePagar	= IDCliente from RH.tblCatClientes where NombreComercial = 'DUSGEM PAGAR'
	select top 1 @IDClienteActual	= IDCliente from Nomina.tblCatTipoNomina where IDTipoNomina = @IDTipoNomina
	select top 1 @IDConcepto005 = IDConcepto from @dtConceptos where Codigo = '005'
	select top 1 @IDConcepto007 = IDConcepto from @dtConceptos where Codigo = '007'
	select top 1 @IDDatoExtraConceptosPagar = IDCatDatoExtraCliente from RH.tblCatDatosExtraClientes where Nombre = 'CONCEPTOS_GRAVAR'

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
	--IF( @General = 1 OR @Finiquito = 1 )
	IF( @General = 1 and @IDClienteActual = @IDClientePagar)
	BEGIN
		
		IF object_ID('TEMPDB..#TempDetallePeriodoTimbrar') IS NOT NULL DROP TABLE #TempDetallePeriodoTimbrar
		if OBJECT_ID('tempdb..#tempPercepciones') is not null  drop table #tempPercepciones; 

		select top 1 @IDTipoNominaTimbrar = IDTipoNomina
			from Nomina.tblCatTipoNomina 
			where Descripcion = (select top 1 Descripcion from Nomina.tblCatTipoNomina where IDTipoNomina = @IDTipoNomina )
				and IDCliente = @IDClienteTimbrar
				and IDTiponomina <> @IDTiponomina
	
		select top 1 @IDPeriodoTimbrar = IDPeriodo from Nomina.tblCatPeriodos
		where FechaInicioPago = @FechaInicioPago 
			and FechaFinPago = @FechaFinPago
			and General = 1
			and IDTipoNomina = @IDTipoNominaTimbrar
		
		select 
			EmpleadosPagar.IDEmpleado				as IDEmpleadoPagar
			,SUM(isnull(dp.ImporteTotal1,0.00))		as ImporteTotal1
			into #TempDetallePeriodoTimbrar
			from @dtempleados EmpleadosPagar
				left join RH.tblEmpleados EmpleadosTimbrar
					on EmpleadosTimbrar.ClaveEmpleado = '0' + SUBSTRING(EmpleadosPagar.ClaveEmpleado,2,6)
				left join Nomina.tblDetallePeriodo dp
					on dp.IDEmpleado = EmpleadosTimbrar.IDEmpleado
						and dp.IDPeriodo = @IDPeriodoTimbrar
				inner join Nomina.tblCatConceptos cc
					on cc.IDConcepto = dp.IDConcepto
						and cc.Codigo between '601' and '607'
			group by EmpleadosPagar.IDEmpleado
  
		  select e.IDEmpleado  
			 ,dp.IDPeriodo  
			 ,sum(dp.ImporteGravado) as ImporteGravado  
			 ,sum(dp.ImporteExcento) as ImporteExcento  
			 ,sum(dp.ImporteOtro) as ImporteOtro  
			 ,sum(dp.ImporteTotal1) as ImporteTotal1  
			 ,sum(dp.ImporteTotal2) as ImporteTotal2  
		   into #tempPercepciones    
		  from   
			@dtempleados E  
				inner join  @dtDetallePeriodo DP  
					on E.IDEmpleado = dp.IDEmpleado  
						and DP.IDPeriodo = @IDPeriodo  
				inner join @dtConceptos c  
					on DP.IDConcepto = C.IDConcepto     
						--and c.Codigo in ('106','110','111','135','136','137')
						and c.Codigo in (select cast (item as varchar(20)) from App.split((select valor from RH.tblDatosExtraClientes where IDCliente = @IDClientePagar and IDCatDatoExtraCliente = @IDDatoExtraConceptosPagar),',') )
						and c.Estatus = 1
		  GROUP BY e.IDEmpleado,dp.IDPeriodo  

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
				ELSE EmpleadosPagar.ImporteTotal1 -- Función personalizada																			 
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
			Left join #TempDetallePeriodoTimbrar EmpleadosPagar
				on EmpleadosPagar.IDEmpleadoPagar = Empleados.IDEmpleado

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

		--- MOVIMIENTOS AFILIATORIOS

		if OBJECT_ID('tempdb..#tempSDI') is not null  drop table #tempSDI;
		IF object_ID('TEMPDB..#Prestaciones') IS NOT NULL DROP TABLE #Prestaciones;
		IF object_ID('TEMPDB..#PrestacionEmpleado') IS NOT NULL DROP TABLE #PrestacionEmpleado;

		select top 1
			@json = [Data]
			from App.tblCatDatosExtras 
			where JSON_VALUE ( Traduccion,'$.esmx.Nombre') = 'prestaciones pagar'
				and IDTipoDatoExtra = 'centrosCostos'

		select *
			into #Prestaciones
			from OPENJSON(@json) with (
				ID varchar (max) '$.ID',
				Prestaciones int '$.Nombre'
			);

		select 
			em.IDEmpleado
			--,em.IDCentroCosto
			--,vde.Valor
			,p.Prestaciones Prestacion
			into #PrestacionEmpleado
			from @dtempleados em
				inner join [App].[tblValoresDatosExtras] vde
					on vde.IDReferencia = em.IDCentroCosto
				inner join #Prestaciones p
					on p.ID = vde.Valor

		select 
			e.IDEmpleado
			,e.IDCliente
			,e.FechaAntiguedad
			,e.SalarioIntegrado
			,e.SalarioDiario
			,e.IDRegPatronal
			--,e.ClaveEmpleado
			--,e.SalarioDiario
			--,tp.ImporteGravado
			--,dpDiasPagados.ImporteTotal1 Pagados
			--,dpSeptimoDia.ImporteTotal1 SeptimoDia
			, CAST( ROUND( CASE WHEN e.SalarioDiario = 0 THEN 0 ELSE (tp.ImporteGravado / (dpDiasPagados.ImporteTotal1 + dpSeptimoDia.ImporteTotal1 )) END + e.SalarioDiario + (((ISNULL(PE.Prestacion,18))/365.0) * e.SalarioDiario),2) as decimal(18,2)) NewSalarioIntegrado
			--,Prestaciones.DiasAguinaldo
			--,Prestaciones.PrimaVacacional * Prestaciones.DiasVacaciones
			into #tempSDI
			from @dtempleados e
				left join #tempPercepciones tp
					on tp.IDEmpleado = e.IDEmpleado
				--left join RH.tblCatTiposPrestacionesDetalle Prestaciones
				--	on Prestaciones.IDTipoPrestacion = e.IDTipoPrestacion
				--		and Prestaciones.Antiguedad = DATEDIFF(DAY,e.FechaAntiguedad,GETDATE()) /365 + 1
				left join @dtDetallePeriodo dpDiasPagados
					on dpDiasPagados.IDEmpleado = e.IDEmpleado
						and dpDiasPagados.IDConcepto = @IDConcepto005
				left join @dtDetallePeriodo dpSeptimoDia
					on dpSeptimoDia.IDEmpleado = e.IDEmpleado
						and dpSeptimoDia.IDConcepto = @IDConcepto007
				left join #PrestacionEmpleado PE
					on PE.IDEmpleado = e.IDEmpleado
			--where e.IDCliente = @IDClientePagar
			
		delete from #tempSDI 
			where SalarioIntegrado = NewSalarioIntegrado
			
		MERGE IMSS.tblMovAfiliatorios AS TARGET
		USING #tempSDI AS SOURCE
			ON TARGET.Fecha = CASE WHEN SOURCE.FechaAntiguedad = @FechaInicioPago THEN @FechaInicioPago 
								   WHEN SOURCE.FechaAntiguedad between @FechaInicioPago AND @FechaFinPago THEN SOURCE.FechaAntiguedad
								ELSE DATEADD(DAY,-1,@FechaInicioPago) END
				and TARGET.IDEmpleado = SOURCE.IDEmpleado
				--and SOURCE.IDCliente = @IDClientePagar
		WHEN MATCHED Then
			update
				Set TARGET.SalarioIntegrado  = isnull(SOURCE.NewSalarioIntegrado ,0)  
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT (Fecha,IDEmpleado,IDTipoMovimiento,FechaIMSS,FechaIDSE,IDRazonMovimiento,SalarioDiario,SalarioIntegrado,SalarioVariable,SalarioDiarioReal,IDRegPatronal,RespetarAntiguedad) 
				VALUES(DATEADD(DAY,-1,@FechaInicioPago)
					,SOURCE.IDEmpleado
					,4							--M	MOVIMIENTO SALARIAL
					,NULL						--FechaIMSS
					,NUll						--FechaIDSE
					,NULL						--IDRazonMovimiento 
					,SOURCE.SalarioDiario		--SalarioDiario
					,SOURCE.NewSalarioIntegrado	--SalarioIntegrado
					,0.0						--SalarioVariable
					,0.0						--SalarioDiarioReal
					,SOURCE.IDRegPatronal		--IDRegPatronal
					,0							--RespetarAntiguedad
				);

	--delete
	--	from IMSS.tblMovAfiliatorios
	--	where IDMovAfiliatorio in 
	--	( select ma.IDMovAfiliatorio
	--		from IMSS.tblMovAfiliatorios ma
	--			inner join #TempEmpleados e
	--				on e.IDEmpleado = ma.IDEmpleado
	--		where ma.SalarioDiario = 0.00 and ma.Fecha = @FechaInicioPago and IDTipoMovimiento = 4) 


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
