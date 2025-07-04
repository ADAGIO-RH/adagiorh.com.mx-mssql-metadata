USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: ISR INDEMNIZACIONES
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
CREATE PROC [Nomina].[spCoreConcepto_301B]
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
		,@Codigo varchar(20) = '301B' 
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
		,@PeriodicidadesPagoDias int 
		,@IDConcepto005 int --- DIAS PAGADOS
		,@IDConcepto002 int --- DIAS VACACIONES
		,@IDConcepto301 int --- ISR NORMAL
		,@IDPais int 
        ,@ConfigISRProporcionalTipoNomina bit 
		,@IDISRProporcionalTipoNomina INT 
	;

	
	       /* Variables Para el Calculo*/            
  DECLARE @IDPeriodicidadPagoMensual int,            
       @IDPeriodicidadPagoPeriodo int    


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
	select top 1 @IDConcepto301=IDConcepto from @dtConceptos where Codigo='301'; 

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

     --Configuracion de ISR Proporcional por Tipo de Nomina

    select top 1 @ConfigISRProporcionalTipoNomina = cast(isnull(valor,0) as bit) 
	from @dtconfigs
	where Configuracion = 'ConfigISRProporcionalTipoNomina'

    select top 1 @IDISRProporcionalTipoNomina = cast(isnull(valor,-1) as int) 
	from @dtconfigs
	where Configuracion = 'IDISRProporcionalTipoNomina'

	select @PeriodicidadPago = PP.Descripcion 
		,@IDPais = TN.IDPais
	from Nomina.tblCatTipoNomina TN
		Inner join [Sat].[tblCatPeriodicidadesPago] PP
			on TN.IDPEriodicidadPAgo = PP.IDPeriodicidadPago
	Where TN.IDTipoNomina = @IDTipoNomina

	select top 1 @IDPeriodicidadPagoMensual = IDPeriodicidadPago from SAT.tblCatPeriodicidadesPago where Descripcion = 'Mensual'  

		Select TOP 1 
		 @IDPeriodicidadPagoPeriodo = tn.IDPeriodicidadPago            
		,@PeriodicidadesPagoDias = case when pp.Descripcion = 'Semanal'		then 7              
										when pp.Descripcion = 'Catorcenal'	then 14              
										when pp.Descripcion = 'Quincenal'	then 15              
										when pp.Descripcion = 'Mensual'		then 30              
										when pp.Descripcion = 'Decenal'		then 10              
									else 1              
									END      
	from Nomina.tblCatTipoNomina tn            
		left join sat.tblCatPeriodicidadesPago pp             
		on tn.IDPeriodicidadPago = pp.IDPeriodicidadPago                    
	where IDTipoNomina = @IDTipoNomina     
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

	if object_id('tempdb..#TempGravadoPeriodo') is not null drop table #TempGravadoPeriodo;     
	if object_id('tempdb..#TempDiasPeriodo') is not null drop table #TempDiasPeriodo;     
	if object_id('tempdb..#TempISRNormal') is not null drop table #TempISRNormal;     
	if object_id('tempdb..#TempISRGratificacionesAnuales') is not null drop table #TempISRGratificacionesAnuales;     
	if object_id('tempdb..#TempISRGratificacionesAnualFinal') is not null drop table #TempISRGratificacionesAnualFinal;    
	if object_id('tempdb..#TempISRTotal') is not null drop table #TempISRTotal;    
	if object_id('tempdb..#TempISRAjusta') is not null drop table #TempISRAjusta; 


	if object_id('tempdb..#TempGravadoPeriodoTotal') is not null drop table #TempGravadoPeriodoTotal;     



	--SACAR GRAVADO DEL PERIODO     
	select dp.IDEmpleado as IDEmpleado                   
       ,SUM(dp.ImporteGravado) as Gravado           
	into #TempGravadoPeriodo --- INDEMNIZACION        
	from @dtDetallePeriodo dp            
		inner join @dtConceptos c            
		on dp.IDConcepto = c.IDConcepto
			and C.IDPais = @IDPais
		inner join Nomina.tblCatTipoCalculoISR ti            
		on ti.IDCalculo = c.IDCalculo            
		inner join Nomina.tblCatTipoConcepto TC    
		on TC.IDTipoConcepto = c.IDTipoConcepto    
	where ti.Codigo = 'ISR_INDEMNIZACIONES'            
	and tc.Descripcion = 'PERCEPCION'      
	Group by dp.IDEmpleado     

	Select t.IDEmpleado, SUM(t.Gravado) as Gravado
	into #TempGravadoPeriodoTotal --- INDEMNIZACION      
	FROM(
	select dp.IDEmpleado as IDEmpleado                   
       ,SUM(dp.ImporteGravado) as Gravado           
	from @dtDetallePeriodo dp            
		inner join @dtConceptos c            
		on dp.IDConcepto = c.IDConcepto  
			and c.IDPais = @IDPais
		inner join Nomina.tblCatTipoCalculoISR ti            
		on ti.IDCalculo = c.IDCalculo            
		inner join Nomina.tblCatTipoConcepto TC    
		on TC.IDTipoConcepto = c.IDTipoConcepto    
	where tc.Descripcion = 'PERCEPCION'      
	Group by dp.IDEmpleado 
	UNION 
	Select Empleados.IDEmpleado , Acum.ImporteGravado
	from @dtempleados empleados
		CROSS APPLY Nomina.fnObtenerAcumuladoPorTipoConceptoPorMes(Empleados.IDEmpleado,1,@IDMes,@Ejercicio) Acum
	
	) as t

	Group by t.IDEmpleado


--	select * from #TempGravadoPeriodo
	
	--SACAR GRAVADO DEL PERIODO     

		-- Elimina lo registros de los colaboradores que no tiene Importe gravado en el periodo
	delete dtl
	from @dtDetallePeriodoLocal dtl
		left join #TempGravadoPeriodo tgp on dtl.IDEmpleado = tgp.IDEmpleado 
	WHERE tgp.IDEmpleado is null or tgp.Gravado = 0



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

 
	IF(@General = 1 OR @Finiquito = 1 OR @Especial = 1)
	BEGIN
		IF object_ID('TEMPDB..#TempValores') IS NOT NULL DROP TABLE #TempValores
 
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
                CASE WHEN Grv.Gravado >= (Empleados.SalarioDiario * 30.4)  THEN 
                                                                                        CASE WHEN @ConfigISRProporcionalTipoNomina = 1 
                                                                                            THEN ([Nomina].[fnCoreISRSUELDOSTipoNomina](@IDPeriodicidadPagoMensual,(Empleados.SalarioDiario * 30.4),30.4,@Ejercicio,0,@IDPais,ISNULL(@Finiquito,0),@IDISRProporcionalTipoNomina)/(Empleados.SalarioDiario * 30.4)) 
                                                                                            ELSE ([Nomina].[fnCoreISRSUELDOS](@IDPeriodicidadPagoMensual,(Empleados.SalarioDiario * 30.4),30.4,@Ejercicio,0,@IDPais,ISNULL(@Finiquito,0))/(Empleados.SalarioDiario * 30.4)) 
                                                                                        END * Grv.Gravado
							ELSE  
                                CASE WHEN @ConfigISRProporcionalTipoNomina = 1 
                                    THEN [Nomina].[fnCoreISRSUELDOSTipoNomina](@IDPeriodicidadPagoMensual,isnull(GrvTotal.Gravado,0),30.4,@Ejercicio,0,@IDPais,ISNULL(@Finiquito,0),@IDISRProporcionalTipoNomina) 
                                    ELSE [Nomina].[fnCoreISRSUELDOS](@IDPeriodicidadPagoMensual,isnull(GrvTotal.Gravado,0),30.4,@Ejercicio,0,@IDPais,ISNULL(@Finiquito,0)) 
                                END - isnull( DT301.ImporteTotal1,0)
						END
																				  
			END Valor
			,ISNULL(DTLocal.CantidadMonto,0) as CantidadMonto  
			,ISNULL(DTLocal.CantidadDias ,0) as CantidadDias  
			,ISNULL(DTLocal.CantidadVeces,0) as CantidadVeces  																							  
			,ISNULL(DTLocal.CantidadOtro1,0) as CantidadOtro1  																							  
			,ISNULL(DTLocal.CantidadOtro2,0) as CantidadOtro2  	
			--,Grv.Gravado	
			--,[Nomina].[fnISRSUELDOS](@IDPeriodicidadPagoMensual,(Empleados.SalarioDiario * 30.4),30.4,@Ejercicio) ISROrdinario		
			--,(Empleados.SalarioDiario * 30.4) ORdinario
			--,	 ([Nomina].[fnISRSUELDOS](@IDPeriodicidadPagoMensual,(Empleados.SalarioDiario * 30.4),30.4,@Ejercicio)/(Empleados.SalarioDiario * 30.4)) * Grv.Gravado as total																	  
		INTO #TempValores
		FROM @dtempleados Empleados
			Left Join @dtDetallePeriodoLocal DTLocal
				on Empleados.IDEmpleado = DTLocal.IDEmpleado
			left join #TempGravadoPeriodo Grv
				on Grv.IDEmpleado = Empleados.IDEmpleado
			left join #TempGravadoPeriodoTotal GrvTotal
				on GrvTotal.IDEmpleado = Empleados.IDEmpleado
			Left Join @dtDetallePeriodo DT301
				on Empleados.IDEmpleado = DT301.IDEmpleado
				and DT301.IDConcepto = @IDConcepto301
		Where isnull(Grv.Gravado,0) > 0
		/* Inicio de segmento para programar las opciones de LFT, Personalizada, Doble Paga*/
		/* @Concepto_LFT, @Concepto_Personalizada, @Concepto_ConDoblePago*/
	--	select * from #TempValores

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
 

	END

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
		isnull(ImporteTotal2,0) <> 0 )	 
END;
GO
