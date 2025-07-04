USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar mapeo de puestos
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-05-29
** Paremetros		: @IDMapeo			- Identificador del mapeo.
					  @IDSucursal		- Identificador de la sucursal.
					  @IDDepartamento	- Identificador del departamento.
					  @IDPuesto			- Identificador del puesto.
					  @IDUsuario		- Identificador del usuario.
					  @PageNumber		- Numero de pagina que se esta solicitando.
					  @PageSize			- Numero de registros de la pagina.
					  @query			- Cualquier descripcion que tenga relacion con la dirección.
					  @orderByColumn	- Los registros se ordenan por la columna solicitada.
					  @orderDirection 	- Los registros pueden ser ordenados por (ASC o DESC).
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

CREATE   PROCEDURE [Staffing].[spBuscarMapeoPuestos](
	@IDMapeo			INT = 0
	, @IDSucursal		INT = 0
	, @IDDepartamento	INT = 0
	, @IDPuesto			INT = 0	
	, @IDUsuario		INT = 0
	, @PageNumber		INT = 1
	, @PageSize			INT = 2147483647
	, @query			VARCHAR(100) = '""'
	, @orderByColumn	VARCHAR(50) = 'IDSucursal'
	, @orderDirection	VARCHAR(4) = 'ASC'
)
AS
BEGIN

	SET FMTONLY OFF;  
	
		DECLARE @TotalPaginas	INT = 0,
				@TotalRegistros INT;

		IF(ISNULL(@PageNumber, 0) = 0) SET @PageNumber = 1;
		IF(ISNULL(@PageSize, 0) = 0) SET @PageSize = 2147483647;

		SET @query = CASE
						WHEN @query IS NULL THEN '""'
						WHEN @query = '' THEN '""'
						WHEN @query = '""' THEN @query
					 ELSE '"' + @query + '*"' END

		SELECT	@orderByColumn = CASE WHEN @orderByColumn IS NULL THEN 'IDSucursal' ELSE @orderByColumn END,
				@orderDirection = CASE WHEN @orderDirection IS NULL THEN 'ASC' ELSE @orderDirection END


		DECLARE @tempResponse AS TABLE (
			IDMapeo					INT
			, IDSucursal			INT
			, CodigoSucursal		VARCHAR(20)
			, Sucursal				VARCHAR(255)
			, IDDepartamento		INT
			, CodigoDepartamento	VARCHAR(20)
			, Departamento			VARCHAR(255)
			, IDPuesto				INT
			, CodigoPuesto			VARCHAR(20)
			, Puesto				VARCHAR(255)
			, ROWNUMBER				INT
		);

		INSERT @tempResponse
		SELECT MP.IDMapeo
			   , MP.IDSucursal
			   , S.Codigo AS CodigoSucursal
			   , S.Descripcion AS Sucursal
			   , MP.IDDepartamento
			   , D.Codigo AS CodigoDepartamento
			   , D.Descripcion AS Departamento
			   , MP.IDPuesto
			   , P.Codigo AS CodigoPuesto
			   , P.Descripcion AS Puesto
			   , ROWNUMBER = ROW_NUMBER()OVER(ORDER BY IDMapeo ASC) 
		FROM [Staffing].[tblCatMapeoPuestos] MP
			INNER JOIN [RH].[tblCatSucursales] S ON MP.IDSucursal = S.IDSucursal
			INNER JOIN [RH].[tblCatDepartamentos] D ON MP.IDDepartamento = D.IDDepartamento
			INNER JOIN [RH].[tblCatPuestos] P ON MP.IDPuesto = P.IDPuesto
		WHERE ((MP.IDMapeo = @IDMapeo OR ISNULL(@IDMapeo, 0) = 0))
			  AND ((MP.IDSucursal = @IDSucursal OR ISNULL(@IDSucursal, 0) = 0)) 
			  AND ((MP.IDDepartamento = @IDDepartamento OR ISNULL(@IDDepartamento, 0) = 0)) 
			  AND ((MP.IDPuesto = @IDPuesto OR ISNULL(@IDPuesto, 0) = 0))
			  AND (
					@query = '""'
					OR (CONTAINS(S.Codigo, @query) OR CONTAINS(S.Descripcion, @query))
					OR (CONTAINS(D.Codigo, @query) OR CONTAINS(D.Descripcion, @query))
					OR (CONTAINS(P.Codigo, @query) OR CONTAINS(P.Descripcion, @query))
				  )
	   
	   

		SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20,2))/CAST(@PageSize AS DECIMAL(20,2)))
		FROM @tempResponse

		SELECT @TotalRegistros = CAST(COUNT([IDMapeo]) AS DECIMAL(18,2)) FROM @tempResponse

		SELECT *,
				TotalPages = CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END,
				CAST(@TotalRegistros AS INT) AS TotalRows
		FROM @tempResponse
		ORDER BY
			CASE WHEN @orderByColumn = 'IDSucursal' and @orderDirection = 'asc'	THEN IDSucursal END
			, CASE WHEN @orderByColumn = 'IDSucursal' and @orderDirection = 'desc' THEN IDSucursal END DESC
			, CASE WHEN @orderByColumn = 'IDDepartamento'	and @orderDirection = 'asc'	THEN IDDepartamento END
			, CASE WHEN @orderByColumn = 'IDDepartamento'	and @orderDirection = 'desc' THEN IDDepartamento END DESC
			, CASE WHEN @orderByColumn = 'IDPuesto'	and @orderDirection = 'asc'	THEN IDPuesto END
			, CASE WHEN @orderByColumn = 'IDPuesto'	and @orderDirection = 'desc' THEN IDPuesto END DESC
			, Sucursal ASC, Departamento ASC, Puesto ASC
		OFFSET @PageSize * (@PageNumber - 1) ROWS
		FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

END
GO
