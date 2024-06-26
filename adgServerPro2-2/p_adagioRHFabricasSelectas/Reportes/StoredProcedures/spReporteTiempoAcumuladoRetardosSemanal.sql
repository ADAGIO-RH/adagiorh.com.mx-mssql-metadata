USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spReporteTiempoAcumuladoRetardosSemanal](

	 @dtFiltros [Nomina].[dtFiltrosRH] READONLY
	,@IDUsuario INT

) AS

BEGIN
		
		DECLARE
			 @FechaIni DATE
			,@FechaFin DATE
			,@Ejercicio INT
			,@IDTipoNomina INT
			,@EmpleadoIni VARCHAR(20)
			,@EmpleadoFin VARCHAR(20) 
			,@IDIncidencia VARCHAR(20) = 'R'
			,@EmpleadosVigentes [RH].[dtEmpleados]
			,@Fechas [App].[dtFechas]

		SELECT @FechaIni = ISNULL((SELECT CAST(Item AS DATE) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'FechaIni'),',')),'1900-01-01')
		SELECT @FechaFin = ISNULL((SELECT CAST(Item AS DATE) FROM APP.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'FechaFin'),',')),'9999-12-31')
		SELECT @IDTipoNomina = ISNULL((SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE	Catalogo = 'TipoNomina'),',')),0)

		SELECT @EmpleadoIni = ISNULL((SELECT Item FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'ClaveEmpleadoInicial'),',')),'0')
		SELECT @EmpleadoFin = ISNULL((SELECT Item FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZ')

		IF OBJECT_ID ('TempDB..#TempCatIncidencias') IS NOT NULL DROP TABLE #TempCatIncidencias
		IF OBJECT_ID('TempDB..#TempIncidenciaEmpleado') IS NOT NULL DROP TABLE #TempIncidenciaEmpleado

		SELECT *
		INTO #TempCatIncidencias
		FROM Asistencia.tblCatIncidencias
		WHERE IDIncidencia = @IDIncidencia

		INSERT INTO @EmpleadosVigentes
		EXEC [RH].[spBuscarEmpleados] 
		 @FechaIni = @FechaIni
		,@FechaFin = @FechaFin
		,@IDUsuario = @IDUsuario
		,@EmpleadoIni = @EmpleadoIni
		,@EmpleadoFin = @EmpleadoFin
		,@IDTipoNomina = @IDTipoNomina
		,@dtFiltros = @dtFiltros

		INSERT INTO @Fechas 
		EXEC [App].[spListaFechas] @FechaIni = @FechaIni, @FechaFin = @FechaFin

		SELECT 
			IDEmpleado
		   ,SUM(TiempoAcumuladoTotal) AS TiempoTotalRetardos
		INTO #TempIncidenciaEmpleado
		FROM
			(SELECT 
				E.IDEmpleado
			   ,((DATEDIFF(SECOND,0,IE.TiempoSugerido)) / 60.0) AS TiempoAcumuladoTotal
			 FROM @EmpleadosVigentes E
				INNER JOIN Asistencia.tblIncidenciaEmpleado IE ON IE.IDEmpleado = E.IDEmpleado
				INNER JOIN @Fechas Fechas ON Fechas.Fecha = IE.Fecha
			 WHERE IE.IDIncidencia IN (SELECT IDIncidencia FROM #TempCatIncidencias)
			/*AND IE.Autorizado = 1 --VALIDAR CON EL CLIENTE*/) TiempoRetardos
		GROUP BY IDEmpleado

		SELECT
			 E.ClaveEmpleado AS Clave
			,E.NOMBRECOMPLETO AS Nombre
			,E.Puesto AS Puesto
			,E.Sucursal AS Sucursal
			,E.Departamento AS Departamento
			,E.Empresa AS [Razon Social]
			,E.CentroCosto AS [Centro De Costo]
			,E.ClasificacionCorporativa AS [Clasificacion Corporativa]
			,E.TipoNomina [Tipo Nomina]
			,CAST(IE.TiempoTotalRetardos AS INT) [Minutos De Retardo]
			,[Amerita Ajuste] = CASE WHEN IE.TiempoTotalRetardos >= 10.0 THEN 'SI' ELSE 'NO' END 
		FROM @EmpleadosVigentes E
			INNER JOIN #TempIncidenciaEmpleado IE 
				ON IE.IDEmpleado = E.IDEmpleado
	
END
GO
