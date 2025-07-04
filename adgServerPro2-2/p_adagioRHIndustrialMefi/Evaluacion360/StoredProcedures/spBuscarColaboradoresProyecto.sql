USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Busca los colaboradores del proyecto que seran evaluados según las restricciones que cumplan los colaboradores
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2022-10-05
** Paremetros		:              

** DataTypes Relacionados: 

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			    Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/

CREATE PROC [Evaluacion360].[spBuscarColaboradoresProyecto](
	@IDEmpleado INT = 0,
	@IDUsuario	INT,
	@IDProyecto	INT,
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
			 @orderByColumn	= CASE WHEN @orderByColumn IS NULL THEN 'NOMBRECOMPLETO' ELSE @orderByColumn END,
			 @orderDirection = CASE WHEN @orderDirection IS NULL THEN 'ASC' ELSE @orderDirection END

   
		SET @query = CASE
						WHEN @query IS NULL THEN '""'
						WHEN @query = '' THEN '""'
						WHEN @query = '""' THEN @query
					ELSE '"' + @query + '*"' END

		DECLARE @tempResponse AS TABLE (
			IDEmpleado INT,
			Colaborador VARCHAR(254),
			ClaveEmpleado VARCHAR(50),
			Iniciales VARCHAR(2)
		);

		INSERT @tempResponse
		SELECT EP.IDEmpleado,
			   E.NOMBRECOMPLETO,
			   E.ClaveEmpleado,
			   SUBSTRING (E.Nombre, 1, 1) + SUBSTRING (E.Paterno, 1, 1)
		FROM [Evaluacion360].[tblEmpleadosProyectos] EP
			JOIN [RH].[tblEmpleadosMaster] E ON EP.IDEmpleado = E.IDEmpleado
		WHERE EP.IDProyecto = @IDProyecto AND
			  EP.TipoFiltro != 'Excluir Empleado' AND
			  ((EP.IDEmpleado = @IDEmpleado OR ISNULL(@IDEmpleado, 0) = 0)) AND
			  (@query = '""' OR CONTAINS(E.*, @query))


		SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20,2))/CAST(@PageSize AS DECIMAL(20,2)))
		FROM @tempResponse

		SELECT @TotalRegistros = CAST(COUNT([IDEmpleado]) AS DECIMAL(18,2)) FROM @tempResponse

		SELECT *,
			   TotalPages = CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END,
			   CAST(@TotalRegistros AS INT) AS TotalRows
		FROM @tempResponse
		ORDER BY
			CASE WHEN @orderByColumn = 'IDEmpleado'	and @orderDirection = 'asc'	THEN IDEmpleado END,
			CASE WHEN @orderByColumn = 'IDEmpleado'	and @orderDirection = 'desc' THEN IDEmpleado END DESC,
			CASE WHEN @orderByColumn = 'Colaborador'	and @orderDirection = 'asc'	THEN Colaborador END,
			CASE WHEN @orderByColumn = 'Colaborador'	and @orderDirection = 'desc' THEN Colaborador END DESC,
			Colaborador
		OFFSET @PageSize * (@PageNumber - 1) ROWS
		FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
