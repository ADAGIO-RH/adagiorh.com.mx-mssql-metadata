USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Obtiene el promedio sobre el reclutamiento y seleccion
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2022-06-22
** Paremetros		: @IDIndicador
**					: @JsonFiltros
**					: @JsonGroup
**					: @IDPeriodo
**					: @FechaDe
**					: @FechaHasta
** IDAzure			: 

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

create PROC [InfoDir].[spIndicadorReclutamientoPromedio]
(
	@IDIndicador INT,
	@JsonFiltros NVARCHAR(MAX),
	@JsonGroup NVARCHAR(MAX),
	@IDPeriodo INT,
	@FechaDe DATE,
	@FechaHasta DATE
)
AS
	BEGIN		

		SET LANGUAGE 'spanish'

		DECLARE @dtFiltros [Nomina].[dtFiltrosRH];
		DECLARE @GroupBy NVARCHAR(MAX) = '';
		DECLARE @Label VARCHAR(250) = '';
		DECLARE @Condicion VARCHAR(MAX);
		DECLARE @Qry NVARCHAR(MAX);
		DECLARE @Qry2 VARCHAR(MAX);
		
		
		CREATE TABLE #GroupBy(
			[ID] INT IDENTITY(1,1),
			[Catalogo] VARCHAR(50)
		)		
		
		CREATE TABLE #TempReclutamiento (
			[Dia] DATE,
			[IDCandidato] INT,
			[Candidato] VARCHAR(150),
			[IDPuesto] INT,
			[Puesto] VARCHAR(150),
			[IDRequisitoPuesto] INT,
			[RequisitoPuesto] VARCHAR(MAX),
			[IDTipoCaracteristica] INT,
			[TipoCaracteristica] VARCHAR(50),
			[Resultado] VARCHAR(15),
			[Semana] INT,
			[Mes] VARCHAR(25),
			[Anio] INT			
		);

		CREATE TABLE #TempFiltrosReclutamiento (
			[Dia] DATE,
			[IDCandidato] INT,
			[Candidato] VARCHAR(150),
			[IDPuesto] INT,
			[Puesto] VARCHAR(150),
			[IDRequisitoPuesto] INT,
			[RequisitoPuesto] VARCHAR(MAX),
			[IDTipoCaracteristica] INT,
			[TipoCaracteristica] VARCHAR(50),
			[Resultado] VARCHAR(15),
			[Semana] INT,
			[Mes] VARCHAR(25),
			[Anio] INT	
		);



		-- CONSULTAMOS CONDICION DEL PERIODO
		IF(@IDIndicador <> 0)
			BEGIN				
				-- CONSULTAMOS JSON(FILTROS Y GROUP BY) Y CONDICION DEL PERIODO
				SELECT @JsonFiltros = I.ConfiguracionFiltros,
					   @JsonGroup = I.ConfiguracionGroupBy,
					   @Condicion = P.Condicion,
					   @FechaDe = I.FechaDe,
					   @FechaHasta = I.FechaHasta
				FROM [InfoDir].[tblCatIndicadores] I
					INNER JOIN [InfoDir].[tblCatPeriodos] P ON I.IDPeriodo = P.IDPeriodo
				WHERE I.IDIndicador = @IDIndicador
			END
		ELSE
			BEGIN
				-- CONSULTAMOS CONDICION DEL PERIODO
				SELECT @Condicion = P.Condicion 
				FROM [InfoDir].[tblCatPeriodos] P
				WHERE P.IDPeriodo = @IDPeriodo
			END


					   
		-- FILTRAMOS POR PERIODICIDAD
		SET @Qry = N'INSERT INTO #TempReclutamiento '
		SET @Qry = @Qry + 'SELECT R.FechaNormalizacion AS Dia, '
		SET @Qry = @Qry + 'R.IDCandidato, '
		SET @Qry = @Qry + 'R.Candidato, '
		SET @Qry = @Qry + 'R.IDPuesto, '
		SET @Qry = @Qry + 'R.Puesto, '
		SET @Qry = @Qry + 'R.IDRequisitoPuesto, '
		SET @Qry = @Qry + 'R.RequisitoPuesto, '
		SET @Qry = @Qry + 'R.IDTipoCaracteristica, '
		SET @Qry = @Qry + 'R.TipoCaracteristica, '
		SET @Qry = @Qry + 'R.Resultado, '
		SET @Qry = @Qry + 'DATEPART(WEEK, R.FechaNormalizacion) AS Semana, '
		SET @Qry = @Qry + 'DATENAME(MONTH, R.FechaNormalizacion) AS Mes, '
		SET @Qry = @Qry + 'DATEPART(YEAR, R.FechaNormalizacion) AS Anio '
		SET @Qry = @Qry + 'FROM [InfoDir].[tblReclutamientoNormalizado] R '
		SET @Qry = @Qry + '' + @Condicion + ' '
		SET @Qry = @Qry + 'ORDER BY R.FechaNormalizacion'
		--SELECT @Qry
		EXEC SP_EXECUTESQL @Qry, N'@FechaDe DATE, @FechaHasta DATE', @FechaDe, @FechaHasta;
		
			
		
		-- CONVERTIMOS FILTROS A TABLA
		INSERT @dtFiltros(Catalogo, Value)
		SELECT *
		FROM OPENJSON(JSON_QUERY(@JsonFiltros,  '$.Filtros'))
		  WITH (
			catalogo NVARCHAR(50) '$.catalogo',
			valor NVARCHAR(50) '$.valor'
		  );

		-- CONVERTIMOS GROUP BY A TABLA
		INSERT #GroupBy(Catalogo)
		SELECT *
		FROM OPENJSON(JSON_QUERY(@JsonGroup,  '$.GroupBy'))
		  WITH (
			catalogo NVARCHAR(50) '$.catalogo'
		  );	

		  
		
		-- OBTENEMOS LA INFORMACION FILTRADA
		INSERT INTO #TempFiltrosReclutamiento
		SELECT *
		FROM #TempReclutamiento
		WHERE (
				IDPuesto IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDPuesto'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDPuesto' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDCandidato IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDCandidato'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDCandidato' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDTipoCaracteristica IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDTipoCaracteristica'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDTipoCaracteristica' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDRequisitoPuesto IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDRequisitoPuesto'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDRequisitoPuesto' AND ISNULL(Value, '') <> '')
					)
			 ) 	 			 
			 ORDER BY Dia


		
		-- OBTENEMOS EL GROUP BY PARA APLICARLO A LA CONSULTA DINAMICA			
		SELECT @Label = Catalogo FROM #GroupBy WHERE ID = 1
		IF(@Label = '')
			BEGIN				
				SELECT @Label = 'Dia'
			END
		SELECT @GroupBy = ISNULL(STUFF((SELECT ',' + CONVERT(NVARCHAR(MAX), catalogo) FROM #GroupBy WHERE ID > 1 FOR XML PATH('')), 1, 1, ''), '');



		-- RESULTADO FINAL
		SET @Qry2 = ';WITH TblLabel (' + @Label + ', ResultadoTotal) '
		SET @Qry2 = @Qry2 + 'AS '
		SET @Qry2 = @Qry2 + '( '
		SET @Qry2 = @Qry2 + 'SELECT ' + @Label + ', '
		SET @Qry2 = @Qry2 + 'COUNT(Resultado) AS ResultadoTotal '
		SET @Qry2 = @Qry2 + 'FROM #TempFiltrosReclutamiento '
		SET @Qry2 = @Qry2 + 'GROUP BY ' + @Label + ' '
		SET @Qry2 = @Qry2 + ') '		
		SET @Qry2 = @Qry2 + 'SELECT (SELECT T.' + @Label + ', '
		SET @Qry2 = @Qry2 + 'CAST((CAST(COUNT(Grupo.Resultado) AS FLOAT) / CAST(T.ResultadoTotal AS FLOAT)) * 100 AS DECIMAL(18,2)) AS Resultado, '
		SET @Qry2 = @Qry2 + 'Grupo.Resultado '

		IF (ISNULL(@GroupBy, '') <> '')
			BEGIN
				SET @Qry2 = @Qry2 + ',' + @GroupBy + ' '
			END
					
		SET @Qry2 = @Qry2 + 'FROM TblLabel T '
		SET @Qry2 = @Qry2 + 'INNER JOIN #TempFiltrosReclutamiento Grupo ON T.' + @Label + ' = Grupo.' + @Label + ' '
		SET @Qry2 = @Qry2 + 'GROUP BY T.' + @Label + ', T.ResultadoTotal, Grupo.Resultado '

		IF (ISNULL(@GroupBy, '') <> '')
			BEGIN
				SET @Qry2 = @Qry2 + ', ' + @GroupBy + ' '
			END

		SET @Qry2 = @Qry2 + 'ORDER BY T.' + @Label + ', T.ResultadoTotal, Grupo.Resultado '

		IF (ISNULL(@GroupBy, '') <> '')
			BEGIN
				SET @Qry2 = @Qry2 + ', ' + @GroupBy + ' '
			END

		SET @Qry2 = @Qry2 + 'FOR JSON AUTO) AS ResultJson'

		--SELECT @Qry2
		EXECUTE (@Qry2);

		--SELECT '[{"Candidato":"ASDFASDF SDFSDF NO","Resultado":50,"Grupo":[{"Resultado":"No"}]},{"Candidato":"ASDFASDF SDFSDF","Resultado":50,"Grupo":[{"Resultado":"No"}]},{"Candidato":"JOSE  ROMAN","Resultado":40,"Grupo":[{"Resultado":"No"}]},{"Candidato":"JOSE  ROMAN","Resultado":60,"Grupo":[{"Resultado":"Si"}]}]' AS ResultJson
		

	END
GO
