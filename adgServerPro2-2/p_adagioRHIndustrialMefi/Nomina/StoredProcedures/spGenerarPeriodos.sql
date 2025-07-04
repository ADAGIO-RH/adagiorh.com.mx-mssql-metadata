USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spGenerarPeriodos] --19,2018,0,1,'2018-07-02',0,1,0,0
(
	@IDTipoNomina int,
	@Ejercicio int,
	@DiasDesfaceINC int,
	@PeriodosEstrictos bit,
	@FechaGenera date,
	@General bit,
	@Finiquito bit,
	@Especial bit,
	@Presupuesto bit,
	@IDUsuario int
)
AS
BEGIN

	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spGenerarPeriodos]',
		@Tabla		varchar(max) = '[Nomina].[tblCatPeriodos]',
		@Accion		varchar(20)	= 'GENERACIÓN DE PERIODOS',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;

	select @NewJSON = a.JSON
	from (
		select 
			 @IDTipoNomina		as IDTipoNomina		
			,@Ejercicio			as Ejercicio			
			,@DiasDesfaceINC	as DiasDesfaceINC			
			,@PeriodosEstrictos	as PeriodosEstrictos	
			,@FechaGenera		as FechaGenera		
			,@General			as General			
			,@Finiquito			as Finiquito			
			,@Especial			as Especial		
			,@Presupuesto		as Presupuesto
	) b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
		,@Mensaje		= @Mensaje
		,@InformacionExtra		= @InformacionExtra

	DECLARE 
		--@IDTipoNomina int,
		@TipoNomina Varchar(50),
		@IDPeriodicidadPago int,
		@EjercicioTexto int,
		@Perioricidad Varchar(50),
		@FechaInicio Date,
		@FechaFin Date,
		--@DiasDesfaceINC int,
		@DiasPeriodo int,
		@IDCliente Varchar
		--@PeriodosEstrictos bit,
		--@FechaGenera date

	IF(@Finiquito = 1)
	BEGIN
		set @EjercicioTexto = cast(SUBSTRING(cast(@Ejercicio as varchar),3,LEN(cast(@Ejercicio as varchar))-2)as int)
		select @EjercicioTexto
	END
	ELSE
	BEGIN
		set @EjercicioTexto = @Ejercicio
	END

	--set @IDTipoNomina = 12
	--set @DiasDesfaceINC = 0
	--set @Ejercicio = 2017
	--set @PeriodosEstrictos = 1
	--set @FechaGenera = '2017-01-01'	

	IF OBJECT_ID('tempdb..#tblCatPeriodos') IS NOT NULL DROP TABLE #tblCatPeriodos

	CREATE TABLE #tblCatPeriodos(
		[IDPeriodo] [int] IDENTITY(1,1) NOT NULL,
		[IDTipoNomina] [int] NOT NULL,
		[Ejercicio] [int] NOT NULL,
		[ClavePeriodo] [varchar](20) NOT NULL,
		[Descripcion] [varchar](250) NULL,
		[FechaInicioPago] [date] NOT NULL,
		[FechaFinPago] [date] NOT NULL,
		[FechaInicioIncidencia] [date] NOT NULL,
		[FechaFinIncidencia] [date] NOT NULL,
		[Dias] [int] NULL,
		[AnioInicio] [bit] NOT NULL,
		[AnioFin] [bit] NOT NULL,
		[MesInicio] [bit] NOT NULL,
		[MesFin] [bit] NOT NULL,
		[IDMes] [int] NOT NULL,
		[BimestreInicio] [bit] NOT NULL,
		[BimestreFin] [bit] NOT NULL,
		[General] [bit] NOT NULL,
		[Finiquito] [bit] NOT NULL,
		[Especial] [bit] NOT NULL,
		[Presupuesto] [bit] NOT NULL,
	)

	select @IDPeriodicidadPago = IDPeriodicidadPago,
		  @TipoNomina = Descripcion,
		  @IDCliente = cast(IDCliente as Varchar)
	From Nomina.tblCatTipoNomina
	where IDTipoNomina = @IDTipoNomina

	select @Perioricidad = Descripcion,
		   @DiasPeriodo = case when Descripcion = 'Diario' then 1
							   when Descripcion = 'Semanal' then 7
							   when Descripcion = 'Catorcenal' then 14
							   when Descripcion = 'Quincenal' then 15
							   when Descripcion = 'Mensual' then 30
							   when Descripcion = 'Bimestral' then 60
							   when Descripcion = 'Decenal' then 10
							else 0
							end
	from sat.tblCatPeriodicidadesPago with (nolock)
	where IDPeriodicidadPago = @IDPeriodicidadPago

	select @Perioricidad,@DiasPeriodo
	
	set @FechaInicio = null
	
	--select @FechaGenera,@FechaInicio

	--select  @IDTipoNomina as IDTipoNomina,
	--		@TipoNomina as TipoNomina,
	--		@IDPeriodicidadPago as IDPeriodicidadPago,
	--		@Perioricidad as Perioricidad,
	--		@DiasPeriodo as DiasPeriodo,
	--		@DiasDesfaceINC as DiasDesfaceINC
	
IF(@Perioricidad = 'Semanal')
BEGIN
	IF(@FechaInicio is null)
	BEGIN
		set @FechaInicio = @FechaGenera
	END

	While(DATEPART(YEAR,@FechaInicio)<= @Ejercicio + 1)
	BEGIN
		IF(YEAR(@FechaInicio) = @Ejercicio + 1 )
		BEGIN
			BREAK;
		END
		SET @FechaFin = DATEADD(DAY,@DiasPeriodo-1,@FechaInicio)

		INSERT INTO #tblCatPeriodos (
									[IDTipoNomina]
									,[Ejercicio]
									,[ClavePeriodo]
									,[Descripcion]
									,[FechaInicioPago]
									,[FechaFinPago]
									,[FechaInicioIncidencia] 
									,[FechaFinIncidencia]
									,[Dias]
									,[AnioInicio]
									,[AnioFin] 
									,[MesInicio]
									,[MesFin]
									,[IDMes] 
									,[BimestreInicio]
									,[BimestreFin] 
									,[General]
									,[Finiquito]
									,[Especial]
									,[Presupuesto]
								
		)
		SELECT @IDTipoNomina
				,@Ejercicio
				,CASE WHEN ISNULL(@Presupuesto,0) = 1 THEN 'P_' ELSE '' END + RIGHT('000'+ISNULL(@IDCliente,''),3) +'_'+RIGHT('00'+ISNULL(CAST(@IDTipoNomina AS VARCHAR),''),2)+'_'+CAST(@EjercicioTexto AS VARCHAR)+ RIGHT('00'+ISNULL( CAST((SELECT COUNT(*)+1 FROM #tblCatPeriodos) AS VARCHAR),''),2)
				,[Nomina].[fnDescripcionPeriodo](@IDTipoNomina, @FechaInicio,@FechaFin)
				,@FechaInicio
				,@FechaFin
				,DATEADD(Day,@DiasDesfaceINC,@FechaInicio)
				,DATEADD(Day,@DiasDesfaceINC,@FechaFin)
				,CASE WHEN @PeriodosEstrictos = 1 THEN @DiasPeriodo ELSE DATEDIFF(DAY,@FechaInicio,@FechaFin)+1 END
			    ,CASE WHEN cast(CAST(@Ejercicio AS VARCHAR) as date) BETWEEN @FechaInicio and @FechaFin then 1 ELSE 0 END
				,CASE WHEN dateadd(day,-1,cast(CAST(@Ejercicio+1 AS VARCHAR) as date)) BETWEEN @FechaInicio and @FechaFin then 1 ELSE 0 END
			    ,0--CASE WHEN DATEADD(DAY,1,EOMONTH(@FechaInicio,-1)) BETWEEN @FechaInicio and @FechaFin then 1 ELSE 0 END
				,0--CASE WHEN EOMONTH(@FechaInicio) BETWEEN @FechaInicio and @FechaFin then 1 ELSE 0 END
				,Nomina.fnMesMayorEntreFechas(@FechaInicio,@FechaFin)
				,0
				,0
				,@General
				,@Finiquito
				,@Especial
				,@Presupuesto
	
		SET @FechaInicio = DATEADD(DAY,1,@FechaFin)
	END

	SELECT IDMes, MIN(IDPeriodo) as IDperiodo
	into #InicioMesSemanal
    FROM #tblCatPeriodos
    GROUP BY IDMes
	ORDER BY IDMes ASC

	--select * from #InicioMesSemanal

	SELECT IDMes, MAX(IDPeriodo) as IDperiodo
	into #FinMesSemanal
    FROM #tblCatPeriodos
	 Where IDPeriodo not in (select IDPeriodo from #InicioMesSemanal)
	 and year(FechaFinPago) = Ejercicio
    GROUP BY IDMes, Year(FechaFinPago)
	ORDER BY IDMes ASC

	--select * From #FinMesSemanal

	-- Inicio BImestres----------------

	SELECT IDMes, MIN(IDPeriodo) as IDperiodo
	into #InicioBimestreSemanal
    FROM #tblCatPeriodos
	where IDMES in (1,3,5,7,9,11)
    GROUP BY IDMes
	ORDER BY IDMes ASC

	SELECT IDMes, MAX(IDPeriodo) as IDperiodo
	into #FinBimestreSemanal
    FROM #tblCatPeriodos
	where IDMES in (2,4,6,8,10,12)
    GROUP BY IDMes
	ORDER BY IDMes ASC
	-- Fin BImestres----------------


	update #tblCatPeriodos
		set BimestreInicio = 1
	where IDperiodo in (select IDperiodo from #InicioBimestreSemanal)

	
	update #tblCatPeriodos
	set BimestreFin = 1
	where IDperiodo in (select IDperiodo from #FinBimestreSemanal)

	update #tblCatPeriodos
		set MesInicio = 1
	where IDperiodo in (select IDperiodo from #InicioMesSemanal)

	
	update #tblCatPeriodos
	set MesFin = 1
	where IDperiodo in (select IDperiodo from #FinMesSemanal)

	
	IF  OBJECT_ID('tempdb..#InicioBimestreSemanal') IS NOT NULL DROP TABLE #InicioBimestreSemanal

	IF  OBJECT_ID('tempdb..#FinBimestreSemanal') IS NOT NULL DROP TABLE #FinBimestreSemanal
	IF  OBJECT_ID('tempdb..#InicioMesSemanal') IS NOT NULL DROP TABLE #InicioMesSemanal

	IF  OBJECT_ID('tempdb..#FinMesSemanal') IS NOT NULL DROP TABLE #FinMesSemanal

	insert into Nomina.tblCatPeriodos(
	IDTipoNomina
	,Ejercicio
	,ClavePeriodo
	,Descripcion
	,FechaInicioPago
	,FechaFinPago
	,FechaInicioIncidencia
	,FechaFinIncidencia
	,Dias
	,AnioInicio
	,AnioFin
	,MesInicio
	,MesFin
	,IDMes
	,BimestreInicio
	,BimestreFin
	,General
	,Finiquito
	,Especial
	,Cerrado
	,Presupuesto
	)
	select 
	IDTipoNomina
	,Ejercicio
	,ClavePeriodo
	,Descripcion
	,FechaInicioPago
	,FechaFinPago
	,FechaInicioIncidencia
	,FechaFinIncidencia
	,Dias
	,AnioInicio
	,AnioFin
	,MesInicio
	,MesFin
	,IDMes
	,BimestreInicio
	,BimestreFin
	,General
	,Finiquito
	,Especial
	,0 
	,Presupuesto
	from #tblCatPeriodos
END


IF(@Perioricidad = 'Quincenal')
BEGIN
	IF(@FechaInicio is null)
	BEGIN
			
		set @FechaInicio = @FechaGenera
	END
	select @FechaInicio
	While(DATEPART(YEAR,@FechaInicio)<= @Ejercicio + 1)
	BEGIN
		
		IF(YEAR(@FechaInicio) = @Ejercicio + 1 )
		BEGIN
			BREAK;
		END
		SET @FechaFin =  CASE WHEN DAY(@FechaInicio) < 14 THEN  (dateadd(dd,datediff(dd,datepart(dd,@fechaInicio),15),@fechaInicio))
							  WHEN DAY(@FechaInicio)> 15 THEN EOMONTH(@FechaInicio)
							  ELSE GETDATE()
							  END

		INSERT INTO #tblCatPeriodos (
									[IDTipoNomina]
									,[Ejercicio]
									,[ClavePeriodo]
									,[Descripcion]
									,[FechaInicioPago]
									,[FechaFinPago]
									,[FechaInicioIncidencia] 
									,[FechaFinIncidencia]
									,[Dias]
									,[AnioInicio]
									,[AnioFin] 
									,[MesInicio]
									,[MesFin]
									,[IDMes] 
									,[BimestreInicio]
									,[BimestreFin] 
									,[General]
									,[Finiquito]
									,[Especial]
									,[Presupuesto]
									
		)
		SELECT @IDTipoNomina
				,@Ejercicio
				,CASE WHEN ISNULL(@Presupuesto,0) = 1 THEN 'P_' ELSE '' END + RIGHT('000'+ISNULL(@IDCliente,''),3) +'_'+RIGHT('00'+ISNULL(CAST(@IDTipoNomina AS VARCHAR),''),2)+'_'+CAST(@EjercicioTexto AS VARCHAR)+ RIGHT('00'+ISNULL( CAST((SELECT COUNT(*)+1 FROM #tblCatPeriodos) AS VARCHAR),''),2)
				,[Nomina].[fnDescripcionPeriodo](@IDTipoNomina, @FechaInicio,@FechaFin)
				,@FechaInicio
				,@FechaFin
				,DATEADD(Day,@DiasDesfaceINC,@FechaInicio)
				,DATEADD(Day,@DiasDesfaceINC,@FechaFin)
				,CASE WHEN @PeriodosEstrictos = 1 THEN @DiasPeriodo ELSE DATEDIFF(DAY,@FechaInicio,@FechaFin)+1 END
			    ,CASE WHEN cast(CAST(@Ejercicio AS VARCHAR) as date) BETWEEN @FechaInicio and @FechaFin then 1 ELSE 0 END
				,CASE WHEN dateadd(day,-1,cast(CAST(@Ejercicio+1 AS VARCHAR) as date)) BETWEEN @FechaInicio and @FechaFin then 1 ELSE 0 END
			    ,CASE WHEN DATEADD(DAY,1,EOMONTH(@FechaInicio,-1)) BETWEEN @FechaInicio and @FechaFin then 1 ELSE 0 END
				,CASE WHEN EOMONTH(@FechaInicio) BETWEEN @FechaInicio and @FechaFin then 1 ELSE 0 END
				,Nomina.fnMesMayorEntreFechas(@FechaInicio,@FechaFin)
				,0
				,0
				,@General
				,@Finiquito
				,@Especial
				,@Presupuesto
				

	
		SET @FechaInicio = DATEADD(DAY,1,@FechaFin)
		
	END

	SELECT * FROM #tblCatPeriodos


	SELECT IDMes, MIN(IDPeriodo) as IDperiodo
	into #InicioBimestreQuincenal
    FROM #tblCatPeriodos
	where IDMES in (1,3,5,7,9,11)
    GROUP BY IDMes
	ORDER BY IDMes ASC

	SELECT IDMes, MAX(IDPeriodo) as IDperiodo
	into #FinBimestreQuincenal
    FROM #tblCatPeriodos
	where IDMES in (2,4,6,8,10,12)
    GROUP BY IDMes
	ORDER BY IDMes ASC

	update #tblCatPeriodos
		set BimestreInicio = 1
	where IDperiodo in (select IDperiodo from #InicioBimestreQuincenal)

	
	update #tblCatPeriodos
	set BimestreFin = 1
	where IDperiodo in (select IDperiodo from #FinBimestreQuincenal)

	IF  OBJECT_ID('tempdb..#InicioBimestreQuincenal') IS NOT NULL DROP TABLE #InicioBimestreQuincenal

	IF  OBJECT_ID('tempdb..#FinBimestreQuincenal') IS NOT NULL DROP TABLE #FinBimestreQuincenal

	insert into Nomina.tblCatPeriodos(
	IDTipoNomina
	,Ejercicio
	,ClavePeriodo
	,Descripcion
	,FechaInicioPago
	,FechaFinPago
	,FechaInicioIncidencia
	,FechaFinIncidencia
	,Dias
	,AnioInicio
	,AnioFin
	,MesInicio
	,MesFin
	,IDMes
	,BimestreInicio
	,BimestreFin
	,General
	,Finiquito
	,Especial
	,Cerrado
	,Presupuesto
	)
	select 
	IDTipoNomina
	,Ejercicio
	,ClavePeriodo
	,Descripcion
	,FechaInicioPago
	,FechaFinPago
	,FechaInicioIncidencia
	,FechaFinIncidencia
	,Dias
	,AnioInicio
	,AnioFin
	,MesInicio
	,MesFin
	,IDMes
	,BimestreInicio
	,BimestreFin
	,@General
	,@Finiquito
	,@Especial
	,0 
	,Presupuesto
	from #tblCatPeriodos
END


IF(@Perioricidad = 'Mensual')
BEGIN
	IF(@FechaInicio is null)
	BEGIN
			
		set @FechaInicio = @FechaGenera
	END

	While(DATEPART(YEAR,@FechaInicio)<= @Ejercicio + 1)
	BEGIN
		
		IF(YEAR(@FechaInicio) = @Ejercicio + 1 )
		BEGIN
			BREAK;
		END
		SET @FechaFin = EOMONTH(@FechaInicio)

		INSERT INTO #tblCatPeriodos (
									[IDTipoNomina]
									,[Ejercicio]
									,[ClavePeriodo]
									,[Descripcion]
									,[FechaInicioPago]
									,[FechaFinPago]
									,[FechaInicioIncidencia] 
									,[FechaFinIncidencia]
									,[Dias]
									,[AnioInicio]
									,[AnioFin] 
									,[MesInicio]
									,[MesFin]
									,[IDMes] 
									,[BimestreInicio]
									,[BimestreFin] 
									,[General]
									,[Finiquito]
									,[Especial]
									,[Presupuesto]
									
		)
		SELECT @IDTipoNomina
				,@Ejercicio
				,CASE WHEN ISNULL(@Presupuesto,0) = 1 THEN 'P_' ELSE '' END + RIGHT('000'+ISNULL(@IDCliente,''),3) +'_'+RIGHT('00'+ISNULL(CAST(@IDTipoNomina AS VARCHAR),''),2)+'_'+CAST(@EjercicioTexto AS VARCHAR)+ RIGHT('00'+ISNULL( CAST((SELECT COUNT(*)+1 FROM #tblCatPeriodos) AS VARCHAR),''),2)
				,[Nomina].[fnDescripcionPeriodo](@IDTipoNomina, @FechaInicio,@FechaFin)
				,@FechaInicio
				,@FechaFin
				,DATEADD(Day,-@DiasDesfaceINC,@FechaInicio)
				,DATEADD(Day,-@DiasDesfaceINC,@FechaFin)
				,CASE WHEN @PeriodosEstrictos = 1 THEN @DiasPeriodo ELSE DATEDIFF(DAY,@FechaInicio,@FechaFin)+1 END
			    ,CASE WHEN cast(CAST(@Ejercicio AS VARCHAR) as date) BETWEEN @FechaInicio and @FechaFin then 1 ELSE 0 END
				,CASE WHEN dateadd(day,-1,cast(CAST(@Ejercicio+1 AS VARCHAR) as date)) BETWEEN @FechaInicio and @FechaFin then 1 ELSE 0 END
			    ,CASE WHEN DATEADD(DAY,1,EOMONTH(@FechaInicio,-1)) BETWEEN @FechaInicio and @FechaFin then 1 ELSE 0 END
				,CASE WHEN EOMONTH(@FechaInicio) BETWEEN @FechaInicio and @FechaFin then 1 ELSE 0 END
				,Nomina.fnMesMayorEntreFechas(@FechaInicio,@FechaFin)
				,0
				,0
				,@General
				,@Finiquito
				,@Especial
				,@Presupuesto

	
		SET @FechaInicio = DATEADD(DAY,1,@FechaFin)
	END

	--SELECT * FROM #tblCatPeriodos

	SELECT IDMes, MIN(IDPeriodo) as IDperiodo
	into #InicioBimestreMensual
    FROM #tblCatPeriodos
	where IDMES in (1,3,5,7,9,11)
    GROUP BY IDMes
	ORDER BY IDMes ASC

	SELECT IDMes, MAX(IDPeriodo) as IDperiodo
	into #FinBimestreMensual
    FROM #tblCatPeriodos
	where IDMES in (2,4,6,8,10,12)
    GROUP BY IDMes
	ORDER BY IDMes ASC

	update #tblCatPeriodos
		set BimestreInicio = 1
	where IDperiodo in (select IDperiodo from #InicioBimestreMensual)

	
	update #tblCatPeriodos
	set BimestreFin = 1
	where IDperiodo in (select IDperiodo from #FinBimestreMensual)

	IF  OBJECT_ID('tempdb..#InicioBimestreMensual') IS NOT NULL DROP TABLE #InicioBimestreMensual
	IF  OBJECT_ID('tempdb..#FinBimestreMensual') IS NOT NULL DROP TABLE #FinBimestreMensual

	insert into Nomina.tblCatPeriodos(
	IDTipoNomina
	,Ejercicio
	,ClavePeriodo
	,Descripcion
	,FechaInicioPago
	,FechaFinPago
	,FechaInicioIncidencia
	,FechaFinIncidencia
	,Dias
	,AnioInicio
	,AnioFin
	,MesInicio
	,MesFin
	,IDMes
	,BimestreInicio
	,BimestreFin
	,General
	,Finiquito
	,Especial
	,Cerrado
	,Presupuesto
	)
	select 
	IDTipoNomina
	,Ejercicio
	,ClavePeriodo
	,Descripcion
	,FechaInicioPago
	,FechaFinPago
	,FechaInicioIncidencia
	,FechaFinIncidencia
	,Dias
	,AnioInicio
	,AnioFin
	,MesInicio
	,MesFin
	,IDMes
	,BimestreInicio
	,BimestreFin
	,@General
	,@Finiquito
	,@Especial
	,0 
	,@Presupuesto
	from #tblCatPeriodos
END

IF(@Perioricidad = 'Catorcenal')
BEGIN
	IF(@FechaInicio is null)
	BEGIN
			
		set @FechaInicio = @FechaGenera
	END
	While(DATEPART(YEAR,@FechaInicio)<= @Ejercicio + 1)
	BEGIN
		
		IF(YEAR(@FechaInicio) = @Ejercicio + 1 )
		BEGIN
			BREAK;
		END
		SET @FechaFin = DATEADD(Day,@DiasPeriodo-1,@FechaInicio)

		INSERT INTO #tblCatPeriodos (
									[IDTipoNomina]
									,[Ejercicio]
									,[ClavePeriodo]
									,[Descripcion]
									,[FechaInicioPago]
									,[FechaFinPago]
									,[FechaInicioIncidencia] 
									,[FechaFinIncidencia]
									,[Dias]
									,[AnioInicio]
									,[AnioFin] 
									,[MesInicio]
									,[MesFin]
									,[IDMes] 
									,[BimestreInicio]
									,[BimestreFin] 
									,[General]
									,[Finiquito]
									,[Especial]
									,[Presupuesto]
									
		)
		SELECT @IDTipoNomina
				,@Ejercicio
				,CASE WHEN ISNULL(@Presupuesto,0) = 1 THEN 'P_' ELSE '' END + RIGHT('000'+ISNULL(@IDCliente,''),3) +'_'+RIGHT('00'+ISNULL(CAST(@IDTipoNomina AS VARCHAR),''),2)+'_'+CAST(@EjercicioTexto AS VARCHAR)+ RIGHT('00'+ISNULL( CAST((SELECT COUNT(*)+1 FROM #tblCatPeriodos) AS VARCHAR),''),2)
				,[Nomina].[fnDescripcionPeriodo](@IDTipoNomina, @FechaInicio,@FechaFin)
				,@FechaInicio
				,@FechaFin
				,DATEADD(Day,-@DiasDesfaceINC,@FechaInicio)
				,DATEADD(Day,-@DiasDesfaceINC,@FechaFin)
				,CASE WHEN @PeriodosEstrictos = 1 THEN @DiasPeriodo ELSE DATEDIFF(DAY,@FechaInicio,@FechaFin) END
			    ,CASE WHEN cast(CAST(@Ejercicio AS VARCHAR) as date) BETWEEN @FechaInicio and @FechaFin then 1 ELSE 0 END
				,CASE WHEN dateadd(day,-1,cast(CAST(@Ejercicio+1 AS VARCHAR) as date)) BETWEEN @FechaInicio and @FechaFin then 1 ELSE 0 END
			    ,0 --CASE WHEN DATEADD(DAY,1,EOMONTH(@FechaInicio,-1)) BETWEEN @FechaInicio and @FechaFin then 1 ELSE 0 END
				,0--CASE WHEN EOMONTH(@FechaInicio) BETWEEN @FechaInicio and @FechaFin then 1 ELSE 0 END
				,Nomina.fnMesMayorEntreFechas(@FechaInicio,@FechaFin)
				,0
				,0
				,@General
				,@Finiquito
				,@Especial
				,@Presupuesto

	
		SET @FechaInicio = DATEADD(DAY,1,@FechaFin)
	END

	SELECT * FROM #tblCatPeriodos

	
	SELECT IDMes, MIN(IDPeriodo) as IDperiodo
	into #InicioMesCatorcenal
    FROM #tblCatPeriodos
    GROUP BY IDMes
	ORDER BY IDMes ASC

	select * from #InicioMesCatorcenal


	SELECT IDMes, MAX(IDPeriodo) as IDperiodo
	into #FinMesCatorcenal
    FROM #tblCatPeriodos
	 Where IDPeriodo not in (select IDPeriodo from #InicioMesCatorcenal)
	 and year(FechaFinPago) = Ejercicio
    GROUP BY IDMes, Year(FechaFinPago)
	ORDER BY IDMes ASC

	select * From #FinMesCatorcenal


	-- Inicio BImestres----------------

	SELECT IDMes, MIN(IDPeriodo) as IDperiodo
	into #InicioBimestreCatorcenal
    FROM #tblCatPeriodos
	where IDMES in (1,3,5,7,9,11)
    GROUP BY IDMes
	ORDER BY IDMes ASC

	SELECT IDMes, MAX(IDPeriodo) as IDperiodo
	into #FinBimestreCatorcenal
    FROM #tblCatPeriodos
	where IDMES in (2,4,6,8,10,12)
    GROUP BY IDMes
	ORDER BY IDMes ASC
	-- Fin BImestres----------------


	update #tblCatPeriodos
		set BimestreInicio = 1
	where IDperiodo in (select IDperiodo from #InicioBimestreCatorcenal)

	
	update #tblCatPeriodos
	set BimestreFin = 1
	where IDperiodo in (select IDperiodo from #FinBimestreCatorcenal)

	update #tblCatPeriodos
		set MesInicio = 1
	where IDperiodo in (select IDperiodo from #InicioMesCatorcenal)

	
	update #tblCatPeriodos
	set MesFin = 1
	where IDperiodo in (select IDperiodo from #FinMesCatorcenal)



	IF  OBJECT_ID('tempdb..#InicioMesCatorcenal') IS NOT NULL DROP TABLE #InicioMesCatorcenal

	IF  OBJECT_ID('tempdb..#FinMesCatorcenal') IS NOT NULL DROP TABLE #FinMesCatorcenal

	
	IF  OBJECT_ID('tempdb..#InicioBimestreCatorcenal') IS NOT NULL DROP TABLE #InicioBimestreCatorcenal

	IF  OBJECT_ID('tempdb..#FinBimestreCatorcenal') IS NOT NULL DROP TABLE #FinBimestreCatorcenal


	insert into Nomina.tblCatPeriodos(
	IDTipoNomina
	,Ejercicio
	,ClavePeriodo
	,Descripcion
	,FechaInicioPago
	,FechaFinPago
	,FechaInicioIncidencia
	,FechaFinIncidencia
	,Dias
	,AnioInicio
	,AnioFin
	,MesInicio
	,MesFin
	,IDMes
	,BimestreInicio
	,BimestreFin
	,General
	,Finiquito
	,Especial
	,Cerrado
	,Presupuesto
	)
	select 
	IDTipoNomina
	,Ejercicio
	,ClavePeriodo
	,Descripcion
	,FechaInicioPago
	,FechaFinPago
	,FechaInicioIncidencia
	,FechaFinIncidencia
	,Dias
	,AnioInicio
	,AnioFin
	,MesInicio
	,MesFin
	,IDMes
	,BimestreInicio
	,BimestreFin
	,@General
	,@Finiquito
	,@Especial
	,0 
	,@Presupuesto
	from #tblCatPeriodos
END


IF(@Perioricidad = 'Decenal')
BEGIN
	IF(@FechaInicio is null)
	BEGIN
			
		set @FechaInicio = @FechaGenera
	END

	While(DATEPART(YEAR,@FechaInicio)<= @Ejercicio + 1)
	BEGIN
		
		IF(YEAR(@FechaInicio) = @Ejercicio + 1 )
		BEGIN
			BREAK;
		END
		SET @FechaFin = DATEADD(Day,10,@FechaInicio)

		INSERT INTO #tblCatPeriodos (
									[IDTipoNomina]
									,[Ejercicio]
									,[ClavePeriodo]
									,[Descripcion]
									,[FechaInicioPago]
									,[FechaFinPago]
									,[FechaInicioIncidencia] 
									,[FechaFinIncidencia]
									,[Dias]
									,[AnioInicio]
									,[AnioFin] 
									,[MesInicio]
									,[MesFin]
									,[IDMes] 
									,[BimestreInicio]
									,[BimestreFin] 
									,[General]
									,[Finiquito]
									,[Especial]
									,[Presupuesto]
									
		)
		SELECT @IDTipoNomina
				,@Ejercicio
				,CASE WHEN ISNULL(@Presupuesto,0) = 1 THEN 'P_' ELSE '' END + RIGHT('000'+ISNULL(@IDCliente,''),3) +'_'+RIGHT('00'+ISNULL(CAST(@IDTipoNomina AS VARCHAR),''),2)+'_'+CAST(@EjercicioTexto AS VARCHAR)+ RIGHT('00'+ISNULL( CAST((SELECT COUNT(*)+1 FROM #tblCatPeriodos) AS VARCHAR),''),2)
				,[Nomina].[fnDescripcionPeriodo](@IDTipoNomina, @FechaInicio,@FechaFin)
				,@FechaInicio
				,@FechaFin
				,DATEADD(Day,-@DiasDesfaceINC,@FechaInicio)
				,DATEADD(Day,-@DiasDesfaceINC,@FechaFin)
				,CASE WHEN @PeriodosEstrictos = 1 THEN @DiasPeriodo ELSE DATEDIFF(DAY,@FechaInicio,@FechaFin) END
			    ,CASE WHEN cast(CAST(@Ejercicio AS VARCHAR) as date) BETWEEN @FechaInicio and @FechaFin then 1 ELSE 0 END
				,CASE WHEN dateadd(day,-1,cast(CAST(@Ejercicio+1 AS VARCHAR) as date)) BETWEEN @FechaInicio and @FechaFin then 1 ELSE 0 END
			    ,0--CASE WHEN DATEADD(DAY,1,EOMONTH(@FechaInicio,-1)) BETWEEN @FechaInicio and @FechaFin then 1 ELSE 0 END
				,0--CASE WHEN EOMONTH(@FechaInicio) BETWEEN @FechaInicio and @FechaFin then 1 ELSE 0 END
				,Nomina.fnMesMayorEntreFechas(@FechaInicio,@FechaFin)
				,0
				,0
				,@General
				,@Finiquito
				,@Especial
				,@Presupuesto
			

	
		SET @FechaInicio = DATEADD(DAY,1,@FechaFin)
	END

	--SELECT * FROM #tblCatPeriodos

	SELECT IDMes, MIN(IDPeriodo) as IDperiodo
	into #InicioMesDecenal
    FROM #tblCatPeriodos
    GROUP BY IDMes
	ORDER BY IDMes ASC


	SELECT IDMes, MAX(IDPeriodo) as IDperiodo
	into #FinMesDecenal
    FROM #tblCatPeriodos
	 Where IDPeriodo not in (select IDPeriodo from #InicioMesDecenal)
	 and year(FechaFinPago) = Ejercicio
    GROUP BY IDMes, Year(FechaFinPago)
	ORDER BY IDMes ASC




	SELECT IDMes, MIN(IDPeriodo) as IDperiodo
	into #InicioBimestreDecenal
    FROM #tblCatPeriodos
	where IDMES in (1,3,5,7,9,11)
    GROUP BY IDMes
	ORDER BY IDMes ASC

	SELECT IDMes, MAX(IDPeriodo) as IDperiodo
	into #FinBimestreDecenal
    FROM #tblCatPeriodos
	where IDMES in (2,4,6,8,10,12)
    GROUP BY IDMes
	ORDER BY IDMes ASC

	update #tblCatPeriodos
		set BimestreInicio = 1
	where IDperiodo in (select IDperiodo from #InicioBimestreDecenal)

	
	update #tblCatPeriodos
	set BimestreFin = 1
	where IDperiodo in (select IDperiodo from #FinBimestreDecenal)

	update #tblCatPeriodos
		set MesInicio = 1
	where IDperiodo in (select IDperiodo from #InicioMesDecenal)

	
	update #tblCatPeriodos
	set MesFin = 1
	where IDperiodo in (select IDperiodo from #FinMesDecenal)

	IF  OBJECT_ID('tempdb..#InicioBimestreDecenal') IS NOT NULL DROP TABLE #InicioBimestreDecenal

	IF  OBJECT_ID('tempdb..#FinBimestreDecenal') IS NOT NULL DROP TABLE #FinBimestreDecenal

	IF  OBJECT_ID('tempdb..#InicioMesDecenal') IS NOT NULL DROP TABLE #InicioMesDecenal

	IF  OBJECT_ID('tempdb..#FinMesDecenal') IS NOT NULL DROP TABLE #FinMesDecenal

	insert into Nomina.tblCatPeriodos(
	IDTipoNomina
	,Ejercicio
	,ClavePeriodo
	,Descripcion
	,FechaInicioPago
	,FechaFinPago
	,FechaInicioIncidencia
	,FechaFinIncidencia
	,Dias
	,AnioInicio
	,AnioFin
	,MesInicio
	,MesFin
	,IDMes
	,BimestreInicio
	,BimestreFin
	,General
	,Finiquito
	,Especial
	,Cerrado
	,Presupuesto
	)
	select 
	IDTipoNomina
	,Ejercicio
	,ClavePeriodo
	,Descripcion
	,FechaInicioPago
	,FechaFinPago
	,FechaInicioIncidencia
	,FechaFinIncidencia
	,Dias
	,AnioInicio
	,AnioFin
	,MesInicio
	,MesFin
	,IDMes
	,BimestreInicio
	,BimestreFin
	,@General
	,@Finiquito
	,@Especial
	,0 
	,@Presupuesto
	from #tblCatPeriodos
END

IF(@Perioricidad = 'Diario')
BEGIN
	IF(@FechaInicio is null)
	BEGIN
			
		set @FechaInicio = @FechaGenera
	END

	While(DATEPART(YEAR,@FechaInicio)<= @Ejercicio + 1)
	BEGIN
		
		IF(YEAR(@FechaInicio) = @Ejercicio + 1 )
		BEGIN
			BREAK;
		END
		SET @FechaFin = @FechaInicio

		INSERT INTO #tblCatPeriodos (
									[IDTipoNomina]
									,[Ejercicio]
									,[ClavePeriodo]
									,[Descripcion]
									,[FechaInicioPago]
									,[FechaFinPago]
									,[FechaInicioIncidencia] 
									,[FechaFinIncidencia]
									,[Dias]
									,[AnioInicio]
									,[AnioFin] 
									,[MesInicio]
									,[MesFin]
									,[IDMes] 
									,[BimestreInicio]
									,[BimestreFin] 
									,[General]
									,[Finiquito]
									,[Especial]
									,[Presupuesto]
		)
		SELECT @IDTipoNomina
				,@Ejercicio
				,CASE WHEN ISNULL(@Presupuesto,0) = 1 THEN 'P_' ELSE '' END + RIGHT('000'+ISNULL(@IDCliente,''),3) +'_'+RIGHT('00'+ISNULL(CAST(@IDTipoNomina AS VARCHAR),''),2)+'_'+CAST(@EjercicioTexto AS VARCHAR)+ RIGHT('00'+ISNULL( CAST((SELECT COUNT(*)+1 FROM #tblCatPeriodos) AS VARCHAR),''),2)
				,[Nomina].[fnDescripcionPeriodo](@IDTipoNomina, @FechaInicio,@FechaFin)
				,@FechaInicio
				,@FechaFin
				,DATEADD(Day,-@DiasDesfaceINC,@FechaInicio)
				,DATEADD(Day,-@DiasDesfaceINC,@FechaFin)
				,CASE WHEN @PeriodosEstrictos = 1 THEN @DiasPeriodo ELSE DATEDIFF(DAY,@FechaInicio,@FechaFin) END
			    ,CASE WHEN cast(CAST(@Ejercicio AS VARCHAR) as date) BETWEEN @FechaInicio and @FechaFin then 1 ELSE 0 END
				,CASE WHEN dateadd(day,-1,cast(CAST(@Ejercicio+1 AS VARCHAR) as date)) BETWEEN @FechaInicio and @FechaFin then 1 ELSE 0 END
			    ,0--CASE WHEN DATEADD(DAY,1,EOMONTH(@FechaInicio,-1)) BETWEEN @FechaInicio and @FechaFin then 1 ELSE 0 END
				,0--CASE WHEN EOMONTH(@FechaInicio) BETWEEN @FechaInicio and @FechaFin then 1 ELSE 0 END
				,Nomina.fnMesMayorEntreFechas(@FechaInicio,@FechaFin)
				,0
				,0
				,@General
				,@Finiquito
				,@Especial
				,@Presupuesto

	
		SET @FechaInicio = DATEADD(DAY,1,@FechaFin)
	END

	--SELECT * FROM #tblCatPeriodos

	SELECT IDMes, MIN(IDPeriodo) as IDperiodo
	into #InicioMesDiario
    FROM #tblCatPeriodos
    GROUP BY IDMes
	ORDER BY IDMes ASC


	SELECT IDMes, MAX(IDPeriodo) as IDperiodo
	into #FinMesDiario
    FROM #tblCatPeriodos
	 Where IDPeriodo not in (select IDPeriodo from #InicioMesDiario)
	 and year(FechaFinPago) = Ejercicio
    GROUP BY IDMes, Year(FechaFinPago)
	ORDER BY IDMes ASC




	SELECT IDMes, MIN(IDPeriodo) as IDperiodo
	into #InicioBimestreDiario
    FROM #tblCatPeriodos
	where IDMES in (1,3,5,7,9,11)
    GROUP BY IDMes
	ORDER BY IDMes ASC

	SELECT IDMes, MAX(IDPeriodo) as IDperiodo
	into #FinBimestreDiario
    FROM #tblCatPeriodos
	where IDMES in (2,4,6,8,10,12)
    GROUP BY IDMes
	ORDER BY IDMes ASC

	update #tblCatPeriodos
		set BimestreInicio = 1
	where IDperiodo in (select IDperiodo from #InicioBimestreDiario)

	
	update #tblCatPeriodos
	set BimestreFin = 1
	where IDperiodo in (select IDperiodo from #FinBimestreDiario)

	update #tblCatPeriodos
		set MesInicio = 1
	where IDperiodo in (select IDperiodo from #InicioMesDiario)

	
	update #tblCatPeriodos
	set MesFin = 1
	where IDperiodo in (select IDperiodo from #FinMesDiario)

	IF  OBJECT_ID('tempdb..#InicioBimestreDiario') IS NOT NULL DROP TABLE #InicioBimestreDiario

	IF  OBJECT_ID('tempdb..#FinBimestreDiario') IS NOT NULL DROP TABLE #FinBimestreDiario

	IF  OBJECT_ID('tempdb..#InicioMesDiario') IS NOT NULL DROP TABLE #InicioMesDiario

	IF  OBJECT_ID('tempdb..#FinMesDiario') IS NOT NULL DROP TABLE #FinMesDiario

	insert into Nomina.tblCatPeriodos(
	IDTipoNomina
	,Ejercicio
	,ClavePeriodo
	,Descripcion
	,FechaInicioPago
	,FechaFinPago
	,FechaInicioIncidencia
	,FechaFinIncidencia
	,Dias
	,AnioInicio
	,AnioFin
	,MesInicio
	,MesFin
	,IDMes
	,BimestreInicio
	,BimestreFin
	,General
	,Finiquito
	,Especial
	,Cerrado
	,Presupuesto
	)
	select 
	IDTipoNomina
	,Ejercicio
	,ClavePeriodo
	,Descripcion
	,FechaInicioPago
	,FechaFinPago
	,FechaInicioIncidencia
	,FechaFinIncidencia
	,Dias
	,AnioInicio
	,AnioFin
	,MesInicio
	,MesFin
	,IDMes
	,BimestreInicio
	,BimestreFin
	,@General
	,@Finiquito
	,@Especial
	,0 
	,@Presupuesto
	from #tblCatPeriodos
END

IF(@Perioricidad = 'Bimestral')
BEGIN
	IF(@FechaInicio is null)
	BEGIN
			
		set @FechaInicio = @FechaGenera
	END

	While(DATEPART(YEAR,@FechaInicio)<= @Ejercicio + 1)
	BEGIN
		
		IF(YEAR(@FechaInicio) = @Ejercicio + 1 )
		BEGIN
			BREAK;
		END
		SET @FechaFin = EOMONTH(DATEADD(MONTH,1,@FechaInicio))

		INSERT INTO #tblCatPeriodos (
									[IDTipoNomina]
									,[Ejercicio]
									,[ClavePeriodo]
									,[Descripcion]
									,[FechaInicioPago]
									,[FechaFinPago]
									,[FechaInicioIncidencia] 
									,[FechaFinIncidencia]
									,[Dias]
									,[AnioInicio]
									,[AnioFin] 
									,[MesInicio]
									,[MesFin]
									,[IDMes] 
									,[BimestreInicio]
									,[BimestreFin] 
									,[General]
									,[Finiquito]
									,[Especial]
									,[Presupuesto]
		)
		SELECT @IDTipoNomina
				,@Ejercicio
				,CASE WHEN ISNULL(@Presupuesto,0) = 1 THEN 'P_' ELSE '' END + RIGHT('000'+ISNULL(@IDCliente,''),3) +'_'+RIGHT('00'+ISNULL(CAST(@IDTipoNomina AS VARCHAR),''),2)+'_'+CAST(@EjercicioTexto AS VARCHAR)+ RIGHT('00'+ISNULL( CAST((SELECT COUNT(*)+1 FROM #tblCatPeriodos) AS VARCHAR),''),2)
				,[Nomina].[fnDescripcionPeriodo](@IDTipoNomina, @FechaInicio,@FechaFin)
				,@FechaInicio
				,@FechaFin
				,DATEADD(Day,-@DiasDesfaceINC,@FechaInicio)
				,DATEADD(Day,-@DiasDesfaceINC,@FechaFin)
				,CASE WHEN @PeriodosEstrictos = 1 THEN @DiasPeriodo ELSE DATEDIFF(DAY,@FechaInicio,@FechaFin) END
			    ,CASE WHEN cast(CAST(@Ejercicio AS VARCHAR) as date) BETWEEN @FechaInicio and @FechaFin then 1 ELSE 0 END
				,CASE WHEN dateadd(day,-1,cast(CAST(@Ejercicio+1 AS VARCHAR) as date)) BETWEEN @FechaInicio and @FechaFin then 1 ELSE 0 END
			    ,1--CASE WHEN DATEADD(DAY,1,EOMONTH(@FechaInicio,-1)) BETWEEN @FechaInicio and @FechaFin then 1 ELSE 0 END
				,1--CASE WHEN EOMONTH(@FechaInicio) BETWEEN @FechaInicio and @FechaFin then 1 ELSE 0 END
				,Nomina.fnMesMayorEntreFechas(@FechaInicio,@FechaInicio)
				,0
				,0
				,@General
				,@Finiquito
				,@Especial
				,@Presupuesto

	
		SET @FechaInicio = DATEADD(DAY,1,@FechaFin)
	END

	--SELECT * FROM #tblCatPeriodos


	SELECT IDMes, MIN(IDPeriodo) as IDperiodo
	into #InicioBimestreBimestral
    FROM #tblCatPeriodos
	where IDMES in (1,3,5,7,9,11)
    GROUP BY IDMes
	ORDER BY IDMes ASC


	update #tblCatPeriodos
		set BimestreInicio = 1,
			BimestreFin = 1
	where IDperiodo in (select IDperiodo from #InicioBimestreBimestral)

	

	IF  OBJECT_ID('tempdb..#InicioBimestreBimestral') IS NOT NULL DROP TABLE #InicioBimestreBimestral

	--IF  OBJECT_ID('tempdb..#FinBimestreBimestral') IS NOT NULL DROP TABLE #FinBimestreBimestral

	insert into Nomina.tblCatPeriodos(
	IDTipoNomina
	,Ejercicio
	,ClavePeriodo
	,Descripcion
	,FechaInicioPago
	,FechaFinPago
	,FechaInicioIncidencia
	,FechaFinIncidencia
	,Dias
	,AnioInicio
	,AnioFin
	,MesInicio
	,MesFin
	,IDMes
	,BimestreInicio
	,BimestreFin
	,General
	,Finiquito
	,Especial
	,Cerrado
	,Presupuesto
	)
	select 
	IDTipoNomina
	,Ejercicio
	,ClavePeriodo
	,Descripcion
	,FechaInicioPago
	,FechaFinPago
	,FechaInicioIncidencia
	,FechaFinIncidencia
	,Dias
	,AnioInicio
	,AnioFin
	,MesInicio
	,MesFin
	,IDMes
	,BimestreInicio
	,BimestreFin
	,@General
	,@Finiquito
	,@Especial
	,0 
	,Presupuesto
	from #tblCatPeriodos
END

END
GO
