USE [p_adagioRHElPro]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--/****************************************************************************************************     
--** Descripción  : Calcular PTU del colaborador    
--** Autor   : Jose Roman   
--** Email   : jose.roman@adagio.com.mx    
--** FechaCreacion : 2019-04-29    
--** Paremetros  :                  
--****************************************************************************************************    
--HISTORIAL DE CAMBIOS    
--Fecha(yyyy-mm-dd)		Autor				Comentario    
---------------------	------------------- ------------------------------------------------------------    
--2024-04-19			JOSE ROMAN			SE REALIZAN AJUSTES PARA OBTENER LOS TRABAJADORES QUE TRABAJARON
--											PARCIALMENTE EN UNA RAZON SOCIAL Y LUEGO SE CAMBIARON A OTRA
--											RAZON SOCIAL.												
--***************************************************************************************************/  
/*
	EXEC [Nomina].[spCalcularPTU] @IDPTU = 5, @IDUsuario = 1
*/

CREATE PROCEDURE [Nomina].[spCalcularPTU]
(
	 @IDPTU int
	,@IDUsuario int
)
AS
BEGIN
	SET FMTONLY OFF;
	--declare 
	--	@IDPTU int = 2
	--	,@IDUsuario int = 1
	--;

	DECLARE 
		@IDEmpresa int,
		@Ejercicio int,
		@ConceptosIntegranSueldo varchar(max),
		@DiasDescontar varchar(MAX),
		@DescontarIncapacidades bit = 0,
		@TiposIncapacidadesADescontar varchar(max),
		@CantidadGanancia Decimal(18,4),
		@CantidadRepartir Decimal(18,4),
		@CantidadPendiente Decimal(18,4),
		@DiasMinimosTrabajados int,
		@DiasMaximosTrabajados int,
		@EjercicioPago int,
		@IDPeriodo	int,
		@TotalRepartir Decimal(18,4),
		@MontoSueldo Decimal(18,2),
		@MontoDias Decimal(18,2),
		@FactorSueldo decimal(18,9),
		@FactorDias decimal(18,9),
		@IDEmpleadoTipoSalarioMensualConfianza int,
		@FechaInicial Date,
		@FechaFinal Date,
		@dtEmpleados RH.dtEmpleados,
		@dtFiltros Nomina.dtFiltrosRH,
		@TopeSindical decimal(18,2),
		@TopeSalarioAnual decimal(18,2),
		@TopeConfianza decimal(18,2),
		@AplicarReforma bit,
		@dtFechas app.dtFechas, 
		@dtFechasPromSalario3Meses app.dtFechas, 
		@FechaHoy Date,
		@Fecha3Meses Date,
		@dtEmpleadosMovimientoSalario RH.dtEmpleados ,
		@ConceptoPTU Varchar(10) = '131',
		@IDConceptoPTU int ,
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spCalcularPTU]',
		@Tabla		varchar(max) = '[Nomina].[tblPTUEmpleados]',
		@Accion		varchar(20)	= 'EJECUCIÓN CÁLCULO PTU',
		@AplicarPTUFinanciero bit = 0
	;	


	SET @FechaHoy = CAST(GETDATE() as DATE)
	SET @Fecha3Meses = DATEADD(MONTH,-3,CAST(GETDATE() as DATE))

	/*OBTENEMOS EL ID DEL CONCEPTO DE PTU*/
	SELECT TOP 1 @IDConceptoPTU = IDConcepto FROM Nomina.tblCatConceptos WITH(NOLOCK) WHERE Codigo = @ConceptoPTU

	/*OBTENEMOS LA CONFIGURACIÓN DEL PTU QUE QUEREMOS CALCULAR*/
	SELECT
		@IDEmpresa					= IDEmpresa,
		@Ejercicio					= Ejercicio,
		@ConceptosIntegranSueldo	= ConceptosIntegranSueldo,
		@DiasDescontar				= DiasDescontar,
		@DescontarIncapacidades		= DescontarIncapacidades, 
		@TiposIncapacidadesADescontar = TiposIncapacidadesADescontar,
		@CantidadGanancia			= ISNULL(CantidadGanancia,0.00) ,
		@CantidadRepartir			= ISNULL(CantidadRepartir,0.00), 
		@CantidadPendiente			= ISNULL(CantidadPendiente,0.00), 
		@DiasMinimosTrabajados      = DiasMinimosTrabajados,
		@EjercicioPago				= EjercicioPago,
		@IDPeriodo					= IDPeriodo,
		@MontoSueldo				= cast((ISNULL(CantidadPendiente, cast(0.00 as decimal(18 ,2)))+ISNULL(CantidadRepartir, cast(0.00 as decimal(18 ,2))))/2.00 as decimal(18 ,2)),
		@MontoDias					= cast((ISNULL(CantidadPendiente, cast(0.00 as decimal(18 ,2)))+ISNULL(CantidadRepartir, cast(0.00 as decimal(18 ,2))))/2.00 as decimal(18 ,2)), 
		@TotalRepartir				= ISNULL(CantidadPendiente, cast(0.00 as decimal(18 ,2)))+ISNULL(CantidadRepartir, cast(0.00 as decimal(18 ,2))), 
		@FechaInicial				= Cast(Cast(Ejercicio as Varchar(4)) +'-01-01' as date),
		@FechaFinal					= Cast(Cast(Ejercicio as Varchar(4)) +'-12-31' as date),
		@TopeConfianza				= ISNULL(TopeConfianza,0.00),
		@AplicarReforma				= isnull(AplicarReforma,0),
		@AplicarPTUFinanciero		= isnull(AplicarPTUFinanciero,0)
	FROM Nomina.tblPTU WITH(NOLOCK)
	WHERE IDPTU = @IDPTU

	/*OBTENERMOS TODOS LOS DIAS DEL AÑO EN UNA LISTA*/
	INSERT INTO @dtFechas  
	EXEC [App].[spListaFechas] @FechaIni = @FechaInicial, @FechaFin = @FechaFinal  

	/*AUDITORIA DE CALCULO*/
	select @NewJSON = a.JSON
	from (
		Select 
			@IDEmpresa					 as IDEmpresa					
			,@Ejercicio					 as Ejercicio					
			,@ConceptosIntegranSueldo	 as ConceptosIntegranSueldo	
			,@DiasDescontar				 as DiasDescontar				
			,@DescontarIncapacidades		 as DescontarIncapacidades		
			,@TiposIncapacidadesADescontar as TiposIncapacidadesADesconta
			,@CantidadGanancia			 as CantidadGanancia			
			,@CantidadRepartir			 as CantidadRepartir			
			,@CantidadPendiente			 as CantidadPendiente			
			,@DiasMinimosTrabajados       as DiasMinimosTrabajados      
			,@EjercicioPago				 as EjercicioPago				
			,@IDPeriodo					 as IDPeriodo					
			,@MontoSueldo				 as MontoSueldo				
			,@MontoDias					 as MontoDias					
			,@TotalRepartir				 as TotalRepartir				
			,@FechaInicial				 as FechaInicial				
			,@FechaFinal				 as FechaFinal	
			,@AplicarReforma			 as AplicarReforma
	) b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
	
	--select @CantidadDias as CantidadDias, @CantidadMonto as CantidadMonto

	/*	COMENTARIO: JOSE ROMAN 2024-04-19
		EXEC [RH].[spBuscarEmpleados]
		LA BUSQUEDA DE EMPLEADOS DEBE SER COMPLETA SIN FILTROS.
		ESTO NOS PERMITE OBTENER A TODOS LOS EMPLEADOS QUE ESTUVIERON VIGENTES EN ALGUN MOMENTO DEL AÑO..
	*/

	INSERT INTO @dtEmpleados
	EXEC [RH].[spBuscarEmpleados]
		 @FechaIni  = @FechaInicial,                
		 @Fechafin  = @FechaFinal, 
		 @IDUsuario = @IDUsuario


	IF object_id('tempdb..#tempVigenciaEmpleados') IS NOT NULL DROP TABLE #tempVigenciaEmpleados  
  
	CREATE TABLE #tempVigenciaEmpleados (  
		IDEmpleado int null,  
		Fecha Date null,  
		Vigente bit null  
	)  

	/*	COMENTARIO: JOSE ROMAN 2024-04-19
		Exec [RH].[spBuscarListaFechasVigenciaEmpresaEmpleado] 
		ESTE PROCEDIMIENTO OBTENDRA POR DIAS Y SI EL EMPLEADO ESTA VIGENTE
		Y CON CUAL RAZON SOCIAL ESTABA VIGENTE.
	*/
  
	INSERT INTO #tempVigenciaEmpleados  
	EXEC [RH].[spBuscarListaFechasVigenciaEmpresaEmpleado]  
		@dtEmpleados	= @dtEmpleados  
		,@Fechas		= @dtFechas  
		,@IDUsuario		= 1
		,@IDEmpresa =  @IDEmpresa

	/*	COMENTARIO: JOSE ROMAN 2024-04-19
		LUEGO ELIMINAMOS LOS REGISTROS DE LOS COLABORADORES QUE NO ESTEN VIGENTES
		YA QUE EL PROCEDIMIENTO SOLO NOS DARA LOS DIAS DE QUE PERTENEZCAN LA RAZON SOCIAL
		SOLICITADA
	*/
  
	DELETE  #tempVigenciaEmpleados WHERE Vigente = 0

	DELETE e
	FROM @dtEmpleados e 
	WHERE IDEmpleado NOT IN(
		SELECT DISTINCT IDEmpleado FROM #tempVigenciaEmpleados
	)

	-- Eliminar de @dtEmpleados los trabajadores que no se les paga PTU
	DELETE e
	FROM @dtEmpleados e
		left join RH.tblEmpleadoPTU ptu WITH(NOLOCK) ON ptu.IDEmpleado = e.IDEmpleado
	WHERE isnull(ptu.PTU,0) = 0


	DECLARE @tempAcumulado as TABLE (
		IDEmpleado int,
		ClaveEmpleado varchar(20),
		Colaborador varchar(500),
		CodigoConcepto varchar(20),
		Concepto varchar(255),
		Total decimal(18,2)
	)

	INSERT INTO @tempAcumulado
	EXEC [Nomina].[spBuscarAcumuladoPorEjercicioyEmpresaConceptosEmpleados]
		@Ejercicio = @Ejercicio,
		@CodigosConceptos = @ConceptosIntegranSueldo,
		@dtEmpleados = @dtEmpleados,
		@IDUsuario = @IDUsuario,
		@IDEmpresa = @IDEmpresa


	DECLARE @acum as TABLE (
		IDEmpleado INT,
		Total DECIMAL(18,2)
	)

	INSERT INTO @acum(IDEmpleado, Total)
	SELECT IDEmpleado, SUM(total)
	FROM @tempAcumulado
	GROUP BY IDEmpleado

	
	IF object_id('tempdb..#tempMovAfilPTU') IS NOT NULL DROP TABLE #tempMovAfilPTU    

	DECLARE @dtMovAfiliatorios as TABLE(
		IDMovAfiliatorio	int			null
		,Fecha	date					null
		,IDEmpleado	int					null
		,IDTipoMovimiento	int			null
		,FechaIMSS	date				null
		,FechaIDSE	date				null
		,IDRazonMovimiento	int			null
		,SalarioDiario	decimal			null
		,SalarioIntegrado	decimal		null
		,SalarioVariable	decimal		null
		,SalarioDiarioReal	decimal		null
		,IDRegPatronal	int				null
		,RespetarAntiguedad	bit			null
		,FechaAntiguedad	date		null
		,IDTipoPrestacion	int			null
	)

	insert into @dtMovAfiliatorios(
		IDMovAfiliatorio
		,Fecha
		,IDEmpleado
		,IDTipoMovimiento
		,FechaIMSS
		,FechaIDSE
		,IDRazonMovimiento
		,SalarioDiario
		,SalarioIntegrado
		,SalarioVariable
		,SalarioDiarioReal
		,IDRegPatronal
		,RespetarAntiguedad
		,FechaAntiguedad
		,IDTipoPrestacion
	)
	select
		 mov.IDMovAfiliatorio
		,mov.Fecha
		,mov.IDEmpleado
		,mov.IDTipoMovimiento
		,mov.FechaIMSS
		,mov.FechaIDSE
		,mov.IDRazonMovimiento
		,mov.SalarioDiario
		,mov.SalarioIntegrado
		,mov.SalarioVariable
		,mov.SalarioDiarioReal
		,mov.IDRegPatronal
		,mov.RespetarAntiguedad
		,mov.FechaAntiguedad
		,mov.IDTipoPrestacion
	from IMSS.tblMovAfiliatorios mov with(nolock)
		inner join @dtEmpleados e
			on e.IDEmpleado = mov.IDEmpleado



      
	SELECT 
		IDEmpleado
		,FechaAlta
		,FechaBaja             
		,CASE WHEN ((FechaBaja IS NOT NULL AND FechaReingreso IS NOT NULL) AND FechaReingreso > FechaBaja) THEN FechaReingreso ELSE NULL END as FechaReingreso              
		,IDMovAfiliatorio      
	INTO #tempMovAfilPTU              
    FROM (SELECT DISTINCT tm.IDEmpleado,              
				CASE WHEN(IDEmpleado is not null) THEN 
					(SELECT TOP 1 Fecha               
						FROM @dtMovAfiliatorios  mAlta               
							JOIN [IMSS].[tblCatTipoMovimientos]   c   on mAlta.IDTipoMovimiento=c.IDTipoMovimiento              
						WHERE mAlta.IDEmpleado=tm.IDEmpleado and c.Codigo='A'                
						ORDER BY mAlta.Fecha DESC , c.Prioridad DESC 
					 ) END AS FechaAlta,              
				CASE WHEN (IDEmpleado IS NOT NULL) THEN 
					(SELECT TOP 1 Fecha               
					 FROM @dtMovAfiliatorios  mBaja               
						JOIN [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mBaja.IDTipoMovimiento=c.IDTipoMovimiento              
					 WHERE mBaja.IDEmpleado=tm.IDEmpleado and c.Codigo='B'                
						AND mBaja.Fecha <= @FechaFinal               
					ORDER BY mBaja.Fecha DESC, C.Prioridad DESC
					) END AS FechaBaja,              
				CASE WHEN (IDEmpleado IS NOT NULL) THEN 
					(SELECT TOP 1 Fecha               
					FROM @dtMovAfiliatorios  mReingreso               
						JOIN [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mReingreso.IDTipoMovimiento=c.IDTipoMovimiento              
					WHERE mReingreso.IDEmpleado=tm.IDEmpleado and c.Codigo='R'                
						AND mReingreso.Fecha <= @FechaFinal               
					ORDER BY mReingreso.Fecha DESC, C.Prioridad DESC
					) END AS FechaReingreso                
			,(SELECT TOP 1 mSalario.IDMovAfiliatorio 
				FROM @dtMovAfiliatorios  mSalario              
					JOIN [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mSalario.IDTipoMovimiento=c.IDTipoMovimiento              
				WHERE mSalario.IDEmpleado=tm.IDEmpleado AND c.Codigo IN ('A','M','R')               
				ORDER BY mSalario.Fecha DESC 
				) as IDMovAfiliatorio                                               
        FROM @dtMovAfiliatorios  tm  ) mm       
	 

	


	
	IF object_id('tempdb..#tempDataEmpleados') IS NOT NULL DROP TABLE #tempDataEmpleados 

	--se agrega em al salario por que toma el salario de la tabla master que contiene lo actual
	SELECT 
		e.IDEmpleado
		,e.ClaveEmpleado
		,e.NOMBRECOMPLETO
		,e.Departamento
		,e.Sucursal
		,e.Puesto
		,em.SalarioDiario AS SalarioDiario
		,e.Empresa
		,ma.FechaAlta 
		,ma.FechaBaja 
		,ma.FechaReingreso
		,ee.EmpresaInicio
		,ee.EmpresaFin 
		,FechaInicioHistoria = 
			CASE WHEN MA.FechaReingreso IS NOT NULL AND MA.FechaReingreso > MA.FechaAlta AND MA.FechaReingreso BETWEEN @FechaInicial and @FechaFinal THEN MA.FechaReingreso 
				WHEN MA.FechaAlta > @FechaInicial THEN MA.FechaAlta
			ELSE @FechaInicial END
		,FechaFinHistoria = CASE WHEN ISNULL(em.Vigente, 0) = 0 AND MA.FechaBaja BETWEEN @FechaInicial AND @FechaFinal THEN MA.FechaBaja
								ELSE @FechaFinal END
		,e.IDTipoPrestacion
		,TP.Descripcion AS TipoPrestacion
		,tp.Sindical
		,salarioAnual.Total AS SalarioAcumuladoReal
		,salarioAnual.Total AS Salario
		--,isnull(((avgSueldo.SalarioDiario)*90.0)/3.0,0) as SueldoPromedio3Meses
		--,isnull(PromPTU3Anios.PromPTU3Anios,0) as PromPTU3Anios
		, 0 as PTURecomendado
	INTO #tempDataEmpleados
	FROM @dtEmpleados e
		JOIN RH.tblEmpleadosMaster em WITH(NOLOCK) ON em.IDEmpleado = e.IDEmpleado
		INNER JOIN #tempMovAfilPTU MA ON MA.IDEmpleado = e.IDEmpleado
		INNER JOIN (
				SELECT empresa.IDEmpresa, empresa.IDEmpleado, min(empresa.FechaIni) EmpresaInicio, max(empresa.FechaFin) EmpresaFin 
				FROM rh.tblEmpresaEmpleado empresa WITH(NOLOCK)
				WHERE empresa.IDEmpresa = @IDEmpresa 
				GROUP BY empresa.IDEmpleado, empresa.IDEmpresa ) EE 
			ON e.IDEmpleado = ee.IDEmpleado
			AND EE.EmpresaInicio<= @FechaFinal and EE.EmpresaFin >= @FechaInicial   
		
		INNER JOIN RH.tblCatTiposPrestaciones TP WITH(NOLOCK) ON TP.IDTipoPrestacion = e.IDTipoPrestacion
		INNER JOIN @acum salarioAnual ON salarioAnual.IDEmpleado = e.IDEmpleado
	ORDER BY E.ClaveEmpleado







	IF object_id('tempdb..#tempDataEmpleadosGeneral') IS NOT NULL DROP TABLE #tempDataEmpleadosGeneral
	IF object_id('tempdb..#tempDataEmpleadosDiasDescontar') IS NOT NULL DROP TABLE #tempDataEmpleadosDiasDescontar
	IF object_id('tempdb..#tempDataEmpleadosIncapacidades') IS NOT NULL DROP TABLE #tempDataEmpleadosIncapacidades

	SELECT temp_data.IDEmpleado, COUNT(ie.IDIncidencia)	as Total	
		into #tempDataEmpleadosDiasDescontar
	FROM #tempDataEmpleados temp_data
	inner join Asistencia.tblIncidenciaEmpleado ie WITH(NOLOCK)
		on temp_data.IDEmpleado = ie.IDEmpleado
		INNER JOIN rh.tblEmpresaEmpleado ee WITH(NOLOCK)
			ON ee.idEmpleado = ie.IdEmpleado
			AND ee.IDEmpresa = @IDEmpresa
			AND (YEAR(ie.Fecha) = @ejercicio AND ie.Fecha BETWEEN ee.FechaIni AND ee.FechaFin)
			AND ISNULL(ie.Autorizado,0) = 1
	WHERE ie.IDIncidencia IN (SELECT item FROM App.split(@DiasDescontar, ','))
	GROUP BY temp_data.IDEmpleado


	SELECT temp_data.IDEmpleado, ISNULL(COUNT(ie.IDIncidencia),0) as Total
		into #tempDataEmpleadosIncapacidades
	FROM #tempDataEmpleados temp_data
	inner join Asistencia.tblIncidenciaEmpleado ie WITH(NOLOCK)
		on temp_data.IDEmpleado = ie.IDEmpleado
	INNER JOIN Asistencia.tblIncapacidadEmpleado ii WITH(NOLOCK) 
		ON ii.IDIncapacidadEmpleado = ie.IDIncapacidadEmpleado
	INNER JOIN rh.tblEmpresaEmpleado ee WITH(NOLOCK)
		ON ee.idEmpleado = ie.IdEmpleado
		AND ee.IDEmpresa = @IDEmpresa
		AND (YEAR(ie.Fecha) = @ejercicio AND ie.Fecha BETWEEN ee.FechaIni AND ee.FechaFin)
	WHERE ii.IDTipoIncapacidad IN (SELECT item FROM App.split(@TiposIncapacidadesADescontar, ','))
		AND ISNULL(ie.Autorizado,0) = 1
		GROUP BY temp_data.IDEmpleado



	SELECT d.* 
		,(SELECT COUNT(*) 
			FROM #tempVigenciaEmpleados 
			WHERE IDEmpleado = d.IDEmpleado ) AS DiasVigencia
		, ISNULL(dias.Total,0) AS DiasADescontar
		, ISNULL(inca.Total,0) AS Incapacidades
		, 0 AS DiasTrabajados
	into #tempDataEmpleadosGeneral
	from #tempDataEmpleados d
	left join #tempDataEmpleadosDiasDescontar dias
		on d.IDEmpleado = dias.IDEmpleado
	left join #tempDataEmpleadosIncapacidades inca	
		on inca.IDEmpleado = d.IDEmpleado
	--select * from #tempDataEmpleadosGeneral






	UPDATE #tempDataEmpleadosGeneral
		SET DiasTrabajados = ISNULL(DiasVigencia,0) - (ISNULL(Incapacidades,0) + ISNULL(DiasADescontar,0))

	
	
	IF (ISNULL(@DiasMinimosTrabajados,0) > 0)
	BEGIN
		DELETE #tempDataEmpleadosGeneral
		WHERE DiasTrabajados < @DiasMinimosTrabajados
	END

	SELECT @DiasMaximosTrabajados =  MAX(DiasVigencia) 
	FROM #tempDataEmpleadosGeneral

	IF(ISNULL(@TopeConfianza,0) <> 0 )
	BEGIN

		UPDATE #tempDataEmpleadosGeneral
			SET Salario = (@TopeConfianza )
		WHERE Salario >= (@TopeConfianza)
			AND isnull(Sindical,0) = 0
	
	END ELSE
	BEGIN 
		select @TopeConfianza = ((MAX(SalarioDiario) * 0.20) + MAX(SalarioDiario))*365
		from #tempDataEmpleadosGeneral
		WHERE isnull(Sindical,0) = 1
			
		UPDATE #tempDataEmpleadosGeneral
			SET Salario = (@TopeConfianza)
		WHERE Salario > (@TopeConfianza)
			AND isnull(Sindical,0) = 0


	END

	SELECT 
		@FactorDias = @MontoDias / CAST(SUM(DiasTrabajados) as decimal(18,9))
	FROM #tempDataEmpleadosGeneral

	SELECT 
		@FactorSueldo = @MontoSueldo / cast((SUM(Salario)) as decimal(18,9)) 
	FROM #tempDataEmpleadosGeneral

	IF EXISTS(SELECT TOP 1 1 FROM #tempDataEmpleadosGeneral WHERE Sindical = 1)
	BEGIN
		SELECT @TopeSindical = MAX(SalarioDiario * 365.0) + (MAX(SalarioDiario * 365.00) * 0.20)
		FROM #tempDataEmpleadosGeneral
		WHERE Sindical = 1
	END
	ELSE
	BEGIN
		SELECT @TopeSindical = MAX(SalarioDiario * 365.0) + (MAX(SalarioDiario * 365.00) * 0.20)
		FROM #tempDataEmpleadosGeneral
	END

	
  
	IF object_id('tempdb..#tempData') IS NOT NULL DROP TABLE #tempData

	/* NOE DIAZ
		COMENTARIOS 2024-04-19
		1. Se agrega en PromPTU3Anios el cast por que si no falla al intentar ingresar la informacion.
		2. Se agrega la multiplicacion de SueldoPromedio3Meses a 91.25 para obtener mas exactitud en el calculo.
		3. Se agrega m.salariodiario para obtener el sueldo actual y con eso obtener el tope.
		4. Se agrega lo de el tipo del salario del trabajador por la articulo 127 de la LFT, donde dice que si es varible se debe 
			de calcular con el promedio obtenido de lo contrario se usa el sueldo actual.
	*/
	SELECT G.* ,
		CantidadMonto	= cast(G.Salario * @FactorSueldo AS DECIMAL(18, 2)),	
		CantidadDias	= cast(G.DiasTrabajados * @FactorDias AS DECIMAL(18, 2)),
		TotalPTU		= cast(0.0000 AS DECIMAL(18 ,2)), 
		VigenteHoy		= M.Vigente,
		SueldoPromedio3Meses = CASE WHEN ISNULL(cs.Descripcion,'') = 'Variable' THEN ((g.SalarioAcumuladoReal/365.0) * 91.25) 
									ELSE ((m.SalarioDiario)*91.25) 
									END,
		PromPTU3Anios = cast(0.00 AS DECIMAL(18 ,2)),
        PTUFinanciero = cast(0.00 AS DECIMAL(18 ,2))
	INTO #tempData
	FROM #tempDataEmpleadosGeneral G
		INNER JOIN RH.tblEmpleadosMaster m WITH(NOLOCK)
			ON G.IDEmpleado = M.IDEmpleado
		LEFT JOIN RH.tblTipoTrabajadorEmpleado te WITH(NOLOCK)
			ON m.IDEmpleado=te.IDEmpleado
		LEFT JOIN imss.tblCatTipoSalario cs WITH(NOLOCK)
			ON cs.IDTipoSalario=te.IDTipoSalario


	
	BEGIN ----PROMEDIO PTU 3 ANIOS
		IF object_id('tempdb..#tempPromPTU3Anios') IS NOT NULL DROP TABLE #tempPromPTU3Anios      
		
		DECLARE @tempAcumuladoPTU3Anios as TABLE (
			IDEmpleado INT,
			ClaveEmpleado varchar(20),
			Colaborador varchar(500),
			CodigoConcepto varchar(20),
			Concepto varchar(255),
			Total decimal(18,2)
		)

		INSERT INTO @tempAcumuladoPTU3Anios
		EXEC [Nomina].[spBuscarAcumuladoPorEjercicioyEmpresaConceptosEmpleados]
			@Ejercicio = @Ejercicio,
			@CodigosConceptos = @ConceptoPTU,
			@dtEmpleados = @dtEmpleados,
			@IDUsuario = @IDUsuario,
			@IDEmpresa = @IDEmpresa
	
		DECLARE @Ejercicio1 int = @Ejercicio - 1 
		DECLARE @Ejercicio2 int = @Ejercicio - 2 

		INSERT INTO @tempAcumuladoPTU3Anios
		EXEC [Nomina].[spBuscarAcumuladoPorEjercicioyEmpresaConceptosEmpleados]
			@Ejercicio = @Ejercicio1,
			@CodigosConceptos = @ConceptoPTU,
			@dtEmpleados = @dtEmpleados,
			@IDUsuario = @IDUsuario,
			@IDEmpresa = @IDEmpresa

		INSERT INTO @tempAcumuladoPTU3Anios
		EXEC [Nomina].[spBuscarAcumuladoPorEjercicioyEmpresaConceptosEmpleados]
			@Ejercicio = @Ejercicio2,
			@CodigosConceptos = @ConceptoPTU,
			@dtEmpleados = @dtEmpleados,
			@IDUsuario = @IDUsuario,
			@IDEmpresa = @IDEmpresa

		--select * from @tempAcumuladoPTU3Anios

		SELECT IDEmpleado, AVG(Total) PromPTU3Anios
			INTO #tempPromPTU3Anios
		FROM @tempAcumuladoPTU3Anios 
		GROUP BY IDEmpleado

	END

	UPDATE t
		SET TotalPTU = CASE WHEN (CantidadMonto + CantidadDias) > @TopeSindical  and @TopeSindical > 0.00 THEN @TopeSindical 
							ELSE (CantidadMonto + CantidadDias) 
							END 
		,t.PromPTU3Anios = ptu3.PromPTU3Anios
	FROM #tempDataEmpleadosGeneral G
		INNER JOIN RH.tblEmpleadosMaster m 
			ON G.IDEmpleado = M.IDEmpleado
		INNER JOIN #tempData t 
			ON t.IDEmpleado = M.IDEmpleado
		LEFT JOIN #tempPromPTU3Anios ptu3 
			ON ptu3.IDEmpleado = m.IDEmpleado


	IF @AplicarPTUFinanciero = 1
	BEGIN
		Declare @TopePTUFinanciero decimal(18,2)
		select @TopePTUFinanciero = MAX(TotalPTU) from #tempData
		UPDATE t
			SET PTUFinanciero = CASE WHEN (SalarioDiario * 30) > @TopePTUFinanciero THEN @TopePTUFinanciero ELSE ( ( (SalarioDiario * 30) * DiasTrabajados ) / 360) END
		FROM #tempData
	END	

	/*  
		NOE DIAZ
		COMENTARIO: 2024-04-19 Articulo 127 de la LFT
		Se modifico esta parte por que por ley le corresponde lo mas faborable para el colaborador 
		no lo minimo ademas de que se esta contemplando el calculo del total ptu para saber cual le 
		corresponde al colaborador.
	*/
	UPDATE t
		SET PTURecomendado =  CASE 
									WHEN @AplicarPTUFinanciero = 1 THEN PTUFinanciero
									WHEN t.TotalPTU > A.TheMin THEN A.theMin 
							  ELSE t.TotalPTU 
							  END
	FROM #tempData t
		INNER JOIN  (
			 SELECT A.IDEmpleado, MAX(A.SueldoPromedio3Meses) As TheMin
			 FROM   (
					SELECT IDEmpleado, SueldoPromedio3Meses
					FROM   #tempData
					UNION All
					SELECT IDEmpleado, PromPTU3Anios
					FROM   #tempData
					) AS A
			 WHERE A.SueldoPromedio3Meses > 0
			 GROUP BY A.IDEmpleado
		   ) As A
			ON A.IDEmpleado = t.IDEmpleado

	UPDATE [Nomina].[tblPTU]
		SET MontoSueldo = @MontoSueldo
			,MontoDias = @MontoDias
			,FactorSueldo = @FactorSueldo
			,FactorDias = @FactorDias
			,IDEmpleadoTipoSalarioMensualConfianza = @IDEmpleadoTipoSalarioMensualConfianza
			,TopeSalarioMensualConfianza = @TopeSalarioAnual			
	WHERE IDPTU = @IDPTU

	MERGE [Nomina].[tblPTUEmpleados] as TARGET
		USING #tempData as SOURCE
	ON TARGET.IDPTU = @IDPTU
		and TARGET.IDEmpleado = SOURCE.IDEmpleado
	WHEN MATCHED THEN
		update set
			TARGET.SalarioDiario			= SOURCE.SalarioDiario			
			,TARGET.FechaInicio				= SOURCE.FechaInicioHistoria				
			,TARGET.FechaFin					= SOURCE.FechaFinHistoria				
			,TARGET.Sindical					= SOURCE.Sindical				
			,TARGET.SalarioAcumuladoReal		= SOURCE.SalarioAcumuladoReal	
			,TARGET.SalarioAcumuladoTopado	= SOURCE.Salario	
			,TARGET.DiasVigencia			= SOURCE.DiasVigencia			
			,TARGET.DiasADescontar			= SOURCE.DiasADescontar			
			,TARGET.Incapacidades			= SOURCE.Incapacidades			
			,TARGET.DiasTrabajados			= SOURCE.DiasTrabajados			
			,TARGET.PTUPorSalario			= SOURCE.CantidadMonto			
			,TARGET.PTUPorDias				= SOURCE.CantidadDias
			,TARGET.PromedioSueldo3Meses	= SOURCE.SueldoPromedio3Meses
			,TARGET.PromedioPTU3Anios		= SOURCE.PromPTU3Anios
			,TARGET.PTURecomendado			= SOURCE.PTURecomendado
			,TARGET.PTUFinanciero			= SOURCE.PTUFinanciero    
	WHEN NOT MATCHED BY TARGET THEN 
		insert(IDPTU,[IDEmpleado],SalarioDiario,FechaInicio,FechaFin,Sindical				
			,SalarioAcumuladoReal,SalarioAcumuladoTopado,DiasVigencia, DiasADescontar
			,Incapacidades, DiasTrabajados,PTUPorSalario,PTUPorDias, PromedioSueldo3Meses, PromedioPTU3Anios, PTURecomendado,PTUFinanciero)
		values(@IDPTU
			,SOURCE.[IDEmpleado]
			,SOURCE.SalarioDiario			
			,SOURCE.FechaInicioHistoria				
			,SOURCE.FechaFinHistoria				
			,SOURCE.Sindical				
			,SOURCE.SalarioAcumuladoReal	
			,SOURCE.Salario	
			,SOURCE.DiasVigencia			
			,SOURCE.DiasADescontar			
			,SOURCE.Incapacidades			
			,SOURCE.DiasTrabajados			
			,SOURCE.CantidadMonto			
			,SOURCE.CantidadDias
			,SOURCE.SueldoPromedio3Meses
			,SOURCE.PromPTU3Anios
			,SOURCE.PTURecomendado
            ,SOURCE.PTUFinanciero


		)
	WHEN NOT MATCHED BY SOURCE and TARGET.IDPTU = @IDPTU
	THEN DELETE;

END
GO
