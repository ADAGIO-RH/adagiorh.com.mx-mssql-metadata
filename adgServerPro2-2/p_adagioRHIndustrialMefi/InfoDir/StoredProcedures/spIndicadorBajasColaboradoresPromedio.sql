USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Obtiene el promedio de bajas en colaboradores
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2022-05-06
** Paremetros		: @IDIndicador
**					: @JsonFiltros
**					: @JsonGroup
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

CREATE PROC [InfoDir].[spIndicadorBajasColaboradoresPromedio]
(
	@IDIndicador INT
	,@JsonFiltros NVARCHAR(MAX)
	,@JsonGroup NVARCHAR(MAX)
	,@IDPeriodo INT
	,@FechaDe DATE
	,@FechaHasta DATE
)
AS
	BEGIN
		
		SET LANGUAGE 'spanish';

		DECLARE @dtFiltros [Nomina].[dtFiltrosRH]
				,@GroupBy NVARCHAR(MAX) = ''
				,@Label VARCHAR(250) = ''
				,@Condicion VARCHAR(MAX)
				,@Qry NVARCHAR(MAX)
				,@Qry2 NVARCHAR(MAX)
				,@IDIdioma varchar(20);
	
		SELECT @IDIdioma = [App].[fnGetPreferencia]('Idioma', 1, 'esmx');

		
		-- ELIMINAMOS LAS TABLAS TEMPORALES
		IF OBJECT_ID('tempdb..#TblBajas') IS NOT NULL BEGIN DROP TABLE #TblBajas END
		IF OBJECT_ID('tempdb..#TblFiltrosBajas') IS NOT NULL BEGIN DROP TABLE #TblFiltrosBajas END


		-- CREAMOS TABLAS TEMPORALES
		DECLARE @TblGroupBy TABLE(
			[ID] INT IDENTITY(1,1),
			[Catalogo] VARCHAR(50)
		)	
		
		CREATE TABLE #TblBajas (
			[Dia] DATE,
			[NoBajas] INT,
			[EmpleadosVigentes] INT,
			[IDCliente] INT,
			[IDRazonSocial] INT,
			[IDRegPatronal] INT,
			[IDCentroCosto] INT,
			[IDDepartamento] INT,
			[IDArea] INT,
			[IDPuesto] INT,
			[IDTipoPrestacion] INT,
			[IDSucursal] INT,
			[IDDivision] INT,
			[IDRegion] INT,
			[IDClasificacionCorporativa] INT,
			[NombreComercial] VARCHAR(250),
			[RazonSocial] VARCHAR(250),
			[RegistroPatronal] VARCHAR(250),
			[CentroCosto] VARCHAR(250),
			[Departamento] VARCHAR(250),
			[Area] VARCHAR(250),
			[Puesto] VARCHAR(250),
			[TipoPrestacion] VARCHAR(250),
			[Sucursal] VARCHAR(250),
			[Division] VARCHAR(250),
			[Region] VARCHAR(250),
			[ClasificacionCorporativa] VARCHAR(250),
			[Semana] INT,
			[Mes] VARCHAR(25),
			[Anio] INT,
		);

		CREATE TABLE #TblFiltrosBajas (
			[Dia] DATE,
			[NoBajas] INT,
			[EmpleadosVigentes] INT,
			[IDCliente] INT,
			[IDRazonSocial] INT,
			[IDRegPatronal] INT,
			[IDCentroCosto] INT,
			[IDDepartamento] INT,
			[IDArea] INT,
			[IDPuesto] INT,
			[IDTipoPrestacion] INT,
			[IDSucursal] INT,
			[IDDivision] INT,
			[IDRegion] INT,
			[IDClasificacionCorporativa] INT,
			[NombreComercial] VARCHAR(250),
			[RazonSocial] VARCHAR(250),
			[RegistroPatronal] VARCHAR(250),
			[CentroCosto] VARCHAR(250),
			[Departamento] VARCHAR(250),
			[Area] VARCHAR(250),
			[Puesto] VARCHAR(250),
			[TipoPrestacion] VARCHAR(250),
			[Sucursal] VARCHAR(250),
			[Division] VARCHAR(250),
			[Region] VARCHAR(250),
			[ClasificacionCorporativa] VARCHAR(250),
			[Semana] INT,
			[Mes] VARCHAR(25),
			[Anio] INT,
		);


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
		SET @Qry = N'INSERT INTO #TblBajas '
		SET @Qry = @Qry + 'SELECT C.FechaNormalizacion AS Dia, '
		SET @Qry = @Qry + 'C.NoBajas, '
		SET @Qry = @Qry + 'CASE WHEN C.EmpleadosVigentes = 0 THEN 1 ELSE C.EmpleadosVigentes END AS EmpleadosVigentes, '
		SET @Qry = @Qry + 'C.IDCliente, '
		SET @Qry = @Qry + 'C.IDRazonSocial, '
		SET @Qry = @Qry + 'C.IDRegPatronal, '
		SET @Qry = @Qry + 'C.IDCentroCosto, '
		SET @Qry = @Qry + 'C.IDDepartamento, '
		SET @Qry = @Qry + 'C.IDArea, '
		SET @Qry = @Qry + 'C.IDPuesto, '
		SET @Qry = @Qry + 'C.IDTipoPrestacion, '
		SET @Qry = @Qry + 'C.IDSucursal, '
		SET @Qry = @Qry + 'C.IDDivision, '
		SET @Qry = @Qry + 'C.IDRegion, '
		SET @Qry = @Qry + 'C.IDClasificacionCorporativa, '
		SET @Qry = @Qry + 'ISNULL(JSON_VALUE(CL.Traduccion, FORMATMESSAGE(''$.%s.%s'', '''+lower(replace(@IDIdioma, '-',''))+''', ''NombreComercial'')), '''') AS NombreComercial, '
		SET @Qry = @Qry + 'ISNULL(RS.RFC + '' - '' + RS.NombreComercial, '''') AS RazonSocial, '
		SET @Qry = @Qry + 'ISNULL(RP.RazonSocial, '''') AS RegistroPatronal, '
		SET @Qry = @Qry + 'ISNULL(JSON_VALUE(CC.Traduccion, FORMATMESSAGE(''$.%s.%s'', '''+lower(replace(@IDIdioma, '-',''))+''', ''Descripcion'')), '''') AS CentroCosto, '
		SET @Qry = @Qry + 'ISNULL(JSON_VALUE(DE.Traduccion, FORMATMESSAGE(''$.%s.%s'', '''+lower(replace(@IDIdioma, '-',''))+''', ''Descripcion'')), '''') AS Departamento, '
		SET @Qry = @Qry + 'ISNULL(JSON_VALUE(AR.Traduccion, FORMATMESSAGE(''$.%s.%s'', '''+lower(replace(@IDIdioma, '-',''))+''', ''Descripcion'')), '''') AS  Area, '
		SET @Qry = @Qry + 'ISNULL(JSON_VALUE(PU.Traduccion, FORMATMESSAGE(''$.%s.%s'', '''+lower(replace(@IDIdioma, '-',''))+''', ''Descripcion'')), '''') AS Puesto, '
		SET @Qry = @Qry + 'ISNULL(JSON_VALUE(TP.Traduccion, FORMATMESSAGE(''$.%s.%s'', '''+lower(replace(@IDIdioma, '-',''))+''', ''Descripcion'')), '''') AS TipoPrestacion, '
		SET @Qry = @Qry + 'ISNULL(SU.Descripcion, '''') AS Sucursal, '
		SET @Qry = @Qry + 'ISNULL(JSON_VALUE(DI.Traduccion, FORMATMESSAGE(''$.%s.%s'', '''+lower(replace(@IDIdioma, '-',''))+''', ''Descripcion'')), '''')AS Division, '
		SET @Qry = @Qry + 'ISNULL(JSON_VALUE(RE.Traduccion, FORMATMESSAGE(''$.%s.%s'', '''+lower(replace(@IDIdioma, '-',''))+''', ''Descripcion'')), '''') AS Region, '
		SET @Qry = @Qry + 'ISNULL(CSC.Descripcion, '''') AS ClasificacionCorporativa, '
		SET @Qry = @Qry + 'DATEPART(WEEK, C.FechaNormalizacion) AS Semana, '
		SET @Qry = @Qry + 'DATENAME(MONTH, C.FechaNormalizacion) AS Mes, '
		SET @Qry = @Qry + 'DATEPART(YEAR, C.FechaNormalizacion) AS Anio '
		SET @Qry = @Qry + 'FROM [InfoDir].[tblColaboradoresNormalizados] C '
		SET @Qry = @Qry + 'LEFT JOIN [RH].[tblCatClientes] CL ON C.IDCliente = CL.IDCliente '
		SET @Qry = @Qry + 'LEFT JOIN [RH].[tblEmpresa] RS ON C.IDRazonSocial = RS.IdEmpresa '
		SET @Qry = @Qry + 'LEFT JOIN [RH].[tblCatRegPatronal] RP ON C.IDRegPatronal = RP.IDRegPatronal '
		SET @Qry = @Qry + 'LEFT JOIN [RH].[tblCatCentroCosto] CC ON C.IDCentroCosto = CC.IDCentroCosto '
		SET @Qry = @Qry + 'LEFT JOIN [RH].[tblCatDepartamentos] DE ON C.IDDepartamento = DE.IDDepartamento '
		SET @Qry = @Qry + 'LEFT JOIN [RH].[tblCatArea] AR ON C.IDArea = AR.IDArea '
		SET @Qry = @Qry + 'LEFT JOIN [RH].[tblCatPuestos] PU ON C.IDPuesto = PU.IDPuesto '
		SET @Qry = @Qry + 'LEFT JOIN [RH].[tblCatTiposPrestaciones] TP ON C.IDTipoPrestacion = TP.IDTipoPrestacion '
		SET @Qry = @Qry + 'LEFT JOIN [RH].[tblCatSucursales] SU ON C.IDSucursal = SU.IDSucursal '
		SET @Qry = @Qry + 'LEFT JOIN [RH].[tblCatDivisiones] DI ON C.IDDivision = DI.IDDivision '
		SET @Qry = @Qry + 'LEFT JOIN [RH].[tblCatRegiones] RE ON C.IDRegion = RE.IDRegion '
		SET @Qry = @Qry + 'LEFT JOIN [RH].[tblCatClasificacionesCorporativas] CSC ON C.IDClasificacionCorporativa = CSC.IDClasificacionCorporativa '
		SET @Qry = @Qry + '' + @Condicion + ' '
		SET @Qry = @Qry + 'ORDER BY C.FechaNormalizacion'		
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
		INSERT @TblGroupBy(Catalogo)
		SELECT *
		FROM OPENJSON(JSON_QUERY(@JsonGroup,  '$.GroupBy'))
		  WITH (
			catalogo NVARCHAR(50) '$.catalogo'
		  );


		-- OBTENEMOS LA INFORMACION FILTRADA
		INSERT INTO #TblFiltrosBajas
		SELECT *
		FROM #TblBajas
		WHERE NoBajas > 0 AND
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
			 ORDER BY Dia

			 
		-- OBTENEMOS EL GROUP BY PARA APLICARLO A LA CONSULTA DINAMICA
		SELECT @Label = Catalogo FROM @TblGroupBy WHERE ID = 1
		IF(@Label = '')
			BEGIN
				SELECT @Label = 'Dia'
			END
		SELECT @GroupBy = STUFF((SELECT ',' + CONVERT(NVARCHAR(MAX), catalogo) FROM @TblGroupBy WHERE ID > 1 FOR XML PATH('')), 1, 1, '')		

		-- RESULTADO FINAL
		SET @Qry2 = 'WITH TblLabel (' + @Label + ') AS
					 (
						SELECT ' + @Label + '
						FROM #TblFiltrosBajas
						GROUP BY ' + @Label + '
					 )
						SELECT (
							SELECT T.' + @Label + ',
							(
								SELECT
								CAST((CAST(SUM(NoBajas) AS FLOAT) / SUM(EmpleadosVigentes)) * 100 AS DECIMAL(18, 2)) AS Resultado ' +
								(CASE WHEN ISNULL(@GroupBy, '') <> '' THEN ', ' + @GroupBy ELSE '' END) + '
								FROM #TblFiltrosBajas AS Grupo
								WHERE T.' + @Label + ' = Grupo.' + @Label +
								 (CASE WHEN ISNULL(@GroupBy, '') <> '' THEN ' GROUP BY ' + @GroupBy ELSE '' END) + '
								FOR JSON PATH
							) AS Grupo
							FROM TblLabel T
							GROUP BY T.' + @Label + '
							ORDER BY T.' + @Label + '
							FOR JSON AUTO
						) AS ResultJson';
		
		-- SELECT @Qry2
		EXEC (@Qry2)
		
	END
GO
