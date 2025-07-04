USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: ISR
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
CREATE PROC [Nomina].[spConcepto_RD301]
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
		,@Codigo varchar(20) = 'RD301' 
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
		,@IDCalculo int              
		,@PeriodicidadesPagoDias int 
		,@IDConcepto005 int --- DIAS PAGADOS
		,@IDConcepto002 int --- DIAS VACACIONES
		,@IDConceptoRD301 int --- ISR
		,@IDConcepto301F int --- ISR COMISIONES
		,@IDConceptoRD099 int --Amortizacion
		,@IDConcepto550 int --TotalPercepciones
		,@IDConcepto105 int -- Comisiones
        ,@IDConceptoRD302 INT
        ,@IDConceptoRD303 INT
        ,@IDConceptoRD317 INT --SEGURO PADRES
		,@ISRProporcional int
		,@IDPais int
		,@IDCalculoISRSueldos int
        ,@IDConceptoRD101 int
        ,@IDConceptoRD123 int ---DIAS PENDIENTES DE PAGO
        ,@IDConceptoRD130 int ---DIETA
        ,@IDConceptoRD124 int ---RETROACTIVO
        ,@IDConceptoRD120 int ---VACACIONES
		,@IDConceptoRD134 int ---INCENTIVOS
		,@IDConceptoRD144 int ---GRATIFICACIONES
        ,@TopeMensualAFP decimal(18,4)
        ,@PorcentajeAFP decimal(18,4)
        ,@TopePagoAFP decimal(18,4)
        ,@TopeMensualARS decimal(18,4)
        ,@PorcentajeARS decimal(18,4)
        ,@TopePagoARS decimal(18,4)
        ,@IDReps2002 INT
        ,@IDSunwing2003 INT 
        ,@IDTourDesk2201 int
        ,@IDWater2202 int

	;

	/* Variables Para el Calculo*/            
	DECLARE @IDPeriodicidadPagoMensual int,            
			@IDPeriodicidadPagoPeriodo int ,
            @IDPeriodicidadPagoAnual int

	select top 1 
		@IDPeriodo = IDPeriodo ,@IDTipoNomina= IDTipoNomina,@Ejercicio = Ejercicio,@ClavePeriodo	= ClavePeriodo,@DescripcionPeriodo =  Descripcion 
		,@FechaInicioPago = FechaInicioPago,@FechaFinPago	= FechaFinPago,@FechaInicioIncidencia = FechaInicioIncidencia,@FechaFinIncidencia=	 FechaFinIncidencia 
		,@Dias = Dias,@AnioInicio = AnioInicio,@AnioFin = AnioFin,@MesInicio = MesInicio,@MesFin = MesFin 
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin 
		,@General = General,@Finiquito = Finiquito,@Especial = Especial,@Cerrado = Cerrado 
	from @dtPeriodo 
 
	select top 1 @IDConcepto=IDConcepto from @dtConceptos where Codigo=@Codigo; 
	select top 1 @IDConcepto005=IDConcepto from @dtConceptos where Codigo='005'; 
	select top 1 @IDConcepto002=IDConcepto from @dtConceptos where Codigo='002'; 
	select top 1 @IDConceptoRD101=IDConcepto from @dtConceptos where Codigo='RD101';
    select top 1 @IDConceptoRD301=IDConcepto from @dtConceptos where Codigo='RD301';
    select top 1 @IDConceptoRD302=IDConcepto from @dtConceptos where Codigo='RD302';
    select top 1 @IDConceptoRD303=IDConcepto from @dtConceptos where Codigo='RD303';
    select top 1 @IDConceptoRD317=IDConcepto from @dtConceptos where Codigo='RD317';

    Select top 1 @IDReps2002 = IDCentroCosto from rh.tblCatCentroCosto where Codigo = '2002'
    Select top 1 @IDSunwing2003 = IDCentroCosto from rh.tblCatCentroCosto where Codigo = '2003'
    Select top 1 @IDTourDesk2201 = IDCentroCosto from rh.tblCatCentroCosto where Codigo = '2201'
    Select top 1 @IDWater2202 = IDCentroCosto from rh.tblCatCentroCosto where Codigo = '2202'
          
    --SET @TopeMensualAFP = 325250
	SET @TopeMensualAFP = 433496 --Actualización al 1 de abril 2025
    SET @PorcentajeAFP = 0.0287
    SET @TopePagoAFP = @TopeMensualAFP * @PorcentajeAFP
    --SET @TopeMensualARS = 162625 
	SET @TopeMensualARS = 216748 --Actualización al 1 de abril 2025
    SET @PorcentajeARS = 0.0304
    SET @TopePagoARS = @TopeMensualARS * @PorcentajeARS


	select top 1 @IDConcepto301F=IDConcepto from @dtConceptos where Codigo='301F'; 
	select top 1 @IDConceptoRD099=IDConcepto from @dtConceptos where Codigo='RD099';  
	select top 1 @IDConcepto550=IDConcepto from @dtConceptos where Codigo='550';  
	select top 1 @IDConcepto105=IDConcepto from @dtConceptos where Codigo='105';   
    select top 1 @IDConceptoRD123=IDConcepto from @dtConceptos where Codigo='RD123';   
    select top 1 @IDConceptoRD130=IDConcepto from @dtConceptos where Codigo='RD130';   
    select top 1 @IDConceptoRD120=IDConcepto from @dtConceptos where Codigo='RD120';
    select top 1 @IDConceptoRD124=IDConcepto from @dtConceptos where Codigo='RD124';   
	select top 1 @IDConceptoRD134=IDConcepto from @dtConceptos where Codigo='RD134';  
	select top 1 @IDConceptoRD144=IDConcepto from @dtConceptos where Codigo='RD144';  
	

	Select top 1 @ISRProporcional = cast(isnull(Valor,0) as int)   
	from Nomina.tblConfiguracionNomina   
	where Configuracion = 'ISRProporcional'
 
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
 
 	select top 1 @isPreviewFiniquito = cast(isnull(valor,0) as bit) 
	from @dtconfigs
	where Configuracion = 'isPreviewFiniquito'

	select @PeriodicidadPago = PP.Descripcion from Nomina.tblCatTipoNomina TN
		Inner join [Sat].[tblCatPeriodicidadesPago] PP
			on TN.IDPEriodicidadPAgo = PP.IDPeriodicidadPago
	Where TN.IDTipoNomina = @IDTipoNomina

	select top 1 @IDPeriodicidadPagoMensual = IDPeriodicidadPago from SAT.tblCatPeriodicidadesPago where Descripcion = 'Mensual'  
    select top 1 @IDPeriodicidadPagoAnual = IDPeriodicidadPago from SAT.tblCatPeriodicidadesPago where Descripcion = 'Anual'  

    

	select top 1 @IDCalculoISRSueldos = IDCalculo       
		from Nomina.tblCatTipoCalculoISR      
		WHERE Codigo = 'ISR_SUELDOS'   

    


    -- Saca Periodicidad de Pago y Dias del periodo    
	Select TOP 1 
		 @IDPeriodicidadPagoPeriodo = tn.IDPeriodicidadPago            
		,@PeriodicidadesPagoDias = case when pp.Descripcion = 'Semanal'		then 7              
										when pp.Descripcion = 'Catorcenal'	then 14              
										when pp.Descripcion = 'Quincenal'	then 15              
										when pp.Descripcion = 'Mensual'		then 30              
										when pp.Descripcion = 'Decenal'		then 10              
									else 1              
									END 
		,@IDPais = tn.IDPais
	from Nomina.tblCatTipoNomina tn            
		left join sat.tblCatPeriodicidadesPago pp             
		on tn.IDPeriodicidadPago = pp.IDPeriodicidadPago                    
	where IDTipoNomina = @IDTipoNomina     

	-- Valida si tabla de ISR de la periodicidad existe    
	IF NOT EXISTS(Select *             
				from Nomina.tbltablasImpuestos  TI            
					INNER JOIN Nomina.tblDetalleTablasImpuestos DTI            
						on DTI.IDTablaImpuesto = TI.IDTablaImpuesto    
					INNER JOIN Nomina.tblCatTipoCalculoISR CTCI    
						on CTCI.IDCalculo = TI.IDCalculo      
				WHERE TI.Ejercicio = @Ejercicio            
					AND CTCI.Codigo = 'ISR_SUELDOS'
					AND TI.IDPais = @IDPais
					AND TI.IDPeriodicidadPago = @IDPeriodicidadPagoPeriodo            
		)            
	BEGIN            
		RAISERROR('La tabla de ISR para esta periodicidad de pago y Ejercicio no existe.',16,1);            
	END 

	IF NOT EXISTS(Select *             
				from Nomina.tbltablasImpuestos  TI            
					INNER JOIN Nomina.tblDetalleTablasImpuestos DTI            
					on DTI.IDTablaImpuesto = TI.IDTablaImpuesto    
					INNER JOIN Nomina.tblCatTipoCalculoISR CTCI    
					on CTCI.IDCalculo = TI.IDCalculo      
				WHERE TI.Ejercicio = @Ejercicio   
				AND CTCI.Codigo = 'ISR_SUELDOS' 
				AND TI.IDPais = @IDPais
				AND TI.IDPeriodicidadPago = (select top 1 IDPeriodicidadPago from SAT.tblCatPeriodicidadesPago where Descripcion = 'Mensual' )            
	)            
	BEGIN            
		RAISERROR('La tabla de ISR para esta periodicidad de pago Mensual y Ejercicio no existe.',16,1);            
	END  

	-- Valida si tabla de ISR de la periodicidad existe  
	-- Verificacion de Tabla Temporal de GRAVADO Y DIAS    
	if object_id('tempdb..#TempGravadoPeriodo') is not null drop table #TempGravadoPeriodo;     
    if object_id('tempdb..#TempAFPARS') is not null drop table #TempAFPARS;     
    if object_id('tempdb..#TempVariables') is not null drop table #TempVariables;     
	if object_id('tempdb..#TempDiasPeriodo') is not null drop table #TempDiasPeriodo;     
	if object_id('tempdb..#TempISRNormal') is not null drop table #TempISRNormal;     
	if object_id('tempdb..#TempISRGratificacionesAnuales') is not null drop table #TempISRGratificacionesAnuales;     
	if object_id('tempdb..#TempISRGratificacionesAnualFinal') is not null drop table #TempISRGratificacionesAnualFinal;    
	if object_id('tempdb..#TempISRTotal') is not null drop table #TempISRTotal;    
	if object_id('tempdb..#TempISRAjusta') is not null drop table #TempISRAjusta; 
	if object_id('tempdb..#TempGravadoPeriodoTotalFiniquito') is not null drop table #TempGravadoPeriodoTotalFiniquito; 
	if object_id('tempdb..#TempISRNormalFiniquito') is not null drop table #TempISRNormalFiniquito; 
	if object_id('tempdb..#tempISRFinalFiniquito') is not null drop table tempISRFinalFiniquito; 


    SELECT IDEmpleado,
           CASE WHEN (((ISNULL(e.SalarioDiario,0)*30)/2)*@PorcentajeARS) > @TopePagoARS THEN @TopePagoARS ELSE (((ISNULL(e.SalarioDiario,0)*30)/2)*@PorcentajeARS) END AS PROYARS,
           CASE WHEN (((ISNULL(e.SalarioDiario,0)*30)/2)*@PorcentajeAFP) > @TopePagoAFP THEN @TopePagoAFP ELSE (((ISNULL(e.SalarioDiario,0)*30)/2)*@PorcentajeAFP) END AS PROYAFP
                
    INTO #TempAFPARS
    FROM @dtempleados e



	IF(@General = 1 or @Finiquito = 1 or @Especial=1)
	BEGIN
		--SACAR GRAVADO DEL PERIODO     
		select dp.IDEmpleado as IDEmpleado                   
		   ,SUM(dp.ImporteGravado) as Gravado
		   ,CAST(0.00 as Decimal(18,2))  as AcumGravPeriodosAnteriores
		into #TempGravadoPeriodo         
		from @dtDetallePeriodo dp            
			inner join @dtConceptos c            
				on dp.IDConcepto = c.IDConcepto   
				and c.IDPais = @IDPais
			inner join Nomina.tblCatTipoCalculoISR ti with (nolock)            
				on ti.IDCalculo = c.IDCalculo            
			inner join Nomina.tblCatTipoConcepto TC with (nolock)    
				on TC.IDTipoConcepto = c.IDTipoConcepto    
		where ti.Codigo = 'ISR_SUELDOS' 
			and tc.Descripcion = 'PERCEPCION'     
			--AND C.IDConcepto NOT IN (@IDConcepto105)
		group by dp.IDEmpleado    
		--SACAR GRAVADO DEL PERIODO  
		


		

        -- SACANDO EL GRAVADO DE CONCEPTOS DIFERENTES A SUELDO
        select dp.IDEmpleado as IDEmpleado                   
		,SUM(dp.ImporteGravado) as Gravado
		into #TempVariables         
		from @dtDetallePeriodo dp            
			inner join @dtConceptos c            
				on dp.IDConcepto = c.IDConcepto   
				and c.IDPais = @IDPais
			inner join Nomina.tblCatTipoCalculoISR ti with (nolock)            
				on ti.IDCalculo = c.IDCalculo            
			inner join Nomina.tblCatTipoConcepto TC with (nolock)    
				on TC.IDTipoConcepto = c.IDTipoConcepto    
		where ti.Codigo = 'ISR_SUELDOS' 
			and tc.Descripcion = 'PERCEPCION'     
			-- AND C.IDConcepto NOT IN (@IDConceptoRD101,@IDConceptoRD123,@IDConceptoRD130,@IDConceptoRD124,@IDConceptoRD120)
            AND C.IDConcepto NOT IN (@IDConceptoRD101,@IDConceptoRD130)
            
		group by dp.IDEmpleado 


        

      

		update GP
			set GP.AcumGravPeriodosAnteriores = Acum.ImporteGravado
		From #TempGravadoPeriodo GP
			Cross Apply [Nomina].[fnObtenerAcumuladoPorTipoConceptoPorMesTipoISR](GP.IDEmpleado,1,@IDMes,@Ejercicio,@IDCalculoISRSueldos) Acum

		--select * from #TempGravadoPeriodo
		-- Elimina lo registros de los colaboradores que no tiene Importe gravado en el periodo
		delete dtl
		from @dtDetallePeriodoLocal dtl
			left join #TempGravadoPeriodo tgp on dtl.IDEmpleado = tgp.IDEmpleado 
		WHERE tgp.IDEmpleado is null or tgp.Gravado = 0

        


		--ISR NORMAL    
		Select gp.IDEmpleado    
                 
                ,
             CASE WHEN ( ( @Concepto_bCantidadMonto  = 1 ) and ( ISNULL(DTLocal.CantidadMonto,0) > 0 ) ) THEN ISNULL(DTLocal.CantidadMonto,0)		
                  WHEN @IDTipoNomina=12 
                      THEN  
                      CASE WHEN (([Nomina].[fnISRSUELDOS](@IDPeriodicidadPagoMensual,((((ISNULL(gp.Gravado,0)))-(isnull(dtARS.ImporteTotal1,0))-(isnull(dtAPF.ImporteTotal1,0)) -(ISNULL(dtPADRE.ImporteTotal1,0)))),0,@Ejercicio, @MesFin,@IDPais)) - ISNULL(DescISR.ImporteTotal1,0))>0.00
                           THEN ([Nomina].[fnISRSUELDOS](@IDPeriodicidadPagoMensual,((((ISNULL(gp.Gravado,0)))-(isnull(dtARS.ImporteTotal1,0))-(isnull(dtAPF.ImporteTotal1,0)) -(ISNULL(dtPADRE.ImporteTotal1,0)))),0,@Ejercicio, @MesFin,@IDPais)) - ISNULL(DescISR.ImporteTotal1,0)
                           ELSE 0 END

                      WHEN @MesFin = 1 
                            THEN  
                            CASE WHEN ((([Nomina].[fnISRSUELDOS](@IDPeriodicidadPagoAnual,((((ISNULL(gp.Gravado,0) + ISNULL(gp.AcumGravPeriodosAnteriores,0)))-(isnull(dtARS.ImporteTotal1,0)+isnull(AcumARS.ImporteTotal1,0))-(isnull(dtAPF.ImporteTotal1,0)+isnull(AcumAPF.ImporteTotal1,0)) -(ISNULL(dtPADRE.ImporteTotal1,0) + ISNULL(AcumPADRE.ImporteTotal1,0))))*12,0,@Ejercicio, 0,@IDPais)/12) - (ISNULL(AcumISR.ImporteTotal1,0))  ) - ISNULL(DescISR.ImporteTotal1,0))>0.00
                                 THEN (([Nomina].[fnISRSUELDOS](@IDPeriodicidadPagoAnual,((((ISNULL(gp.Gravado,0) + ISNULL(gp.AcumGravPeriodosAnteriores,0)))-(isnull(dtARS.ImporteTotal1,0)+isnull(AcumARS.ImporteTotal1,0))-(isnull(dtAPF.ImporteTotal1,0)+isnull(AcumAPF.ImporteTotal1,0)) -(ISNULL(dtPADRE.ImporteTotal1,0) + ISNULL(AcumPADRE.ImporteTotal1,0))))*12,0,@Ejercicio, 0,@IDPais)/12) - (ISNULL(AcumISR.ImporteTotal1,0))  ) - ISNULL(DescISR.ImporteTotal1,0)     
                                 ELSE 0 END   
                        		 ELSE 
                                    CASE WHEN ISNULL(variable.Gravado,0) = 0 
                                         THEN 
                                            CASE WHEN (( [Nomina].[fnISRSUELDOS](@IDPeriodicidadPagoAnual,((((ISNULL(gp.Gravado,0)+(((ISNULL(empleados.SalarioDiario,0)*30)/2)-(isnull(proy.PROYAFP,0)+isnull(proy.PROYARS,0))))-(isnull(dtAPF.ImporteTotal1,0)+isnull(dtARS.ImporteTotal1,0) + isnull(dtPADRE.ImporteTotal1,0)))) * 12),0,@Ejercicio, @MesFin,@IDPais) / 24 ) - ISNULL(DescISR.ImporteTotal1,0))>0.00
                                                 THEN ( [Nomina].[fnISRSUELDOS](@IDPeriodicidadPagoAnual,((((ISNULL(gp.Gravado,0)+(((ISNULL(empleados.SalarioDiario,0)*30)/2)-(isnull(proy.PROYAFP,0)+isnull(proy.PROYARS,0))))-(isnull(dtAPF.ImporteTotal1,0)+isnull(dtARS.ImporteTotal1,0) + isnull(dtPADRE.ImporteTotal1,0)))) * 12),0,@Ejercicio, @MesFin,@IDPais) / 24 ) - ISNULL(DescISR.ImporteTotal1,0)
                                                 ELSE 0 END

                                        WHEN ISNULL(variable.Gravado,0) > 0  
                                        THEN 
                                            CASE WHEN (((([Nomina].[fnISRSUELDOS](@IDPeriodicidadPagoAnual,((((ISNULL(gp.Gravado,0)+(((ISNULL(empleados.SalarioDiario,0)*30)/2)-(isnull(proy.PROYAFP,0)+isnull(proy.PROYARS,0))))-(isnull(dtAPF.ImporteTotal1,0)+isnull(dtARS.ImporteTotal1,0) + isnull(dtPADRE.ImporteTotal1,0)))) * 12),0,@Ejercicio, @MesFin,@IDPais) / 12) / 23.83 ) * 15) - ISNULL(DescISR.ImporteTotal1,0))>0
                                            THEN ((([Nomina].[fnISRSUELDOS](@IDPeriodicidadPagoAnual,((((ISNULL(gp.Gravado,0)+(((ISNULL(empleados.SalarioDiario,0)*30)/2)-(isnull(proy.PROYAFP,0)+isnull(proy.PROYARS,0))))-(isnull(dtAPF.ImporteTotal1,0)+isnull(dtARS.ImporteTotal1,0) + isnull(dtPADRE.ImporteTotal1,0)))) * 12),0,@Ejercicio, @MesFin,@IDPais) / 12) / 23.83 ) * 15) - ISNULL(DescISR.ImporteTotal1,0)
                                            ELSE 0 END
                                            
                                        END    
                                    
                                    
								 END AS ISR 
			 ,gp.AcumGravPeriodosAnteriores
			 ,gp.Gravado
			 ,AcumISR.ImporteTotal1 AcumISR
			 , (ISNULL(AcumISR.ImporteTotal1,0)) as acumisrpagado
			 , ISRTotalmensual = [Nomina].[fnISRSUELDOS](@IDPeriodicidadPagoMensual,(gp.Gravado + gp.AcumGravPeriodosAnteriores),0,@Ejercicio, @MesFin,@IDPais)
		into #TempISRNormal    
		from #TempGravadoPeriodo GP   
			left join @dtDetallePeriodo dtDiasPagados
				on gp.IDEmpleado = dtDiasPagados.IDEmpleado
					and dtDiasPagados.IDConcepto = @IDConcepto005 -- Dias Pagados
			left join @dtDetallePeriodo dtDiasVacaciones
				on gp.IDEmpleado = dtDiasVacaciones.IDEmpleado
					and dtDiasVacaciones.IDConcepto = @IDConcepto002 -- Dias Vacaciones
            left join @dtDetallePeriodo dtAPF
				on dtAPF.IDEmpleado = gp.IDEmpleado
					and dtAPF.IDConcepto = @IDConceptoRD302 --afp
            left join @dtDetallePeriodo dtARS
				on dtARS.IDEmpleado = gp.IDEmpleado
					and dtARS.IDConcepto = @IDConceptoRD303 --ars
            left join @dtDetallePeriodo dtPADRE
				on dtPADRE.IDEmpleado = gp.IDEmpleado
					and dtPADRE.IDConcepto = @IDConceptoRD317 --Seguropadre      
             left join @dtDetallePeriodo dtSueldo
				on dtSueldo.IDEmpleado = gp.IDEmpleado
					and dtSueldo.IDConcepto = @IDConceptoRD101 --SUELDO     
			left join @dtDetallePeriodo dtIncentivo
				on dtIncentivo.IDEmpleado = gp.IDEmpleado
					and dtIncentivo.IDConcepto = @IDConceptoRD134 --INCENTIVO   
			left join @dtDetallePeriodo dtGratificaciones
				on dtGratificaciones.IDEmpleado = gp.IDEmpleado
					and dtGratificaciones.IDConcepto = @IDConceptoRD144 --GRATIFICACIONES   
            left join #TempVariables variable
                on variable.IDEmpleado=gp.IDEmpleado        
            left join #TempAFPARS proy
                on proy.IDEmpleado=gp.IDEmpleado      --Proyeccion de sueldo
            left join @dtDetallePeriodo DescISR
                on DescISR.IDEmpleado = gp.IDEmpleado
                and DescISR.IDConcepto = @IDConceptoRD099 --Amortizacion    
            inner join @dtempleados empleados
                on gp.IDEmpleado=empleados.IDEmpleado
            Left Join @dtDetallePeriodoLocal DTLocal
				on Empleados.IDEmpleado = DTLocal.IDEmpleado    
			Cross apply Nomina.[fnObtenerAcumuladoPorConceptoPorMes](GP.IDEmpleado,@IDConceptoRD301,@IDMes,@Ejercicio)  as AcumISR
            Cross apply Nomina.[fnObtenerAcumuladoPorConceptoPorMes](GP.IDEmpleado,@IDConceptoRD302,@IDMes,@Ejercicio)  as AcumAPF
            Cross apply Nomina.[fnObtenerAcumuladoPorConceptoPorMes](GP.IDEmpleado,@IDConceptoRD303,@IDMes,@Ejercicio)  as AcumARS
            Cross apply Nomina.[fnObtenerAcumuladoPorConceptoPorMes](GP.IDEmpleado,@IDConceptoRD317,@IDMes,@Ejercicio)  as AcumPADRE
			
		where gp.Gravado > 0 
    
		-- select * from #TempISRNormal
        -- return
		--ISR GRATIFICACIONES ANUALES    
          
		CREATE TABLE #TempISRTotal    
		(    
			IDEmpleado int,    
			ISRTotal Decimal(18,4)    
		)     
             
		insert into #TempISRTotal(IDEmpleado,ISRTotal)    
		SELECT t.IDEmpleado, SUM(t.ISR)     
		FROM (    
		SELECT ISRNormal.IDEmpleado,    
			ISRNormal.ISR     
			from #TempISRNormal ISRNormal    
		) T    
		GROUP BY t.IDEmpleado    
		--ISR GRATIFICACIONES ANUALES  

		MERGE @dtDetallePeriodoLocal AS TARGET            
		USING #TempISRTotal AS SOURCE            
			ON TARGET.IDPeriodo = @IDPeriodo          
			and TARGET.IDConcepto = @IDConcepto           
			and TARGET.IDEmpleado = SOURCE.IDEmpleado                
		WHEN MATCHED Then            
			update            
			Set                 
			TARGET.ImporteTotal1  = SOURCE.ISRTotal                  
		WHEN NOT MATCHED BY TARGET THEN             
			INSERT(IDEmpleado,IDPeriodo,IDConcepto,ImporteTotal1)            
			VALUES(SOURCE.IDEmpleado,@IDPeriodo,@IDConcepto,Source.ISRTotal)
		WHEN NOT MATCHED BY SOURCE THEN
		DELETE;      
	END 
	-- IF(@Finiquito = 1)
	-- BEGIN
	-- 	--SACAR GRAVADO DEL PERIODO     
	
	-- 	select t.IDEmpleado, SUM( t.Gravado) Gravado 
	-- 	into #TempGravadoPeriodoTotalFiniquito     
	-- 	from (
	-- 		select 
	-- 			dp.IDEmpleado as IDEmpleado                   
	-- 			,SUM(dp.ImporteGravado) as Gravado           
	-- 		from @dtDetallePeriodo dp            
	-- 			inner join @dtConceptos c            
	-- 			on dp.IDConcepto = c.IDConcepto 
	-- 			and c.IDPais = @IDPais
	-- 			inner join Nomina.tblCatTipoCalculoISR ti            
	-- 			on ti.IDCalculo = c.IDCalculo            
	-- 			inner join Nomina.tblCatTipoConcepto TC    
	-- 			on TC.IDTipoConcepto = c.IDTipoConcepto    
	-- 		where ti.Codigo = 'ISR_SUELDOS'            
	-- 			and tc.Descripcion = 'PERCEPCION'    
	-- 		Group by dp.IDEmpleado  
	-- 		UNION
	-- 		select acum.IDEmpleado, acum.ImporteGravado as Gravado 
	-- 		from 
	-- 			@dtempleados empleados
	-- 			CROSS APPLY	Nomina.fnObtenerAcumuladoPorTipoConceptoPorMesTipoISR(empleados.IDEmpleado,1,@IDMes,@Ejercicio,@IDCalculoISRSueldos) acum
	-- 	) t
	-- 	Group by t.IDEmpleado
	-- 	--SACAR GRAVADO DEL PERIODO     
	-- 	-- Elimina lo registros de los colaboradores que no tiene Importe gravado en el periodo

	-- 	--ISR NORMAL    
	-- 	Select gp.IDEmpleado    
	-- 		,[Nomina].[fnISRSUELDOS](@IDPeriodicidadPagoMensual,gp.Gravado,30.4,@Ejercicio,0,@IDPais) as ISR    
	-- 	into #TempISRNormalFiniquito    
	-- 	from #TempGravadoPeriodoTotalFiniquito GP   
	-- 		left join @dtDetallePeriodo dtDiasPagados
	-- 			on gp.IDEmpleado = dtDiasPagados.IDEmpleado
	-- 				and dtDiasPagados.IDConcepto = @IDConcepto005 -- Dias Pagados
	-- 		left join @dtDetallePeriodo dtDiasVacaciones
	-- 			on gp.IDEmpleado = dtDiasVacaciones.IDEmpleado
	-- 				and dtDiasVacaciones.IDConcepto = @IDConcepto002 -- Dias Vacaciones
			
	-- 	where gp.Gravado > 0 

	-- 	--select * from #TempISRNormalFiniquito

	-- 	select t.IDEmpleado, (t.ISR - ac.ImporteTotal1) ISR
	-- 		into #tempISRFinalFiniquito
	-- 	from #TempISRNormalFiniquito t
	-- 		Cross Apply Nomina.fnObtenerAcumuladoPorConceptoPorMes(t.IDEmpleado,@IDConceptoRD301,@IDMes,@Ejercicio) ac

	-- 	MERGE @dtDetallePeriodoLocal AS TARGET            
	-- 	USING #tempISRFinalFiniquito AS SOURCE            
	-- 		ON TARGET.IDPeriodo = @IDPeriodo          
	-- 		and TARGET.IDConcepto = @IDConcepto           
	-- 		and TARGET.IDEmpleado = SOURCE.IDEmpleado                
	-- 	WHEN MATCHED Then            
	-- 		update            
	-- 		Set                 
	-- 		TARGET.ImporteTotal1  = SOURCE.ISR                  
	-- 	WHEN NOT MATCHED BY TARGET THEN             
	-- 		INSERT(IDEmpleado,IDPeriodo,IDConcepto,ImporteTotal1)            
	-- 		VALUES(SOURCE.IDEmpleado,@IDPeriodo,@IDConcepto,Source.ISR)
	-- 	WHEN NOT MATCHED BY SOURCE THEN
	-- 	DELETE;      
	-- END
    
	update @dtDetallePeriodoLocal
		set ImporteTotal1 = 0.00
	where CantidadOtro2 = -1
    
	Select  *
	from @dtDetallePeriodoLocal              
		where (isnull(ImporteTotal1,0)) <> 0
              or (isnull(CantidadOtro2,0)) <> 0       	 
END;
GO
