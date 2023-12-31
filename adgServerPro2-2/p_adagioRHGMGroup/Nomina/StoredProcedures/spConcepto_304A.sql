USE [p_adagioRHGMGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: CREDITO INFONAVIT (SIA)
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
CREATE PROC [Nomina].[spConcepto_304A]
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
		,@Codigo varchar(20) = '304a' 
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
		,@dtFechas app.dtFechas
		,@StartYear date
		,@dtVigenciaEmpleado app.dtFechasVigenciaEmpleado
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
 
	if object_id('tempdb..#tempInfonavitDataEmpleados') is not null drop table #tempInfonavitDataEmpleados
	if object_id('tempdb..#tempInfonavitFormulacionEmpleados') is not null drop table #tempInfonavitFormulacionEmpleados
	if object_id('tempdb..#tempInfonavitResultadoEmpleados') is not null drop table #tempInfonavitResultadoEmpleados

	IF( @General = 1 OR @Finiquito = 1)
	BEGIN ----- CODIGO DE CALCULO MODO SIA
		--insert into @dtFechas  
		--exec [App].[spListaFechas] @FechaIni = @FechaInicioPago, @FechaFin = @FechaFinPago  
    -- use the catalog views to generate as many rows as we need

		INSERT @dtFechas([Fecha]) 
		SELECT d
		FROM
		(
			SELECT d = DATEADD(DAY, rn - 1, @FechaInicioPago)
			FROM 
			(
			SELECT TOP (DATEDIFF(DAY, @FechaInicioPago, @FechaFinPago) +1) 
			rn = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
			FROM sys.all_objects AS s1
			CROSS JOIN sys.all_objects AS s2
			-- on my system this would support > 5 million days
			ORDER BY s1.[object_id]
			) AS x
		) AS y;


  
		--insert into @dtVigenciaEmpleado  
		--Exec [RH].[spBuscarListaFechasVigenciaEmpleado]  
		--	@dtEmpleados	= @dtEmpleados  
		--	,@Fechas		= @dtFechas  
		--	,@IDUsuario		= 1  

		if object_id('tempdb..#tempMovAfil') is not null drop table #tempMovAfil;
    
			select IDEmpleado,FechaAlta, FechaBaja,            
			 case when ((FechaBaja is not null and FechaReingreso is not null) and FechaReingreso > FechaBaja) then FechaReingreso else null end as FechaReingreso       
			 -- FechaReingreso
			  ,IDMovAfiliatorio    
			  ,Fecha
			into #tempMovAfil            
			from (select distinct tm.IDEmpleado,            
			case when(tm.IDEmpleado is not null) then (select top 1 Fecha             
						from [IMSS].[tblMovAfiliatorios]  mAlta WITH(NOLOCK)            
							join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mAlta.IDTipoMovimiento=c.IDTipoMovimiento            
						where mAlta.IDEmpleado=tm.IDEmpleado and c.Codigo='A'              
						Order By mAlta.Fecha Desc , c.Prioridad DESC ) end as FechaAlta,            
			case when (tm.IDEmpleado is not null) then (select top 1 Fecha             
						from [IMSS].[tblMovAfiliatorios]  mBaja WITH(NOLOCK)            
							join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mBaja.IDTipoMovimiento=c.IDTipoMovimiento            
						where mBaja.IDEmpleado=tm.IDEmpleado and c.Codigo='B' and mBaja.Fecha <= Fechas.Fecha             
			order by mBaja.Fecha desc, C.Prioridad desc) end as FechaBaja,            
			case when (tm.IDEmpleado is not null) then (select top 1 Fecha             
						from [IMSS].[tblMovAfiliatorios]  mReingreso WITH(NOLOCK)            
					join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mReingreso.IDTipoMovimiento=c.IDTipoMovimiento            
						where mReingreso.IDEmpleado=tm.IDEmpleado and c.Codigo='R'              
					and mReingreso.Fecha <= Fechas.Fecha             
					order by mReingreso.Fecha desc, C.Prioridad desc) end as FechaReingreso              
			,(Select top 1 mSalario.IDMovAfiliatorio from [IMSS].[tblMovAfiliatorios]  mSalario WITH(NOLOCK)            
					join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mSalario.IDTipoMovimiento=c.IDTipoMovimiento            
						where mSalario.IDEmpleado=tm.IDEmpleado and c.Codigo in ('A','M','R')             
						order by mSalario.Fecha desc ) as IDMovAfiliatorio   
			,Fechas.Fecha                                          
			from [IMSS].[tblMovAfiliatorios]  tm 
				join @dtEmpleados e on tm.IDEmpleado = e.IDEmpleado
			 ,@dtFechas Fechas
			--where tm.IDEmpleado = @IDEmpleado
			) mm    


			insert into @dtVigenciaEmpleado  
			select m.IDEmpleado, Fecha,Vigente = case when ( (M.FechaAlta<=Fecha and (M.FechaBaja>=Fecha or M.FechaBaja is null)) or (M.FechaReingreso<=Fecha)) then cast(1 as bit) else cast(0 as bit) end                           
			from #tempMovAfil M




		delete  @dtVigenciaEmpleado where Vigente = 0

		set @StartYear = cast(cast(@Ejercicio as varchar)+'-01-01' as date)     


		select distinct ve.*
				,HAI.IDInfonavitEmpleado
				,HAI.IDRegPatronal
				,HAI.NumeroCredito
				,HAI.IDTipoDescuento
				,HAI.ValorDescuento
				,HAI.AplicaDisminucion
				,HAI.FolioAviso
				--,HAI.FechaEntraVigor
				,HAI.IDTipoAvisoInfonavit
				--,HAI.FechaFinVigor
				,CASE WHEN DATEPART(MONTH,ve.Fecha) in (1,2) then   DateDiff(day,@StartYear,EOMONTH( DATEADD(MONTH,1,@StartYear)))+1    
											WHEN DATEPART(MONTH,ve.Fecha) in (3,4) then  DateDiff(day,DATEADD(MONTH,2,@StartYear),EOMONTH( DATEADD(MONTH,3,@StartYear)))+1    
											WHEN DATEPART(MONTH,ve.Fecha) in (5,6) then  DateDiff(day,DATEADD(MONTH,4,@StartYear),EOMONTH( DATEADD(MONTH,5,@StartYear)))+1    
											WHEN DATEPART(MONTH,ve.Fecha) in (7,8) then  DateDiff(day,DATEADD(MONTH,6,@StartYear),EOMONTH( DATEADD(MONTH,7,@StartYear)))+1    
											WHEN DATEPART(MONTH,ve.Fecha) in (9,10) then DateDiff(day,DATEADD(MONTH,8,@StartYear),EOMONTH( DATEADD(MONTH,9,@StartYear)))+1    
											WHEN DATEPART(MONTH,ve.Fecha) in (11,12) then  DateDiff(day,DATEADD(MONTH,10,@StartYear),EOMONTH( DATEADD(MONTH,11,@StartYear)))+1   
						else 0 END DiasBimestre,
					CASE WHEN IE.idincidenciaEmpleado is null THEN 0 ELSE 1 END Ausentismos,
					b.IDBimestre,
					(select top 1 SalarioMinimo from nomina.tblSalariosMinimos where Fecha <= ve.Fecha order by Fecha desc) SalarioMinimo,
					(select top 1 FactorDescuento from nomina.tblSalariosMinimos where Fecha <= ve.Fecha order by Fecha desc) FactorDescuento,
					emp.SalarioDiario,
					emp.SalarioIntegrado
			into #tempInfonavitDataEmpleados
			from @dtVigenciaEmpleado ve
			inner join RH.tblHistorialAvisosInfonavitEmpleado HAI
				on ve.IDEmpleado = HAI.IDEmpleado
				and VE.Fecha Between HAI.FechaEntraVigor and HAI.FechaFinVigor
			left join Asistencia.tblCatIncidencias I
				on (I.IDIncidencia <> 'I' and I.EsAusentismo = 1 and I.GoceSueldo = 0) OR(I.IDIncidencia = 'F')
			left join Asistencia.tblIncidenciaEmpleado IE
				on IE.Fecha = ve.Fecha
				and IE.IDEmpleado = ve.IDEmpleado
				and IE.Autorizado = 1
				and IE.IDIncidencia = I.IDIncidencia
			inner join Nomina.tblCatBimestres b
				on MONTH(ve.Fecha) in (select item from app.Split(b.meses,','))
			inner join @dtEmpleados emp
				on ve.IDEmpleado = emp.IDEmpleado
			where HAI.IDTipoAvisoInfonavit not  in (11,12,13,14,15)
				order by ve.Fecha

		select IDEmpleado,count(*) as DiasInfonavit
			,IDInfonavitEmpleado
			,IDRegPatronal
			,NumeroCredito
			,IDTipoDescuento
			,ValorDescuento
			,AplicaDisminucion
			,FolioAviso
			,DiasBimestre
			,SUM(Ausentismos) as Ausentismos
			,IDBimestre
			,SalarioMinimo
			,FactorDescuento
			,SalarioDiario
			,SalarioIntegrado
		into #tempInfonavitFormulacionEmpleados
		from #tempInfonavitDataEmpleados
		Group by 
			IDEmpleado
			,IDInfonavitEmpleado
			,IDRegPatronal
			,NumeroCredito
			,IDTipoDescuento
			,ValorDescuento
			,AplicaDisminucion
			,FolioAviso
			,DiasBimestre
			,IDBimestre
			,SalarioMinimo
			,FactorDescuento
			,SalarioDiario
			,SalarioIntegrado
	--select * from #tempInfonavitFormulacionEmpleados


		select 
			IDEmpleado,
			 SUM(	CASE WHEN SalarioDiario <= SalarioMinimo THEN (SalarioIntegrado * (DiasInfonavit - Ausentismos)* 0.20)
					 ELSE 
						CASE WHEN IDTipoDescuento = 3 THEN ((ValorDescuento*FactorDescuento *2)/DiasBimestre)* (DiasInfonavit - Ausentismos)
							 WHEN IDTipoDescuento = 2 THEN ((ValorDescuento/DiasBimestre)* (DiasInfonavit - Ausentismos))
							 WHEN IDTipoDescuento = 1 THEN (SalarioIntegrado * (ValorDescuento/100))* (DiasInfonavit - Ausentismos)
							 ELSE 0
							 END
				END) Valor
		into #tempInfonavitResultadoEmpleados
		from #tempInfonavitFormulacionEmpleados
		GROUP BY IDEmpleado

	END
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

	IF( @General = 1 OR @Finiquito = 1 )
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
				ELSE isnull(r.Valor,0)																		 
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
			left join #tempInfonavitResultadoEmpleados r
				on empleados.IDEmpleado = r.IDEmpleado
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
