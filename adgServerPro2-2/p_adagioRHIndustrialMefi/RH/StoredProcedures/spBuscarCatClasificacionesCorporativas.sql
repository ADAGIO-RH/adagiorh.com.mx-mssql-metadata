USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/**************************************************************************************************** 
** Descripción				: Busca lista de Clasificaciones Corporativas
** Autor					: No tiene
** Email					: No tiene
** FechaCreacion			: No tiene
** Paremetros				:              
** DataTypes Relacionados	: 

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
2024-07-16			Alejandro Paredes	Se agrego la traducción
***************************************************************************************************/
CREATE   PROCEDURE [RH].[spBuscarCatClasificacionesCorporativas]  
(
	@IDClasificacionCorporativa	INT = NULL
	, @ClasificacionCorporativa VARCHAR(50) = NULL
	, @IDUsuario				INT = NULL
	, @PageNumber				INT = 1
	, @PageSize					INT = 2147483647
	, @query					VARCHAR(100) = '""'
	, @orderByColumn			VARCHAR(50) = 'Descripcion'
	, @orderDirection			VARCHAR(4) = 'asc'
)  
AS  
	BEGIN 
		
		SET FMTONLY OFF;

		DECLARE  
			@TotalPaginas INT = 0
			, @TotalRegistros INT
			, @IDIdioma VARCHAR(MAX)
			;

		SELECT @IDIdioma = [App].[fnGetPreferencia]('Idioma', @IDUsuario, 'esmx')
 

		IF (ISNULL(@PageNumber, 0) = 0) 
			SET @PageNumber = 1;

		IF (ISNULL(@PageSize, 0) = 0) 
			SET @PageSize = 2147483647;


		SELECT
			@orderByColumn	  = CASE WHEN @orderByColumn  IS NULL THEN 'Descripcion' ELSE @orderByColumn END
			, @orderDirection = CASE WHEN @orderDirection IS NULL THEN 'ASC' ELSE @orderDirection END


		IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  
		IF OBJECT_ID('tempdb..#TempClasificacionesCorporativas') IS NOT NULL DROP TABLE #TempClasificacionesCorporativas


		SET @query = 
			CASE
				WHEN @query IS NULL THEN '""'
				WHEN @query = '' THEN '""'
				WHEN @query = '""' THEN '""'
				ELSE '"'+@query + '*"' END


		SELECT ID
		INTO #TempClasificacionesCorporativas
		FROM Seguridad.tblFiltrosUsuarios WITH(NOLOCK)
		WHERE IDUsuario = @IDUsuario AND Filtro = 'ClasificacionesCorporativas'
 

		SELECT 
			IDClasificacionCorporativa  
			, Codigo  
			, UPPER (JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE(@IDIdioma, '-', '')), 'Descripcion'))) AS Descripcion
			, CuentaContable  
			, Traduccion
			, ROW_NUMBER() OVER(ORDER BY IDClasificacionCorporativa) AS ROWNUMBER
		INTO #tempResponse FROM RH.tblCatClasificacionesCorporativas WITH(NOLOCK)
		WHERE 
			--(Codigo like @ClasificacionCorporativa+'%') OR(Descripcion like @ClasificacionCorporativa+'%') OR(@ClasificacionCorporativa is null)  
			--	and ( ( IDClasificacionCorporativa in  ( select ID from #TempClasificacionesCorporativas) or not Exists(select ID from #TempClasificacionesCorporativas)) 
			--               AND                
			--           )
			(IDClasificacionCorporativa = @IDClasificacionCorporativa OR ISNULL(@IDClasificacionCorporativa, 0) = 0)
			AND (@query = '""' OR CONTAINS(RH.tblCatClasificacionesCorporativas.*, @query)) 
		ORDER BY Descripcion ASC

		SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20,2)) / CAST(@PageSize AS DECIMAL(20,2)))
		FROM #TempResponse

		SELECT @TotalRegistros = COUNT(IDClasificacionCorporativa) FROM #TempResponse

		SELECT *
				, TotalPaginas = CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END
				, ISNULL(@TotalRegistros, 0) AS TotalRegistros
		FROM #TempResponse
		ORDER BY
			CASE WHEN @orderByColumn = 'Descripcion' AND @orderDirection = 'ASC' THEN Descripcion END
			, CASE WHEN @orderByColumn = 'Descripcion' AND @orderDirection = 'DESC' THEN Descripcion END DESC
			, Descripcion ASC
		OFFSET @PageSize * (@PageNumber - 1) ROWS
		FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

	END
GO
