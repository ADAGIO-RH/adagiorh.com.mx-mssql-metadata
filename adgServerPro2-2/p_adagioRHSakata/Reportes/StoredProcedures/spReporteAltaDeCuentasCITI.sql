USE [p_adagioRHSakata]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spReporteAltaDeCuentasCITI](


	 @dtFiltros [Nomina].[dtFiltrosRH] READONLY
	,@IDUsuario INT


)
AS

BEGIN


	DECLARE
		 @FechaIni DATE
		,@FechaFin DATE
		,@IDLayoutPago INT
		,@IDTipoNomina INT
		,@AltaFecha VARCHAR(10)
		,@AltaHora VARCHAR(5)
		,@Empleados [RH].[dtEmpleados]


	DECLARE @LayoutParametros AS TABLE 
	(
		IDLayout INT
	   ,IDLayoutPagoParametros INT
	   ,Parametro VARCHAR(550)
	   ,Valor VARCHAR(550)
	);


	IF OBJECT_ID('TempDB..#TempAltasBanco') IS NOT NULL DROP TABLE #TempAltasBanco;
	CREATE TABLE #TempAltasBanco(Respuesta NVARCHAR(MAX));


	IF OBJECT_ID('TempDB..#TempDatos') IS NOT NULL DROP TABLE #TempDatos;
	IF OBJECT_ID('TempDB..#TempMov') IS NOT NULL DROP TABLE #TempMov;


	SELECT @FechaIni      = ISNULL((SELECT TOP 1 Item FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'FechaIni'),',')),'1900-01-01')
	SELECT @FechaFin      = ISNULL((SELECT TOP 1 Item FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'FechaFin'),',')),'9999-12-31')
	SELECT @IDLayoutPago  = ISNULL((SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'IDLayoutPago'),',')),0)
	SELECT @IDTipoNomina  = ISNULL((SELECT CAST(Item AS INT) FROM App.Split((SELECT  TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'TipoNomina'),',')),0)
	SELECT @AltaFecha     = ISNULL((SELECT CAST(FORMAT(CAST(CAST(Item AS DATETIME) AS DATE),'dd/MM/yyyy') AS VARCHAR(10)) FROM App.Split((SELECT  TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'FechaHoraIni'),',')),'1900-01-01') 
	SELECT @AltaHora      = ISNULL((SELECT CAST(CAST(Item AS TIME) AS VARCHAR(5)) FROM App.Split((SELECT  TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'FechaHoraIni'),',')),'00:00')


	INSERT INTO @LayoutParametros (IDLayout,IDLayoutPagoParametros,Parametro,Valor)
	EXEC [Nomina].[spBuscarParametrosLayoutPago] @IDLayoutPago = @IDLayoutPago


	DECLARE 
		 @NumeroCliente VARCHAR(12)
		,@NombreCliente VARCHAR(36)
		,@NumeroRepresentante VARCHAR(12)
		,@NombreRepresentante VARCHAR(36)
		,@Secuencial VARCHAR(2)


	SELECT @NumeroCliente = Valor FROM @LayoutParametros WHERE Parametro = 'No. Cliente'
	SELECT @NombreCliente = Valor FROM @LayoutParametros WHERE Parametro = 'Nombre Empresa'
	SELECT @Secuencial    = Valor FROM @LayoutParametros WHERE Parametro = 'Secuencia Archivo'


	SELECT Mov.*
	INTO #TempMov
	FROM IMSS.tblMovAfiliatorios Mov WITH (NOLOCK)
		INNER JOIN IMSS.tblCatTipoMovimientos TM WITH (NOLOCK)
			ON Mov.IDTipoMovimiento = TM.IDTipoMovimiento 
	WHERE TM.Descripcion IN ('ALTA','REINGRESO')
	AND Mov.Fecha BETWEEN @FechaIni AND @FechaFin


	INSERT INTO @Empleados
	SELECT *
	FROM RH.tblEmpleadosMaster M WITH (NOLOCK)
	WHERE IDEmpleado IN (SELECT IDEmpleado FROM #TempMov)


	SELECT
		E.IDEmpleado
	   ,E.ClaveEmpleado
	   ,E.Nombre AS Nombre
	   ,E.Paterno AS Apellido
	   ,CASE WHEN ISNULL(TRIM(E.SegundoNombre),'') = '' THEN ISNULL(TRIM(E.Nombre),'') ELSE ISNULL(TRIM(E.Nombre),'') +' ' END +ISNULL(TRIM(E.SegundoNombre),'') AS Nombres
	   ,ISNULL(TRIM(E.Paterno),'') AS Paterno
	   ,ISNULL(TRIM(E.Materno),'') AS Materno
	   ,E.RFC
	   ,PE.Interbancaria
	   ,PE.Cuenta
	   ,PE.Tarjeta
	   ,PE.IDBancario
	   ,CASE WHEN PP.Descripcion = 'Semanal' THEN 'S'
			 WHEN PP.Descripcion = 'Mensual' THEN 'M'
		ELSE 'D' END AS PeriodoCuenta
	   ,ROW_NUMBER() OVER(PARTITION BY E.ClaveEmpleado ORDER BY E.ClaveEmpleado ASC) AS RN
	INTO #TempDatos
	FROM @Empleados E
		LEFT JOIN RH.tblPagoEmpleado PE WITH (NOLOCK)
			ON E.IDEmpleado = PE.IDEmpleado
		LEFT JOIN RH.tblContactoEmpleado CE WITH (NOLOCK)
			ON E.IDEmpleado = CE.IDEmpleado
			AND CE.IDTipoContactoEmpleado = 1
			AND CE.Predeterminado = 1
		LEFT JOIN Nomina.tblCatTipoNomina TN WITH (NOLOCK)
			ON E.IDTIpoNomina = TN.IDTipoNomina
		INNER JOIN Sat.tblCatPeriodicidadesPago PP WITH (NOLOCK)
			ON TN.IDPeriodicidadPago = PP.IDPeriodicidadPago
	WHERE PE.IDLayoutPago = @IDLayoutPago

	
	--HEADER
	INSERT INTO #TempAltasBanco
	SELECT 
		 [App].[fnAddString](4,ISNULL(@Secuencial,0),'0',1)
		+[App].[fnAddString](10,@AltaFecha,'',1)
		+[App].[fnAddString](5,@AltaHora,'',1)
		+[App].[fnAddString](12,@NumeroCliente,'0',1)
		+[App].[fnAddString](36,@NombreCliente,'',2)
		+[App].[fnAddString](12,'','0',1)
		+[App].[fnAddString](36,'','',2)
	--HEADER


	--BODY
	INSERT INTO #TempAltasBanco
	SELECT
		  [App].[fnAddString](1,'A','',1)
		 +[App].[fnAddString](4,ISNULL(IDBancario,0),'0',1)
		 +[App].[fnAddString](2,'61','0',1)
		 +[App].[fnAddString](4,'0000','0',1)
		 +[App].[fnAddString](2,'00','0',1)
		 +[App].[fnAddString](4,'0','0',1)
		 +[App].[fnAddString](20,ISNULL(Interbancaria,0),'0',1)
		 +[App].[fnAddString](2,'01','0',1)
		 +[App].[fnAddString](55,ISNULL(Nombres,'')+','+ISNULL(Paterno,'')+'/'+ISNULL(Materno,''),'',2)
		 +[App].[fnAddString](20,SUBSTRING(ISNULL(Nombre,'')+','+ISNULL(Apellido,''),1,20),'',2)
		 +[App].[fnAddString](3,'001','0',1)
		 +[App].[fnAddString](14,'0','0',1)
		 +[App].[fnAddString](1,PeriodoCuenta,'',1)
		 +[App].[fnAddString](18,RFC,'',2)
		 +[App].[fnAddString](2,'04','0',1)
		 +[App].[fnAddString](40,'','',2)
		 +[App].[fnAddString](10,'','',2)
		 +[App].[fnAddString](2,'','',2)
		 +[App].[fnAddString](6,'','',1)
		 +[App].[fnAddString](55,'','',1)
		 +[App].[fnAddString](4,'','',1)
		 +[App].[fnAddString](56,'','',1)
	FROM #TempDatos
	WHERE RN = 1
	--BODY


	SELECT * FROM #TempAltasBanco

END
GO
