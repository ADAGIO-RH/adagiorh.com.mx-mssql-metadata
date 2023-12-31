USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: DIAS PAGADOS
** Autor			: Aneudy Abreu | Jose Román,
** Email			: aneudy.abreu@adagio.com.mx | jose.roman@adagio.com.mx
** FechaCreacion	: 2019-08-12
** Paremetros		:              
** Versión 1 

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
CREATE PROC [Nomina].[spConcepto_005]
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
		,@Codigo varchar(20) = '005' 
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
		,@IDConcepto001 int  /*Días de vigencia*/  
        ,@IDConcepto004 int  /*Días de Ausentismo*/  
        ,@IDConcepto003 int  /*Días de Incapacidad*/  
        ,@IDConcepto002 int  /*Días de Vacaciones*/  
        ,@isPreviewFiniquito bit
        ,@PeriodicidadPago Varchar(100)
	;

	select top 1 
		@IDPeriodo = IDPeriodo ,@IDTipoNomina= IDTipoNomina,@Ejercicio = Ejercicio,@ClavePeriodo	= ClavePeriodo,@DescripcionPeriodo =  Descripcion 
		,@FechaInicioPago = FechaInicioPago,@FechaFinPago	= FechaFinPago,@FechaInicioIncidencia = FechaInicioIncidencia,@FechaFinIncidencia=	 FechaFinIncidencia 
		,@Dias = Dias,@AnioInicio = AnioInicio,@AnioFin = AnioFin,@MesInicio = MesInicio,@MesFin = MesFin 
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin 
		,@General = General,@Finiquito = Finiquito,@Especial = Especial,@Cerrado = Cerrado 
	from @dtPeriodo 
 
	select top 1 @IDConcepto=IDConcepto from @dtConceptos where Codigo=@Codigo; 
 
    select @IDConcepto001=IDConcepto from @dtConceptos where Codigo = '001'  
    select @IDConcepto004=IDConcepto from @dtConceptos where Codigo = '004'  
    select @IDConcepto003=IDConcepto from @dtConceptos where Codigo = '003'  
    select @IDConcepto002=IDConcepto from @dtConceptos where Codigo = '002'  
 
    select top 1 @isPreviewFiniquito = cast(isnull(valor,0) as bit) from @dtconfigs
    where Configuracion = 'isPreviewFiniquito'
 	select @PeriodicidadPago = PP.Descripcion from Nomina.tblCatTipoNomina TN
		Inner join [Sat].[tblCatPeriodicidadesPago] PP
			on TN.IDPEriodicidadPAgo = PP.IDPeriodicidadPago
	Where TN.IDTipoNomina = @IDTipoNomina

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
				and TipoMovimiento.Codigo <>'M' and m.Fecha <= @FechaFinIncidencia  

		delete from #TempMovimientos where [Row] <> 1

		IF object_ID('tempdb..#TempFechasHabiles') IS NOT NULL DROP TABLE #TempFechasHabiles;  

		select Movimientos.IDEmpleado
			,FechaInicio =CASE  WHEN ( Movimientos.Fecha between @FechaInicioIncidencia and @FechaFinIncidencia) AND (Movimientos.Codigo = 'A' OR Movimientos.Codigo = 'R') THEN Movimientos.Fecha
				--WHEN ( Movimientos.Fecha between @FechaInicioIncidencia and @FechaFinIncidencia) AND (Movimientos.Codigo = 'B') THEN @FechaInicioIncidencia
				--WHEN ( Movimientos.Fecha <= @FechaInicioIncidencia) AND (Movimientos.Codigo = 'A' OR Movimientos.Codigo = 'R') THEN @FechaInicioIncidencia
				ELSE @FechaInicioIncidencia  
				END  
			,FechaFin =CASE WHEN ( Movimientos.Fecha between @FechaInicioIncidencia and @FechaFinIncidencia) AND (Movimientos.Codigo = 'B') THEN Movimientos.Fecha
				--WHEN ( Movimientos.Fecha between @FechaInicioIncidencia and @FechaFinIncidencia) AND (Movimientos.Codigo = 'A' OR Movimientos.Codigo = 'R') THEN Movimientos.Fecha
				--WHEN ( Movimientos.Fecha <= @FechaInicioIncidencia) AND (Movimientos.Codigo = 'A' OR Movimientos.Codigo = 'R') THEN @FechaInicioIncidencia
				ELSE @FechaFinIncidencia  
				END  
		INTO #TempFechasHabiles
		from #TempMovimientos Movimientos
	END;


		IF object_ID('TEMPDB..#TempDescanso') IS NOT NULL  
		DROP TABLE #TempDescanso
		

		select ie.IDEmpleado, COUNT(*) Qty
			into #TempDescanso
		from Asistencia.tblIncidenciaEmpleado ie
			join @dtempleados Empleados on ie.IDEmpleado = Empleados.IDEmpleado
			inner join #TempFechasHabiles fechas on fechas.IDEmpleado = Empleados.IDEmpleado
		
		where ie.IDIncidencia = 'D' and ie.Fecha between fechas.FechaInicio and fechas.FechaFin   
		  AND IE.Autorizado = 1
		GROUP BY ie.IDEmpleado


		IF object_ID('TEMPDB..#TempPermisosConGoce') IS NOT NULL DROP TABLE #TempPermisosConGoce;

		select e.IDEmpleado, CAST (COUNT(*) as decimal (18,4)) as qty   
			into #TempPermisosConGoce  
		From @dtempleados e
				inner join Asistencia.tblIncidenciaEmpleado IE on e.IDEmpleado = ie.IDEmpleado
				inner join #TempFechasHabiles fechas on fechas.IDEmpleado = e.IDEmpleado
		Where IE.IDIncidencia IN ( 'DE','G','M','N')
			AND IE.Fecha Between fechas.FechaInicio and fechas.FechaFin      
			AND IE.Autorizado = 1   
		GROUP BY e.IDEmpleado

 
	/* Inicio de segmento para programar el cuerpo del concepto*/
 IF object_ID('TEMPDB..#TempValores') IS NOT NULL DROP TABLE #TempValores

	IF(@General = 1 OR @Finiquito = 1)
	BEGIN
		
 
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
						CASE WHEN @isPreviewFiniquito = 0 THEN
							 CASE WHEN @PeriodicidadPago = 'Semanal' THEN 
								  case when isnull(DTVigencia.ImporteTotal1,0) > 0 THEN
									   case when ((isnull(DTVigencia.ImporteTotal1,0)) < (isnull(DTA.ImporteTotal1,0) + isnull(PermisosConGoce.qty,0) + isnull(DTI.ImporteTotal1,0)+isnull(DTV.ImporteTotal1,0))) THEN 0 
											when isnull(DTVigencia.ImporteTotal1,0) = 6 then isnull(DTVigencia.ImporteTotal1,0)  -((isnull(DTA.ImporteTotal1,0) + isnull(PermisosConGoce.qty,0) + isnull(DTI.ImporteTotal1,0)+isnull(DTV.ImporteTotal1,0)) +1) -- ESTO SE AGREGO
											--when isnull(DTVigencia.ImporteTotal1,0) < 7 then isnull(DTVigencia.ImporteTotal1,0) - -((isnull(DTA.ImporteTotal1,0) + isnull(PermisosConGoce.qty,0) + isnull(DTI.ImporteTotal1,0)+isnull(DTV.ImporteTotal1,0)) - 2) 
											when isnull(DTVigencia.ImporteTotal1,0) < @Dias THEN (isnull(DTVigencia.ImporteTotal1,0)) - (isnull(DTV.ImporteTotal1,0) + isnull(PermisosConGoce.qty,0) + case when (isnull(DTA.ImporteTotal1,0) + isnull(DTI.ImporteTotal1,0)) > 0 THEN
											((isnull(DTA.ImporteTotal1,0) + isnull(DTI.ImporteTotal1,0)) / 1.4) ELSE 0 END
											) 
											when isnull(DTVigencia.ImporteTotal1,0) > @Dias THEN (isnull(@Dias,0)) - (isnull(DTV.ImporteTotal1,0) + isnull(PermisosConGoce.qty,0) + case when (isnull(DTA.ImporteTotal1,0) + isnull(DTI.ImporteTotal1,0)) > 0 THEN
											((isnull(DTA.ImporteTotal1,0) + isnull(DTI.ImporteTotal1,0)) / 1.4) ELSE 0 END
											)
									   else ((isnull(DTVigencia.ImporteTotal1,0)) )-((isnull(DTA.ImporteTotal1,0) + isnull(PermisosConGoce.qty,0) + isnull(DTI.ImporteTotal1,0)+isnull(DTV.ImporteTotal1,0))) 
									   END
									ELSE 0 
									END
						ELSE
							          case when ((isnull(DTVigencia.ImporteTotal1,0))<(isnull(DTA.ImporteTotal1,0) + isnull(PermisosConGoce.qty,0) + isnull(DTI.ImporteTotal1,0)+isnull(DTV.ImporteTotal1,0))) THEN 0 
							               else ((isnull(DTVigencia.ImporteTotal1,0)))-((isnull(DTA.ImporteTotal1,0) + isnull(PermisosConGoce.qty,0) + isnull(DTI.ImporteTotal1,0)+isnull(DTV.ImporteTotal1,0))) 
							          END
						          END                 
				       ELSE ISNULL(cf.DiasDePago,0)
				       END
			       END  
		  END  Valor,  
			ISNULL(DTLocal.CantidadMonto,0) as CantidadMonto  
		   ,ISNULL(DTLocal.CantidadDias ,0) as CantidadDias  
		   ,ISNULL(DTLocal.CantidadVeces,0) as CantidadVeces  
		   ,CASE WHEN ((isnull(DTLocal.CantidadOtro2,0) = -1) ) THEN 0  
			ELSE  
		   CASE WHEN @Concepto_bCantidadMonto  = 1 and ISNULL(DTLocal.CantidadMonto,0) > 0 THEN ISNULL(DTLocal.CantidadMonto,0)      
			  WHEN @Concepto_bCantidadDias  = 1 and ISNULL(DTLocal.CantidadDias,0)  > 0 THEN ISNULL(DTLocal.CantidadDias,0)     
			  WHEN @Concepto_bCantidadVeces = 1 and ISNULL(DTLocal.CantidadVeces,0) > 0 THEN ISNULL(DTLocal.CantidadVeces,0)     
			  WHEN @Concepto_bCantidadOtro1 = 1 and ISNULL(DTLocal.CantidadOtro1,0) > 0 THEN ISNULL(DTLocal.CantidadOtro1,0)     
			  WHEN @Concepto_bCantidadOtro2 = 1 and ISNULL(DTLocal.CantidadOtro2,0) > 0 THEN ISNULL(DTLocal.CantidadOtro2,0)     
			 ELSE 
				CASE WHEN @isPreviewFiniquito = 0 THEN
					case when ((isnull(DTVigencia.ImporteTotal1,0))<(isnull(DTA.ImporteTotal1,0) + isnull(PermisosConGoce.qty,0) + isnull(DTI.ImporteTotal1,0) + isnull(DTV.ImporteTotal1,0))) THEN 0 
					when isnull(DTVigencia.ImporteTotal1,0) < @Dias THEN  ((isnull(DTVigencia.ImporteTotal1,0)) )-((isnull(DTA.ImporteTotal1,0) + isnull(PermisosConGoce.qty,0) + isnull(DTI.ImporteTotal1,0)+isnull(DTV.ImporteTotal1,0) + isnull(d.Qty,0)))
					when isnull(DTVigencia.ImporteTotal1,0) > @Dias THEN  ((isnull(@Dias,0)) )-((isnull(DTA.ImporteTotal1,0) + isnull(PermisosConGoce.qty,0) + isnull(DTI.ImporteTotal1,0)+isnull(DTV.ImporteTotal1,0) ))
						else    ((isnull(DTVigencia.ImporteTotal1,0)))-((isnull(DTA.ImporteTotal1,0) + isnull(PermisosConGoce.qty,0) + isnull(DTI.ImporteTotal1,0)+isnull(DTV.ImporteTotal1,0))) 
						END                 
				ELSE ISNULL(cf.DiasDePago,0)
				END                
			 END  
			END as CantidadOtro1  
		   ,ISNULL(DTLocal.CantidadOtro2,0) as CantidadOtro2                            
		  INTO #TempValores  
		  FROM @dtempleados Empleados  
			left join @dtDetallePeriodo DTVigencia  
				on DTVigencia.IDEmpleado = Empleados.IDEmpleado  
					and DTVigencia.IDConcepto = @IDConcepto001  
					and DTVigencia.IDPeriodo = @IDPeriodo  
			left join @dtDetallePeriodo DTI  
				on DTI.IDEmpleado = Empleados.IDEmpleado  
					and DTI.IDConcepto = @IDConcepto003  
					and DTI.IDPeriodo = @IDPeriodo    
			left join @dtDetallePeriodo DTV  
				on DTV.IDEmpleado = Empleados.IDEmpleado  
					and DTV.IDConcepto = @IDConcepto002  
					and DTV.IDPeriodo = @IDPeriodo 
			left join @dtDetallePeriodo DTA  
				on DTA.IDEmpleado = Empleados.IDEmpleado  
					and DTA.IDConcepto = @IDConcepto004  
					and DTA.IDPeriodo = @IDPeriodo
			left join Nomina.tblControlFiniquitos cf
				on cf.IDPeriodo = @IDPeriodo
					and cf.IDEmpleado = Empleados.IDEmpleado 
			left join @dtDetallePeriodoLocal DTLocal  
				on DTLocal.IDEmpleado = Empleados.IDEmpleado 
			left join #TempDescanso D
				on D.IDEmpleado = Empleados.IDEmpleado
			left join #TempPermisosConGoce PermisosConGoce
				on PermisosConGoce.IDEmpleado = Empleados.IDEmpleado

 
 
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
				TARGET.CantidadMonto = SOURCE.CantidadMonto,
				TARGET.CantidadDias = SOURCE.CantidadDias,
				TARGET.CantidadVeces = SOURCE.CantidadVeces,
				TARGET.CantidadOtro1 = SOURCE.CantidadOtro1,
				TARGET.CantidadOtro2 = SOURCE.CantidadOtro2


		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(IDEmpleado,IDPeriodo,IDConcepto,ImporteTotal1,CantidadMonto,CantidadDias,CantidadVeces,CantidadOtro1,CantidadOtro2)
			VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,@Concepto_IDConcepto,Source.Valor,Source.CantidadMonto,Source.CantidadDias, Source.CantidadVeces,Source.CantidadOtro1,Source.CantidadOtro2)
		WHEN NOT MATCHED BY SOURCE THEN 
			DELETE;
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
