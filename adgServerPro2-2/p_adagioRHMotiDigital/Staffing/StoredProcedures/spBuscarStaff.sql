USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar configuracion de porcentajes
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-08-18
** Paremetros		: @IDConfiguracion			- Identificador de la configuracion.
					  @JsonFiltros				- Filtros solicitados
					  @IDUsuario				- Identificador del usuario.
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

CREATE   PROCEDURE [Staffing].[spBuscarStaff](
	@JsonFiltros    NVARCHAR(MAX)
	,@IDUsuario		 INT = 0
)
AS
BEGIN

	SET FMTONLY OFF;	

		SET LANGUAGE 'spanish'		
		
		DECLARE @dtFiltros [Nomina].[dtFiltrosRH]
				, @IDIdioma VARCHAR(20)
				, @ColsExtra NVARCHAR(MAX)
				, @Qry		 NVARCHAR(MAX)
		;

		SELECT @IDIdioma = [App].[fnGetPreferencia]('Idioma', 1, 'esmx');


		-- ELIMINAMOS LAS TABLAS TEMPORALES
		IF OBJECT_ID('tempdb..#TblStaffFiltrado') IS NOT NULL BEGIN DROP TABLE #TblStaffFiltrado END

		-- CREAMOS TABLAS TEMPORALES
		DECLARE @TblSucursalPuestos TABLE(
			[IDStaff] INT,
			[IDSucursal] INT,
			[Sucursal] VARCHAR(500),
			[IDPuesto] INT,
			[Puesto] VARCHAR(500),
			[IDPorcentaje] INT,
			[Cantidad] INT
		)

		CREATE TABLE #TblStaffFiltrado(
			[IDStaff] INT,
			[IDSucursal] INT,
			[Sucursal] VARCHAR(500),
			[IDPuesto] INT,
			[Puesto] VARCHAR(500),
			[Porcentaje] INT,
			[Cantidad] INT
		)

				
		-- NORMALIZAMOS LA INFORMACION OBTENIENDO LA SUCURSAL, PUESTO Y LA CONFIGURACION DEL STAFF
		;WITH tblSucursalPuestos (IDSucursal, Sucursal, IDPuesto, Puesto)
			AS(
				SELECT S.IDSucursal
					   , S.Codigo + '-' + S.Descripcion AS Sucursal
					   , P.IDPuesto
					   , P.Codigo + '-' + ISNULL(JSON_VALUE(P.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE(@IDIdioma, '-', '')) + '', 'Descripcion')), '') AS Puesto		
				FROM [RH].[tblCatSucursales] S
				CROSS APPLY (
					SELECT IDPuesto, Codigo, Traduccion
					FROM [RH].[tblCatPuestos]
				) AS P
			)
		INSERT INTO @TblSucursalPuestos(IDStaff, IDSucursal, Sucursal, IDPuesto, Puesto, IDPorcentaje, Cantidad)
		SELECT CS.IDStaff
			   , TSP.IDSucursal
			   , TSP.Sucursal
			   , TSP.IDPuesto
			   , TSP.Puesto
			   , P.Porcentaje
			   , CS.Cantidad		
		FROM tblSucursalPuestos TSP
			LEFT JOIN [Staffing].[tblCatStaff] CS ON TSP.IDSucursal = CS.IDSucursal AND TSP.IDPuesto = CS.IDPuesto
			LEFT JOIN [Staffing].[tblCatPorcentajes] P ON CS.IDPorcentaje = P.IDPorcentaje


		-- CONVERTIMOS JSON A TABLA
		INSERT @dtFiltros(Catalogo, Value)
		SELECT *
		FROM OPENJSON(JSON_QUERY(@JsonFiltros,  '$.Filtros'))
		  WITH (
			catalogo NVARCHAR(50) '$.catalogo',
			valor NVARCHAR(50) '$.valor'
		  );

		  
		-- OBTENEMOS LA INFORMACION FILTRADA
		INSERT INTO #TblStaffFiltrado
		SELECT *
		FROM @TblSucursalPuestos
		WHERE (
				 IDSucursal IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDSucursal'),',')) 
				 OR (
					 NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDSucursal' AND ISNULL(Value, '') <> '')
					)
			  ) AND			 
			  (
				 IDPuesto IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDPuesto'),',')) 
				 OR (
					 NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDPuesto' AND ISNULL(Value, '') <> '')
					)
			  )		
		
		
		-- OBTENERMOS COLUMNAS DINAMICAS
		SET @ColsExtra = ISNULL(STUFF(
								(
									SELECT ',' + QUOTENAME(Porcentaje)
									FROM (
										SELECT DISTINCT Porcentaje
										FROM #TblStaffFiltrado
									) AS Subquery
									ORDER BY Porcentaje
									FOR XML PATH(''), TYPE
								).value('.', 'NVARCHAR(MAX)'), 1, 1, ''
							  ), '[0]');


		-- CONSULTA PIVOT
		SET @Qry = '
			SELECT(
				SELECT					
					Sucursal,					
					Puesto,
					' + @ColsExtra + '
				FROM (SELECT Sucursal,							
							 Puesto,
							 Porcentaje,
							 Cantidad
							 FROM #TblStaffFiltrado) AS SourceConfFiltrados
				PIVOT (
					MAX(Cantidad)
					FOR Porcentaje IN (' + @ColsExtra + ')
				) AS PivotTable
				ORDER BY Sucursal, Puesto
				FOR JSON PATH 
			) AS ResultJson;
		';

		--PRINT @Qry;
		EXEC(@Qry)

END
GO
