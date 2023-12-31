USE [p_adagioRHFabricasSelectas]
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
** Paremetros		: @JsonFiltros				- Filtros solicitados
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
		IF OBJECT_ID('tempdb..#TblStaff') IS NOT NULL BEGIN DROP TABLE #TblStaff END


		-- CREAMOS TABLAS TEMPORALES
		DECLARE @TblSucursalPuestos TABLE(
			[IDSucursal] INT,
			[Sucursal] VARCHAR(500),
			[IDPuesto] INT,
			[Puesto] VARCHAR(500)
		)

		DECLARE @TblSucursalPuestosFiltrados TABLE(
			[IDSucursal] INT,
			[Sucursal] VARCHAR(500),
			[IDPuesto] INT,
			[Puesto] VARCHAR(500)
		)

		CREATE TABLE #TblStaff(
			[IDStaff] INT,
			[IDSucursal] INT,
			[Sucursal] VARCHAR(500),
			[IDPuesto] INT,
			[Puesto] VARCHAR(500),
			[Porcentaje] INT,
			[Cantidad] INT
		)

		
		-- OBTENEMOS SUCURSALES Y PUESTOS
		INSERT INTO @TblSucursalPuestos
		EXEC [Staffing].[spBuscarSucursalesPuestos] @IDUsuario


		-- CONVERTIMOS JSON A TABLA
		INSERT @dtFiltros(Catalogo, Value)
		SELECT *
		FROM OPENJSON(JSON_QUERY(@JsonFiltros,  '$.Filtros'))
		  WITH (
			catalogo NVARCHAR(50) '$.catalogo',
			valor NVARCHAR(50) '$.valor'
		  );

		  
		-- OBTENEMOS LA INFORMACION FILTRADA
		INSERT INTO @TblSucursalPuestosFiltrados
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


		-- OBTENEMOS LA CONFIGURACION DEL STAFF		
		INSERT INTO #TblStaff(IDStaff, IDSucursal, Sucursal, IDPuesto, Puesto, Porcentaje, Cantidad)
		SELECT CS.IDStaff
			   , TSP.IDSucursal
			   , TSP.Sucursal
			   , TSP.IDPuesto
			   , TSP.Puesto
			   , P.Porcentaje
			   , CS.Cantidad		
		FROM @TblSucursalPuestosFiltrados TSP
			LEFT JOIN [Staffing].[tblCatStaff] CS ON TSP.IDSucursal = CS.IDSucursal AND TSP.IDPuesto = CS.IDPuesto
			LEFT JOIN [Staffing].[tblCatPorcentajes] P ON CS.IDPorcentaje = P.IDPorcentaje


		-- OBTENERMOS COLUMNAS DINAMICAS
		SET @ColsExtra = ISNULL(STUFF(
								(
									SELECT ',' + QUOTENAME(Porcentaje)
									FROM (
										SELECT DISTINCT Porcentaje
										FROM #TblStaff
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
							 FROM #TblStaff) AS SourceConfFiltrados
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
