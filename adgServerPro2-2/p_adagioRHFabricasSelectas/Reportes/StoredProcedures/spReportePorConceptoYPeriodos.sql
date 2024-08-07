USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spReportePorConceptoYPeriodos](

	@dtFiltros [Nomina].[dtFiltrosRH] READONLY
   ,@IDUsuario INT

) AS

BEGIN

	DECLARE 
		@Ejercicio INT
	   ,@IDTipoNomina INT
	   ,@IDMes INT
	   ,@ClaveEmpleadoInicial VARCHAR(MAX) = '0'
	   ,@ClaveEmpleadoFinal VARCHAR(MAX) = 'ZZZZZZZZZZZZZZZZZZZZ'
	   ,@Periodo [Nomina].[dtPeriodos]
	   ,@Empleados [RH].[dtEmpleados]
	   ,@dtFiltrosEmpleados [Nomina].[dtFiltrosRH]

	   SELECT @Ejercicio = (SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'Ejercicio'),','))
	   SELECT @IDTipoNomina = (SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'TipoNomina'),','))
	   SELECT @IDMes = (SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'IDMes'),','))
	   SELECT @ClaveEmpleadoInicial = ISNULL((SELECT TOP 1 Item FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'ClaveEmpleadoInicial'),',')),'0')

	   SELECT @ClaveEmpleadoFinal = CASE WHEN ISNULL(@ClaveEmpleadoInicial,'0') <> '0' THEN @ClaveEmpleadoInicial ELSE 'ZZZZZZZZZZZZZZZZZZZZ' END

	   INSERT INTO @Periodo
	   SELECT *
	   FROM Nomina.tblCatPeriodos
	   WHERE IDPeriodo IN ((SELECT CAST(Item AS INT) FROM App.Split((SELECT Value FROM @dtFiltros WHERE Catalogo = 'ClaveEmpleadoFinal'),','))) 

	  IF EXISTS ( SELECT TOP 1 Ejercicio	
				  FROM @Periodo 
				  WHERE Ejercicio <> @Ejercicio )
	  BEGIN
		RAISERROR('LOS PERIODOS SELECCIONADOS SON DE DISTINTOS EJERCICIOS',16,1)
		RETURN
	  END

	  IF EXISTS ( SELECT TOP 1 IDTipoNomina	
				  FROM @Periodo 
				  WHERE IDTipoNomina <> @IDTipoNomina )
	  BEGIN
		RAISERROR('LOS PERIODOS SELECCIONADOS SON DE DISTINTOS TIPO DE NOMINA',16,1)
		RETURN
	  END

	  IF EXISTS ( SELECT TOP 1 IDMes
				  FROM @Periodo
				  WHERE IDMes <> @IDMes )
	  BEGIN
		RAISERROR('LOS PERIODOS SELECCIONADOS SON DE DISTINTOS MESES',16,1)
		RETURN
	  END

	  IF EXISTS ( SELECT TOP 1 Cerrado
				  FROM @Periodo
				  WHERE Cerrado <> 1 )
	  BEGIN
		RAISERROR('EXISTEN PERIODOS ABIERTOS',16,1)
		RETURN
	  END

	  INSERT INTO @dtFiltrosEmpleados
	  SELECT * FROM @dtFiltros WHERE Catalogo NOT IN ('ClaveEmpleadoInicial','ClaveEmpleadoFinal')

	  INSERT INTO @Empleados
	  EXEC [RH].[spBuscarEmpleados] @EmpleadoIni = @ClaveEmpleadoInicial, @EmpleadoFin = @ClaveEmpleadoFinal, @IDTipoNomina = @IDTipoNomina, @dtFiltros = @dtFiltrosEmpleados, @IDUsuario = @IDUsuario

	  IF OBJECT_ID('TempDB..#TempConceptos') IS NOT NULL DROP TABLE #TempConceptos
	  IF OBJECT_ID('TempDB..#TempData') IS NOT NULL DROP TABLE #TempData

	  SELECT DISTINCT 
		 C.IDConcepto
		,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(SUBSTRING(C.Descripcion,0,21)+'_'+C.Codigo,' ','_'),'-',''),'.',''),'(',''),')','') AS Concepto
		,C.IDTipoConcepto AS IDTipoConcepto
		,C.TipoConcepto
		,C.Orden AS OrdenCalculo
		,CASE WHEN C.IDTipoConcepto IN (1,4) THEN 1
			  WHEN C.IDTipoConcepto = 2      THEN 2
			  WHEN C.IDTipoConcepto = 3      THEN 3
			  WHEN C.IDTipoConcepto = 6      THEN 4
			  WHEN C.IDTipoConcepto = 5      THEN 5
		 ELSE 0
		 END AS OrdenColumn
	INTO #TempConceptos
	FROM (SELECT 
			 CCC.*
			,TC.Descripcion AS TipoConcepto
			,CRR.Orden
		FROM Nomina.tblCatConceptos CCC WITH(NOLOCK) 
			INNER JOIN Nomina.tblCatTipoConcepto TC WITH(NOLOCK) ON TC.IDTipoConcepto = CCC.IDTipoConcepto
			INNER JOIN Reportes.tblConfigReporteRayas CRR WITH(NOLOCK) ON CRR.IDConcepto = CCC.IDConcepto AND CRR.Impresion = 1
		) C 
	WHERE C.IDConcepto IN ( (SELECT CAST(Item AS int) FROM App.Split((SELECT Value FROM @dtFiltros WHERE Catalogo = 'CatalogoConceptos'),',') ) )

	SELECT
		 E.ClaveEmpleado AS CLAVE
		,E.NOMBRECOMPLETO AS NOMBRE
		,E.Empresa AS [RAZON SOCIAL]
		,E.Sucursal AS SUCURSAL
		,E.Departamento AS DEPARTAMENTO
		,E.Puesto AS PUESTO
		,E.Division AS DIVISION
		,E.CentroCosto AS [CENTRO COSTO]
		,C.Concepto AS CONCEPTO
		,P.ClavePeriodo+' '+P.Descripcion AS PERIODO
		,SUM(ISNULL(DP.ImporteTotal1,0)) AS ImporteTotal1
	INTO #TempData
	FROM @Periodo P
		INNER JOIN Nomina.tblDetallePeriodo DP WITH(NOLOCK)
			ON P.IDPeriodo = DP.IDPeriodo
		INNER JOIN #TempConceptos C WITH(NOLOCK)
			ON C.IDConcepto = DP.IDConcepto
		INNER JOIN @Empleados E 
			ON DP.IDEmpleado = E.IDEmpleado
	GROUP BY 
		 E.ClaveEmpleado
		,E.NOMBRECOMPLETO
		,C.Concepto
		,E.Empresa
		,E.Sucursal 
		,E.Departamento
		,E.Puesto
		,E.Division
		,E.CentroCosto
		,P.ClavePeriodo
		,P.Descripcion
	ORDER BY E.ClaveEmpleado ASC

	DECLARE 
		 @Cols      AS VARCHAR(MAX)
		,@ColsAlone AS VARCHAR(MAX)
		,@Query1    AS VARCHAR(MAX)
		,@Query2    AS VARCHAR(MAX)
	;

	SET @Cols = STUFF((SELECT ',' +' ISNULL('+ QUOTENAME(P.ClavePeriodo+' '+P.Descripcion)+',0) AS '+ QUOTENAME(P.ClavePeriodo+' '+P.Descripcion)
				FROM @Periodo P
				GROUP BY P.IDPeriodo,P.ClavePeriodo,P.Descripcion
				ORDER BY P.IDPeriodo
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');

	SET @ColsAlone = STUFF((SELECT ','+ QUOTENAME(P.ClavePeriodo+' '+P.Descripcion)
			FROM @Periodo P
			GROUP BY P.IDPeriodo,P.ClavePeriodo,P.Descripcion
			ORDER BY P.IDPeriodo
			FOR XML PATH(''), TYPE
			).value('.', 'VARCHAR(MAX)') 
		,1,1,'');

	
	SET @Query1 = 'SELECT CLAVE, NOMBRE, [RAZON SOCIAL], SUCURSAL, [CENTRO COSTO], DEPARTAMENTO, PUESTO, CONCEPTO, ' + @Cols + '
				   FROM 
					  (SELECT 
						  CLAVE
						 ,NOMBRE
						 ,[RAZON SOCIAL]
						 ,SUCURSAL
						 ,[CENTRO COSTO]
						 ,DEPARTAMENTO
						 ,PUESTO
						 ,CONCEPTO
						 ,PERIODO
						 ,ISNULL(ImporteTotal1,0) AS ImporteTotal1
					   FROM #TempData
					) X'

	SET @Query2 = '
					PIVOT 
						(
							MAX(ImporteTotal1)
							FOR Periodo IN (' + @ColsAlone + ')
						) P 

					ORDER BY CLAVE
				  '

	EXEC (@Query1 + @Query2) 

END
GO
