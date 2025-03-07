USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Docs].[ProcedureCustomDocumentosContratos] 
(
    @IDEmpleado Int,        
    @FechaIni Date = '1900-01-01',         
    @Fechafin Date = '9999-12-31',
    @IDContratoEmpleado Int = 0,
    @IDIdioma VARCHAR(5),    
    @empleados [RH].[dtEmpleados] READONLY,
    @IDUsuario int = 0          
)         
AS         
BEGIN
	IF OBJECT_ID('TEMPDB..#tempEmpleados') IS NOT NULL DROP TABLE #tempEmpleados
	IF OBJECT_ID('TEMPDB..#tempHorario') IS NOT NULL DROP TABLE #tempHorario
	IF OBJECT_ID('TEMPDB..#tempPrestaciones') IS NOT NULL DROP TABLE #tempPrestaciones
	IF OBJECT_ID('TEMPDB..#tempDescansos') IS NOT NULL DROP TABLE #tempDescansos
	IF OBJECT_ID('TEMPDB..#tempJornada') IS NOT NULL DROP TABLE #tempJornada
	IF OBJECT_ID('TEMPDB..#tempFechaIndeterminado') IS NOT NULL DROP TABLE #tempFechaIndeterminado
	IF OBJECT_ID('TEMPDB..#tempRazonSocial') IS NOT NULL DROP TABLE #tempRazonSocial
	IF OBJECT_ID('TEMPDB..#tempFechaDocumento') IS NOT NULL DROP TABLE #tempFechaDocumento
	IF OBJECT_ID('TEMPDB..#tempCustomDatos') IS NOT NULL DROP TABLE #tempCustomDatos

	SELECT @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	SET LANGUAGE 'Spanish';

	Select
	E.IDEmpleado
	,SUBSTRING(UPPER(COALESCE(E.Nombre,'') + ' '+CASE WHEN E.SegundoNombre<>'' THEN COALESCE(E.SegundoNombre,'')+' ' ELSE '' END +COALESCE(E.Paterno,'')+ CASE WHEN E.Materno <> '' THEN +' '+COALESCE(E.Materno,'') ELSE '' END),1,49 ) AS NombreCompleto2 
	INTO #tempEmpleados
	FROM @empleados E
	WHERE IDEmpleado = @IDEmpleado

	SELECT 
	 E.IDEmpleado 
	,ISNULL(CH.Codigo,'') AS Horario
	INTO #tempHorario
	FROM @empleados E
	INNER JOIN Asistencia.tblHorariosEmpleados HE
		ON HE.IDEmpleado = E.IDEmpleado
	INNER JOIN Asistencia.tblCatHorarios CH
		ON CH.IDHorario = HE.IDHorario
	WHERE HE.IDEmpleado = @IDEmpleado
		AND HE.Fecha = @FechaIni
/**********************************************************************************************************************************************/
	DECLARE @Antiguedad FLOAT = 0
	
	SELECT @Antiguedad = DATEDIFF(DAY,FechaAntiguedad,@FechaIni) / 365.2425
	FROM @empleados
 
	SELECT @Antiguedad = CASE WHEN @Antiguedad < 1.0 THEN 1 ELSE FLOOR(@Antiguedad) END

	SELECT 
	 E.IDEmpleado
	,ISNULL(CAST((CAST(CTPD.PrimaVacacional AS DECIMAL(18,2)) * 100) AS VARCHAR(250)),'') AS PrimaVacacional
	INTO #tempPrestaciones
	FROM @empleados E
	LEFT JOIN RH.tblPrestacionesEmpleado PE 
		ON PE.IDEmpleado = E.IDEmpleado AND PE.FechaIni <= @FechaFin AND PE.FechaFin >= @FechaFin
	LEFT JOIN RH.tblCatTiposPrestacionesDetalle CTPD 
		ON CTPD.IDTipoPrestacion = PE.IDTipoPrestacion AND CTPD.Antiguedad = @Antiguedad
	WHERE PE.IDEmpleado = @IDEmpleado
/**********************************************************************************************************************************************/

	DECLARE
	 @Inicio DATE 
	,@Fin DATE

	SELECT
	 @Inicio = FechaInicioPago
	,@Fin = FechaFinPago
	FROM Nomina.tblCatPeriodos
	WHERE Ejercicio = YEAR(@FechaIni) 
	AND IDTipoNomina IN (SELECT IDTipoNomina FROM @empleados WHERE IDEmpleado = @IDEmpleado)
	AND @FechaIni BETWEEN FechaInicioPago AND FechaFinPago
	AND General = 1

	SELECT 
		 E.IDEmpleado
		,ISNULL(STRING_AGG(DATENAME(WEEKDAY,IE.Fecha),' y '),'SIN INFO') AS Descanso
	INTO #tempDescansos
	FROM @empleados E
	LEFT JOIN Asistencia.tblIncidenciaEmpleado IE
		ON IE.IDEmpleado = E.IDEmpleado
	AND IE.IDIncidencia = 'D'
	AND IE.IDEmpleado = @IDEmpleado
	AND IE.Fecha BETWEEN @Inicio AND @Fin
	AND IE.Autorizado = 1
	GROUP BY E.IDEmpleado

/**********************************************************************************************************************************************/

	SELECT 
		 E.IDEmpleado
		,DATENAME(WEEKDAY,MIN(HE.Fecha))+' a '+DATENAME(WEEKDAY,MAX(HE.Fecha)) AS JornadaEmpleado
	INTO #tempJornada
	FROM @empleados E
	INNER JOIN Asistencia.tblHorariosEmpleados HE
		ON HE.IDEmpleado = E.IDEmpleado
	WHERE HE.IDEmpleado = @IDEmpleado
	AND HE.Fecha BETWEEN @Inicio AND @Fin
	AND HE.Fecha NOT IN (SELECT Fecha FROM Asistencia.tblIncidenciaEmpleado WHERE IDEmpleado = @IDEmpleado AND IDIncidencia ='D' AND Fecha BETWEEN @Inicio AND @Fin)
	GROUP BY E.IDEmpleado

/**********************************************************************************************************************************************/

	DECLARE
		 @DuracionContrato INT;

	SELECT @DuracionContrato = Duracion FROM [RH].[tblContratoEmpleado] WHERE IDContratoEmpleado = @IDContratoEmpleado

	SELECT 
		 IDEmpleado
		,ISNULL([Utilerias].[fnDateToStringByFormat](FechaIndeterminado,'FM','Spanish'),'') AS FechaIndeterminado
	INTO #tempFechaIndeterminado
	FROM
		(SELECT 
			 IDEmpleado
			,CAST(CAST(DATEADD(DAY,@DuracionContrato,@FechaIni) AS DATE) AS VARCHAR(10)) AS FechaIndeterminado
		FROM @empleados
		WHERE IDEmpleado = @IDEmpleado) Fecha

	SELECT 
		 E.IDEmpleado
		,ISNULL(VDE.Valor,'') AS RazonSocialDoc
	INTO #tempRazonSocial
	FROM @empleados E
	LEFT JOIN App.tblValoresDatosExtras VDE
		ON VDE.IDReferencia = E.IDEmpresa
	INNER JOIN App.tblCatDatosExtras CDD 
		ON CDD.IDDatoExtra = VDE.IDDatoExtra AND CDD.IDDatoExtra = 2
	WHERE E.IDEmpleado = @IDEmpleado


	SELECT 
		 E.IDEmpleado
		,Utilerias.fnDateToStringByFormat (DATEADD(DAY,1,CE.FechaIni),'FM','Spanish') AS DocumentoFechaIniMasUno
	INTO #tempFechaDocumento
	FROM @empleados E
		LEFT JOIN RH.tblContratoEmpleado CE
			ON E.IDEmpleado = CE.IDEmpleado 
	WHERE CE.IDContratoEmpleado = @IDContratoEmpleado


	CREATE TABLE #tempCustomDatos(
			IDEmpleado Int,
			Columna Varchar(255),
			Valor Varchar(255)
		)

	INSERT INTO #tempCustomDatos(IDEmpleado,Columna,Valor)
		SELECT IDEmpleado ,'NombreCompleto2', NombreCompleto2 AS Valor
		FROM #tempEmpleados
		WHERE IDEmpleado = @IDEmpleado
			UNION ALL
		SELECT IDEmpleado,'Horario', Horario AS Valor
		FROM #tempHorario
		WHERE IDEmpleado = @IDEmpleado
			UNION ALL
		SELECT IDEmpleado,'PrimaVacacional', PrimaVacacional AS Valor
		FROM #tempPrestaciones
			UNION ALL
		SELECT IDEmpleado, 'Descansos', Descanso AS Valor
		FROM #tempDescansos
			UNION ALL
		SELECT IDEmpleado, 'JornadaEmpleado', JornadaEmpleado AS Valor
		FROM #tempJornada
		WHERE IDEmpleado = @IDEmpleado
			UNION ALL
		SELECT IDEmpleado, 'FechaIndeterminado', FechaIndeterminado AS Valor
		FROM #tempFechaIndeterminado
		WHERE IDEmpleado = @IDEmpleado
			UNION ALL
		SELECT IDEmpleado, 'RazonSocialDoc', RazonSocialDoc AS Valor
		FROM #tempRazonSocial
		WHERE IDEmpleado = @IDEmpleado
			UNION ALL
	    SELECT IDEmpleado, 'DocumentoFechaIniMasUno', DocumentoFechaIniMasUno AS Valor
		FROM #tempFechaDocumento
		WHERE IDEmpleado = @IDEmpleado

	SELECT * FROM  #tempCustomDatos

END
GO
