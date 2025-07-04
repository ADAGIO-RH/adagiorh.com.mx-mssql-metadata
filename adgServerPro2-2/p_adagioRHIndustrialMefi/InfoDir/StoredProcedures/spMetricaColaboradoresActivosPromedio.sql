USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Obtiene el promedio de colaboradores activos
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2022-04-08
** Parametros		: @IDMetrica
**					: @JsonFiltros
**					: @IDPeriodo
**					: @FechaDe
**					: @FechaHasta
** IDAzure			: 821

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROC [InfoDir].[spMetricaColaboradoresActivosPromedio]
(
	@IDMetrica INT
	,@JsonFiltros NVARCHAR(MAX)
	,@IDPeriodo INT
	,@FechaDe DATE
	,@FechaHasta DATE
)
AS
	BEGIN

		SET LANGUAGE 'spanish'
		
		DECLARE @dtFiltros [Nomina].[dtFiltrosRH]
				,@GroupBy NVARCHAR(MAX) = ''
				,@Condicion VARCHAR(MAX)
				,@Qry NVARCHAR(MAX)
				,@Qry2 NVARCHAR(MAX)
				,@Metrica INT = 1
				,@IDIdioma varchar(20);				

		SELECT @IDIdioma = [App].[fnGetPreferencia]('Idioma', 1, 'esmx');

		
		-- ELIMINAMOS LAS TABLAS TEMPORALES
		IF OBJECT_ID('tempdb..#TempActivos') IS NOT NULL BEGIN DROP TABLE #TempActivos END
		IF OBJECT_ID('tempdb..#TblFiltrosActivos') IS NOT NULL BEGIN DROP TABLE #TblFiltrosActivos END	

		-- CREAMOS TABLAS TEMPORALES
		DECLARE @TblGroupBy TABLE(
			[ID] INT IDENTITY(1,1),
			[Catalogo] VARCHAR(50)
		)

		CREATE TABLE #TempActivos (
			[FechaNormalizacion] DATE
			,[EmpleadosVigentes] INT
			,[IDCliente] INT
			,[IDRazonSocial] INT
			,[IDRegPatronal] INT
			,[IDCentroCosto] INT
			,[IDDepartamento] INT
			,[IDArea] INT
			,[IDPuesto] INT
			,[IDTipoPrestacion] INT
			,[IDSucursal] INT
			,[IDDivision] INT
			,[IDRegion] INT
			,[IDClasificacionCorporativa] INT
			,[NombreComercial] VARCHAR(250)
			,[RazonSocial] VARCHAR(250)
			,[RegistroPatronal] VARCHAR(250)
			,[CentroCosto] VARCHAR(250)
			,[Departamento] VARCHAR(250)
			,[Area] VARCHAR(250)
			,[Puesto] VARCHAR(250)
			,[TipoPrestacion] VARCHAR(250)
			,[Sucursal] VARCHAR(250)
			,[Division] VARCHAR(250)
			,[Region] VARCHAR(250)
			,[ClasificacionCorporativa] VARCHAR(250)
		);

		CREATE TABLE #TblFiltrosActivos (
			[FechaNormalizacion] DATE
			,[EmpleadosVigentes] INT
			,[IDCliente] INT
			,[IDRazonSocial] INT
			,[IDRegPatronal] INT
			,[IDCentroCosto] INT
			,[IDDepartamento] INT
			,[IDArea] INT
			,[IDPuesto] INT
			,[IDTipoPrestacion] INT
			,[IDSucursal] INT
			,[IDDivision] INT
			,[IDRegion] INT
			,[IDClasificacionCorporativa] INT
			,[NombreComercial] VARCHAR(250)
			,[RazonSocial] VARCHAR(250)
			,[RegistroPatronal] VARCHAR(250)
			,[CentroCosto] VARCHAR(250)
			,[Departamento] VARCHAR(250)
			,[Area] VARCHAR(250)
			,[Puesto] VARCHAR(250)
			,[TipoPrestacion] VARCHAR(250)
			,[Sucursal] VARCHAR(250)
			,[Division] VARCHAR(250)
			,[Region] VARCHAR(250)
			,[ClasificacionCorporativa] VARCHAR(250)
		);
		
		IF(@IDMetrica <> 0)
			BEGIN				
				-- CONSULTAMOS JSON(FILTROS) Y CONDICION DEL PERIODO DE METRICA
				SELECT @JsonFiltros = M.ConfiguracionFiltros, 
					   @Condicion = P.Condicion,
					   @FechaDe = M.FechaDe,
					   @FechaHasta = M.FechaHasta  
				FROM [InfoDir].[tblCatMetricas] M
					INNER JOIN [InfoDir].[tblCatPeriodos] P ON M.IDPeriodo = P.IDPeriodo
				WHERE M.IDMetrica = @IDMetrica
			END
		ELSE
			BEGIN
				-- CONSULTAMOS CONDICION DEL PERIODO DE METRICA
				SELECT @Condicion = P.Condicion 
				FROM [InfoDir].[tblCatPeriodos] P
				WHERE P.IDPeriodo = @IDPeriodo
			END


		-- FILTRAMOS POR PERIODICIDAD
		SET @Qry = N'INSERT INTO #TempActivos 
					SELECT CN.FechaNormalizacion
						   ,CN.EmpleadosVigentes
						   ,CN.IDCliente
						   ,CN.IDRazonSocial
						   ,CN.IDRegPatronal
						   ,CN.IDCentroCosto
						   ,CN.IDDepartamento
						   ,CN.IDArea
						   ,CN.IDPuesto
						   ,CN.IDTipoPrestacion
						   ,CN.IDSucursal
						   ,CN.IDDivision
						   ,CN.IDRegion
						   ,CN.IDClasificacionCorporativa
						   ,ISNULL(JSON_VALUE(CL.Traduccion, FORMATMESSAGE(''$.%s.%s'', '''+lower(replace(@IDIdioma, '-',''))+''', ''NombreComercial'')), '''') AS NombreComercial
						   ,ISNULL(RS.RFC + '' - '' + RS.NombreComercial, '''') AS RazonSocial
						   ,ISNULL(RP.RazonSocial, '''') AS RegistroPatronal
						   ,ISNULL(JSON_VALUE(CC.Traduccion, FORMATMESSAGE(''$.%s.%s'', '''+lower(replace(@IDIdioma, '-',''))+''', ''Descripcion'')), '''') AS CentroCosto
						   ,ISNULL(JSON_VALUE(DE.Traduccion, FORMATMESSAGE(''$.%s.%s'', '''+lower(replace(@IDIdioma, '-',''))+''', ''Descripcion'')), '''')  AS Departamento
						   ,ISNULL(JSON_VALUE(AR.Traduccion, FORMATMESSAGE(''$.%s.%s'', '''+lower(replace(@IDIdioma, '-',''))+''', ''Descripcion'')), '''') AS  Area
						   ,ISNULL(JSON_VALUE(PU.Traduccion, FORMATMESSAGE(''$.%s.%s'', '''+lower(replace(@IDIdioma, '-',''))+''', ''Descripcion'')), '''') AS Puesto
						   ,ISNULL(JSON_VALUE(TP.Traduccion, FORMATMESSAGE(''$.%s.%s'', '''+lower(replace(@IDIdioma, '-',''))+''', ''Descripcion'')), '''') AS TipoPrestacion
						   ,ISNULL(SU.Descripcion, '''') AS Sucursal
						   ,ISNULL(JSON_VALUE(DI.Traduccion, FORMATMESSAGE(''$.%s.%s'', '''+lower(replace(@IDIdioma, '-',''))+''', ''Descripcion'')), '''') AS Division
						   ,ISNULL(JSON_VALUE(RE.Traduccion, FORMATMESSAGE(''$.%s.%s'', '''+lower(replace(@IDIdioma, '-',''))+''', ''Descripcion'')), '''') AS Region
						   ,ISNULL(CSC.Descripcion, '''') AS ClasificacionCorporativa 
					FROM [InfoDir].[tblColaboradoresNormalizados] CN 
						LEFT JOIN [RH].[tblCatClientes] CL ON CN.IDCliente = CL.IDCliente 
						LEFT JOIN [RH].[tblEmpresa] RS ON CN.IDRazonSocial = RS.IdEmpresa 
						LEFT JOIN [RH].[tblCatRegPatronal] RP ON CN.IDRegPatronal = RP.IDRegPatronal 
						LEFT JOIN [RH].[tblCatCentroCosto] CC ON CN.IDCentroCosto = CC.IDCentroCosto 
						LEFT JOIN [RH].[tblCatDepartamentos] DE ON CN.IDDepartamento = DE.IDDepartamento 
						LEFT JOIN [RH].[tblCatArea] AR ON CN.IDArea = AR.IDArea 
						LEFT JOIN [RH].[tblCatPuestos] PU ON CN.IDPuesto = PU.IDPuesto 
						LEFT JOIN [RH].[tblCatTiposPrestaciones] TP ON CN.IDTipoPrestacion = TP.IDTipoPrestacion 
						LEFT JOIN [RH].[tblCatSucursales] SU ON CN.IDSucursal = SU.IDSucursal 
						LEFT JOIN [RH].[tblCatDivisiones] DI ON CN.IDDivision = DI.IDDivision 
						LEFT JOIN [RH].[tblCatRegiones] RE ON CN.IDRegion = RE.IDRegion 
						LEFT JOIN [RH].[tblCatClasificacionesCorporativas] CSC ON CN.IDClasificacionCorporativa = CSC.IDClasificacionCorporativa '
					+ '' + @Condicion + ''
		--SELECT @Qry
		EXEC SP_EXECUTESQL @Qry, N'@FechaDe DATE, @FechaHasta DATE', @FechaDe, @FechaHasta;
		
		
		-- CONVERTIMOS JSON A TABLA
		INSERT @dtFiltros(Catalogo, Value)
		SELECT *
		FROM OPENJSON(JSON_QUERY(@JsonFiltros,  '$.Filtros'))
		  WITH (
			catalogo NVARCHAR(50) '$.catalogo',
			valor NVARCHAR(50) '$.valor'
		  );

		-- OBTENEMOS GROUP BY
		INSERT @TblGroupBy(Catalogo)
		SELECT FI.DisplayMember
		FROM [InfoDir].[tblCatFiltrosItems] FI
			JOIN @dtFiltros F ON FI.DisplayValue = F.Catalogo
		WHERE FI.IDTipoItem = @Metrica
		

		-- OBTENEMOS LA INFORMACION FILTRADA
		INSERT INTO #TblFiltrosActivos
		SELECT *
		FROM #TempActivos
		WHERE EmpleadosVigentes > 0 AND
			 (
				IDCliente IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDCliente'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDCliente' AND ISNULL(Value, '') <> '')
					)
			 )AND
			 (
				IDRazonSocial IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDRazonSocial'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDRazonSocial' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDRegPatronal IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDRegPatronal'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDRegPatronal' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDCentroCosto IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDCentroCosto'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDCentroCosto' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDDepartamento IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDDepartamento'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDDepartamento' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDArea IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDArea'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDArea' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDPuesto IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDPuesto'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDPuesto' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDTipoPrestacion IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDTipoPrestacion'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDTipoPrestacion' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDSucursal IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDSucursal'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDSucursal' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDDivision IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDDivision'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDDivision' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDRegion IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDRegion'),','))
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDRegion' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDClasificacionCorporativa IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDClasificacionCorporativa'),','))
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDClasificacionCorporativa' AND ISNULL(Value, '') <> '')
					)
			 )


			 -- OBTENEMOS EL GROUP BY PARA APLICARLO A LA CONSULTA DINAMICA	
			 SELECT @GroupBy = STUFF((SELECT ',' + CONVERT(NVARCHAR(MAX), catalogo) FROM @TblGroupBy FOR XML PATH('')), 1, 1, '')


			 -- RESULTADO FINAL
			 SET @Qry2 = '
						SELECT ISNULL(CAST(AVG(CAST(F2.EmpleadosVigentes AS DECIMAL(18,2))) AS DECIMAL(18,2)), 0) AS Resultado,
						(' + CASE WHEN @GroupBy <> '' 
								THEN 'SELECT ' + @GroupBy + '
										FROM #TblFiltrosActivos
										GROUP BY ' + @GroupBy + '
										FOR JSON PATH'
								ELSE 'JSON_QUERY(N''[{"No Aplicaron": "Filtros"}]'')'
								END +
						') AS Filtro 
						FROM #TblFiltrosActivos F2
						  ';
		
			 --SELECT @Qry2
			 EXEC (@Qry2)
	
	END
GO
