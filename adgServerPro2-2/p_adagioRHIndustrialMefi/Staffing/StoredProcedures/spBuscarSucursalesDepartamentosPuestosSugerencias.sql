USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************
** Descripción		: Busca sucursales, departamentos y puestos como sugerencias
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-06-03
** Paremetros		: @IDSucursal		- Identificador de la sucursal.
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

CREATE   PROCEDURE [Staffing].[spBuscarSucursalesDepartamentosPuestosSugerencias](
	@IDSucursal		INT = 0
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
		
		SET LANGUAGE 'spanish'


		DECLARE @TotalPaginas		INT = 0
				, @TotalRegistros	INT = 0
				, @IDIdioma			VARCHAR(20)
				;

		IF(ISNULL(@PageNumber, 0) = 0) SET @PageNumber = 1;
		IF(ISNULL(@PageSize, 0) = 0) SET @PageSize = 2147483647;

		SET @query = CASE
						WHEN @query IS NULL THEN '""'
						WHEN @query = '' THEN '""'
						WHEN @query = '""' THEN @query
					 ELSE '"' + @query + '*"' END

		SELECT	@orderByColumn = CASE WHEN @orderByColumn IS NULL THEN 'IDSucursal' ELSE @orderByColumn END,
				@orderDirection = CASE WHEN @orderDirection IS NULL THEN 'ASC' ELSE @orderDirection END


		-- TABLAS TEMPORALES
		DECLARE @tempDatosNormalizados AS TABLE (
			ID					INT IDENTITY(1,1)
			, IDSucursal		INT
			, IDDepartamento	INT
			, IDPuesto			INT			
		);

		DECLARE @tempResponse AS TABLE (	
			IDSucursal				INT
			, CodigoSucursal		VARCHAR(20)
			, Sucursal				[App].[MDDescription]
			, IDDepartamento		INT
			, CodigoDepartamento	VARCHAR(20)
			, Departamento			[App].[MDDescription]
			, IDPuesto				INT
			, CodigoPuesto			VARCHAR(20)
			, Puesto				[App].[MDDescription]
			, ROWNUMBER				INT
		);


		-- DETECCION DE IDIOMA
		SELECT @IDIdioma = [App].[fnGetPreferencia]('Idioma', 1, 'esmx');


		-- NORMALIZAMOS LA INFORMACION OBTENIENDO LA SUCURSAL, DEPARTAMENTO Y PUESTO (QUE NO EXISTAN EN [Staffing].[tblCatMapeoPuestos])
		INSERT @tempDatosNormalizados
		SELECT EM.IDSucursal
				, EM.IDDepartamento
				, EM.IDPuesto
		FROM [RH].[tblEmpleadosMaster] EM
			JOIN [RH].[tblCatSucursales] S ON EM.IDSucursal = S.IDSucursal
			JOIN [RH].[tblCatDepartamentos] D ON EM.IDDepartamento = D.IDDepartamento
			JOIN [RH].[tblCatPuestos] P ON EM.IDPuesto = P.IDPuesto
		WHERE EM.IDSucursal > 0
				AND EM.IDDepartamento > 0
				AND EM.IDPuesto > 0
				AND NOT EXISTS (SELECT MP.IDMapeo FROM [Staffing].[tblCatMapeoPuestos] MP WHERE MP.IDSucursal = EM.IDSucursal AND MP.IDDepartamento = EM.IDDepartamento AND MP.IDPuesto = EM.IDPuesto)
		GROUP BY EM.IDSucursal, EM.IDDepartamento, EM.IDPuesto

		
		-- CONSULTAMOS LA INFORMACION NORMALIZADA
		INSERT @tempResponse
		SELECT DN.IDSucursal
			   , S.Codigo AS CodigoSucursal
			   , S.Descripcion AS Sucursal
			   , DN.IDDepartamento
			   , D.Codigo AS CodigoDepartamento
			   , D.Descripcion AS Departamento
			   , DN.IDPuesto
			   , P.Codigo AS CodigoPuesto
			   , P.Descripcion AS Puesto			   
			   , ROWNUMBER = ROW_NUMBER()OVER(ORDER BY DN.ID ASC) 
		FROM @tempDatosNormalizados DN
			JOIN [RH].[tblCatSucursales] S ON DN.IDSucursal = S.IDSucursal
			JOIN [RH].[tblCatDepartamentos] D ON DN.IDDepartamento = D.IDDepartamento
			JOIN [RH].[tblCatPuestos] P ON DN.IDPuesto = P.IDPuesto
		WHERE ((S.IDSucursal = @IDSucursal OR ISNULL(@IDSucursal, 0) = 0)) 
				AND ((D.IDDepartamento = @IDDepartamento OR ISNULL(@IDDepartamento, 0) = 0)) 
				AND ((P.IDPuesto = @IDPuesto OR ISNULL(@IDPuesto, 0) = 0))
				AND (
					@query = '""'
					OR (CONTAINS(S.Codigo, @query) OR CONTAINS(S.Descripcion, @query))
					OR (CONTAINS(D.Codigo, @query) OR CONTAINS(D.Descripcion, @query))
					OR (CONTAINS(P.Codigo, @query) OR CONTAINS(P.Descripcion, @query))
				  )
		
		
		-- PAGINACION
		SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20,2))/CAST(@PageSize AS DECIMAL(20,2)))
		FROM @tempResponse

		SELECT @TotalRegistros = CAST(COUNT(IDSucursal) AS DECIMAL(18,2)) FROM @tempResponse

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
