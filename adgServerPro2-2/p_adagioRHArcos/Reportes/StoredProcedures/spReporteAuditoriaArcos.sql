USE [p_adagioRHArcos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spReporteAuditoriaArcos](

	 @dtFiltros [Nomina].[dtFiltrosRH] READONLY
	,@IDUsuario INT

)
AS

BEGIN

	DECLARE
		 @FechaIni DATE
		,@FechaFin DATE
		,@ClaveEmpleadoInicial VARCHAR(20)
		,@ClaveEmpleadoFinal VARCHAR(20)
		,@Empleados [RH].[dtEmpleados]
		,@IDEmpleado INT
		,@TablaIncidencias VARCHAR(250) = '[Asistencia].[tblIncidenciaEmpleado]'
		,@TablaPapeletas VARCHAR(250) = '[Asistencia].[tblPapeletas]'

	SELECT @ClaveEmpleadoInicial = (SELECT Item FROM App.Split((SELECT TOP 1 [Value] FROM @dtFiltros WHERE Catalogo = 'ClaveEmpleadoInicial'),','))
	SELECT @FechaIni = (SELECT CAST(Item AS DATE) FROM App.Split((SELECT TOP 1 [Value] FROM @dtFiltros WHERE Catalogo = 'FechaIni'),','))
	SELECT @FechaFin = (SELECT CAST(Item AS DATE) FROM App.Split((SELECT TOP 1 [Value] FROM @dtFiltros WHERE Catalogo = 'FechaFin'),','))

	IF (@ClaveEmpleadoInicial IS NULL)
	BEGIN
		RAISERROR('SELECCIONE UN COLABORADOR',16,1)
		RETURN;
	END;

	SELECT @ClaveEmpleadoFinal = @ClaveEmpleadoInicial

	INSERT INTO @Empleados
	EXEC [RH].[spBuscarEmpleados] @EmpleadoIni = @ClaveEmpleadoInicial, @EmpleadoFin = @ClaveEmpleadoFinal, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario

	SELECT @IDEmpleado = IDEmpleado FROM @Empleados WHERE ClaveEmpleado = @ClaveEmpleadoInicial

	IF OBJECT_ID('TempDB..#TempAuditoria') IS NOT NULL DROP TABLE #TempAuditoria
	IF OBJECT_ID('TempDB..#TempAuditoriaB') IS NOT NULL DROP TABLE #TempAuditoriaB
	IF OBJECT_ID('TempDB..#TempAuditoriaC') IS NOT NULL DROP TABLE #TempAuditoriaC

	SELECT
		 IDAuditoria
		,IDUsuario
		,FORMAT(Fecha,'dd/MM/yyyy HH:mm:ss tt') AS Fecha
		,Tabla
		,Procedimiento
		,Accion
		,CASE WHEN LEN(NewData) = 0 THEN NULL ELSE REPLACE(REPLACE(NewData,'[',''),']','') END AS NewData
		,CASE WHEN LEN(OldData) = 0 THEN NULL ELSE REPLACE(REPLACE(OldData,'[',''),']','') END AS OldData
		,IDEmpleado
		,CASE WHEN Tabla = '[Asistencia].[tblIncidenciaEmpleado]' THEN SUBSTRING(NewData,CHARINDEX('Fecha',NewData)+8,10) 
		 ELSE SUBSTRING(NewData,CHARINDEX('FechaInicio',NewData)+14,10) END AS FechaNewData
		,CASE WHEN Tabla = '[Asistencia].[tblIncidenciaEmpleado]' THEN SUBSTRING(OldData,CHARINDEX('Fecha',OldData)+8,10) 
		 ELSE SUBSTRING(OldData,CHARINDEX('FechaInicio',OldData)+14,10) END AS FechaOldData
	INTO #TempAuditoria
	FROM Auditoria.tblAuditoria 
	WHERE IDEmpleado = @IDEmpleado
	AND (Tabla = @TablaIncidencias OR Tabla = @TablaPapeletas)
	AND IDUsuario <> 1 
	
	SELECT 
		 A.IDAuditoria
		,U.Cuenta AS Cuenta
		,U.Nombre+' '+U.Apellido AS Usuario
		,A.Fecha AS Fecha
		,A.Tabla AS Tabla
		,A.Accion AS Accion
		,M.ClaveEmpleado AS Clave
		,M.NOMBRECOMPLETO AS Colaborador
		,JND.[Key]+': '+JND.[Value] AS [Informacion Nueva]
	INTO #TempAuditoriaB
	FROM #TempAuditoria A
		INNER JOIN Seguridad.tblUsuarios U
			 ON U.IDUsuario = A.IDUsuario
		INNER JOIN RH.tblEmpleadosMaster M
			ON M.IDEmpleado = A.IDEmpleado
	CROSS APPLY OPENJSON(A.NewData) AS JND
	WHERE ((A.FechaNewData BETWEEN @FechaIni AND @FechaFin) OR (A.FechaOldData BETWEEN @FechaIni AND @FechaFin))
	ORDER BY A.Fecha

	SELECT 
		 A.IDAuditoria
		,U.Cuenta AS Cuenta
		,U.Nombre+' '+U.Apellido AS Usuario
		,A.Fecha AS Fecha
		,A.Tabla AS Tabla
		,A.Accion AS Accion
		,M.ClaveEmpleado AS Clave
		,M.NOMBRECOMPLETO AS Colaborador
		,JOD.[Key]+': '+JOD.[Value] AS [Informacion Anterior]
	INTO #TempAuditoriaC
	FROM #TempAuditoria A
		INNER JOIN Seguridad.tblUsuarios U
			 ON U.IDUsuario = A.IDUsuario
		INNER JOIN RH.tblEmpleadosMaster M
			ON M.IDEmpleado = A.IDEmpleado
	CROSS APPLY OPENJSON(A.OldData) AS JOD
	WHERE ((A.FechaNewData BETWEEN @FechaIni AND @FechaFin) OR (A.FechaOldData BETWEEN @FechaIni AND @FechaFin))
	ORDER BY A.Fecha

	SELECT
		 Cuenta
		,Usuario
		,Fecha
		,Tabla
		,Accion
		,Clave
		,Colaborador
		,STRING_AGG([Informacion Nueva],'  |  ') AS [Informacion]
	FROM #TempAuditoriaB
	GROUP BY 
		 IDAuditoria
		,Cuenta
		,Usuario
		,Fecha
		,Tabla
		,Accion
		,Clave
		,Colaborador
	UNION ALL
	SELECT
		 Cuenta
		,Usuario
		,Fecha
		,Tabla
		,Accion
		,Clave
		,Colaborador
		,STRING_AGG([Informacion Anterior],'  |  ') AS [Informacion]
	FROM #TempAuditoriaC
	GROUP BY 
		 IDAuditoria
		,Cuenta
		,Usuario
		,Fecha
		,Tabla
		,Accion
		,Clave
		,Colaborador
	ORDER BY Fecha

END
GO
