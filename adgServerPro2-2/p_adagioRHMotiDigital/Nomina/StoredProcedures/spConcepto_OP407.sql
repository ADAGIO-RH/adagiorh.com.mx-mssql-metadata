USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: HORAS FESTIVO LABORADO TRIPLE
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
CREATE PROC [Nomina].[spConcepto_OP407]
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
		,@Codigo varchar(20) = 'OP407' 
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

	IF object_ID('TEMPDB..#TempIncidencia') IS NOT NULL
		DROP TABLE #TempIncidencia

	-- Domingo = 1, Lunes =2, Martes = 3, Miércoles = 4, Jueves = 5, Viernes 6, Sábado = 7

	declare @table table ( ID int NOT NULL identity (1,1)
						,IDEmpleado int
						,Fecha date
						,Horas float
						,Dia int
						,Semana int
					) 
	insert into @table (IDEmpleado,Fecha,Horas,Dia,Semana)
	select 
		IE.IDEmpleado,
		IE.Fecha,
		DATEPART(HOUR,IE.TiempoAutorizado) as Horas, 
		DATEPART(dw,Fecha) as Dia,
		CASE WHEN IE.Fecha between @FechaInicioIncidencia and DATEADD(DAY,6,@FechaInicioIncidencia) THEN 1 
			WHEN IE.Fecha between DATEADD(DAY,7,@FechaInicioIncidencia) and DATEADD(DAY,13,@FechaInicioIncidencia) THEN 2
			ELSE 3
			END as Semana
	 From @dtempleados e
		inner join Asistencia.tblIncidenciaEmpleado IE on e.IDEmpleado = ie.IDEmpleado
		inner join #TempFechasHabiles fechas on fechas.IDEmpleado = e.IDEmpleado
	 Where  IE.Autorizado = 1  
			AND IE.IDIncidencia = 'DF' 
			AND IE.Fecha Between fechas.FechaInicio and fechas.FechaFin     

	declare @TiemposExtras table( ID int NOT NULL identity (1,1)
						,IDEmpleado int
						,Sem1 float 
						,Sem2 float
						,Sem3 float
						,domingo float
						,SueldoTotal float
					)

	insert into @TiemposExtras(IDEmpleado, sem1, sem2, sem3, domingo,SueldoTotal)
	select e.IDEmpleado, 0.00 as sem1, 0.00 as sem2, 0.00 as sem3, 0.0 as domingo
		,CAST(((CAST(isnull(DEE.Valor,0) as decimal (18,2)) /30.00) + SalarioDiarioReal)  / 8.00 as decimal(18,2))--SalarioDiarioReal (Complemento + Fiscal) + Optimo mensual / 30 / 8
		from @dtempleados e
			left join rh.tblDatosExtraEmpleados DEE
				on DEE.IDEmpleado = e.IDEmpleado and DEE.IDDatoExtra = 6
			--where DEE.IDDatoExtra = 6 --OPTIMO_MENSUAL
	
	declare @count int = ( select count (*) from @table )
			,@ID int
			,@DIA int 
			,@SEMANA int 
			,@Empleado int
			,@Sem1 int = 0
			,@Sem2 int = 0
			,@Sem3 int = 0
			,@domingo int = 0
			,@Horas float
			,@Fecha date
		;
	while @count > 0
	begin
		set @ID = ( select top(1) ID from @table  )
		set @DIA = ( select top(1) Dia from @table  )
		set @SEMANA = ( select top(1) Semana from @table  )
		set @Empleado = ( select top(1) IDEmpleado from @table  )
		set @Horas = (select Horas from @table where ID = @ID)
		set @Fecha = (select Fecha from @table where ID = @ID)

		
		select 
			@sem1 = TE.sem1
			,@Sem2 = TE.Sem2
			,@Sem3 = TE.Sem3
			,@domingo = TE.domingo
			from @table t
				inner join @TiemposExtras TE
					on TE.IDEmpleado = t.IDEmpleado
			where t.ID = @ID

		set @domingo = CASE WHEN @Horas > 8 THEN @domingo + @Horas - 8 ELSE @domingo END
	
		--if @dia <> 1 --Domingo
		--begin
		--	set @sem1 = CASE WHEN @SEMANA = 1 then @sem1 + @horas ELSE @Sem1 END
		--	set @Sem2 = CASE WHEN @SEMANA = 2 then @sem2 + @horas ELSE @Sem2 END
		--	set @sem3 = CASE WHEN @SEMANA = 3 then @sem3 + @horas ELSE @Sem3 END
		--	--set @sem2 = CASE WHEN @SEMANA = 2 then CASE WHEN @sem2 + @horas <= 9 then @sem2 + @Horas ELSE 9 END ELSE @sem2 END
		--	--set @sem3 = CASE WHEN @SEMANA = 3 then CASE WHEN @sem3 + @horas <= 9 then @sem3 + @Horas ELSE 9 END ELSE @Sem3 END
		--end
		--else
		--begin
		--	if exists (select Fecha from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'DL' and Fecha = @Fecha and Autorizado = 1 and IDEmpleado = @Empleado)
		--	begin
		--		set @domingo = @domingo + @Horas
		--	end	
		--end

		update @TiemposExtras
				set Sem1 = @Sem1
					,Sem2 = @Sem2
					,Sem3 = @Sem3
					,Domingo = @Domingo
				where IDEmpleado = @Empleado

		delete @table where ID = @ID
		set @count = ( select count (*) from @table  )
	end

	update @TiemposExtras
			set  Sem1 = CASE WHEN Sem1 > 9 THEN Sem1 - 9 ELSE 0 END
				,Sem2 = CASE WHEN Sem2 > 9 THEN Sem2 - 9 ELSE 0 END
				,Sem3 = CASE WHEN Sem3 > 9 THEN Sem3 - 9 ELSE 0 END
 
	
 
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
	IF( @General=1 or @DescripcionPeriodo Like '%OPTIMO%' or @DescripcionPeriodo like '%TIEMPO EXTRA%')
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
				CASE WHEN (
				/*Asi funcionaba a la fecha 10 de Febrero del 2025*/
							--(@DescripcionPeriodo Like '%OPTIM%' and isnull ( Empleados.iDSucursal , 0 ) = 3) or 
							--(@DescripcionPeriodo like '%EXTR%' and ( isnull ( Empleados.iDSucursal , 0 ) = 1 or isnull ( Empleados.iDSucursal , 0 ) = 2 ))
							(@DescripcionPeriodo like '%EXTR%' and ( isnull ( Empleados.iDSucursal , 0 ) in (1,2,3)
							))) THEN
								(TE.domingo) -- Función personalizada	
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
			left join @TiemposExtras TE
				on TE.IDEmpleado = Empleados.IDEmpleado
		/* Inicio de segmento para programar las opciones de LFT, Personalizada, Doble Paga*/
		/* @Concepto_LFT, @Concepto_Personalizada, @Concepto_ConDoblePago*/
		
		IF(ISNULL(@Concepto_LFT,0) = 1)
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
