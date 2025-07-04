USE [p_adagioRHAC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
2024-10-12			Alejandro Paredes	Se filtraron las notificaciones activas por la propiedad "IsActivo"
***************************************************************************************************/
CREATE PROCEDURE [RH].[spBuscarContactosEmpleadosTiposNotificaciones]
(
	@IDContactoEmpleadoTipoNotificacion INT = 0
	, @IDEmpleado						INT
	, @IDUsuario						INT = 0
	, @PageNumber						INT = 1
	, @PageSize							INT = 2147483647
	, @query							VARCHAR(100) = '""'
	, @orderByColumn					VARCHAR(50) = 'NombreTipoNotificacion'
	, @orderDirection					VARCHAR(4) = 'asc'
)
AS
BEGIN
	
	SET FMTONLY OFF;

	DECLARE @TotalPaginas		INT = 0
			, @TotalRegistros	DECIMAL(18,2) = 0.00
			, @IDIdioma			VARCHAR(20)
			, @IDIdiomaEmpleado	VARCHAR(20)
			, @NO				BIT = 0
			, @SI				BIT = 1
			;

	SELECT @IDIdioma = [App].[fnGetPreferencia]('Idioma', @IDUsuario, 'es-MX')

    SELECT @IDIdiomaEmpleado = [App].[fnGetPreferencia]('Idioma', S.IDUsuario, 'es-MX')
    FROM [Seguridad].[tblUsuarios] S
	WHERE IDEmpleado = @IDEmpleado
 
	IF(@PageNumber = 0) SET @PageNumber = 1;
	IF(@PageSize = 0) SET @PageSize = 2147483647;
				
	SET @query = CASE
					WHEN @query IS NULL THEN '""'
					WHEN @query = '' THEN '""'
					WHEN @query = '""' THEN '""'
					ELSE '"' + @query + '*"' 
					END

	DECLARE @tempResponse AS TABLE(
		IDTipoNotificacion						VARCHAR(255)   
		, NombreTipoNotificacion				VARCHAR(255)
		, DescripcionTipoNotificacion			VARCHAR(MAX)
		, IDTemplateNotificacion				INT
		, IDMedioNotificacion					VARCHAR(50) 
		, MedioNotificacion						VARCHAR(255)			
		, IDContactoEmpleadoTipoNotificacion	INT
		, IDEmpleado							INT
		, IDContactoEmpleado					INT 
		, IDTipoContactoEmpleado				INT
		, TipoContactoEmpleado					VARCHAR(255)
		, Valor									VARCHAR(MAX)
        , RowNumber								INT 		
	);

	INSERT @tempResponse
	SELECT TN.IDTipoNotificacion
			, TN.Nombre
			, TN.Descripcion
			, TEMPLATE.IDTemplateNotificacion
			, TEMPLATE.IDMedioNotificacion
			--, MN.Descripcion
			, JSON_VALUE(MN.Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE(@IDIdioma, '-','')), 'Descripcion')) AS MedioNotificacion
			, ISNULL(CETN.IDContactoEmpleadoTipoNotificacion, 0) AS IDContactoEmpleadoTipoNotificacion
			, ISNULL(@IDEmpleado, 0) AS IDEmpleado
			, ISNULL(CETN.IDContactoEmpleado, 0) AS IDContactoEmpleado
			, ISNULL(CE.IDTipoContactoEmpleado, 0) AS IDTipoContactoEmpleado
			--, TCC.Descripcion as TipoContactoEmpleado
			, JSON_VALUE(TCC.Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE(@IDIdioma, '-','')), 'Descripcion')) AS TipoContactoEmpleado
			, CE.Value AS Valor
			, ROW_NUMBER()OVER(PARTITION BY TN.IDTipoNotificacion ORDER BY TN.IDTipoNotificacion)
	FROM [App].[tblTiposNotificaciones] TN
		INNER JOIN [App].[tblTemplateNotificaciones] TEMPLATE ON TN.IDTipoNotificacion = TEMPLATE.IDTipoNotificacion
		INNER JOIN [App].[tblMediosNotificaciones] MN ON MN.IDMedioNotificacion = TEMPLATE.IDMedioNotificacion
		LEFT JOIN [RH].[tblContactosEmpleadosTiposNotificaciones] CETN ON CETN.IDEmpleado = @IDEmpleado
																			AND CETN.IDTipoNotificacion = TN.IDTipoNotificacion
																			AND CETN.IDTemplateNotificacion = TEMPLATE.IDTemplateNotificacion
		LEFT JOIN [RH].[tblContactoEmpleado] CE ON CE.IDEmpleado = CETN.IDEmpleado
													AND CETN.IDContactoEmpleado = CE.IDContactoEmpleado
		LEFT JOIN [RH].[tblCatTipoContactoEmpleado] TCC ON TCC.IDTipoContacto = CE.IDTipoContactoEmpleado
	WHERE (@query = '""' OR CONTAINS(TN.*, @query))
			AND (CETN.IDContactoEmpleadoTipoNotificacion = ISNULL(@IDContactoEmpleadoTipoNotificacion, 0) OR ISNULL(@IDContactoEmpleadoTipoNotificacion, 0) = 0)
            AND TN.IsSpecial = @NO
			AND TN.IsActivo = @SI
            -- AND TEMPLATE.IDIdioma = @IDIdioma
	ORDER BY TN.Nombre ASC



	SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20,2)) / CAST(@PageSize AS DECIMAL(20,2)))
	FROM @tempResponse

	SELECT @TotalRegistros = CAST(COUNT(IDTipoNotificacion) AS DECIMAL(18,2)) FROM @tempResponse;

	SELECT *
			, TotalPaginas = CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END
	FROM @tempResponse
    WHERE RowNumber = 1
	ORDER BY
		CASE WHEN @orderByColumn = 'NombreTipoNotificacion'			AND @orderDirection = 'asc'		THEN NombreTipoNotificacion END,			
		CASE WHEN @orderByColumn = 'NombreTipoNotificacion'			AND @orderDirection = 'desc'	THEN NombreTipoNotificacion END DESC,			
		CASE WHEN @orderByColumn = 'DescripcionTipoNotificacion'	AND @orderDirection = 'asc'		THEN DescripcionTipoNotificacion END,			
		CASE WHEN @orderByColumn = 'DescripcionTipoNotificacion'	AND @orderDirection = 'desc'	THEN DescripcionTipoNotificacion END DESC,					
		NombreTipoNotificacion ASC
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

END
GO
