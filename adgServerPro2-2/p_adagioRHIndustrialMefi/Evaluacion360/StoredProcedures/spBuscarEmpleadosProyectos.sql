USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca los colaboradores que están asignados a una prueba
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-01-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2019-05-10			Aneudy Abreu		Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
										Seguridad.tblDetalleFiltrosEmpleadosUsuarios
2022-08-31			Alejandro Paredes	Paginación
2023-12-07			Alejandro Paredes	Se quito el JOIN a la tabla de 
										Seguridad.tblDetalleFiltrosEmpleadosUsuarios
***************************************************************************************************/

CREATE PROC [Evaluacion360].[spBuscarEmpleadosProyectos](
	 @IDProyecto INT = NULL
	,@IDEmpleadoProyecto INT = NULL
	,@TipoFiltro VARCHAR(255) = NULL
	,@IDUsuario INT
	,@PageNumber INT = NULL
	,@PageSize INT = NULL
	,@query VARCHAR(100) = '""'
	,@orderByColumn	VARCHAR(50) = NULL
	,@orderDirection VARCHAR(4) = NULL
) AS
	
	SET FMTONLY OFF;

		SET LANGUAGE 'Spanish';

		DECLARE
			@TotalPaginas INT = 0,
			@TotalRegistros DECIMAL(18,2) = 0.00;

		IF(ISNULL(@PageNumber, 0) = 0) SET @PageNumber = 1;
		IF(ISNULL(@PageSize, 0) = 0) SET @PageSize = 2147483647;

		SELECT
			 @orderByColumn	= CASE WHEN @orderByColumn IS NULL THEN 'ClaveEmpleado' ELSE @orderByColumn END,
			 @orderDirection = CASE WHEN @orderDirection IS NULL THEN 'ASC' ELSE @orderDirection END
   
		SET @query = CASE
						WHEN @query IS NULL THEN '""'
						WHEN @query = '' THEN '""'
						WHEN @query = '""' THEN @query
					ELSE '"' + @query + '*"' END


		DECLARE @tempResponse AS TABLE (
			IDEmpleadoProyecto	INT,
			IDProyecto			INT,
			IDEmpleado			INT,
			ClaveEmpleado		VARCHAR(20),
			NOMBRECOMPLETO		VARCHAR(100),
			Iniciales			VARCHAR(2),
			Departamento		[App].[MDDescription],
			Sucursal			[App].[MDDescription],
			Puesto				[App].[MDDescription],
			CicloEvaluacion		VARCHAR(255),
			TipoFiltro			VARCHAR(255)
		);

		INSERT @tempResponse
		SELECT EP.IDEmpleadoProyecto
			  ,EP.IDProyecto
			  ,EP.IDEmpleado
			  ,EM.ClaveEmpleado
			  ,EM.NOMBRECOMPLETO
			  ,SUBSTRING (EM.Nombre, 1, 1) + SUBSTRING (EM.Paterno, 1, 1)
			  ,EM.Departamento
			  ,EM.Sucursal
			  ,EM.Puesto
			  ,'Del ' + CONVERT(VARCHAR(100), ISNULL(P.FechaInicio, GETDATE()), 106) + ' al ' + CONVERT(VARCHAR(100), ISNULL(P.FechaFin, GETDATE()),106) AS CicloEvaluacion
			  ,ISNULL(EP.TipoFiltro,'Empleados') AS TipoFiltro
		FROM [Evaluacion360].[tblEmpleadosProyectos] EP WITH (NOLOCK)
			JOIN [RH].[tblEmpleadosMaster] EM  WITH (NOLOCK) ON EP.IDEmpleado = EM.IDEmpleado
			--JOIN Seguridad.tblDetalleFiltrosEmpleadosUsuarios DFE WITH (NOLOCK) ON DFE.IDEmpleado = EM.IDEmpleado AND DFE.IDUsuario = @IDUsuario
			JOIN [Evaluacion360].[tblCatProyectos] P WITH (NOLOCK) ON EP.IDProyecto = P.IDProyecto
		WHERE ((EP.IDProyecto = @IDProyecto OR ISNULL(@IDProyecto, 0) = 0)) AND 
			  ((EP.IDEmpleadoProyecto = @IDEmpleadoProyecto OR ISNULL(@IDEmpleadoProyecto, 0) = 0)) AND 
			  (ISNULL(EP.TipoFiltro, 'Empleados') = @TipoFiltro OR @TipoFiltro IS NULL) AND
			  (@query = '""' OR CONTAINS(EM.*, @query))


		SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20,2))/CAST(@PageSize AS DECIMAL(20,2)))
		FROM @tempResponse

		SELECT @TotalRegistros = CAST(COUNT([IDEmpleadoProyecto]) AS DECIMAL(18,2)) FROM @tempResponse

		SELECT *,
			   TotalPages = CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END,
			   CAST(@TotalRegistros AS INT) AS TotalRows
		FROM @tempResponse
		ORDER BY
			CASE WHEN @orderByColumn = 'IDProyecto'	and @orderDirection = 'asc'	THEN IDProyecto END,
			CASE WHEN @orderByColumn = 'IDProyecto'	and @orderDirection = 'desc' THEN IDProyecto END DESC,
			CASE WHEN @orderByColumn = 'IDEmpleadoProyecto'	and @orderDirection = 'asc'	THEN IDEmpleadoProyecto END,
			CASE WHEN @orderByColumn = 'IDEmpleadoProyecto'	and @orderDirection = 'desc' THEN IDEmpleadoProyecto END DESC,
			CASE WHEN @orderByColumn = 'TipoFiltro' and @orderDirection = 'asc'	THEN TipoFiltro END,
			CASE WHEN @orderByColumn = 'TipoFiltro' and @orderDirection = 'desc' THEN TipoFiltro END DESC,
			ClaveEmpleado ASC
		OFFSET @PageSize * (@PageNumber - 1) ROWS
		FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
