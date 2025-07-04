USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Obtiene la lista de items 
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2022-04-19
** Paremetros		: @IDConfItem
**					: @IDTipoItem
**					: @IDAplicacion
**					: @PageNumber
**					: @PageSize
**					: @query
**					: @orderByColumn
**					: @orderDirection
** IDAzure			: 814

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROC [InfoDir].[spBuscarItems](
	@IDConfItem INT = NULL,
	@IDTipoItem INT = NULL,
	@IDAplicacion VARCHAR(100) = '',
	@PageNumber	INT = 1,
	@PageSize INT = 2147483647,
	@query VARCHAR(100) = '""',
	@orderByColumn	VARCHAR(50) = 'IDTipoItem',
	@orderDirection VARCHAR(4) = 'ASC'
)
AS
	BEGIN

		SET FMTONLY OFF;

		DECLARE
			@TotalPaginas INT = 0,
			@TotalRegistros DECIMAL(18,2) = 0.00;


		IF(ISNULL(@PageNumber, 0) = 0) SET @PageNumber = 1;
		IF(ISNULL(@PageSize, 0) = 0) SET @PageSize = 2147483647;

		SELECT
			 @orderByColumn	= CASE WHEN @orderByColumn IS NULL THEN 'Nombre' ELSE @orderByColumn END,
			 @orderDirection = CASE WHEN @orderDirection IS NULL THEN 'ASC' ELSE @orderDirection END

   
		SET @query = CASE
						WHEN @query IS NULL THEN '""'
						WHEN @query = '' THEN '""'
						WHEN @query = '""' THEN @query
					ELSE '"' + @query + '*"' END

		DECLARE @tempResponse AS TABLE (
			IDConfItem INT,
			IDTipoItem INT,
			TipoDescripcion VARCHAR(50),
			IDAplicacion VARCHAR(100),
			IDDataSource INT,
			Nombre VARCHAR(100),
			Descripcion VARCHAR(255)
		);

		INSERT @tempResponse
		SELECT
			C.IDConfItem,
			C.IDTipoItem,
			T.Descripcion AS TipoDescripcion,
			C.IDAplicacion,
			C.IDDataSource,
			C.Nombre,
			C.Descripcion
		FROM [InfoDir].[tblCatItems] C WITH (NOLOCK)
			INNER JOIN [InfoDir].[tblCatTipoItems] T WITH (NOLOCK) ON C.IDTipoItem = T.IDTipoItem
			INNER JOIN [InfoDir].[tblCatDataSource] DS WITH (NOLOCK) ON C.IDDataSource = DS.IDDataSource
		WHERE ((C.IDConfItem = @IDConfItem OR ISNULL(@IDConfItem, 0) = 0)) AND
			  ((C.IDTipoItem = @IDTipoItem OR ISNULL(@IDTipoItem, 0) = 0)) AND
			  ((C.IDAplicacion = @IDAplicacion OR ISNULL(@IDAplicacion, '') = '')) AND
			  (@query = '""' OR CONTAINS(C.*, @query))

		
		SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20,2))/CAST(@PageSize AS DECIMAL(20,2)))
		FROM @tempResponse

		SELECT @TotalRegistros = CAST(COUNT([IDConfItem]) AS DECIMAL(18,2)) FROM @tempResponse

		SELECT *,
			   TotalPaginas = CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END
		FROM @tempResponse
		ORDER BY
			CASE WHEN @orderByColumn = 'IDTipoItem'	and @orderDirection = 'asc'	THEN IDTipoItem END,
			CASE WHEN @orderByColumn = 'IDTipoItem'	and @orderDirection = 'desc' THEN IDTipoItem END DESC,
			CASE WHEN @orderByColumn = 'IDAplicacion'	and @orderDirection = 'asc'	THEN IDAplicacion END,
			CASE WHEN @orderByColumn = 'IDAplicacion'	and @orderDirection = 'desc' THEN IDAplicacion END DESC,
			IDTipoItem, IDAplicacion ASC, Nombre
		OFFSET @PageSize * (@PageNumber - 1) ROWS
		FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

	END
GO
