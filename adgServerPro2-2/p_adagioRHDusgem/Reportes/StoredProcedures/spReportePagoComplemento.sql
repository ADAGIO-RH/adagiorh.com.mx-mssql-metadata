USE [p_adagioRHDusgem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spReportePagoComplemento](


	 @dtFiltros [Nomina].[dtFiltrosRH] READONLY
	,@IDUsuario INT


)
AS

BEGIN

		
		DECLARE 
			 @IDTipoNomina INT
			,@IDPeriodoSeleccionado INT
			,@Empleados [RH].[dtEmpleados]
			,@Periodo [Nomina].[dtPeriodos]
			,@FechaIni DATE
			,@FechaFin DATE
			,@ConceptosPagoComplemento VARCHAR(250) = '901,A902'
			,@Concepto902 VARCHAR(5) = '902'
			

		SELECT @IDTipoNomina = ISNULL((SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'TipoNomina'),',')),0)
		SELECT @IDPeriodoSeleccionado = ISNULL((SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'IDPeriodoInicial'),',')),0)


		INSERT INTO @Periodo
		SELECT *
		FROM Nomina.tblCatPeriodos WITH (NOLOCK)
		WHERE IDPeriodo = @IDPeriodoSeleccionado


		SELECT @FechaIni = FechaInicioPago
			  ,@FechaFin = FechaFinPago
		FROM @Periodo


		INSERT INTO @Empleados
		EXEC [RH].[spBuscarEmpleados] @FechaIni = @FechaIni, @FechaFin = @FechaFin, @IDTipoNomina = @IDTipoNomina, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario


		IF OBJECT_ID('TempDB..#TempSalida') IS NOT NULL DROP TABLE #TempSalida

		CREATE TABLE #TempSalida 
		(
			PROYECTO VARCHAR(250)
		   ,CLABE VARCHAR(50)
		   ,RFC VARCHAR(20)
		   ,NOMBRE VARCHAR(250)
		   ,MONTO DECIMAL(18,2)
		   ,BANCO VARCHAR(255)
		   ,OBSERVACIONES CHAR(1)
		)


		IF OBJECT_ID('TempDB..#TempPagos') IS NOT NULL DROP TABLE #TempPagos
		
		SELECT PE.*, B.Descripcion AS Banco, ROW_NUMBER() OVER(PARTITION BY PE.IDEmpleado ORDER BY PE.IDEmpleado ASC) AS CantidadLayouts
		INTO #TempPagos
		FROM @Empleados E
			LEFT JOIN RH.tblPagoEmpleado PE WITH (NOLOCK)
				ON E.IDEmpleado = PE.IDEmpleado
			INNER JOIN Sat.tblCatBancos B WITH (NOLOCK)
				ON B.IDBanco = PE.IDBanco


		DELETE FROM #TempPagos WHERE CantidadLayouts <> 1


		INSERT INTO #TempSalida (PROYECTO, CLABE, RFC, NOMBRE, MONTO, BANCO)
		SELECT
			 E.Sucursal
			,ISNULL(TP.Interbancaria,'SIN CLABE')
			,E.RFC
			,E.NOMBRECOMPLETO
			,ISNULL(DP.ImporteTotal1,0)
			,ISNULL(TP.Banco,'SIN BANCO')
		FROM @Empleados E
			LEFT JOIN Nomina.tblDetallePeriodo DP WITH (NOLOCK)
				ON E.IDEmpleado = DP.IDEmpleado
			INNER JOIN @Periodo P 
				ON P.IDPeriodo = DP.IDPeriodo
			LEFT JOIN #TempPagos TP WITH (NOLOCK)
				ON E.IDEmpleado = TP.IDEmpleado
		WHERE DP.ImporteTotal1 > 0
		AND DP.IDConcepto IN (SELECT IDConcepto FROM Nomina.tblCatConceptos WITH (NOLOCK) WHERE Codigo IN 
		(SELECT Item FROM App.Split(CASE WHEN E.TipoNomina = 'PROYECTOS SEMANAL' AND E.CentroCosto <> 'EL RETAMAL' THEN @Concepto902 ELSE @ConceptosPagoComplemento END,',')))
		 

		SELECT
			PROYECTO 
		   ,CLABE 
		   ,RFC AS [RFC ]
		   ,NOMBRE 
		   ,MONTO 
		   ,BANCO 
		   ,OBSERVACIONES 
		FROM #TempSalida


END
GO
