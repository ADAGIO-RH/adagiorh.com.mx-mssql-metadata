USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar Direcciones
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-01-27
** Paremetros		: @IDDireccion			- Identificador de la dirección.
					  @Codigo				- Codigo de la dirección.
					  @Descripcion			- Descripcion de la dirección.
					  @CuentaContable 		- Cuenta de la dirección.
					  @IDUsuario			- Identificador del usuario.
					  @PageNumber			- Numero de pagina que se esta solicitando.
					  @PageSize				- Numero de registros de la pagina.
					  @query				- Cualquier descripcion que tenga relacion con la dirección.
					  @orderByColumn		- Los registros se ordenan por la columna solicitada.
					  @orderDirection 		- Los registros pueden ser ordenados por (ASC o DESC).
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

CREATE   PROCEDURE [RH].[spBuscarDireccionesOrganizacionales](
	@IDDireccion	INT = NULL,
	@Codigo			VARCHAR(20),
	@Descripcion	VARCHAR(50),
	@CuentaContable VARCHAR(50),
	@IDUsuario		INT,
	@PageNumber		INT = 1,
	@PageSize		INT = 2147483647,
	@query			VARCHAR(100) = '""',
	@orderByColumn	VARCHAR(50) = 'Codigo',
	@orderDirection VARCHAR(4) = 'ASC'
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

	SELECT	@orderByColumn = CASE WHEN @orderByColumn IS NULL THEN 'Codigo' ELSE @orderByColumn END,
			@orderDirection = CASE WHEN @orderDirection IS NULL THEN 'ASC' ELSE @orderDirection END


	DECLARE @tempResponse AS TABLE (
		IDDireccion INT,
		Codigo VARCHAR(20),
		Descripcion [App].[MDDescription],
		CuentaContable VARCHAR(50),
		ROWNUMBER INT
	); 

	INSERT @tempResponse
	SELECT D.IDDireccion,
		   D.Codigo,
		   D.Descripcion,
		   D.CuentaContable,
		   ROWNUMBER = ROW_NUMBER()OVER(ORDER BY Codigo ASC) 
	FROM [RH].[tblCatDireccionesOrganizacionales] D
	WHERE ((D.IDDireccion = @IDDireccion OR ISNULL(@IDDireccion, 0) = 0)) AND
		  ((D.Codigo = @Codigo OR ISNULL(@Codigo, 0) = 0)) AND
		  ((D.Descripcion = @Descripcion OR ISNULL(@Descripcion, '') = '')) AND
		  ((D.CuentaContable = @CuentaContable OR ISNULL(@CuentaContable, '') = '')) AND
		  (@query = '""' OR CONTAINS(D.*, @query)) 
	
	SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20,2))/CAST(@PageSize AS DECIMAL(20,2)))
	FROM @tempResponse

	SELECT @TotalRegistros = CAST(COUNT([IDDireccion]) AS DECIMAL(18,2)) FROM @tempResponse

	SELECT *,
			TotalPages = CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END,
			CAST(@TotalRegistros AS INT) AS TotalRows
	FROM @tempResponse
	ORDER BY
		CASE WHEN @orderByColumn = 'Codigo'	and @orderDirection = 'asc'	THEN Codigo END,
		CASE WHEN @orderByColumn = 'Codigo'	and @orderDirection = 'desc' THEN Codigo END DESC,
		CASE WHEN @orderByColumn = 'Descripcion'	and @orderDirection = 'asc'	THEN Descripcion END,
		CASE WHEN @orderByColumn = 'Descripcion'	and @orderDirection = 'desc' THEN Descripcion END DESC,
		CASE WHEN @orderByColumn = 'CuentaContable' and @orderDirection = 'asc'	THEN CuentaContable END,
		CASE WHEN @orderByColumn = 'CuentaContable' and @orderDirection = 'desc' THEN CuentaContable END DESC,
		IDDireccion ASC
	OFFSET @PageSize * (@PageNumber - 1) ROWS
	FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

END
GO
