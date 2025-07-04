USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: COMPENSACION A APLICAR (SUBSIDIO)
** Autor			: Jcastillo 					| 
** Email			: Jcastillo@adagio.com.mx	| 
** FechaCreacion	: 2025-02-01
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
CREATE   PROC [Nomina].[spConcepto_CI014]
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
		,@Codigo varchar(20) = 'ci014' 
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
        ,@IDPais int
        ,@IDCalculoISRSueldos int 
		,@PeriodicidadPago Varchar(100)
		,@isPreviewFiniquito bit 
        ,@IDConceptoCI013 int
        ,@IDConceptoCI011 int
        ,@IDConcepto002 int
        ,@IDConcepto005 int
        ,@IDConcepto007 int
        ,@IDConcepto078 int
        ,@IDConcepto079 INT
        ,@IDConceptoCI301 INT
        ,@UMA decimal(18,2)
		,@PorcentajeUMASubsidio decimal(18,4) 
		,@ValorDiarioUMA decimal(18,4)
		,@TopeMensualSubsidioSalario decimal(18,2)
		,@ConfiguracionReformaSubsidio2024 bit = 0
		,@SUBSIDIOREFORMA2024_DEVOLUCION bit = 0
        ,@SUBSIDIOREFORMA2024 bit = 0
		,@TopeMensualSubsidio decimal(18,2)
		,@TopeSalarialPorPeriodo decimal(18,2)
		,@SalarioMinimo decimal(18,2)
		,@SalarioMinimoFronterizo decimal(18,2)
        ,@ConfigISRProporcionalTipoNomina bit 
        ,@IDISRProporcionalTipoNomina int
	;

    /* Variables Para el Calculo*/            
	DECLARE @IDPeriodicidadPagoMensual int,            
			@IDPeriodicidadPagoPeriodo int, 
            @ISRProporcional int

	select top 1 
		@IDPeriodo = IDPeriodo ,@IDTipoNomina= IDTipoNomina,@Ejercicio = Ejercicio,@ClavePeriodo	= ClavePeriodo,@DescripcionPeriodo =  Descripcion 
		,@FechaInicioPago = FechaInicioPago,@FechaFinPago	= FechaFinPago,@FechaInicioIncidencia = FechaInicioIncidencia,@FechaFinIncidencia=	 FechaFinIncidencia 
		,@Dias = Dias,@AnioInicio = AnioInicio,@AnioFin = AnioFin,@MesInicio = MesInicio,@MesFin = MesFin 
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin 
		,@General = General,@Finiquito = Finiquito,@Especial = Especial,@Cerrado = Cerrado 
	from @dtPeriodo 

    select top 1 @IDPeriodicidadPagoMensual = IDPeriodicidadPago from SAT.tblCatPeriodicidadesPago with(nolock)  where Descripcion = 'Mensual'  

    -- Saca Periodicidad de Pago y Dias del periodo    
	Select TOP 1 
		 @IDPeriodicidadPagoPeriodo = tn.IDPeriodicidadPago            
		,@IDPais = tn.IDPais
	from Nomina.tblCatTipoNomina tn with(nolock)            
		left join sat.tblCatPeriodicidadesPago pp with(nolock)              
		on tn.IDPeriodicidadPago = pp.IDPeriodicidadPago                    
	where IDTipoNomina = @IDTipoNomina

    Select top 1 @ISRProporcional = cast(isnull(Valor,0) as int)   
	from Nomina.tblConfiguracionNomina with(nolock)  
	where Configuracion = 'ISRProporcional' 
 
	select top 1 @IDConcepto=IDConcepto from @dtConceptos where Codigo=@Codigo; 
    select top 1 @IDConceptoCI013=IDConcepto from @dtConceptos where Codigo='CI013';
    select top 1 @IDConceptoCI011=IDConcepto from @dtConceptos where Codigo='CI011';
    select top 1 @IDConceptoCI301=IDConcepto from @dtConceptos where Codigo='CI301';
    select top 1 @IDConcepto078=IDConcepto from @dtConceptos where Codigo='078';
    select top 1 @IDConcepto079=IDConcepto from @dtConceptos where Codigo='079';
    select top 1 @IDConcepto002=IDConcepto from @dtConceptos where Codigo='002';
    select top 1 @IDConcepto005=IDConcepto from @dtConceptos where Codigo='005';
    select top 1 @IDConcepto007=IDConcepto from @dtConceptos where Codigo='007';


    SELECT top 1 @UMA = isnull(UMA,0.00), @TopeMensualSubsidioSalario = isnull(TopeMensualSubsidioSalario,0.00), @PorcentajeUMASubsidio = isnull(PorcentajeUMASubsidio,0.00), @SalarioMinimo = SalarioMinimo, @SalarioMinimoFronterizo = SalarioMinimoFronterizo
	FROM Nomina.tblSalariosMinimos with(nolock)
	WHERE YEAR(Fecha) = YEAR(@FechaInicioPago)
	ORDER BY Fecha desc

	SET @ValorDiarioUMA = @UMA * (@PorcentajeUMASubsidio / 100.00)
	SET @TopeMensualSubsidio = @ValorDiarioUMA * 30.4
	SET @TopeSalarialPorPeriodo = ((@TopeMensualSubsidioSalario/30.4)*@Dias)
	--select @ValorDiarioUMA ValorDiarioUMA , @TopeMensualSubsidio

	select @ConfiguracionReformaSubsidio2024 = CAST(isnull((Valor),'0') as bit) 
	from @dtconfigs 
	where Configuracion = 'SUBSIDIOREFORMA2024'

	select @SUBSIDIOREFORMA2024_DEVOLUCION = CAST(isnull((Valor),'0') as bit) 
	from @dtconfigs 
	where Configuracion = 'SUBSIDIOREFORMA2024_DEVOLUCION'

    select @SUBSIDIOREFORMA2024= CAST(isnull((Valor),'0') as bit) 
	from @dtconfigs 
	where Configuracion = 'SUBSIDIOREFORMA2024'

    select top 1 @ConfigISRProporcionalTipoNomina = cast(isnull(valor,0) as bit) 
	from @dtconfigs
	where Configuracion = 'ConfigISRProporcionalTipoNomina'

    select top 1 @IDISRProporcionalTipoNomina = cast(isnull(valor,-1) as int) 
	from @dtconfigs
	where Configuracion = 'IDISRProporcionalTipoNomina'
 
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
	from Nomina.tblCatTipoCalculoISR with(nolock)       
	WHERE Codigo = 'ISR_SUELDOS'  

 	 /* @configs: Contiene todos los parametros de configuración de la nómina. */ 
 	 /* @empleados: Contiene todos los trabajadores a calcular.*/ 

    declare 
    @ConceptosPercepciones varchar(max),
    @ConceptosDeducciones varchar(max)

    Select @ConceptosPercepciones = Valor from @dtconfigs where Configuracion = 'CALCULOINVERSOCONCEPTOSPERCEPCIONES'
    Select @ConceptosDeducciones = Valor from @dtconfigs where Configuracion = 'CALCULOINVERSOCONCEPTOSDEDUCCIONES'


    CREATE TABLE #TempConceptosCalculoInverso   
        (    
            IDConcepto int,
            Tipo varchar(max)   			   
        ) 

    Insert into #TempConceptosCalculoInverso
    Select item,'percepcion'
    from App.Split(@ConceptosPercepciones,',')

    Insert into #TempConceptosCalculoInverso
    Select item,'deduccion'
    from App.Split(@ConceptosDeducciones,',')

    SELECT
        Empleados.IDEmpleado
        ,SUM(DT.ImporteTotal1) as ImporteTotal1
        ,SUM(DT.ImporteGravado) as ImporteGravado
        ,SUM(DT.ImporteExcento) as ImporteExcento
    INTO #TempPercepcionesInverso
    FROM @dtempleados Empleados
    Left Join @dtDetallePeriodo DT
            on Empleados.IDEmpleado = DT.IDEmpleado
    inner join #TempConceptosCalculoInverso CI
            on CI.IDConcepto = DT.IDConcepto
    where CI.tipo = 'percepcion'
    GROUP BY Empleados.IDEmpleado


    SELECT
        Empleados.IDEmpleado
        ,SUM(DT.ImporteTotal1) as ImporteTotal1
        ,SUM(DT.ImporteGravado) as ImporteGravado
        ,SUM(DT.ImporteExcento) as ImporteExcento
    INTO #TempDeduccionesInverso
    FROM @dtempleados Empleados
    Left Join @dtDetallePeriodo DT
            on Empleados.IDEmpleado = DT.IDEmpleado
    inner join #TempConceptosCalculoInverso CI
            on CI.IDConcepto = DT.IDConcepto
    where CI.tipo = 'deduccion'
    GROUP BY Empleados.IDEmpleado





    -- Select * from @dtDetallePeriodo dp 
    -- inner join @dtConceptos c      
	-- 		on dp.IDConcepto = c.IDConcepto 
	-- 		and c.IDPais = @IDPais
	-- 	inner join Nomina.tblCatTipoCalculoISR ti      
	-- 		on ti.IDCalculo = c.IDCalculo      
	-- WHERE ti.Codigo = 'ISR_SUELDOS'      
    -- return  


 
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


	IF( (@General = 1 OR @Finiquito = 1 ) AND @SUBSIDIOREFORMA2024 = 1)
	BEGIN   

    /*BLOQUE DE CALCULO DE ISR*/

    IF OBJECT_ID('tempdb..#TempISR') IS NOT NULL DROP TABLE #TempISR

        SELECT  
        CASE WHEN @ConfigISRProporcionalTipoNomina = 1            
            THEN
					CASE WHEN @IDISRProporcionalTipoNomina in (0,1,2,3) THEN [Nomina].[fnCoreISRSUELDOSTipoNomina](@IDPeriodicidadPagoPeriodo,dp301.ImporteTotal1,(isnull(dtDiasPagados.ImporteTotal1,0)+isnull(dtDiasVacaciones.ImporteTotal1,0)+isnull(dtSeptimoDia.ImporteTotal1,0)),@Ejercicio, @MesFin, @IDPais,0,@IDISRProporcionalTipoNomina)
						  WHEN @IDISRProporcionalTipoNomina = 4 THEN 
									CASE WHEN @MesFin = 1 THEN [Nomina].[fnCoreISRSUELDOSTipoNomina](@IDPeriodicidadPagoMensual,(dp301.ImporteTotal1 + AcumGravadoAnterior.ImporteGravado),0,@Ejercicio, @MesFin,@IDPais,0,@IDISRProporcionalTipoNomina) - ISNULL(AcumISR.ImporteTotal1,0)
										 ELSE [Nomina].[fnCoreISRSUELDOSTipoNomina](@IDPeriodicidadPagoPeriodo,(dp301.ImporteTotal1),0,@Ejercicio, @MesFin,@IDPais,0,@IDISRProporcionalTipoNomina)
										 END
						  WHEN @IDISRProporcionalTipoNomina = 5 then [Nomina].[fnCoreISRSUELDOSTipoNomina](@IDPeriodicidadPagoPeriodo
																				,(dp301.ImporteTotal1+(select top 1 ImporteGravado from [Nomina].[fnObtenerAcumuladoPorTipoConceptoPorEjercicioTipoISR](Empleados.IDEmpleado,1,@Ejercicio,2)))
																				,(
																					isnull(dtDiasPagados.ImporteTotal1,0)
																					+isnull(dtDiasVacaciones.ImporteTotal1,0)
																					+isnull(dtSeptimoDia.ImporteTotal1,0)
																					+(select top 1 ImporteTotal1 from [Nomina].[fnObtenerAcumuladoPorConcepto](Empleados.IDEmpleado,@IDConcepto005,@Ejercicio))
																					+(select top 1 ImporteTotal1 from [Nomina].[fnObtenerAcumuladoPorConcepto](Empleados.IDEmpleado,@IDConcepto002,@Ejercicio))
																					+(select top 1 ImporteTotal1 from [Nomina].[fnObtenerAcumuladoPorConcepto](Empleados.IDEmpleado,@IDConcepto007,@Ejercicio))
																				)
																				,@Ejercicio
																				,@MesFin
																				,@IDPais,0,@IDISRProporcionalTipoNomina) -  +(select top 1 ImporteTotal1 from [Nomina].[fnObtenerAcumuladoPorConcepto](Empleados.IDEmpleado,@IDConcepto,@Ejercicio))
					  ELSE 0
					 END

            ELSE
            CASE WHEN @ISRProporcional in (0,1,2,3) THEN [Nomina].[fnCoreISRSUELDOS](@IDPeriodicidadPagoPeriodo,dp301.ImporteTotal1,(isnull(dtDiasPagados.ImporteTotal1,0)+isnull(dtDiasVacaciones.ImporteTotal1,0)+isnull(dtSeptimoDia.ImporteTotal1,0)),@Ejercicio, @MesFin, @IDPais,0)
						  WHEN @ISRProporcional = 4 THEN 
									CASE WHEN @MesFin = 1 THEN [Nomina].[fnCoreISRSUELDOS](@IDPeriodicidadPagoMensual,(dp301.ImporteTotal1 + AcumGravadoAnterior.ImporteGravado),0,@Ejercicio, @MesFin,@IDPais,0) - ISNULL(AcumISR.ImporteTotal1,0)
										 ELSE [Nomina].[fnCoreISRSUELDOS](@IDPeriodicidadPagoPeriodo,(dp301.ImporteTotal1),0,@Ejercicio, @MesFin,@IDPais,0)
										 END
						  WHEN @ISRProporcional = 5 then [Nomina].[fnCoreISRSUELDOS](@IDPeriodicidadPagoPeriodo
																				,(dp301.ImporteTotal1+(select top 1 ImporteGravado from [Nomina].[fnObtenerAcumuladoPorTipoConceptoPorEjercicioTipoISR](Empleados.IDEmpleado,1,@Ejercicio,2)))
																				,(
																					isnull(dtDiasPagados.ImporteTotal1,0)
																					+isnull(dtDiasVacaciones.ImporteTotal1,0)
																					+isnull(dtSeptimoDia.ImporteTotal1,0)
																					+(select top 1 ImporteTotal1 from [Nomina].[fnObtenerAcumuladoPorConcepto](Empleados.IDEmpleado,@IDConcepto005,@Ejercicio))
																					+(select top 1 ImporteTotal1 from [Nomina].[fnObtenerAcumuladoPorConcepto](Empleados.IDEmpleado,@IDConcepto002,@Ejercicio))
																					+(select top 1 ImporteTotal1 from [Nomina].[fnObtenerAcumuladoPorConcepto](Empleados.IDEmpleado,@IDConcepto007,@Ejercicio))
																				)
																				,@Ejercicio
																				,@MesFin
																				,@IDPais,0) -  +(select top 1 ImporteTotal1 from [Nomina].[fnObtenerAcumuladoPorConcepto](Empleados.IDEmpleado,@IDConcepto,@Ejercicio))
					  ELSE 0
					 END 
			END 
			 as ISR 
        ,Empleados.IDEmpleado
        INTO #TempISR
        FROM @dtempleados Empleados
            left join @dtDetallePeriodo dtDiasPagados
				on Empleados.IDEmpleado = dtDiasPagados.IDEmpleado
					and dtDiasPagados.IDConcepto = @IDConcepto005 -- Dias Pagados
			left join @dtDetallePeriodo dtDiasVacaciones
				on Empleados.IDEmpleado = dtDiasVacaciones.IDEmpleado
					and dtDiasVacaciones.IDConcepto = @IDConcepto002 -- Dias Vacaciones
			left join @dtDetallePeriodo dtSeptimoDia
				on dtSeptimoDia.IDEmpleado = Empleados.IDEmpleado
					and dtSeptimoDia.IDConcepto = @IDConcepto007
            left join @dtDetallePeriodo dp301
                on Empleados.IDEmpleado = dp301.IDEmpleado
                and dp301.IDConcepto = @IDConceptoCI301
            Cross Apply [Nomina].[fnObtenerAcumuladoPorTipoConceptoPorMesTipoISR](Empleados.IDEmpleado,1,@IDMes,@Ejercicio,@IDCalculoISRSueldos) AcumGravadoAnterior
            Cross apply Nomina.[fnObtenerAcumuladoPorConceptoPorMes](Empleados.IDEmpleado,@IDConcepto079,@IDMes,@Ejercicio)  as AcumISR --Acumulado ISR Causado
        
            
    /*BLOQUE DE CALCULO DE ISR*/


    /*BLOQUE DE CALCULO SUBSIDIO*/


		IF object_ID('TEMPDB..#TempSubsidio') IS NOT NULL DROP TABLE #TempSubsidio
		SELECT
			Empleados.IDEmpleado,
			[Nomina].[fnCalcularSubsidioReforma2024]
                (@MesFin,@Dias,@ValorDiarioUMA,@TopeSalarialPorPeriodo,@TopeMensualSubsidioSalario,dpCI301.ImporteTotal1,AcumGravadoAnterior.ImporteTotal1,Acum078.ImporteTotal1,ISR.ISR) as Valor																		 			   																							 
		INTO #TempSubsidio
		FROM @dtempleados Empleados
            left join #TempISR ISR
                on Empleados.IDEmpleado = ISR.IDEmpleado
            left join @dtDetalleperiodo dpCI301
                on Empleados.IDEmpleado = dpCI301.IDEmpleado
                and dpCI301.IDConcepto = @IDConceptoCI301
            Cross Apply [Nomina].[fnObtenerAcumuladoPorTipoConceptoPorMesTipoISR](Empleados.IDEmpleado,1,@IDMes,@Ejercicio,@IDCalculoISRSueldos) AcumGravadoAnterior
            Cross apply Nomina.[fnObtenerAcumuladoPorConceptoPorMes](Empleados.IDEmpleado,@IDConcepto078,@IDMes,@Ejercicio)  as Acum078


    /*BLOQUE DE CALCULO SUBSIDIO*/

    /*BLOQUE DE CALCULO INVERSO*/

        IF object_ID('TEMPDB..#TempCalculoIverso') IS NOT NULL DROP TABLE #TempCalculoIverso
            SELECT
			Empleados.IDEmpleado,
			           
                CASE WHEN dt011.ImporteTotal1 > 0 THEN

                    CASE WHEN @ConfigISRProporcionalTipoNomina = 1 
                    THEN
                        CASE 
                        WHEN @IDISRProporcionalTipoNomina in (0,1,2,3) 
                            THEN [Nomina].[fnISRINVERSOTipoNomina] (@IDPeriodicidadPagoPeriodo,isnull(dt011.ImporteTotal1 - sub.Valor,0),(isnull(dtDiasPagados.ImporteTotal1,0)+isnull(dtDiasVacaciones.ImporteTotal1,0)+isnull(dtSeptimoDia.ImporteTotal1,0)),@Ejercicio,@MesFin,@IDPais,@IDISRProporcionalTipoNomina)	
                        
                        WHEN @IDISRProporcionalTipoNomina in (4) 
                                    THEN 
                                    CASE WHEN @MesFin = 1 THEN [Nomina].[fnISRINVERSOTipoNomina](@IDPeriodicidadPagoMensual,dt011.ImporteTotal1 - sub.Valor + AcumBase011.ImporteTotal1,0,@Ejercicio,@MesFin,@IDPais,@IDISRProporcionalTipoNomina) - ISNULL(AcumISRInverso.ImporteTotal1,0)
                                    ELSE [Nomina].[fnISRINVERSOTipoNomina](@IDPeriodicidadPagoPeriodo,isnull(dt011.ImporteTotal1 - sub.Valor,0),0,@Ejercicio, @MesFin,@IDPais,@IDISRProporcionalTipoNomina)
                                    
                                    END  
                        WHEN @IDISRProporcionalTipoNomina in (5) THEN [Nomina].[fnISRINVERSOTipoNomina](@IDPeriodicidadPagoPeriodo
                                                                                ,isnull(dt011.ImporteTotal1 - sub.Valor,0) + (select top 1 ImporteGravado from [Nomina].[fnObtenerAcumuladoPorTipoConcepto](Empleados.IDEmpleado,1,@Ejercicio))
                                                                                ,(isnull(dtDiasPagados.ImporteTotal1,0)+(select top 1 ImporteTotal1 from [Nomina].[fnObtenerAcumuladoPorConcepto](Empleados.IDEmpleado,@IDConcepto005,@Ejercicio)))
                                                                                ,@Ejercicio
                                                                                ,@MesFin
                                                                                ,@IDPais
                                                                                ,@IDISRProporcionalTipoNomina)
                        ELSE 0 
                        END
                    ELSE 
                    CASE 
                        WHEN @ISRProporcional in (0,1,2,3) 
                            THEN [Nomina].[fnISRINVERSO] (@IDPeriodicidadPagoPeriodo,isnull(dt011.ImporteTotal1 - sub.Valor,0),(isnull(dtDiasPagados.ImporteTotal1,0)+isnull(dtDiasVacaciones.ImporteTotal1,0)+isnull(dtSeptimoDia.ImporteTotal1,0)),@Ejercicio,@MesFin,@IDPais)	
                        
                        WHEN @ISRProporcional in (4) 
                                    THEN 
                                    CASE WHEN @MesFin = 1 THEN [Nomina].[fnISRINVERSO](@IDPeriodicidadPagoMensual,dt011.ImporteTotal1 - sub.Valor + AcumBase011.ImporteTotal1,0,@Ejercicio,@MesFin,@IDPais) - ISNULL(AcumISRInverso.ImporteTotal1,0)
                                    ELSE [Nomina].[fnISRINVERSO](@IDPeriodicidadPagoPeriodo,isnull(dt011.ImporteTotal1 - sub.Valor,0),0,@Ejercicio, @MesFin,@IDPais)
                                    
                                    END  
                        WHEN @ISRProporcional in (5) THEN [Nomina].[fnISRINVERSO](@IDPeriodicidadPagoPeriodo
                                                                                ,isnull(dt011.ImporteTotal1 - sub.Valor,0)+(select top 1 ImporteGravado from [Nomina].[fnObtenerAcumuladoPorTipoConcepto](Empleados.IDEmpleado,1,@Ejercicio))
                                                                                ,(isnull(dtDiasPagados.ImporteTotal1,0)+(select top 1 ImporteTotal1 from [Nomina].[fnObtenerAcumuladoPorConcepto](Empleados.IDEmpleado,@IDConcepto005,@Ejercicio)))
                                                                                ,@Ejercicio
                                                                                ,@MesFin
                                                                                ,@IDPais)
                        ELSE 0
                        END
                    END																	 
			END Valor																							 
		INTO #TempCalculoIverso
		FROM @dtempleados Empleados
            left join #TempSubsidio sub
                on Empleados.IDEmpleado = sub.IDEmpleado and sub.Valor > 0
            left join @dtDetallePeriodo dt011
				on dt011.IDEmpleado = Empleados.IDEmpleado
				    and dt011.IDConcepto = @IDConceptoCI011
            left join @dtDetallePeriodo dtDiasPagados
				on Empleados.IDEmpleado = dtDiasPagados.IDEmpleado
					and dtDiasPagados.IDConcepto = @IDConcepto005 -- Dias Pagados
			left join @dtDetallePeriodo dtDiasVacaciones
				on Empleados.IDEmpleado = dtDiasVacaciones.IDEmpleado
					and dtDiasVacaciones.IDConcepto = @IDConcepto002 -- Dias Vacaciones
			left join @dtDetallePeriodo dtSeptimoDia
				on dtSeptimoDia.IDEmpleado = Empleados.IDEmpleado
					and dtSeptimoDia.IDConcepto = @IDConcepto007
            Cross Apply Nomina.fnObtenerAcumuladoPorConceptoPorMes(Empleados.IDEmpleado,@IDConceptoCI301,@IDMes,@Ejercicio) AcumISRInverso
            Cross Apply Nomina.fnObtenerAcumuladoPorConceptoPorMes(Empleados.IDEmpleado,@IDConceptoCI011,@IDMes,@Ejercicio) AcumBase011


        /*BLOQUE DE CALCULO INVERSO*/



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
                CASE WHEN isnull(dtCI.Valor,0) > 0 THEN 
					      CASE WHEN (isnull(dtCI.Valor,0)) - ISNULL(Pi.ImporteGravado,0) < 0 THEN 0 
                            ELSE (isnull(dtCI.Valor,0)) - ISNULL(Pi.ImporteGravado,0) 
                          END
                END																	 
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
            left join #TempCalculoIverso dtCI
				on dtCI.IDEmpleado = Empleados.IDEmpleado
            Left Join #TempPercepcionesInverso Pi --Percepciones Inverso
                on pi.IDEmpleado = Empleados.IDEmpleado

            
            
		/* Inicio de segmento para programar las opciones de LFT, Personalizada, Doble Paga*/
		/* @Concepto_LFT, @Concepto_Personalizada, @Concepto_ConDoblePago*/
		
		
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
