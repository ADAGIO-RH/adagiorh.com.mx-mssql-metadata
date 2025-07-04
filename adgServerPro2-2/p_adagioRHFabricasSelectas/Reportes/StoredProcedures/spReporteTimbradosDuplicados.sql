USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spReporteTimbradosDuplicados](

	 @dtfiltros [Nomina].[dtFiltrosRH] READONLY
	,@IDUsuario INT

)
AS

BEGIN


	SET NOCOUNT ON;


	DECLARE 
		 @Ejercicio INT
		,@IDTipoNomina INT
		,@MesIni INT
		,@MesFin INT
		,@Periodo [Nomina].[dtPeriodos]


	SELECT @Ejercicio    = ISNULL((SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtfiltros WHERE Catalogo = 'Ejercicio'),',')),0)
	SELECT @IDTipoNomina = ISNULL((SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtfiltros WHERE Catalogo = 'TipoNomina'),',')),0)
	SELECT @MesIni       = ISNULL((SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtfiltros WHERE Catalogo = 'IDMes'),',')),0)
	SELECT @MesFin       = ISNULL((SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtfiltros WHERE Catalogo = 'IDMesFin'),',')),0)


	INSERT INTO @Periodo
	SELECT *
	FROM Nomina.tblCatPeriodos WITH (NOLOCK)
	WHERE Ejercicio = @Ejercicio AND IDTipoNomina = @IDTipoNomina AND (IDMes >= @MesIni AND IDMes <= @MesFin)


	IF OBJECT_ID('TempDB..#TempFoliosTimbrados') IS NOT NULL DROP TABLE #TempFoliosTimbrados;
	IF OBJECT_ID('TempDB..#TempFoliosCancelados') IS NOT NULL DROP TABLE #TempFoliosCancelados;

	SELECT *
	INTO #TempFoliosTimbrados
	FROM (
			SELECT 
				 T.IDHistorialEmpleadoPeriodo AS Folio
				,T.UUID
				,CET.Descripcion AS EstatusTimbrado
				,T.Fecha
				,T.Actual
				,COUNT(*) OVER(PARTITION BY T.IDHistorialEmpleadoPeriodo ORDER BY T.IDHistorialEmpleadoPeriodo DESC) AS Quantity
				,E.NombreComercial AS [Razon Social]
			FROM Nomina.tblHistorialesEmpleadosPeriodos HEP WITH (NOLOCK)
				INNER JOIN @Periodo P
					ON HEP.IDPeriodo = P.IDPeriodo
				INNER JOIN Facturacion.TblTimbrado T WITH (NOLOCK)
					ON T.IDHistorialEmpleadoPeriodo = HEP.IDHistorialEmpleadoPeriodo
				INNER JOIN Facturacion.tblCatEstatusTimbrado CET WITH (NOLOCK)
					ON T.IDEstatusTimbrado = CET.IDEstatusTimbrado
				INNER JOIN RH.tblEmpresa E WITH (NOLOCK)
					ON HEP.IDEmpresa = E.IDEmpresa
			WHERE CET.Descripcion IN ('TIMBRADO')
		 ) X

	WHERE Quantity > 1 AND Actual = 0


	SELECT 
		 T.IDHistorialEmpleadoPeriodo AS Folio
		,T.UUID
		,CET.Descripcion AS EstatusTimbrado
		,T.Fecha
		,T.Actual
		,E.NombreComercial
	INTO #TempFoliosCancelados
	FROM Nomina.tblHistorialesEmpleadosPeriodos HEP WITH (NOLOCK)
		INNER JOIN @Periodo P
			ON HEP.IDPeriodo = P.IDPeriodo
		INNER JOIN Facturacion.TblTimbrado T WITH (NOLOCK)
			ON T.IDHistorialEmpleadoPeriodo = HEP.IDHistorialEmpleadoPeriodo
		INNER JOIN Facturacion.tblCatEstatusTimbrado CET WITH (NOLOCK)
			ON T.IDEstatusTimbrado = CET.IDEstatusTimbrado
		INNER JOIN RH.tblEmpresa E WITH (NOLOCK)
			ON HEP.IDEmpresa = E.IDEmpresa
	WHERE CET.Descripcion IN ('CANCELADO')


	IF (@Ejercicio <= 2024)
	BEGIN
		PRINT '0000'
		DELETE FROM #TempFoliosTimbrados
		DELETE FROM #TempFoliosCancelados
	END


	SELECT *
	FROM (
			SELECT 
			     T.[Razon Social]
				,T.Folio
				,T.UUID
				,T.EstatusTimbrado
				,FORMAT(T.Fecha,'dd/MM/yyyy HH:mm:ss') AS Fecha
			FROM #TempFoliosTimbrados T
				LEFT JOIN #TempFoliosCancelados C
					ON T.Folio = C.Folio AND T.UUID = C.UUID
			WHERE C.Folio IS NULL
		 ) X

	ORDER BY Folio ASC, Fecha DESC
 

END
GO
