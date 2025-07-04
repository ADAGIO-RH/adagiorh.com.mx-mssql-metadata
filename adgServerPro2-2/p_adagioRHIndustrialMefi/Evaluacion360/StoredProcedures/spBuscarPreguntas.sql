USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar Preguntas
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-09-26
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2018-10-08			Aneudy Abreu	Se agregó el sp [spBuscarQuienRespondePregunta]
2019-02-07			Aneudy Abreu	Se agregaron los campos  Box9EsRequerido,Comentario,ComentarioEsRequerido 															 
2022-08-02			Javier Paredes	Se adapto el codigo para la busqueda por paginacion y se elimino el codigo que hacia referencia
									a spBuscarQuienRespondePregunta
***************************************************************************************************/
CREATE PROC [Evaluacion360].[spBuscarPreguntas](
	@IDPregunta INT = 0,
	@IDTipoPregunta INT = 0,
	@IDGrupo INT = 0,	
	@IDCategoriaPregunta INT = 0,
	@PageNumber	INT = 1,
	@PageSize INT = 2147483647,
	@query VARCHAR(100) = '""',
	@orderByColumn	VARCHAR(50) = 'IDPregunta',
	@orderDirection VARCHAR(4) = 'ASC'
    ,@IDUsuario int =0
) AS
	
	SET FMTONLY OFF;

	DECLARE
		@TotalPaginas INT = 0,
		@TotalRegistros DECIMAL(18,2) = 0.00,
        @IDIdioma varchar(max);


	IF(ISNULL(@PageNumber, 0) = 0) SET @PageNumber = 1;
	IF(ISNULL(@PageSize, 0) = 0) SET @PageSize = 2147483647;
    
     select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	SELECT
			@orderByColumn	= CASE WHEN @orderByColumn IS NULL THEN 'Nombre' ELSE @orderByColumn END,
			@orderDirection = CASE WHEN @orderDirection IS NULL THEN 'ASC' ELSE @orderDirection END

   
	SET @query = CASE
					WHEN @query IS NULL THEN '""'
					WHEN @query = '' THEN '""'
					WHEN @query = '""' THEN @query
				ELSE '"' + @query + '*"' END

	DECLARE @tempResponse AS TABLE (
		IDPregunta INT,
		IDTipoPregunta INT,
		TipoPregunta VARCHAR(50),
		IDGrupo INT,
		Grupo VARCHAR(254),
		IDTipoGrupo INT,
		TipoGrupo VARCHAR(100),
		IDCategoriaPregunta INT,
		Categoria VARCHAR(255),
		Descripcion VARCHAR(MAX),
		EsRequerida BIT,
		Calificar BIT,
		Respuesta VARCHAR(255),
		Box9 BIT,
		Box9EsRequerido BIT,
		Comentario BIT,
		ComentarioEsRequerido BIT,
		TotalComentarios INT,
		IDIndicador INT,
		Indicador varchar(255)
	);


	INSERT @tempResponse
	SELECT P.IDPregunta,
			P.IDTipoPregunta,
			UPPER (JSON_VALUE(tp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'TipoPregunta'))) as TipoPregunta,
			P.IDGrupo,
			CG.Nombre AS Grupo,
			TG.IDTipoGrupo,
			TG.Nombre AS TipoGrupo,
			ISNULL(P.IDCategoriaPregunta, 0) AS IDCategoriaPregunta,
			ISNULL(CCP.Nombre, 'Sin categoría asignada') AS Categoria,
			P.Descripcion,
			P.EsRequerida,
			P.Calificar,
			RP.Respuesta,
			ISNULL(P.Box9, CAST(0 AS BIT)) Box9,
			ISNULL(P.Box9EsRequerido, CAST(0 AS BIT)) Box9EsRequerido,
			ISNULL(P.Comentario, CAST(0 AS BIT)) Comentario,
			ISNULL(P.ComentarioEsRequerido, CAST(0 AS BIT)) ComentarioEsRequerido,
			(SELECT COUNT(*) FROM [Evaluacion360].[tblComentariosPregunta] WITH (NOLOCK) WHERE IDPregunta = P.IDPregunta ) AS TotalComentarios,
			isnull(p.IDIndicador, 0) as IDIndicador,
			isnull(indicadores.Nombre, 'Sin indicador') as Indicador
	FROM [Evaluacion360].[tblCatPreguntas] P
		JOIN [Evaluacion360].[tblCatTiposDePreguntas] TP ON P.IDTipoPregunta = TP.IDTipoPregunta
		JOIN [Evaluacion360].[tblCatGrupos] CG ON P.IDGrupo = CG.IDGrupo
		JOIN [Evaluacion360].[tblCatTipoGrupo] TG ON TG.IDTipoGrupo = CG.IDTipoGrupo
		LEFT JOIN [Evaluacion360].[tblCatCategoriasPreguntas] CCP ON P.IDCategoriaPregunta = CCP.IDCategoriaPregunta
		left join [Evaluacion360].[tblCatIndicadores] indicadores  with (nolock) on p.IDIndicador = indicadores.IDIndicador
		LEFT JOIN [Evaluacion360].[tblRespuestasPreguntas] RP ON RP.IDPregunta = P.IDPregunta
	WHERE ((P.IDPregunta = @IDPregunta OR ISNULL(@IDPregunta, 0) = 0)) AND
			((P.IDTipoPregunta = @IDTipoPregunta OR ISNULL(@IDTipoPregunta, 0) = 0)) AND
			((P.IDGrupo = @IDGrupo OR ISNULL(@IDGrupo, 0) = 0)) AND
			((P.IDCategoriaPregunta = @IDCategoriaPregunta OR ISNULL(@IDCategoriaPregunta, '') = '')) AND
			(@query = '""' OR CONTAINS(P.*, @query))


		
		
		SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20,2))/CAST(@PageSize AS DECIMAL(20,2)))
		FROM @tempResponse

		SELECT @TotalRegistros = CAST(COUNT([IDPregunta]) AS DECIMAL(18,2)) FROM @tempResponse

		SELECT *,
			   TotalPages = CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END,
			   CAST(@TotalRegistros AS INT) AS TotalRows
		FROM @tempResponse
		ORDER BY
			CASE WHEN @orderByColumn = 'IDPregunta'	and @orderDirection = 'asc'	THEN IDPregunta END,
			CASE WHEN @orderByColumn = 'IDPregunta'	and @orderDirection = 'desc' THEN IDPregunta END DESC,
			CASE WHEN @orderByColumn = 'IDTipoPregunta'	and @orderDirection = 'asc'	THEN IDTipoPregunta END,
			CASE WHEN @orderByColumn = 'IDTipoPregunta'	and @orderDirection = 'desc' THEN IDTipoPregunta END DESC,
			CASE WHEN @orderByColumn = 'IDGrupo' and @orderDirection = 'asc'	THEN IDGrupo END,
			CASE WHEN @orderByColumn = 'IDGrupo' and @orderDirection = 'desc' THEN IDGrupo END DESC,
			CASE WHEN @orderByColumn = 'IDCategoriaPregunta' and @orderDirection = 'asc' THEN IDCategoriaPregunta END,
			CASE WHEN @orderByColumn = 'IDCategoriaPregunta' and @orderDirection = 'desc' THEN IDCategoriaPregunta END DESC,
			CASE WHEN @orderByColumn = 'Descripcion' and @orderDirection = 'asc' THEN Descripcion END,
			CASE WHEN @orderByColumn = 'Descripcion' and @orderDirection = 'desc' THEN Descripcion END DESC,
			IDPregunta, ISNULL(Categoria, 'Sin categoría asignada') ASC
		OFFSET @PageSize * (@PageNumber - 1) ROWS
		FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


		exec [Evaluacion360].[spBuscarPosiblesRespuestasPreguntas] @IDPregunta = @IDPregunta
GO
