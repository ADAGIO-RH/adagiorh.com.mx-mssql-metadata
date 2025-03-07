USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
		  
CREATE PROC [Reportes].[spReporteBasicoAsistenciaRangoDeFecha_FS](
	 
	 @dtFiltros [Nomina].[dtFiltrosRH] READONLY
	,@IDUsuario INT

) AS

	SET NOCOUNT ON;

	IF 1=0 
	BEGIN
		SET FMTONLY OFF
	END

	DECLARE 
		 @IDIdioma VARCHAR(5)  
		,@IdiomaSQL VARCHAR(100) = NULL  
		,@Fechas [App].[dtFechasFull]   
		,@dtEmpleados RH.dtEmpleados
		,@IDTipoNomina INT
		,@FechaIni DATE
		,@FechaFin DATE
		,@EmpleadoIni VARCHAR(20)
		,@EmpleadoFin VARCHAR(20)
		,@TipoVigente INT
	;

	DECLARE 
		 @Cols      VARCHAR(MAX)
		,@ColsAlone VARCHAR(MAX)
		,@Query1	VARCHAR(MAX)
		,@Query2	VARCHAR(MAX)
	;

	SET DATEFIRST 7;

	SELECT @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')

	SELECT @IdiomaSQL = [SQL]
	FROM App.tblIdiomas WITH(NOLOCK)
	WHERE IDIdioma = @IDIdioma

	IF (@IdiomaSQL IS NULL OR LEN(@IdiomaSQL) = 0)
	BEGIN
		SET @IdiomaSQL = 'Spanish';
	END
  
	SET LANGUAGE @IdiomaSQL

	SET @IDTipoNomina = ISNULL((SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'TipoNomina'),',')),0)
	SET @FechaIni = (SELECT TOP 1 CAST(Item AS DATE) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'FechaIni'),','))
	SET @FechaFin = (SELECT TOP 1 CAST(Item AS DATE) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'FechaFin'),','))
	SET @EmpleadoIni = ISNULL((SELECT TOP 1 Item FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'ClaveEmpleadoInicial'),',')),'0')    
	SET @EmpleadoFin = ISNULL((SELECT TOP 1 ITem FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZ')  
	SET @TipoVigente = ISNULL((SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'TipoVigente'),',')),1)
	
	INSERT @Fechas  
	EXEC App.spListaFechas @FechaIni = @FechaIni, @FechaFin = @FechaFin  

	IF OBJECT_ID('TempDB..#TempFechas') IS NOT NULL DROP TABLE #TempFechas

	SELECT 
		 App.fnAddString(2,CAST(Dia AS VARCHAR(2)),'0',1)+
									+' - '+ UPPER(SUBSTRING(NombreMes,1,3))
									+' '+ UPPER(NombreDia) AS FECHA
	   ,ROW_NUMBER() OVER(ORDER BY Anio, Mes, Dia ASC) AS OrderColumn
	INTO #TempFechas
	FROM @Fechas

	IF (@TipoVigente = 1)
	BEGIN

	IF OBJECT_ID('TempDB..#TempAusentismosIncidenciasVigentes') IS NOT NULL DROP TABLE #TempAusentismosIncidenciasVigentes;
	IF OBJECT_ID('TempDB..#TempFinalVigentes') IS NOT NULL DROP TABLE #TempFinalVigentes;

		INSERT @dtEmpleados  
		EXEC [RH].[spBuscarEmpleados]   
			 @FechaIni		= @FechaIni           
			,@FechaFin		= @FechaFin    
			,@EmpleadoIni	= @EmpleadoIni
			,@EmpleadoFin	= @EmpleadoFin
			,@IDTipoNomina	= @IDTipoNomina         
			,@IDUsuario		= @IDUsuario                
			,@dtFiltros		= @dtFiltros 

		SELECT IE.*
		INTO #TempAusentismosIncidenciasVigentes
		FROM Asistencia.tblIncidenciaEmpleado IE WITH(NOLOCK)
			 INNER JOIN @Fechas Fecha ON IE.Fecha = Fecha.Fecha 
			 INNER JOIN @dtEmpleados TempEmp ON IE.IDEmpleado = TempEmp.IDEmpleado
		WHERE IE.Autorizado = 1

		SELECT
			 EmpFecha.IDEmpleado AS IDEMPLEADO
			,EmpFecha.ClaveEmpleado AS [CLAVE EMPLEADO]
			,EmpFecha.NOMBRECOMPLETO AS NOMBRE
			,EmpFecha.Puesto AS PUESTO
			,FECHA = App.fnAddString(2,CAST(EmpFecha.Dia AS VARCHAR(2)),'0',1)+
									+' - '+ UPPER(SUBSTRING(EmpFecha.NombreMes,1,3))
									+' '+ UPPER(EmpFecha.NombreDia)
			,STRING_AGG(ISNULL(I.IDIncidencia,''),',') AS [AUSENTISMO/INCIDENCIA]
		INTO #TempFinalVigentes
		FROM (SELECT *
			  FROM @Fechas
				  ,@dtEmpleados) AS EmpFecha
		LEFT JOIN #TempAusentismosIncidenciasVigentes I ON I.IDEmpleado = EmpFecha.IDEmpleado AND I.Fecha = EmpFecha.Fecha
		LEFT JOIN Seguridad.tblDetalleFiltrosEmpleadosUsuarios DFE ON DFE.IDEmpleado = EmpFecha.IDEmpleado AND DFE.IDUsuario = @IDUsuario
		GROUP BY EmpFecha.IDEmpleado
				,EmpFecha.ClaveEmpleado
				,EmpFecha.NOMBRECOMPLETO
				,EmpFecha.Puesto 
				,EmpFecha.Dia
				,EmpFecha.NombreMes
				,EmpFecha.NombreDia
		ORDER BY EmpFecha.IDEmpleado

		SET @Cols = STUFF((SELECT ',' + ' ISNULL('+ QUOTENAME(FECHA) +',''1900-01-01'') AS '+ QUOTENAME(FECHA)
					FROM #TempFechas
					ORDER BY OrderColumn
					FOR XML PATH(''), TYPE
					).value('.','VARCHAR(MAX)')
			,1,1,'')

		SET @ColsAlone = STUFF((SELECT ',' + QUOTENAME(FECHA)
						 FROM #TempFechas
						 ORDER BY OrderColumn
						 FOR XML PATH(''), TYPE
						 ).value('.','VARCHAR(MAX)')
			,1,1,'')


		SET @Query1 = 'SELECT [CLAVE EMPLEADO], NOMBRE, PUESTO, + ' + @Cols + '
					   FROM 
							(SELECT
								  [CLAVE EMPLEADO]
								 ,NOMBRE
								 ,PUESTO
								 ,FECHA
								 ,[AUSENTISMO/INCIDENCIA]
							 FROM #TempFinalVigentes
							) X'

		SET @Query2 = '
						PIVOT 
							 (
								MAX([AUSENTISMO/INCIDENCIA])
								FOR FECHA IN (' + @ColsAlone + ')
							) P

							ORDER BY [CLAVE EMPLEADO]
					  '
		EXEC (@Query1 + @Query2)

	END
	ELSE IF (@TipoVigente = 2)
	BEGIN
	
	IF OBJECT_ID('TempDB..#TempAusentismosIncidenciasNoVigentes') IS NOT NULL DROP TABLE #TempAusentismosIncidenciasNoVigentes;
	IF OBJECT_ID('TempDB..#TempFinalNoVigentes') IS NOT NULL DROP TABLE #TempFinalNoVigentes;

		INSERT @dtEmpleados  
		EXEC [RH].[spBuscarEmpleados]   
			 @FechaIni		= @FechaIni           
			,@FechaFin		= @FechaFin    
			,@EmpleadoIni	= @EmpleadoIni
			,@EmpleadoFin	= @EmpleadoFin
			,@IDTipoNomina	= @IDTipoNomina         
			,@IDUsuario		= @IDUsuario                
			,@dtFiltros		= @dtFiltros 

		SELECT IE.*
		INTO #TempAusentismosIncidenciasNoVigentes
		FROM Asistencia.tblIncidenciaEmpleado IE WITH(NOLOCK)
			 INNER JOIN @Fechas Fecha ON IE.Fecha = Fecha.Fecha
		WHERE IE.Autorizado = 1
		
		SELECT
			 EmpFecha.IDEmpleado AS IDEMPLEADO
			,EmpFecha.ClaveEmpleado AS [CLAVE EMPLEADO]
			,EmpFecha.NOMBRECOMPLETO AS NOMBRE
			,EmpFecha.Puesto AS PUESTO
			,FECHA = App.fnAddString(2,CAST(EmpFecha.Dia AS VARCHAR(2)),'0',1)+
									+' - '+ UPPER(SUBSTRING(EmpFecha.NombreMes,1,3))
									+' '+ UPPER(EmpFecha.NombreDia)
			,STRING_AGG(ISNULL(I.IDIncidencia,''),',') AS [AUSENTISMO/INCIDENCIA]
		INTO #TempFinalNoVigentes
		FROM (SELECT *
			  FROM @Fechas
				  ,RH.tblEmpleadosMaster) AS EmpFecha
		LEFT JOIN #TempAusentismosIncidenciasNoVigentes I ON I.IDEmpleado = EmpFecha.IDEmpleado AND I.Fecha = EmpFecha.Fecha
		LEFT JOIN Seguridad.tblDetalleFiltrosEmpleadosUsuarios DFE ON DFE.IDEmpleado = EmpFecha.IDEmpleado AND DFE.IDUsuario = @IDUsuario
		WHERE EmpFecha.IDEmpleado NOT IN (SELECT IDEmpleado FROM @dtEmpleados)
			  AND (EmpFecha.IDTiponomina = @IDTipoNomina)
			  AND ((EmpFecha.IDDivision				    IN (SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'Divisiones'),','))
													    OR (NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'Divisiones' AND ISNULL(Value,'') <> ''))))
			  AND ((EmpFecha.IDClasificacionCorporativa IN (SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'ClasificacionesCorporativas'),','))
													    OR (NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'ClasificacionesCorporativas' AND ISNULL(Value,'') <> ''))))
			  AND ((EmpFecha.IDCentroCosto			    IN (SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'CentrosCostos'),','))
													    OR (NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'CentrosCostos' AND ISNULL(Value,'') <> ''))))
			  AND ((EmpFecha.IDDepartamento			    IN (SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'Departamentos'),','))
														OR (NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'Departamentos' AND ISNULL(Value,'') <> ''))))
			  AND ((EmpFecha.IDArea					    IN (SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'Areas'),','))
														OR (NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'Areas' AND ISNULL(Value,'') <> ''))))
			  AND ((EmpFecha.IDSucursal				    IN (SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'Sucursales'),','))
														OR (NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'Sucursales' AND ISNULL(Value,'') <> ''))))
			  AND ((EmpFecha.IDCliente				    IN (SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'Clientes'),','))
														OR (NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'Clientes' AND ISNULL(Value,'') <> ''))))
		GROUP BY EmpFecha.IDEmpleado
				,EmpFecha.ClaveEmpleado
				,EmpFecha.NOMBRECOMPLETO
				,EmpFecha.Puesto 
				,EmpFecha.Dia
				,EmpFecha.NombreMes
				,EmpFecha.NombreDia
		ORDER BY EmpFecha.IDEmpleado


		SET @Cols = STUFF((SELECT ',' + ' ISNULL('+ QUOTENAME(FECHA) +',''1900-01-01'') AS '+ QUOTENAME(FECHA)
					FROM #TempFechas
					ORDER BY OrderColumn
					FOR XML PATH(''), TYPE
					).value('.','VARCHAR(MAX)')
			,1,1,'')

		SET @ColsAlone = STUFF((SELECT ',' + QUOTENAME(FECHA)
						 FROM #TempFechas
						 ORDER BY OrderColumn
						 FOR XML PATH(''), TYPE
						 ).value('.','VARCHAR(MAX)')
			,1,1,'')


		SET @Query1 = 'SELECT [CLAVE EMPLEADO], NOMBRE, PUESTO, + ' + @Cols + '
					   FROM 
							(SELECT
								  [CLAVE EMPLEADO]
								 ,NOMBRE
								 ,PUESTO
								 ,FECHA
								 ,[AUSENTISMO/INCIDENCIA]
							 FROM #TempFinalNoVigentes
							) X'

		SET @Query2 = '
						PIVOT 
							 (
								MAX([AUSENTISMO/INCIDENCIA])
								FOR FECHA IN (' + @ColsAlone + ')
							) P

							ORDER BY [CLAVE EMPLEADO]
					  '
		EXEC (@Query1 + @Query2)

	END
	ELSE IF (@TipoVigente = 3)
	BEGIN
			
	IF OBJECT_ID('TempDB..#TempAusentismosIncidenciasAmbos') IS NOT NULL DROP TABLE #TempAusentismosIncidenciasAmbos;
	IF OBJECT_ID('TempDB..#TempFinalAmbos') IS NOT NULL DROP TABLE #TempFinalAmbos;

		SELECT IE.*
		INTO #TempAusentismosIncidenciasAmbos
		FROM Asistencia.tblIncidenciaEmpleado IE WITH(NOLOCK)
			 INNER JOIN @Fechas Fecha ON IE.Fecha = Fecha.Fecha
		WHERE IE.Autorizado = 1

		SELECT
			 EmpFecha.IDEmpleado AS IDEMPLEADO
			,EmpFecha.ClaveEmpleado AS [CLAVE EMPLEADO]
			,EmpFecha.NOMBRECOMPLETO AS NOMBRE
			,EmpFecha.Puesto AS PUESTO
			,FECHA = App.fnAddString(2,CAST(EmpFecha.Dia AS VARCHAR(2)),'0',1)+
									+' - '+ UPPER(SUBSTRING(EmpFecha.NombreMes,1,3))
									+' '+ UPPER(EmpFecha.NombreDia)
			,STRING_AGG(ISNULL(I.IDIncidencia,''),',') AS [AUSENTISMO/INCIDENCIA]
		INTO #TempFinalAmbos
		FROM (SELECT *
			  FROM @Fechas
				  ,RH.tblEmpleadosMaster) AS EmpFecha
		LEFT JOIN #TempAusentismosIncidenciasAmbos I ON I.IDEmpleado = EmpFecha.IDEmpleado AND I.Fecha = EmpFecha.Fecha
		LEFT JOIN Seguridad.tblDetalleFiltrosEmpleadosUsuarios DFE ON DFE.IDEmpleado = EmpFecha.IDEmpleado AND DFE.IDUsuario = @IDUsuario
		WHERE (EmpFecha.IDTiponomina = @IDTipoNomina)
			  AND ((EmpFecha.IDDivision				    IN (SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'Divisiones'),','))
													    OR (NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'Divisiones' AND ISNULL(Value,'') <> ''))))
			  AND ((EmpFecha.IDClasificacionCorporativa IN (SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'ClasificacionesCorporativas'),','))
													    OR (NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'ClasificacionesCorporativas' AND ISNULL(Value,'') <> ''))))
			  AND ((EmpFecha.IDCentroCosto			    IN (SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'CentrosCostos'),','))
													    OR (NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'CentrosCostos' AND ISNULL(Value,'') <> ''))))
			  AND ((EmpFecha.IDDepartamento			    IN (SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'Departamentos'),','))
														OR (NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'Departamentos' AND ISNULL(Value,'') <> ''))))
			  AND ((EmpFecha.IDArea					    IN (SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'Areas'),','))
														OR (NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'Areas' AND ISNULL(Value,'') <> ''))))
			  AND ((EmpFecha.IDSucursal				    IN (SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'Sucursales'),','))
														OR (NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'Sucursales' AND ISNULL(Value,'') <> ''))))
			  AND ((EmpFecha.IDCliente				    IN (SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'Clientes'),','))
														OR (NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'Clientes' AND ISNULL(Value,'') <> ''))))
		GROUP BY EmpFecha.IDEmpleado
				,EmpFecha.ClaveEmpleado
				,EmpFecha.NOMBRECOMPLETO
				,EmpFecha.Puesto 
				,EmpFecha.Dia
				,EmpFecha.NombreMes
				,EmpFecha.NombreDia
		ORDER BY EmpFecha.IDEmpleado

		SET @Cols = STUFF((SELECT ',' + ' ISNULL('+ QUOTENAME(FECHA) +',''1900-01-01'') AS '+ QUOTENAME(FECHA)
					FROM #TempFechas
					ORDER BY OrderColumn
					FOR XML PATH(''), TYPE
					).value('.','VARCHAR(MAX)')
			,1,1,'')

		SET @ColsAlone = STUFF((SELECT ',' + QUOTENAME(FECHA)
						 FROM #TempFechas
						 ORDER BY OrderColumn
						 FOR XML PATH(''), TYPE
						 ).value('.','VARCHAR(MAX)')
			,1,1,'')


		SET @Query1 = 'SELECT [CLAVE EMPLEADO], NOMBRE, PUESTO, + ' + @Cols + '
					   FROM 
							(SELECT
								  [CLAVE EMPLEADO]
								 ,NOMBRE
								 ,PUESTO
								 ,FECHA
								 ,[AUSENTISMO/INCIDENCIA]
							 FROM #TempFinalAmbos
							) X'

		SET @Query2 = '
						PIVOT 
							 (
								MAX([AUSENTISMO/INCIDENCIA])
								FOR FECHA IN (' + @ColsAlone + ')
							) P

							ORDER BY [CLAVE EMPLEADO]
					  '
		EXEC (@Query1 + @Query2)

	END
GO
