USE [p_adagioRHNomade]
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
					  @IDSucursal				- Identificador de la sucursal.
					  @IDPuesto					- Identificador del puesto.
					  @Porcentaje 				- Pordentaje asignado
					  @IDUsuario				- Identificador del usuario.
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

CREATE   PROCEDURE [Staffing].[spBuscarStaff](
	@IDConfiguracion INT = 0
	,@IDSucursal  	 INT = 0
	,@IDPuesto		 INT = 0
	,@Porcentaje	 INT = 0
	,@query			 VARCHAR(100) = '""'
	,@IDUsuario		 INT = 0
)
AS
BEGIN

	SET FMTONLY OFF;	

		SET LANGUAGE 'spanish'

		IF OBJECT_ID('tempdb..#ConfFiltrados') is not null drop table #ConfFiltrados;

		DECLARE @IDIdioma VARCHAR(20)
				, @ColsExtra NVARCHAR(MAX)
				, @Qry		 NVARCHAR(MAX)
		;

		SELECT @IDIdioma = [App].[fnGetPreferencia]('Idioma', 1, 'esmx');

		SET @query = CASE
						WHEN @query IS NULL THEN '""'
						WHEN @query = '' THEN '""'
						WHEN @query = '""' THEN @query
					 ELSE '"' + @query + '*"' END

	
		SELECT CS.IDConfiguracion
			   , S.Codigo + '-' + S.Descripcion AS Sucursal
			   , P.Codigo + '-' + ISNULL(JSON_VALUE(P.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE(@IDIdioma, '-', '')) + '', 'Descripcion')), '') AS Puesto
			   , CS.Porcentaje
			   , CS.Cantidad
		INTO #ConfFiltrados 
		FROM [Staffing].[tblCatStaff] CS
			JOIN [RH].[tblCatSucursales] S ON CS.IDSucursal = S.IDSucursal
			JOIN [RH].[tblCatPuestos] P ON CS.IDPuesto = P.IDPuesto
		WHERE ((CS.IDConfiguracion = @IDConfiguracion OR ISNULL(@IDConfiguracion, 0) = 0)) 
				AND ((CS.IDSucursal = @IDSucursal OR ISNULL(@IDSucursal, 0) = 0)) 
				AND ((CS.IDPuesto = @IDPuesto OR ISNULL(@IDPuesto, 0) = 0))
				AND ((CS.Porcentaje = @Porcentaje OR ISNULL(@Porcentaje, 0) = 0))
				AND (
					(@query = '""' OR CONTAINS(S.Descripcion, @query)) 
					OR
					(@query = '""' OR CONTAINS(P.Descripcion, @query))
					)		
		--SELECT * FROM #ConfFiltrados
		

		-- OBTENERMOS COLUMNAS DINAMICAS
		SET @ColsExtra = STUFF(
								(
									SELECT ',' + QUOTENAME(Porcentaje)
									FROM (
										SELECT DISTINCT Porcentaje
										FROM #ConfFiltrados
									) AS Subquery
									ORDER BY Porcentaje
									FOR XML PATH(''), TYPE
								).value('.', 'NVARCHAR(MAX)'), 1, 1, ''
							  );


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
							 FROM #ConfFiltrados) AS SourceConfFiltrados
				PIVOT (
					MAX(Cantidad)
					FOR Porcentaje IN (' + @ColsExtra + ')
				) AS PivotTable
				ORDER BY Sucursal, Puesto
				FOR JSON PATH 
			) AS ResultJson;
		';

		EXEC(@Qry)

END
GO
