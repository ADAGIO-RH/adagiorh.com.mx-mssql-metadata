USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar Grupos por Nombre
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-10-19
** Paremetros		: @filter
	
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2022-11-14			Alejandro Paredes	Paginación
2023-12-11			ANEUDY ABREU COLON	Agrega isnull(CG.IDTipoEvaluacion, -1) != 0
***************************************************************************************************/
CREATE   PROC [Evaluacion360].[spBuscarGruposFilters](
	@IDTipoGrupo INT = 0,
	@TipoReferencia INT = 0,
	@IDReferencia INT = 0,
	@IDUsuario INT = 0,
	@PageNumber	INT = 1,
	@PageSize INT = 2147483647,
	@query VARCHAR(100) = '""',
	@orderByColumn	VARCHAR(50) = 'IDGrupo',
	@orderDirection VARCHAR(4) = 'ASC'
) 
AS
	--set @IDTipoGrupo  = 1;
	DECLARE  
		@IDIdioma VARCHAR(5),
		@IdiomaSQL VARCHAR(100) = NULL,
		@TotalPaginas INT = 0,
		@TotalRegistros DECIMAL(18,2) = 0.00;
		
	IF(ISNULL(@PageNumber, 0) = 0) SET @PageNumber = 1;
	IF(ISNULL(@PageSize, 0) = 0) SET @PageSize = 2147483647;

	SELECT
			@orderByColumn	= CASE WHEN @orderByColumn IS NULL THEN 'IDTipoEvaluacion' ELSE @orderByColumn END,
			@orderDirection = CASE WHEN @orderDirection IS NULL THEN 'ASC' ELSE @orderDirection END
			    
	SET @query = CASE
					WHEN @query IS NULL THEN '""'
					WHEN @query = '' THEN '""'
					WHEN @query = '""' THEN @query
				ELSE '"' + @query + '*"' END

	DECLARE @tempResponse AS TABLE (
			IDGrupo INT,
			IDTipoGrupo INT,
			TipoGrupo VARCHAR(255),
			Nombre VARCHAR(255),
			Descripcion VARCHAR(max),
			FechaCreacion DATETIME,
			FechaCreacionStr VARCHAR(100),
			TipoReferencia INT,
			IDReferencia INT,
			CopiadoDeIDGrupo INT,
			IDTipoPreguntaGrupo INT,
			TipoPreguntaGrupo VARCHAR(255),
			RequerirComentario BIT,
			IDTipoEvaluacion INT,
			TipoEvaluacion VARCHAR(MAX),
			EscalaIndividualStr VARCHAR(255),
			Peso DECIMAL(18,2),
			IsDefault BIT,
			[Row] INT
		);
	
	SET DATEFIRST 7;

	SELECT @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')

    SELECT @IdiomaSQL = [SQL]
    FROM app.tblIdiomas
    WHERE IDIdioma = @IDIdioma

    IF(@IdiomaSQL IS NULL OR LEN(@IdiomaSQL) = 0)
	BEGIN
		SET @IdiomaSQL = 'Spanish' ;
	END
  
    SET LANGUAGE @IdiomaSQL;

	INSERT @tempResponse
	SELECT *
	FROM (
		SELECT 
			CG.IDGrupo,
			CG.IDTipoGrupo,
			CTG.Nombre AS TipoGrupo,
			CG.Nombre,
			CG.Descripcion,
			ISNULL(CG.FechaCreacion, GETDATE()) AS FechaCreacion,				   
			LEFT(DATENAME(WEEKDAY,ISNULL(CG.FechaCreacion,GETDATE())),3) + ' ' + CONVERT(VARCHAR(6),ISNULL(CG.FechaCreacion,GETDATE()),106) + ' ' + CONVERT(VARCHAR(4),DATEPART(YEAR,ISNULL(CG.FechaCreacion,GETDATE()))) FechaCreacionStr,
				   
			CG.TipoReferencia,
			CG.IDReferencia,
			ISNULL(CG.CopiadoDeIDGrupo,0) AS CopiadoDeIDGrupo,
			ISNULL(CG.IDTipoPreguntaGrupo,0) AS IDTipoPreguntaGrupo,
			ISNULL(CTPG.Nombre,'Sin asignar') AS TipoPreguntaGrupo,				
			ISNULL(cg.RequerirComentario, 0) AS RequerirComentario,
				   
			ISNULL(cg.IDTipoEvaluacion, 0) AS IDTipoEvaluacion,
			JSON_VALUE(cte.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) AS TipoEvaluacion,
			EscalaIndividualStr = CASE 
									WHEN CG.IDTipoPreguntaGrupo = 3 
										THEN STUFF((SELECT ', (' + CAST(Valor AS VARCHAR(10))+') ' + CONVERT(NVARCHAR(100), Nombre) 
														FROM [Evaluacion360].[tblEscalasValoracionesGrupos] 
														WHERE IDGrupo = CG.IDGrupo 
														FOR XML PATH('')
													), 1, 1, '') 
										ELSE NULL 
									END,
			ISNULL(CG.Peso, 0) AS Peso,
			ISNULL(CG.IsDefault, 0) as IsDefault,
			ROW_NUMBER() OVER(PARTITION BY CG.Nombre, ISNULL(CG.IDTipoEvaluacion, 0) ORDER BY CG.Nombre ASC) [Row]
		from [Evaluacion360].[tblCatGrupos] CG 
			JOIN [Evaluacion360].[tblCatTipoGrupo] CTG ON CG.IDTipoGrupo = CTG.IDTipoGrupo
			LEFT JOIN [Evaluacion360].[tblCatTiposPreguntasGrupos] CTPG ON CG.IDTipoPreguntaGrupo = CTPG.IDTipoPreguntaGrupo
			LEFT JOIN Evaluacion360.tblCatTiposEvaluaciones cte on cte.IDTipoEvaluacion = cg.IDTipoEvaluacion
		WHERE (CG.IDTipoGrupo = @IDTipoGrupo OR @IDTipoGrupo IS NULL) AND 
			  (CG.TipoReferencia = @TipoReferencia OR @TipoReferencia IS NULL) AND 
			  (CG.IDReferencia = @IDReferencia OR @IDReferencia IS NULL) AND
			  (@query = '""' OR CONTAINS(CG.*, @query)) AND
			  isnull(CG.IDTipoEvaluacion, -1) != 0
	) A
	WHERE [Row] = 1
	
	SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20,2))/CAST(@PageSize AS DECIMAL(20,2)))
	FROM @tempResponse

	SELECT @TotalRegistros = CAST(COUNT([IDGrupo]) AS DECIMAL(18,2)) FROM @tempResponse
	
	SELECT *,
			TotalPages = CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END,
			CAST(@TotalRegistros AS INT) AS TotalRows
	FROM @tempResponse
	ORDER BY
		CASE WHEN @orderByColumn = 'IDGrupo' AND @orderDirection = 'asc' THEN IDGrupo END,
		CASE WHEN @orderByColumn = 'IDGrupo' AND @orderDirection = 'desc' THEN IDGrupo END DESC,
		CASE WHEN @orderByColumn = 'Nombre' AND @orderDirection = 'asc'	THEN Nombre END,
		CASE WHEN @orderByColumn = 'Nombre'	AND @orderDirection = 'desc' THEN Nombre END DESC,
		CASE WHEN @orderByColumn = 'Descripcion'	and @orderDirection = 'asc'	THEN Descripcion END,
		CASE WHEN @orderByColumn = 'Descripcion'	and @orderDirection = 'desc' THEN Descripcion END DESC,
		CASE WHEN @orderByColumn = 'IDTipoEvaluacion'	and @orderDirection = 'asc'	THEN IDTipoEvaluacion END,
		CASE WHEN @orderByColumn = 'IDTipoEvaluacion'	and @orderDirection = 'desc' THEN IDTipoEvaluacion END DESC,
		IDTipoEvaluacion, IDGrupo
	OFFSET @PageSize * (@PageNumber - 1) ROWS
	FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
