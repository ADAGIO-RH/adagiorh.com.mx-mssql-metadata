USE [p_adagioRHIndustrialMefi]
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
		DECLARE @TblSucursalDepartamentosPuestosMapeados TABLE(
			[IDMapeo] INT,
			[IDSucursal] INT,
			[Sucursal] VARCHAR(500),
			[IDDepartamento] INT,
			[Departamento] VARCHAR(500),
			[IDPuesto] INT,
			[Puesto] VARCHAR(500)
		)

		DECLARE @TblSucursalDepartamentosPuestosFiltrado TABLE(
			[IDMapeo] INT,
			[IDSucursal] INT,
			[Sucursal] VARCHAR(500),
			[IDDepartamento] INT,
			[Departamento] VARCHAR(500),
			[IDPuesto] INT,
			[Puesto] VARCHAR(500)			
		)

		CREATE TABLE #TblStaff(
			[IDStaff] INT,
			[IDSucursal] INT,
			[Sucursal] VARCHAR(500),
			[IDDepartamento] INT,
			[Departamento] VARCHAR(500),
			[IDPuesto] INT,
			[Puesto] VARCHAR(500),
			[Porcentaje] VARCHAR(7),
			[Cantidad] INT
		)

		
		-- OBTENEMOS SUCURSALES Y PUESTOS
		INSERT INTO @TblSucursalDepartamentosPuestosMapeados
		EXEC [Staffing].[spBuscarSucursalesDepartamentosPuestosMapeados] @IDUsuario


		
		-- CONVERTIMOS JSON A TABLA
		INSERT @dtFiltros(Catalogo, Value)
		SELECT *
		FROM OPENJSON(JSON_QUERY(@JsonFiltros,  '$.Filtros'))
		  WITH (
			catalogo NVARCHAR(50) '$.catalogo',
			valor NVARCHAR(50) '$.valor'
		  );

		 
		-- OBTENEMOS LA INFORMACION FILTRADA
		INSERT INTO @TblSucursalDepartamentosPuestosFiltrado
		SELECT *
		FROM @TblSucursalDepartamentosPuestosMapeados
		WHERE (
				 IDSucursal IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDSucursal'),',')) 
				 OR (
					 NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDSucursal' AND ISNULL(Value, '') <> '')
					)
			  ) AND
			  (
				IDDepartamento IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDDepartamento'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDDepartamento' AND ISNULL(Value, '') <> '')
					)
			  ) AND
			  (
				 IDPuesto IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDPuesto'),','))
				 OR (
					 NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDPuesto' AND ISNULL(Value, '') <> '')
					)
			  )			  



		-- OBTENEMOS LA CONFIGURACION DEL STAFF		
		INSERT INTO #TblStaff(IDStaff, IDSucursal, Sucursal, IDDepartamento, Departamento, IDPuesto, Puesto, Porcentaje, Cantidad)
		SELECT CS.IDStaff
			   , TSP.IDSucursal
			   , TSP.Sucursal
			   , TSP.IDDepartamento
			   , TSP.Departamento
			   , TSP.IDPuesto
			   , TSP.Puesto			   
			   , CASE 
					WHEN (P.PorcentajeInicial IS NULL OR P.PorcentajeFinal IS NULL)
						THEN NULL
						ELSE CONCAT(CAST(P.PorcentajeInicial AS VARCHAR(3)), '_', CAST(P.PorcentajeFinal AS VARCHAR(3)))
					END AS Porcentaje
			   , CS.Cantidad		
		FROM @TblSucursalDepartamentosPuestosFiltrado TSP
			LEFT JOIN [Staffing].[tblCatStaff] CS ON TSP.IDMapeo = CS.IDMapeo
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
					Departamento,
					Puesto,
					' + @ColsExtra + '
				FROM (SELECT IDSucursal,
							 Sucursal,
							 IDDepartamento,
							 Departamento,
							 IDPuesto,
							 Puesto,
							 Porcentaje,
							 Cantidad
							 FROM #TblStaff) AS SourceConfFiltrados
				PIVOT (
					MAX(Cantidad)
					FOR Porcentaje IN (' + @ColsExtra + ')
				) AS PivotTable
				ORDER BY IDSucursal, IDDepartamento, IDPuesto
				FOR JSON PATH
			) AS ResultJson;
		';

		--PRINT @Qry;
		EXEC(@Qry)

END
GO
