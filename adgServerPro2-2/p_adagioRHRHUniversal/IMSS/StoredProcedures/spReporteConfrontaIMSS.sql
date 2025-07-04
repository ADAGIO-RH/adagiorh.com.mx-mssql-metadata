USE [p_adagioRHRHUniversal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [IMSS].[spReporteConfrontaIMSS] --1,1
(
	@IDControlConfrontaIMSS int,
	@IDUsuario int
)
AS
BEGIN
	DECLARE @IDRegPatronal int,
		@Ejercicio int,
		@IDMes int,
		@IDBimestre int,
		@EMA bit,
		@EBA bit,
		@Bimestres varchar(10),
		@EmpleadosEMA RH.dtEmpleados,
		@EmpleadosEBA RH.dtEmpleados,
		@filtros Nomina.dtFiltrosRH,
		@FechaIniMes Date,
		@FechaFinMes Date,
		@FechaIniBimestre date,
		@FechaFinBimestre date,
		@IDConceptoDiasCotizados int,
		@IDConceptoCuotaFija int,
		@IDConceptoExcedentePatronal int,
		@IDConceptoExcedenteObrera int,
		@IDConceptoGastosMedicosPensionadosPatronal int,
		@IDConceptoGastosMedicosPensionadosObrera int,
		@IDConceptoRiesgoTrabajo int,
		@IDConceptoInvalidezVidaPatronal int,
		@IDConceptoInvalidezVidaObrera int,
		@IDConceptoGuarderia int,
		@IDConceptoPrestacionesDineroPatronal int,
		@IDConceptoPrestacionesDineroObrera	int,
		@IDConceptoRetiro int,
		@IDConceptoCesantiaVejezPatronal int,
		@IDConceptoCesantiaVejezObrera	int,
		@IDConceptoInfonavitPatronal	int,
		@IDConceptoInfonavitEmpleado	int,
		@IDConceptoInfonavitEmpleadoSeguro	int,
		@RegistroPatronal Varchar(max)
		;

		DECLARE @TablasResultados as Table(
			ORDEN int identity(1,1),
			Titulo Varchar(max)
		)


		SELECT @IDConceptoDiasCotizados						= IDConcepto from Nomina.tblCatConceptos with(nolock) where codigo = '006'
		SELECT @IDConceptoCuotaFija 						= IDConcepto from Nomina.tblCatConceptos with(nolock) where codigo = '500'
		SELECT @IDConceptoExcedentePatronal					= IDConcepto from Nomina.tblCatConceptos with(nolock) where codigo = '501'
		SELECT @IDConceptoExcedenteObrera 					= IDConcepto from Nomina.tblCatConceptos with(nolock) where codigo = '520'
		SELECT @IDConceptoGastosMedicosPensionadosPatronal 	= IDConcepto from Nomina.tblCatConceptos with(nolock) where codigo = '505'
		SELECT @IDConceptoGastosMedicosPensionadosObrera	= IDConcepto from Nomina.tblCatConceptos with(nolock) where codigo = '515'
		SELECT @IDConceptoRiesgoTrabajo 					= IDConcepto from Nomina.tblCatConceptos with(nolock) where codigo = '504'
		SELECT @IDConceptoInvalidezVidaPatronal 			= IDConcepto from Nomina.tblCatConceptos with(nolock) where codigo = '506'
		SELECT @IDConceptoInvalidezVidaObrera 				= IDConcepto from Nomina.tblCatConceptos with(nolock) where codigo = '516'
		SELECT @IDConceptoGuarderia 						= IDConcepto from Nomina.tblCatConceptos with(nolock) where codigo = '503'
		SELECT @IDConceptoPrestacionesDineroPatronal		= IDConcepto from Nomina.tblCatConceptos with(nolock) where codigo = '502'
		SELECT @IDConceptoPrestacionesDineroObrera			= IDConcepto from Nomina.tblCatConceptos with(nolock) where codigo = '514'
		SELECT @IDConceptoRetiro							= IDConcepto from Nomina.tblCatConceptos with(nolock) where codigo = '509'
		SELECT @IDConceptoCesantiaVejezPatronal				= IDConcepto from Nomina.tblCatConceptos with(nolock) where codigo = '508'
		SELECT @IDConceptoCesantiaVejezObrera				= IDConcepto from Nomina.tblCatConceptos with(nolock) where codigo = '303'
		SELECT @IDConceptoInfonavitPatronal					= IDConcepto from Nomina.tblCatConceptos with(nolock) where codigo = '510'
		SELECT @IDConceptoInfonavitEmpleado					= IDConcepto from Nomina.tblCatConceptos with(nolock) where codigo = '304'
		SELECT @IDConceptoInfonavitEmpleadoSeguro			= IDConcepto from Nomina.tblCatConceptos with(nolock) where codigo = '305'

		--select * from Nomina.tblCatConceptos where codigo like '30%'


		SELECT 
			 @IDRegPatronal	= CC.IDRegPatronal
			,@IDMes			= CC.IDMes
			,@IDBimestre	= CC.IDBimestre
			,@EMA			= ISNULL(CC.EMA,0)
			,@EBA			= ISNULL(CC.EBA,0)
			,@Ejercicio		= CC.Ejercicio
			,@Bimestres		= b.Meses
			,@RegistroPatronal = r.RegistroPatronal 
		from IMSS.tblControlConfrontaIMSS CC WITH(NOLOCK)
			left join Nomina.tblcatBimestres B
				on b.IDBimestre = CC.IDBimestre
			left join RH.tblCatRegPatronal R
				on CC.IDRegPatronal = R.IDRegPatronal
		WHERE IDControlConfrontaIMSS = @IDControlConfrontaIMSS

		INSERT INTO @filtros(Catalogo,Value)
		VALUES('RegPatronal',@IDRegPatronal)


		IF(@EMA = 1)
		BEGIN
			INSERT INTO @TablasResultados(Titulo)
			SELECT 'EMA - '+UPPER(LEFT(DATENAME(MONTH, DATEFROMPARTS(2000, @IDMes, 1)), 3))+' - '+@RegistroPatronal
		END

		IF(@EBA = 1)
		BEGIN
			INSERT INTO @TablasResultados(Titulo)
			SELECT 'EBA - ('+UPPER(LEFT(DATENAME(MONTH, DATEFROMPARTS(2000, (select min(item) from app.split(@Bimestres,',')), 1)), 3))+' - '+UPPER(LEFT(DATENAME(MONTH, DATEFROMPARTS(2000, (select max(item) from app.split(@Bimestres,',')), 1)), 3))+') - '+@RegistroPatronal
		END

		select Titulo 
		from @TablasResultados
		order by ORDEN


	IF(@EMA = 1)
	BEGIN
		

		select @fechaIniMes = min(DATEADD(month,IDMes-1,DATEADD(year,@Ejercicio-1900,0)))   
			, @fechaFinMes=MAX(DATEADD(day,-1,DATEADD(month,IDMes,DATEADD(year,@Ejercicio-1900,0))))   
		from Nomina.tblCatMeses with (nolock)  
		where IDMes = @IDMes

		INSERT INTO @EmpleadosEMA
		EXEC RH.spBuscarEmpleados @IDUsuario = @IDUsuario, @dtFiltros = @filtros, @FechaIni = @FechaIniMes, @FechaFin = @FechaFinMes


		

		SELECT 
			ISNULL(SUA.NSS,'') AS  SUA_NSS,
			ISNULL(IDSE.NSS,'') AS  IDSE_NSS,
			ISNULL(ADG.IMSS,'') AS  ADG_NSS,
			CASE WHEN (SUA.NSS = IDSE.NSS and SUA.NSS = ADG.IMSS) THEN 'NO' ELSE 'SI' END as DIF_NSS,
			
			ISNULL(SUA.Nombre,'') AS  SUA_NOMBRE,
			ISNULL(IDSE.Nombre,'') AS  IDSE_NOMBRE,
			ISNULL(ADG.NOMBRECOMPLETO,'') AS  ADG_NOMBRE,
			CASE WHEN (SUA.Nombre = IDSE.Nombre and SUA.Nombre = ADG.NOMBRECOMPLETO) THEN 'NO' ELSE 'SI' END as DIF_NOMBRE,
			
			ISNULL(SUA.DIAS,0) AS  SUA_DIAS,
			ISNULL(IDSE.DIAS,0) AS  IDSE_DIAS,
			ISNULL(ADGDias.ImporteTotal1,0) AS  ADG_DIAS,
			CASE WHEN (SUA.DIAS = IDSE.DIAS and SUA.DIAS = ADGDias.ImporteTotal1) THEN 'NO' ELSE 'SI' END as DIF_DIAS,
			
			ISNULL(SUA.SalarioDiario,0) AS  SUA_SALARIODIARIO,
			ISNULL(IDSE.SalarioDiario,0) AS  IDSE_SALARIODIARIO,
			ISNULL(ADG.SalarioIntegrado,0) AS  ADG_SALARIODIARIO,
			CASE WHEN (SUA.SalarioDiario = IDSE.SalarioDiario and SUA.SalarioDiario = ADG.SalarioIntegrado) THEN 'NO' ELSE 'SI' END as DIF_SalarioDiario,
			
			ISNULL(SUA.CUOTAFIJA,0) AS  SUA_CUOTAFIJA,
			ISNULL(IDSE.CUOTAFIJA,0) AS  IDSE_CUOTAFIJA,
			ISNULL(ADGCUOTAFIJA.ImporteTotal1,0) AS  ADG_CUOTAFIJA,
			CASE WHEN (SUA.CUOTAFIJA = IDSE.CUOTAFIJA and SUA.CUOTAFIJA = ADGCUOTAFIJA.ImporteTotal1) THEN 'NO' ELSE 'SI' END as DIF_CUOTAFIJA,
			
			ISNULL(SUA.Excedentes ,0)AS  SUA_EXCEDENTE,
			ISNULL(IDSE.ExcedentePatronal ,0) AS  IDSE_EXCEDENTE_PATRONAL,
			ISNULL(IDSE.ExcedenteObrera  ,0)AS  IDSE_EXCEDENTE_OBRERA,
			ISNULL((IDSE.ExcedentePatronal + IDSE.ExcedenteObrera) ,0)as IDSE_EXCEDENTE,
			ISNULL(ADGEXCEDENTEPATRONAL.ImporteTotal1,0) AS  ADG_EXCEDENTE_PATRONAL,
			ISNULL(ADGEXCEDENTEOBRERA.ImporteTotal1 ,0)AS  ADG_EXCEDENTE_OBRERA,
			ISNULL((ADGEXCEDENTEPATRONAL.ImporteTotal1+ ADGEXCEDENTEOBRERA.ImporteTotal1 ),0) as ADG_EXCEDENTE,
			CASE WHEN (SUA.Excedentes = (IDSE.ExcedentePatronal + IDSE.ExcedenteObrera) and SUA.Excedentes = (ADGEXCEDENTEPATRONAL.ImporteTotal1+ ADGEXCEDENTEOBRERA.ImporteTotal1 )) THEN 'NO' ELSE 'SI' END as DIF_EXCEDENTES,

			ISNULL(SUA.PrestacionesDinero ,0)AS  SUA_PRESTACIONES_DINERO,
			ISNULL(IDSE.PrestacionesDineroPatronal ,0) AS  IDSE_PRESTACIONES_DINERO_PATRONAL,
			ISNULL(IDSE.PrestacionesDineroObrera  ,0)AS  IDSE_PRESTACIONES_DINERO_OBRERA,
			ISNULL((IDSE.PrestacionesDineroPatronal + IDSE.PrestacionesDineroObrera) ,0)as IDSE_PRESTACIONES_DINERO,
			ISNULL(ADGPRESTASIONESDINEROPATRONAL.ImporteTotal1,0) AS  ADG_PRESTACIONES_DINERO_PATRONAL,
			ISNULL(ADGPRESTASIONESDINEROOBRERA.ImporteTotal1 ,0)AS  ADG_PRESTACIONES_DINERO_OBRERA,
			ISNULL((ADGPRESTASIONESDINEROPATRONAL.ImporteTotal1+ ADGPRESTASIONESDINEROOBRERA.ImporteTotal1 ) ,0)as ADG_PRESTACIONES_DINERO,
			CASE WHEN (SUA.PrestacionesDinero = (IDSE.PrestacionesDineroPatronal + IDSE.PrestacionesDineroObrera) and SUA.PrestacionesDinero = (ADGPRESTASIONESDINEROPATRONAL.ImporteTotal1+ ADGPRESTASIONESDINEROOBRERA.ImporteTotal1 )) THEN 'NO' ELSE 'SI' END as DIF_PRESTACIONES_DINERO,

			ISNULL(SUA.GastosMedicosPensionados,0) AS  SUA_GASTOS_MEDICOS_PENSIONADOS,
			ISNULL(IDSE.GastosMedicosPensionadosPatronal ,0) AS  IDSE_GASTOS_MEDICOS_PENSIONADOS_PATRONAL,
			ISNULL(IDSE.GastosMedicosPensionadosObrera  ,0)AS  IDSE_GASTOS_MEDICOS_PENSIONADOS_OBRERA,
			ISNULL((IDSE.GastosMedicosPensionadosPatronal + IDSE.GastosMedicosPensionadosObrera),0) as IDSE_GASTOS_MEDICOS_PENSIONADOS,
			ISNULL(ADGGASTOSMEDICOSPENSIONADOSPATRONAL.ImporteTotal1 ,0)AS  ADG_GASTOS_MEDICOS_PENSIONADOS_PATRONAL,
			ISNULL(ADGGASTOSMEDICOSPENSIONADOSOBRERA.ImporteTotal1 ,0)AS  ADG_GASTOS_MEDICOS_PENSIONADOS_OBRERA,
			ISNULL((ADGGASTOSMEDICOSPENSIONADOSPATRONAL.ImporteTotal1+ ADGGASTOSMEDICOSPENSIONADOSOBRERA.ImporteTotal1 ),0) as ADG_GASTOS_MEDICOS_PENSIONADOS,
			CASE WHEN (SUA.GastosMedicosPensionados = (IDSE.GastosMedicosPensionadosPatronal + IDSE.GastosMedicosPensionadosObrera) and SUA.GastosMedicosPensionados = (ADGGASTOSMEDICOSPENSIONADOSPATRONAL.ImporteTotal1+ ADGGASTOSMEDICOSPENSIONADOSOBRERA.ImporteTotal1 )) THEN 'NO' ELSE 'SI' END as DIF_GASTOS_MEDICOS_PENSIONADOS,

			ISNULL(SUA.RiesgoTrabajo,0) AS  SUA_RIESGO_TRABAJO,
			ISNULL(IDSE.RiesgoTrabajo,0) AS  IDSE_RIESGO_TRABAJO,
			ISNULL(ADGRIESGOTRABAJO.ImporteTotal1,0) AS  ADG_RIESGO_TRABAJO,
			CASE WHEN (SUA.RiesgoTrabajo = IDSE.RiesgoTrabajo and SUA.RiesgoTrabajo = ADGRIESGOTRABAJO.ImporteTotal1) THEN 'NO' ELSE 'SI' END as DIF_RIESGO_TRABAJO,


			ISNULL(SUA.InvalidezVida,0) AS  SUA_INVALIDEZ_VIDA,
			ISNULL(IDSE.InvalidezVidaPatronal ,0) AS  IDSE_INVALIDEZ_VIDA_PATRONAL,
			ISNULL(IDSE.InvalidezVidaObreara ,0) AS  IDSE_INVALIDEZ_VIDA_OBRERA,
			ISNULL((IDSE.InvalidezVidaPatronal + IDSE.InvalidezVidaObreara),0) as IDSE_INVALIDEZ_VIDA,
			ISNULL(ADGINVALIDEZVIDAPATRONAL.ImporteTotal1,0) AS  ADG_INVALIDEZ_VIDA_PATRONAL,
			ISNULL(ADGINVALIDEZVIDAOBRERA.ImporteTotal1 ,0)AS  ADG_INVALIDEZ_VIDA_OBRERA,
			ISNULL((ADGINVALIDEZVIDAPATRONAL.ImporteTotal1+ ADGINVALIDEZVIDAOBRERA.ImporteTotal1 ),0) as ADG_INVALIDEZ_VIDA,
			CASE WHEN (SUA.InvalidezVida = (IDSE.InvalidezVidaPatronal + IDSE.InvalidezVidaObreara) and SUA.InvalidezVida = (ADGINVALIDEZVIDAPATRONAL.ImporteTotal1+ ADGINVALIDEZVIDAOBRERA.ImporteTotal1 )) THEN 'NO' ELSE 'SI' END as DIF_INVALIDEZ_VIDA,

			ISNULL(SUA.GuarderiasPrestacionesSociales ,0)AS  SUA_GUARDERIA,
			ISNULL(IDSE.GuarderiasPrestacionesSociales ,0)AS  IDSE_GUARDERIA,
			ISNULL(ADGGUARDERIA.ImporteTotal1 ,0)AS  ADG_GUARDERIA,
			CASE WHEN (SUA.GuarderiasPrestacionesSociales = IDSE.GuarderiasPrestacionesSociales and SUA.GuarderiasPrestacionesSociales = ADGGUARDERIA.ImporteTotal1) THEN 'NO' ELSE 'SI' END as DIF_GUARDERIA,

			ISNULL((SUA.CuotaFija+SUA.Excedentes+SUA.PrestacionesDinero+SUA.GastosMedicosPensionados+ SUA.RiesgoTrabajo+ SUA.InvalidezVida + SUA.GuarderiasPrestacionesSociales) ,0)as SUA_TOTAL,
			ISNULL((SUA.CUOTAFIJA+(IDSE.ExcedentePatronal + IDSE.ExcedenteObrera)+(IDSE.PrestacionesDineroPatronal + IDSE.PrestacionesDineroObrera)+(IDSE.GastosMedicosPensionadosPatronal + IDSE.GastosMedicosPensionadosObrera)+ IDSE.RiesgoTrabajo+ (IDSE.InvalidezVidaPatronal + IDSE.InvalidezVidaObreara) + IDSE.GuarderiasPrestacionesSociales) ,0)as IDSE_TOTAL,
			ISNULL((ADGCUOTAFIJA.ImporteTotal1+(ADGEXCEDENTEPATRONAL.ImporteTotal1 + ADGEXCEDENTEOBRERA.ImporteTotal1)+(ADGPRESTASIONESDINEROPATRONAL.ImporteTotal1 + ADGPRESTASIONESDINEROOBRERA.ImporteTotal1)+(ADGGASTOSMEDICOSPENSIONADOSPATRONAL.ImporteTotal1 + ADGGASTOSMEDICOSPENSIONADOSOBRERA.ImporteTotal1)+ ADGRIESGOTRABAJO.ImporteTotal1+ (ADGINVALIDEZVIDAPATRONAL.ImporteTotal1 + ADGINVALIDEZVIDAOBRERA.ImporteTotal1) + ADGGUARDERIA.ImporteTotal1) ,0)as ADG_TOTAL


		from IMSS.tblDetalleConfrontaEMASUA SUA with(nolock)
			left join IMSS.tblDetalleConfrontaEMAIDSE 	IDSE with(nolock)
				on SUA.IDControlConfrontaIMSS = IDSE.IDControlConfrontaIMSS
					and SUA.NSS = IDSE.NSS
			left join @EmpleadosEMA ADG 
				on SUA.NSS = ADG.IMSS
			CROSS APPLY Nomina.fnObtenerAcumuladoPorConceptoPorMesRegPatronal(ISNULL(ADG.IDEmpleado,0),@IDConceptoDiasCotizados,@IDMes, @Ejercicio,@IDRegPatronal) ADGDias
			CROSS APPLY Nomina.fnObtenerAcumuladoPorConceptoPorMesRegPatronal(ISNULL(ADG.IDEmpleado,0),@IDConceptoCuotaFija,@IDMes, @Ejercicio,@IDRegPatronal) ADGCUOTAFIJA
			CROSS APPLY Nomina.fnObtenerAcumuladoPorConceptoPorMesRegPatronal(ISNULL(ADG.IDEmpleado,0),@IDConceptoExcedentePatronal,@IDMes, @Ejercicio,@IDRegPatronal) ADGEXCEDENTEPATRONAL
			CROSS APPLY Nomina.fnObtenerAcumuladoPorConceptoPorMesRegPatronal(ISNULL(ADG.IDEmpleado,0),@IDConceptoExcedenteObrera,@IDMes, @Ejercicio,@IDRegPatronal) ADGEXCEDENTEOBRERA
			CROSS APPLY Nomina.fnObtenerAcumuladoPorConceptoPorMesRegPatronal(ISNULL(ADG.IDEmpleado,0),@IDConceptoPrestacionesDineroPatronal,@IDMes, @Ejercicio,@IDRegPatronal) ADGPRESTASIONESDINEROPATRONAL
			CROSS APPLY Nomina.fnObtenerAcumuladoPorConceptoPorMesRegPatronal(ISNULL(ADG.IDEmpleado,0),@IDConceptoPrestacionesDineroObrera,@IDMes, @Ejercicio,@IDRegPatronal) ADGPRESTASIONESDINEROOBRERA
			CROSS APPLY Nomina.fnObtenerAcumuladoPorConceptoPorMesRegPatronal(ISNULL(ADG.IDEmpleado,0),@IDConceptoGastosMedicosPensionadosPatronal,@IDMes, @Ejercicio,@IDRegPatronal) ADGGASTOSMEDICOSPENSIONADOSPATRONAL
			CROSS APPLY Nomina.fnObtenerAcumuladoPorConceptoPorMesRegPatronal(ISNULL(ADG.IDEmpleado,0),@IDConceptoGastosMedicosPensionadosObrera,@IDMes, @Ejercicio,@IDRegPatronal) ADGGASTOSMEDICOSPENSIONADOSOBRERA
			CROSS APPLY Nomina.fnObtenerAcumuladoPorConceptoPorMesRegPatronal(ISNULL(ADG.IDEmpleado,0),@IDConceptoRiesgoTrabajo,@IDMes, @Ejercicio,@IDRegPatronal) ADGRIESGOTRABAJO
			CROSS APPLY Nomina.fnObtenerAcumuladoPorConceptoPorMesRegPatronal(ISNULL(ADG.IDEmpleado,0),@IDConceptoInvalidezVidaPatronal,@IDMes, @Ejercicio,@IDRegPatronal) ADGINVALIDEZVIDAPATRONAL
			CROSS APPLY Nomina.fnObtenerAcumuladoPorConceptoPorMesRegPatronal(ISNULL(ADG.IDEmpleado,0),@IDConceptoInvalidezVidaObrera,@IDMes, @Ejercicio,@IDRegPatronal) ADGINVALIDEZVIDAOBRERA
			CROSS APPLY Nomina.fnObtenerAcumuladoPorConceptoPorMesRegPatronal(ISNULL(ADG.IDEmpleado,0),@IDConceptoGuarderia,@IDMes, @Ejercicio,@IDRegPatronal) ADGGUARDERIA
		
	END

	IF(@EBA = 1)
	BEGIN
		select @fechaIniBimestre = min(DATEADD(month,IDMes-1,DATEADD(year,@Ejercicio-1900,0)))   
			, @fechaFinBimestre=MAX(DATEADD(day,-1,DATEADD(month,IDMes,DATEADD(year,@Ejercicio-1900,0))))   
		from Nomina.tblCatMeses with (nolock)  
		where cast(IDMes as varchar) in (select item from app.Split( @Bimestres,','))  

		--select @fechaIniBimestre,@fechaFinBimestre

		INSERT INTO @EmpleadosEBA
		EXEC RH.spBuscarEmpleados @IDUsuario = @IDUsuario, @dtFiltros = @filtros, @FechaIni = @fechaIniBimestre, @FechaFin = @fechaFinBimestre

	--	select * from @EmpleadosEBA


		SELECT 
			ISNULL(SUA.NSS,'') AS  SUA_NSS,
			ISNULL(IDSE.NSS ,'')AS  IDSE_NSS,
			ISNULL(ADG.IMSS ,'')AS  ADG_NSS,
			CASE WHEN (SUA.NSS = IDSE.NSS and SUA.NSS = ADG.IMSS) THEN 'NO' ELSE 'SI' END as DIF_NSS,
			
			ISNULL(SUA.Nombre ,'')AS  SUA_NOMBRE,
			ISNULL(IDSE.Nombre ,'')AS  IDSE_NOMBRE,
			ISNULL(ADG.NOMBRECOMPLETO ,'')AS  ADG_NOMBRE,
			CASE WHEN (SUA.Nombre = IDSE.Nombre and SUA.Nombre = ADG.NOMBRECOMPLETO) THEN 'NO' ELSE 'SI' END as DIF_NOMBRE,
			
			ISNULL(SUA.DIAS ,0)AS  SUA_DIAS,
			ISNULL(IDSE.DIAS ,0)AS  IDSE_DIAS,
			ISNULL(ADGDias.ImporteTotal1 ,0)AS  ADG_DIAS,
			CASE WHEN (SUA.DIAS = IDSE.DIAS and SUA.DIAS = ADGDias.ImporteTotal1) THEN 'NO' ELSE 'SI' END as DIF_DIAS,
			
			ISNULL(SUA.SalarioDiario ,0) AS  SUA_SALARIODIARIO,
			ISNULL(IDSE.SalarioDiario  ,0)AS  IDSE_SALARIODIARIO,
			ISNULL(ADG.SalarioIntegrado  ,0)AS  ADG_SALARIODIARIO,
			CASE WHEN (SUA.SalarioDiario = IDSE.SalarioDiario and SUA.SalarioDiario = ADG.SalarioIntegrado) THEN 'NO' ELSE 'SI' END as DIF_SalarioDiario,
			
			ISNULL(SUA.Retiro  ,0)AS  SUA_RETIRO,
			ISNULL(IDSE.Retiro  ,0)AS  IDSE_RETIRO,
			ISNULL(ADGRETIRO.ImporteTotal1  ,0)AS  ADG_RETIRO,
			CASE WHEN (SUA.Retiro = IDSE.Retiro and SUA.Retiro = ADGRETIRO.ImporteTotal1) THEN 'NO' ELSE 'SI' END as DIF_RETIRO,
			
			ISNULL(SUA.CesantiaVejezPatronal  ,0)AS  SUA_CESANTIA_VEJEZ_PATRONAL,
			ISNULL(IDSE.CesantiaVejezPatronal   ,0)AS  IDSE_CESANTIA_VEJEZ_PATRONAL,
			ISNULL(ADGCESANTIAVEJEZPATRONAL.ImporteTotal1  ,0)AS  ADG_CESANTIA_VEJEZ_PATRONAL,
			CASE WHEN (SUA.CesantiaVejezPatronal = IDSE.CesantiaVejezPatronal and SUA.CesantiaVejezPatronal = ADGCESANTIAVEJEZPATRONAL.ImporteTotal1) THEN 'NO' ELSE 'SI' END as DIF_CESANTIA_VEJEZ_PATRONAL,

			ISNULL(SUA.CesantiaVejezObrero  ,0)AS  SUA_CESANTIA_VEJEZ_OBRERA,
			ISNULL(IDSE.CesantiaVejezObrero   ,0)AS  IDSE_CESANTIA_VEJEZ_OBRERA,
			ISNULL(ADGCESANTIAVEJEZOBRERA.ImporteTotal1  ,0)AS  ADG_CESANTIA_VEJEZ_OBRERA,
			CASE WHEN (SUA.CesantiaVejezObrero = IDSE.CesantiaVejezObrero and SUA.CesantiaVejezObrero = ADGCESANTIAVEJEZOBRERA.ImporteTotal1) THEN 'NO' ELSE 'SI' END as DIF_CESANTIA_VEJEZ_OBRERA,

			
			ISNULL(SUA.AportacionPatronal  ,0)AS  SUA_INFONAVIT_PATRONAL,
			ISNULL(IDSE.AportacionPatronal   ,0)AS  IDSE_INFONAVIT_PATRONAL,
			ISNULL(ADGINFONAVITPATRONAL.ImporteTotal1  ,0)AS  ADG_INFONAVIT_PATRONAL,
			CASE WHEN (SUA.AportacionPatronal = IDSE.AportacionPatronal and SUA.AportacionPatronal = ADGINFONAVITPATRONAL.ImporteTotal1) THEN 'NO' ELSE 'SI' END as DIF_INFONAVIT_PATRONAL,

				
			ISNULL(SUA.Amortizacion  ,0)AS  SUA_INFONAVIT_OBRERA,
			ISNULL(IDSE.Amortizacion  ,0) AS  IDSE_INFONAVIT_OBRERA,
			ISNULL((ADGINFONAVITOBRERA.ImporteTotal1 +ADGINFONAVITOBRERASEGURO.ImporteTotal1)  ,0)AS  ADG_INFONAVIT_OBRERA,
			--ADGINFONAVITOBRERASEGURO.ImporteTotal1 ADG_INFONAVIT_OBRERA_SEGURO,
			CASE WHEN (SUA.Amortizacion = IDSE.Amortizacion and SUA.Amortizacion = ADGINFONAVITOBRERA.ImporteTotal1 + ADGINFONAVITOBRERASEGURO.ImporteTotal1) THEN 'NO' ELSE 'SI' END as DIF_INFONAVIT_OBRERA,

			
			ISNULL((SUA.Retiro+SUA.CesantiaVejezPatronal+SUA.CesantiaVejezObrero+SUA.AportacionPatronal+ SUA.Amortizacion) ,0) as SUA_TOTAL,
			ISNULL((SUA.Retiro+(IDSE.CesantiaVejezPatronal + IDSE.CesantiaVejezObrero)+(IDSE.AportacionPatronal + IDSE.Amortizacion))  ,0)as IDSE_TOTAL,
			ISNULL((ADGRETIRO.ImporteTotal1+(ADGCESANTIAVEJEZPATRONAL.ImporteTotal1 + ADGCESANTIAVEJEZOBRERA.ImporteTotal1)+(ADGINFONAVITPATRONAL.ImporteTotal1 + ADGINFONAVITOBRERA.ImporteTotal1))  ,0)as ADG_TOTAL




		from IMSS.tblDetalleConfrontaEBASUA SUA with(nolock)
			left join IMSS.tblDetalleConfrontaEBAIDSE 	IDSE with(nolock)
				on SUA.IDControlConfrontaIMSS = IDSE.IDControlConfrontaIMSS
					and SUA.NSS = IDSE.NSS
			left join @EmpleadosEBA ADG 
				on SUA.NSS = ADG.IMSS
			CROSS APPLY Nomina.fnObtenerAcumuladoPorConceptoPorBimestreRegPatronal(ISNULL(ADG.IDEmpleado,0),@IDConceptoDiasCotizados,@IDBimestre, @Ejercicio,@IDRegPatronal) ADGDias
			CROSS APPLY Nomina.fnObtenerAcumuladoPorConceptoPorBimestreRegPatronal(ISNULL(ADG.IDEmpleado,0),@IDConceptoRetiro,@IDBimestre, @Ejercicio,@IDRegPatronal) ADGRETIRO
			CROSS APPLY Nomina.fnObtenerAcumuladoPorConceptoPorBimestreRegPatronal(ISNULL(ADG.IDEmpleado,0),@IDConceptoCesantiaVejezPatronal,@IDBimestre, @Ejercicio,@IDRegPatronal) ADGCESANTIAVEJEZPATRONAL
			CROSS APPLY Nomina.fnObtenerAcumuladoPorConceptoPorBimestreRegPatronal(ISNULL(ADG.IDEmpleado,0),@IDConceptoCesantiaVejezObrera,@IDBimestre, @Ejercicio,@IDRegPatronal) ADGCESANTIAVEJEZOBRERA
			CROSS APPLY Nomina.fnObtenerAcumuladoPorConceptoPorBimestreRegPatronal(ISNULL(ADG.IDEmpleado,0),@IDConceptoInfonavitPatronal,@IDBimestre, @Ejercicio,@IDRegPatronal) ADGINFONAVITPATRONAL
			CROSS APPLY Nomina.fnObtenerAcumuladoPorConceptoPorBimestreRegPatronal(ISNULL(ADG.IDEmpleado,0),@IDConceptoInfonavitEmpleado,@IDBimestre, @Ejercicio,@IDRegPatronal) ADGINFONAVITOBRERA
			CROSS APPLY Nomina.fnObtenerAcumuladoPorConceptoPorBimestreRegPatronal(ISNULL(ADG.IDEmpleado,0),@IDConceptoInfonavitEmpleadoSeguro,@IDBimestre, @Ejercicio,@IDRegPatronal) ADGINFONAVITOBRERASEGURO
			
	END

END
GO
