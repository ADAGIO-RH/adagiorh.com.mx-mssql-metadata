USE [p_adagioRHArcos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spReporteDeIncidenciasAusentismosConAutorizador](

		@dtFiltros [Nomina].[dtFiltrosRH] READONLY
	   ,@IDUsuario INT

) AS

BEGIN

	SET DATEFIRST 7;

	DECLARE 
		 @FechaIni DATE
		,@FechaFin DATE
		,@EmpleadoIni VARCHAR(MAX)
		,@EmpleadoFin VARCHAR(MAX)
		,@IDIdioma VARCHAR(5)
		,@IdiomaSQL VARCHAR(100)
		,@Fechas [App].[dtFechasFull]
		,@Empleados [RH].[dtEmpleados]
		,@IDSGenerarIncidencias VARCHAR(250)

	SELECT @IDIdioma = App.fnGetPreferencia('Idioma',@IDUsuario,'es-MX')

	SELECT @IdiomaSQL = [SQL]
	FROM App.tblIdiomas	WITH(NOLOCK)
	WHERE IDIdioma = @IDIdioma

	IF (@IdiomaSQL IS NULL OR LEN(@IdiomaSQL) = 0)
	BEGIN
		SET @IdiomaSQl = 'Spanish'
	END

	SET LANGUAGE @IdiomaSQL

	SELECT @FechaIni = ISNULL((SELECT CAST(Item AS DATE) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'FechaIni'),',')),CAST(GETDATE() AS DATE))
	SELECT @FechaFin = ISNULL((SELECT CAST(Item AS DATE) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'FechaFin'),',')),CAST(GETDATE() AS DATE))
	SELECT @EmpleadoIni = ISNULL((SELECT Item FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'ClaveEmpleadoInicial'),',')),'0')
	SELECT @EmpleadoFin = ISNULL((SELECT Item FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZ')

	SELECT @IDSGenerarIncidencias = STRING_AGG(IDIncidencia,',') FROM Asistencia.tblCatIncidencias WHERE ISNULL(GenerarIncidencias,0) = 1 AND ISNULL(NombreProcedure,'') <> ''
	
	INSERT INTO @Fechas
	EXEC [App].[spListaFechas] @FechaIni = @FechaIni, @FechaFin = @FechaFin

	INSERT INTO @Empleados
	EXEC [RH].[spBuscarEmpleados] @FechaIni = @FechaIni, @FechaFin = @FechaFin, @EmpleadoIni = @EmpleadoIni, @EmpleadoFin = @EmpleadoFin, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario

	IF NOT EXISTS((SELECT TOP 1 1 FROM App.Split((SELECT Value FROM @dtFiltros WHERE Catalogo = 'IDIncidencia'),',')))
	BEGIN
		RAISERROR('SELECCIONE LAS INCIDENCIAS/AUSENTISMOS',16,1)
		RETURN
	END

	IF OBJECT_ID('TempDB..#TempIncidenciaEmpleado') IS NOT NULL DROP TABLE #TempIncidenciaEmpleado
	IF OBJECT_ID('TempDB..#TempPapeletas') IS NOT NULL DROP TABLE #TempPapeletas

	SELECT 
		 IE.*
		,CreadoPor.Cuenta AS CreadorClave
		,CreadoPor.Nombre+' '+CreadoPor.Apellido AS CreadorNombre
		,AutorizadoPor.Cuenta AS AutorizadorClave
		,AutorizadoPor.Nombre+' '+AutorizadoPor.Apellido AS AutorizadorNombre
	INTO #TempIncidenciaEmpleado
	FROM Asistencia.tblIncidenciaEmpleado IE WITH(NOLOCK)
		INNER JOIN @Fechas F ON F.Fecha = IE.Fecha
		INNER JOIN @Empleados E ON E.IDEmpleado = IE.IDEmpleado
		LEFT JOIN Seguridad.tblUsuarios CreadoPor WITH(NOLOCK) ON CreadoPor.IDUsuario = IE.CreadoPorIDUsuario
		LEFT JOIN Seguridad.tblUsuarios AutorizadoPor WITH(NOLOCK) ON AutorizadoPor.IDUsuario = IE.AutorizadoPor
	WHERE IE.IDincidencia IN (SELECT CAST(Item AS VARCHAR(10)) FROM App.Split((SELECT Value FROM @dtFiltros WHERE Catalogo = 'IDIncidencia'),','))

	SELECT 
		 P.*
		,U.Cuenta AS ClaveCreador
		,U.Nombre+' '+U.Apellido AS NombreCreador
	INTO #TempPapeletas
	FROM Asistencia.tblPapeletas P WITH(NOLOCK)
		INNER JOIN @Fechas F ON F.Fecha = P.Fecha
		INNER JOIN @Empleados E ON E.IDEmpleado = P.IDEmpleado
		LEFT JOIN Seguridad.tblUsuarios U WITH(NOLOCK) ON U.IDUsuario = P.IDUsuario
	WHERE P.IDIncidencia IN (SELECT CAST(Item AS VARCHAR(10)) FROM App.Split((SELECT Value FROM @dtFiltros WHERE Catalogo = 'IDIncidencia'),','))

	SELECT 
		 E.ClaveEmpleado AS [CLAVE EMPLEADO]
		,E.NOMBRECOMPLETO AS [NOMBRE EMPLEADO]
		,E.Puesto AS [PUESTO]
		,IE.IDincidencia+' - '+CI.Descripcion AS [AUSENTISMO/INCIDENCIA]
		,FORMAT(IE.Fecha,'dd/MM/yyyy') AS [FECHA]
		,CASE WHEN IE.IDIncidencia NOT IN (SELECT Item FROM App.Split((@IDSGenerarIncidencias),',')) THEN IE.CreadorClave+' - '+IE.CreadorNombre ELSE '' END AS [CREADO POR]
		,CASE WHEN IE.Autorizado = 1 THEN 'SI' ELSE 'NO' END AS [AUTORIZADO]
		,ISNULL(IE.AutorizadorClave+' - '+IE.AutorizadorNombre,'') AS [AUTORIZADO POR]
		,ISNULL(CAST(FORMAT(CAST(IE.FechaHoraAutorizacion AS DATE),'dd/MM/yyyy') AS VARCHAR(25))+' '+SUBSTRING(CAST(CAST(IE.FechaHoraAutorizacion AS TIME) AS VARCHAR(25)),1,8),'') AS [FECHA HORA AUTORIZACION]
		,CASE WHEN P.IDPapeleta IS NOT NULL AND P.Autorizado = 1 THEN 'CREADA Y AUTORIZADA POR: '+P.ClaveCreador+' - '+P.NombreCreador
			  WHEN P.IDPapeleta IS NOT NULL AND P.Autorizado = 0 THEN 'CREADA SIN AUTORIZAR POR: '+P.ClaveCreador+' - '+P.NombreCreador
		 ELSE '' END AS [PAPELETA]
		,ISNULL(CASE WHEN P.FechaFin = P.FechaInicio THEN CAST(FORMAT(P.FechaInicio,'dd/MM/yyy') AS VARCHAR(10)) 
		 ELSE 'DEL '+CAST(FORMAT(P.FechaInicio,'dd/MM/yyyy') AS VARCHAR(10))+' AL'+CAST(FORMAT(P.FechaFin,'dd/MM/yyyy') AS VARCHAR(10)) END,'') AS [FECHAS PAPELETA]
		,ISNULL(UPPER(IE.Comentario),'') AS [COMENTARIO]
	FROM (SELECT *
		  FROM @Fechas
			  ,@Empleados) AS E 
		LEFT JOIN #TempIncidenciaEmpleado IE WITH(NOLOCK) ON IE.IDEmpleado = E.IDEmpleado AND IE.Fecha = E.Fecha
		LEFT JOIN #TempPapeletas P WITH(NOLOCK) ON P.IDEmpleado = IE.IDEmpleado AND P.Fecha = IE.Fecha AND P.IDIncidencia = IE.IDIncidencia
		LEFT JOIN Seguridad.tblDetalleFiltrosEmpleadosUsuarios DFE WITH(NOLOCK) ON DFE.IDEmpleado = E.IDEmpleado AND DFE.IDUsuario = @IDUsuario
		INNER JOIN Asistencia.tblCatIncidencias CI WITH(NOLOCK) ON CI.IDIncidencia = IE.IDIncidencia
	ORDER BY [CLAVE EMPLEADO] ASC,IE.Fecha DESC

END
GO
