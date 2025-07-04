USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [Evaluacion360].[spBuscarEnviarResultadosAColaboradores](
	@IDProyecto INT,
	@IDUsuario INT,
	@PageNumber	INT = 1,
	@PageSize INT = 2147483647,
	@query VARCHAR(100) = '""',
	@orderByColumn	VARCHAR(50) = '',
	@orderDirection VARCHAR(4) = ''
) AS

	SET FMTONLY OFF;

		DECLARE
			@TotalPaginas INT = 0,
			@TotalRegistros DECIMAL(18,2) = 0.00;


		IF(ISNULL(@PageNumber, 0) = 0) SET @PageNumber = 1;
		IF(ISNULL(@PageSize, 0) = 0) SET @PageSize = 2147483647;

		SELECT
			 @orderByColumn	= CASE WHEN @orderByColumn IS NULL THEN 'IDEnviarResultadosAColaboradores' ELSE @orderByColumn END,
			 @orderDirection = CASE WHEN @orderDirection IS NULL THEN 'ASC' ELSE @orderDirection END


		SET @query = CASE
						WHEN @query IS NULL THEN '""'
						WHEN @query = '' THEN '""'
						WHEN @query = '""' THEN @query
					ELSE '"' + @query + '*"' END

		

		DECLARE @tempResponse AS TABLE (
			IDEmpleadoProyecto INT,
			IDEmpleado INT,
			ClaveEmpleado VARCHAR(50),
			NombreCompleto VARCHAR(254),
			Iniciales VARCHAR(2),
			IDEnviarResultadosAColaboradores INT,
			Valor BIT
		);



		INSERT @tempResponse
		SELECT EP.IDEmpleadoProyecto,
			   EP.IDEmpleado,
			   E.ClaveEmpleado,
			   E.NOMBRECOMPLETO AS NombreCompleto,
			   SUBSTRING (E.Nombre, 1, 1) + SUBSTRING (E.Paterno, 1, 1),
			   ISNULL(ERAC.IDEnviarResultadosAColaboradores, 0) IDEnviarResultadosAColaboradores,
			   ISNULL(ERAC.Valor, 0) Valor
		FROM Evaluacion360.tblEmpleadosProyectos EP
			JOIN RH.tblEmpleadosMaster E on EP.IDEmpleado = E.IDEmpleado
			LEFT JOIN Evaluacion360.tblEnviarResultadosAColaboradores ERAC ON ERAC.IDEmpleadoProyecto = EP.IDEmpleadoProyecto
		WHERE EP.IDProyecto = @IDProyecto AND
			  (@query = '""' OR CONTAINS(E.*, @query))


		SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20,2))/CAST(@PageSize AS DECIMAL(20,2)))
		FROM @tempResponse

		SELECT @TotalRegistros = CAST(COUNT([IDEmpleadoProyecto]) AS DECIMAL(18,2)) FROM @tempResponse

		SELECT *,
			   TotalPages = CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END,
			   CAST(@TotalRegistros AS INT) AS TotalRows
		FROM @tempResponse
		ORDER BY
			CASE WHEN @orderByColumn = 'NombreCompleto'	and @orderDirection = 'asc'	THEN NombreCompleto END,
			CASE WHEN @orderByColumn = 'NombreCompleto'	and @orderDirection = 'desc' THEN NombreCompleto END DESC,
			CASE WHEN @orderByColumn = 'IDEnviarResultadosAColaboradores'	and @orderDirection = 'asc'	THEN IDEnviarResultadosAColaboradores END,
			CASE WHEN @orderByColumn = 'IDEnviarResultadosAColaboradores'	and @orderDirection = 'desc' THEN IDEnviarResultadosAColaboradores END DESC,
			IDEnviarResultadosAColaboradores, NombreCompleto ASC
		OFFSET @PageSize * (@PageNumber - 1) ROWS
		FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
