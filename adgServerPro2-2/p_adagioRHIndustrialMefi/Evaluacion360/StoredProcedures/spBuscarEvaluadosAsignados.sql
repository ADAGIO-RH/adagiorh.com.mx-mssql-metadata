USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Busca los colaboradores asignados al @IDEmpleado para evaluar
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@gmail.com
** FechaCreacion	: 2018-10-30
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
2022-09-28			Alejandro Paredes	Paginación
***************************************************************************************************/

CREATE PROC [Evaluacion360].[spBuscarEvaluadosAsignados](
	@IDEmpleado INT,
	@IDTipoRelacion INT = 0,
	@IDUsuario INT,
	@IDProyecto INT,
	@PageNumber	INT = 1,
	@PageSize INT = 2147483647,
	@query VARCHAR(100) = '""',
	@orderByColumn	VARCHAR(50) = '',
	@orderDirection VARCHAR(4) = ''
) AS
	
		SET FMTONLY OFF;

		DECLARE
			@TotalPaginas INT = 0,
			@TotalRegistros DECIMAL(18,2) = 0.00,
            @IDIdioma varchar(max);
            
            select @IDIdioma=App.fnGetPreferencia('idioma',@IDUsuario,'esmx')


		IF(ISNULL(@PageNumber, 0) = 0) SET @PageNumber = 1;
		IF(ISNULL(@PageSize, 0) = 0) SET @PageSize = 2147483647;

		SELECT
			 @orderByColumn	= CASE WHEN @orderByColumn IS NULL THEN 'Colaborador' ELSE @orderByColumn END,
			 @orderDirection = CASE WHEN @orderDirection IS NULL THEN 'ASC' ELSE @orderDirection END

   
		SET @query = CASE
						WHEN @query IS NULL THEN '""'
						WHEN @query = '' THEN '""'
						WHEN @query = '""' THEN @query
					ELSE '"' + @query + '*"' END

		DECLARE @tempResponse AS TABLE (
			IDEmpleadoProyecto INT,
			IDProyecto INT,
			IDEmpleado INT,
			ClaveEmpleado VARCHAR(50),
			Colaborador VARCHAR(254),
			Iniciales VARCHAR(2),
			IDEvaluacionEmpleado INT,
			IDTipoRelacion INT,
			Relacion VARCHAR(50),
			IDEvaluador INT
		);

		INSERT @tempResponse
		SELECT EP.IDEmpleadoProyecto,
			   EP.IDProyecto,
			   EP.IDEmpleado,
			   E.ClaveEmpleado,
			   E.NOMBRECOMPLETO AS Colaborador,
			   SUBSTRING (E.Nombre, 1, 1) + SUBSTRING (E.Paterno, 1, 1),
			   EE.IDEvaluacionEmpleado,
			   EE.IDTipoRelacion,
			   JSON_VALUE(TP.Traduccion,FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Relacion')) as Relacion,
			   EE.IDEvaluador
		FROM [Evaluacion360].[tblEmpleadosProyectos] EP
			JOIN [Evaluacion360].[tblEvaluacionesEmpleados] EE ON EE.IDEmpleadoProyecto = EP.IDEmpleadoProyecto
			JOIN [RH].[tblEmpleadosMaster] E ON EP.IDEmpleado = E.IDEmpleado
			JOIN [Evaluacion360].[tblCatTiposRelaciones] TP ON EE.IDTipoRelacion = TP.IDTipoRelacion
		WHERE EP.IDProyecto = @IDProyecto AND
			  EE.IDEvaluador = @IDEmpleado AND
			  (EE.IDTipoRelacion = @IDTipoRelacion OR @IDTipoRelacion = 0) AND
			  (@query = '""' OR CONTAINS(E.*, @query))

			  
		SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20,2))/CAST(@PageSize AS DECIMAL(20,2)))
		FROM @tempResponse

		SELECT @TotalRegistros = CAST(COUNT([IDEmpleadoProyecto]) AS DECIMAL(18,2)) FROM @tempResponse

		SELECT *,
				TotalPages = CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END,
				CAST(@TotalRegistros AS INT) AS TotalRows
		FROM @tempResponse
		ORDER BY
			CASE WHEN @orderByColumn = 'IDEmpleadoProyecto'	and @orderDirection = 'asc'	THEN IDEmpleadoProyecto END,
			CASE WHEN @orderByColumn = 'IDEmpleadoProyecto'	and @orderDirection = 'desc' THEN IDEmpleadoProyecto END DESC,
			CASE WHEN @orderByColumn = 'IDEmpleado'	and @orderDirection = 'asc'	THEN IDEmpleado END,
			CASE WHEN @orderByColumn = 'IDEmpleado'	and @orderDirection = 'desc' THEN IDEmpleado END DESC,
			CASE WHEN @orderByColumn = 'ClaveEmpleado' and @orderDirection = 'asc'	THEN ClaveEmpleado END,
			CASE WHEN @orderByColumn = 'ClaveEmpleado' and @orderDirection = 'desc' THEN ClaveEmpleado END DESC,
			CASE WHEN @orderByColumn = 'Colaborador' and @orderDirection = 'asc' THEN Colaborador END,
			CASE WHEN @orderByColumn = 'Colaborador' and @orderDirection = 'desc' THEN Colaborador END DESC,
			CASE WHEN @orderByColumn = 'IDTipoRelacion' and @orderDirection = 'asc' THEN IDTipoRelacion END,
			CASE WHEN @orderByColumn = 'IDTipoRelacion' and @orderDirection = 'desc' THEN IDTipoRelacion END DESC,
			Colaborador
		OFFSET @PageSize * (@PageNumber - 1) ROWS
		FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
