USE [p_adagioRHElPro]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: CREDITO INFONAVIT
** Autor			: Aneudy Abreu | Jose Román,
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
CREATE PROC [Nomina].[spCoreConcepto_304]
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
		,@Codigo varchar(20) = '304' 
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
		,@SMGDF decimal(18,2)          
		,@UMA decimal(18,2)         
		,@StartYear date      
		,@FactorDescuento decimal(18,2)        
		,@DiasBismestre int    
		,@IDConceptoDiasVacaciones int    
		,@IDConceptoDiasPagados int 
		,@IDConceptoDiasVigencia int    
		,@INFONAVITREFORMA2025 bit = 0
	;

	select top 1 
		@IDPeriodo = IDPeriodo ,@IDTipoNomina= IDTipoNomina,@Ejercicio = Ejercicio,@ClavePeriodo	= ClavePeriodo,@DescripcionPeriodo =  Descripcion 
		,@FechaInicioPago = FechaInicioPago,@FechaFinPago	= FechaFinPago,@FechaInicioIncidencia = FechaInicioIncidencia,@FechaFinIncidencia=	 FechaFinIncidencia 
		,@Dias = Dias,@AnioInicio = AnioInicio,@AnioFin = AnioFin,@MesInicio = MesInicio,@MesFin = MesFin 
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin 
		,@General = General,@Finiquito = Finiquito,@Especial = Especial,@Cerrado = Cerrado 
	from @dtPeriodo 
 
	SELECT @INFONAVITREFORMA2025 = CAST(ISNULL(Valor,'0') as bit) FROM Nomina.tblConfiguracionNomina where Configuracion = 'INFONAVITREFORMA2025'

	select top 1 @IDConcepto=IDConcepto from @dtConceptos where Codigo=@Codigo; 
	select top 1 @IDConceptoDiasPagados=IDConcepto from @dtConceptos where Codigo='005';      
	select top 1 @IDConceptoDiasVacaciones=IDConcepto from @dtConceptos where Codigo='002';      
	select top 1 @IDConceptoDiasVigencia=IDConcepto from @dtConceptos where Codigo='001';      
         
	set @StartYear = cast(cast(@Ejercicio as varchar)+'-01-01' as date)       
      
	
	select @DiasBismestre = CASE WHEN DATEPART(MONTH,@FechaInicioPago) in (1,2) then   DateDiff(day,@StartYear,EOMONTH( DATEADD(MONTH,1,@StartYear)))+1    
								WHEN DATEPART(MONTH,@FechaInicioPago) in (3,4) then  DateDiff(day,DATEADD(MONTH,2,@StartYear),EOMONTH( DATEADD(MONTH,3,@StartYear)))+1    
								WHEN DATEPART(MONTH,@FechaInicioPago) in (5,6) then  DateDiff(day,DATEADD(MONTH,4,@StartYear),EOMONTH( DATEADD(MONTH,5,@StartYear)))+1    
								WHEN DATEPART(MONTH,@FechaInicioPago) in (7,8) then  DateDiff(day,DATEADD(MONTH,6,@StartYear),EOMONTH( DATEADD(MONTH,7,@StartYear)))+1    
								WHEN DATEPART(MONTH,@FechaInicioPago) in (9,10) then DateDiff(day,DATEADD(MONTH,8,@StartYear),EOMONTH( DATEADD(MONTH,9,@StartYear)))+1    
								WHEN DATEPART(MONTH,@FechaInicioPago) in (11,12) then  DateDiff(day,DATEADD(MONTH,10,@StartYear),EOMONTH( DATEADD(MONTH,11,@StartYear)))+1   
							else 0 END 

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

	--IF object_ID('TEMPDB..#TempDetalle') IS NOT NULL DROP TABLE #TempDetalle  
     
	--CREATE TABLE #TempDetalle(  
	--	IDEmpleado int,  
	--	IDPeriodo int,  
	--	IDConcepto int,  
	--	CantidadDias Decimal(18,2) null,  
	--	CantidadMonto Decimal(18,2) null,  
	--	CantidadVeces Decimal(18,2) null,  
	--	CantidadOtro1 Decimal(18,2) null,  
	--	CantidadOtro2 Decimal(18,2) null,  
	--	ImporteGravado Decimal(18,2) null,  
	--	ImporteExcento Decimal(18,2) null,  
	--	ImporteTotal1 Decimal(18,2) null,  
	--	ImporteTotal2 Decimal(18,2) null,  
	--	Descripcion varchar(255) null,  
	--	IDReferencia int null  
	--);
 
	IF(@General = 1 Or @Finiquito =1)
	BEGIN
		select TOP 1  @SMGDF = SalarioMinimo, @UMA = UMA , @FactorDescuento = FactorDescuento          
		from Nomina.tblSalariosMinimos          
		WHERE DATEPART(YEAR, Fecha) = @Ejercicio          
		ORDER BY Fecha DESC          
          
		if object_id('tempdb..#tempCreditoInfonavit') is not null drop table #tempCreditoInfonavit;           
		if object_id('tempdb..#tempCreditoInfonavitSUM') is not null drop table #tempCreditoInfonavitSUM;  
	--	IF object_ID('TEMPDB..#TempValores') IS NOT NULL DROP TABLE #TempValores
 
		Select           
			IE.IDInfonavitEmpleado          
			,IE.IDEmpleado          
			,E.ClaveEmpleado          
			,substring(UPPER(COALESCE(E.Paterno,'')+' '+COALESCE(E.Materno,'')+', '+COALESCE(E.Nombre,'')+' '+COALESCE(E.SegundoNombre,'')),1,49 ) AS NOMBRECOMPLETO          
			,IE.IDTipoDescuento          
			,TD.Descripcion as TipoDescuento          
			,IE.NumeroCredito          
			,IE.ValorDescuento          
			,IE.IDTipoMovimiento           
			,TM.Descripcion as TipoMovimiento           
			,case when isnull(dp.CantidadOtro2,0)=-1 THEN 0   
				ELSE 
						CASE WHEN ISNULL(@INFONAVITREFORMA2025,0) = 0 THEN
								CASE WHEN isnull(dp.CantidadMonto,0)>0 then isnull(dp.CantidadMonto,0)          
									WHEN TD.Codigo = '1' THEN ((((E.SalarioIntegrado * (IE.ValorDescuento/100)) *(ISNULL(dpDiasPagados.ImporteTotal1,0)+isnull(dpVacaciones.ImporteTotal1,0)) )))        
									WHEN TD.Codigo = '2' THEN (((((IE.ValorDescuento) / 30)) *(ISNULL(dpDiasPagados.ImporteTotal1,0)+isnull(dpVacaciones.ImporteTotal1,0))) )           
									WHEN TD.Codigo = '3' THEN  (((((@FactorDescuento * IE.ValorDescuento))/ 30 ) *(ISNULL(dpDiasPagados.ImporteTotal1,0)+isnull(dpVacaciones.ImporteTotal1,0))))            
								ELSE 0          
								END 
							ELSE
								CASE WHEN isnull(dp.CantidadMonto,0)>0 then isnull(dp.CantidadMonto,0)          
									WHEN TD.Codigo = '1' THEN ((((E.SalarioIntegrado * (IE.ValorDescuento/100)) *(ISNULL(dpDiasVigencia.ImporteTotal1,0)) )))        
									WHEN TD.Codigo = '2' THEN (((((IE.ValorDescuento) / 30)) *(ISNULL(dpDiasVigencia.ImporteTotal1,0))) )           
									WHEN TD.Codigo = '3' THEN  (((((@FactorDescuento * IE.ValorDescuento))/ 30 ) *(ISNULL(dpDiasVigencia.ImporteTotal1,0))))            
								ELSE 0          
								END 
							END
			 END as Descuento          
			,@IDPeriodo as IDPeriodo   
			,ISNULL(dp.CantidadMonto,0)CantidadMonto  
			,ISNULL(dp.CantidadDias,0)CantidadDias  
			,ISNULL(dp.CantidadVeces,0)CantidadVeces  
			,ISNULL(dp.CantidadOtro1,0)CantidadOtro1  
			,ISNULL(dp.CantidadOtro2,0)CantidadOtro2  
		into #tempCreditoInfonavit           
		from RH.tblInfonavitEmpleado IE          
			INNER JOIN RH.tblCatInfonavitTipoMovimiento TM 
				on IE.IDTipoMovimiento =  TM.IDTipoMovimiento        
			INNER JOIN RH.tblCatInfonavitTipoDescuento TD 
				on TD.IDTipoDescuento = IE.IDTipoDescuento        
			INNER JOIN @dtempleados E 
				on E.IDEmpleado = IE.IDEmpleado          
			LEFT JOIN @dtDetallePeriodoLocal dp 
				on dp.IDEmpleado = E.IDEmpleado          
				and dp.IDConcepto = @IDConcepto 
			LEFT JOIN @dtDetallePeriodo dpVacaciones  
				on dpVacaciones.IDEmpleado = e.IDEmpleado and dpVacaciones.IDConcepto = @IDConceptoDiasVacaciones  
				and dpVacaciones.IDPeriodo =  @IDPeriodo  
			LEFT JOIN @dtDetallePeriodo dpDiasPagados  
				on dpDiasPagados.IDEmpleado = e.IDEmpleado and dpDiasPagados.IDConcepto = @IDConceptoDiasPagados  
				and dpDiasPagados.IDPeriodo = @IDPeriodo
			LEFT JOIN @dtDetallePeriodo dpDiasVigencia  
				on dpDiasVigencia.IDEmpleado = e.IDEmpleado and dpDiasVigencia.IDConcepto = @IDConceptoDiasVigencia  
				and dpDiasVigencia.IDPeriodo = @IDPeriodo  
			WHERE TM.Codigo NOT IN ('16')          
         
           
		select t.IDEmpleado    
			,STUFF((    
				SELECT ', Credito ' + [NumeroCredito] + ': $' + CAST(Descuento AS VARCHAR(MAX))     
				FROM #tempCreditoInfonavit     
				WHERE (IDEmpleado = t.IDEmpleado)     
				FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')    
				,1,2,'') AS Creditos    
			,IDPeriodo    
			,SUM(Descuento) Descuento   
			,ISNULL(CantidadMonto,0)CantidadMonto  
			,ISNULL(CantidadDias,0)CantidadDias  
			,ISNULL(CantidadVeces,0)CantidadVeces  
			,ISNULL(CantidadOtro1,0)CantidadOtro1  
			,ISNULL(CantidadOtro2,0)CantidadOtro2 
			, IDInfonavitEmpleado
		into #tempCreditoInfonavitSUM    
		from #tempCreditoInfonavit t         
		GROUP BY t.IDEmpleado, t.IDPeriodo    
			,ISNULL(CantidadMonto,0)  
			,ISNULL(CantidadDias,0)  
			,ISNULL(CantidadVeces,0)  
			,ISNULL(CantidadOtro1,0)  
			,ISNULL(CantidadOtro2,0)  
			,IDInfonavitEmpleado 

		--SELECT * FROM #tempCreditoInfonavitSUM
		MERGE @dtDetallePeriodoLocal AS TARGET          
		USING #tempCreditoInfonavitSUM AS SOURCE          
			ON TARGET.IDPeriodo = SOURCE.IDPeriodo          
			and TARGET.IDConcepto = @IDConcepto          
			and TARGET.IDEmpleado = SOURCE.IDEmpleado
			and TARGET.IDReferencia = SOURCE.IDInfonavitEmpleado
		WHEN MATCHED Then          
		update Set               
			TARGET.ImporteTotal1  = SOURCE.Descuento          
			,TARGET.ImporteGravado  = 0.00   
			,TARGET.CantidadMonto   = SOURCE.CantidadMonto      
			,TARGET.CantidadDias    = SOURCE.CantidadDias      
			,TARGET.CantidadVeces   = SOURCE.CantidadVeces     
			,TARGET.CantidadOtro1   = SOURCE.CantidadOtro1     
			,TARGET.CantidadOtro2   = SOURCE.CantidadOtro2     
			,TARGET.IDReferencia = SOURCE.IDInfonavitEmpleado          
			,TARGET.Descripcion = SOURCE.Creditos          
              
		WHEN NOT MATCHED BY TARGET THEN           
		INSERT(IDEmpleado,IDPeriodo,IDConcepto,ImporteGravado,ImporteTotal1,Descripcion,  
			CantidadMonto,CantidadDias ,CantidadVeces,CantidadOtro1,CantidadOtro2 , IDReferencia)          
		VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,@IDConcepto,0.00,Source.Descuento,SOURCE.Creditos,  
			SOURCE.CantidadMonto ,SOURCE.CantidadDias  ,SOURCE.CantidadVeces  ,SOURCE.CantidadOtro1  ,SOURCE.CantidadOtro2,  SOURCE.IDInfonavitEmpleado)          
		WHEN NOT MATCHED BY SOURCE THEN           
		DELETE;          

		--SELECT
		--	Empleados.IDEmpleado,
		--	@IDPeriodo as IDPeriodo,
		--	@Concepto_IDConcepto as IDConcepto,
		--	CASE WHEN @Concepto_bCantidadMonto  = 1 and ISNULL(DTLocal.CantidadMonto,0) > 0 THEN ISNULL(DTLocal.CantidadMonto,0)		  
		--				WHEN @Concepto_bCantidadDias  = 1 and ISNULL(DTLocal.CantidadDias,0)  > 0 THEN ISNULL(DTLocal.CantidadDias,0)	  
		--				WHEN @Concepto_bCantidadVeces = 1 and ISNULL(DTLocal.CantidadVeces,0) > 0 THEN ISNULL(DTLocal.CantidadVeces,0)	  
		--				WHEN @Concepto_bCantidadOtro1 = 1 and ISNULL(DTLocal.CantidadOtro1,0) > 0 THEN ISNULL(DTLocal.CantidadOtro1,0)	  
		--				WHEN @Concepto_bCantidadOtro2 = 1 and ISNULL(DTLocal.CantidadOtro2,0) > 0 THEN ISNULL(DTLocal.CantidadOtro2,0)	  
		--		ELSE 0 -- Función personalizada																			  
		--		END Valor
		--	,ISNULL(DTLocal.CantidadMonto,0) as CantidadMonto  
		--	,ISNULL(DTLocal.CantidadDias ,0) as CantidadDias  
		--	,ISNULL(DTLocal.CantidadVeces,0) as CantidadVeces  																							  
		--	,ISNULL(DTLocal.CantidadOtro1,0) as CantidadOtro1  																							  
		--	,ISNULL(DTLocal.CantidadOtro2,0) as CantidadOtro2  																							  
		--INTO #TempValores
		--FROM @dtempleados Empleados
		--	Left Join @dtDetallePeriodoLocal DTLocal
		--		on Empleados.IDEmpleado = DTLocal.IDEmpleado
 
 
		/* Inicio de segmento para programar las opciones de LFT, Personalizada, Doble Paga*/
		/* @Concepto_LFT, @Concepto_Personalizada, @Concepto_ConDoblePago*/
		
		/*IF(ISNULL(@Concepto_LFT,0) = 1)  
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
				Descripcion = '',  
				IDReferencia = NULL  
			FROM #TempValores  
		END*/

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
 
	Select * from @dtDetallePeriodoLocal  
 	where 
		(isnull(CantidadMonto,0) <> 0 OR		 
		isnull(CantidadDias,0)  <> 0 OR		 
		isnull(CantidadVeces,0) <> 0 OR		 
		isnull(CantidadOtro1,0) <> 0 OR		 
		isnull(CantidadOtro2,0) <> 0 OR		 
		isnull(ImporteGravado,0) <> 0 OR		 
		isnull(ImporteExcento,0) <> 0 OR		 
		isnull(ImporteOtro,0) <> 0 OR		 
		isnull(ImporteTotal1,0) <> 0 OR		 
		isnull(ImporteTotal2,0) <> 0  )  
END;
GO
