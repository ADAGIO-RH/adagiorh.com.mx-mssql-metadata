USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca los tipos de notificación.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-09-05
** Paremetros		: @IDTipoNotificacion		Identificador del tipo de notificación.
**					: @PageNumber				Número de página solicitado.
**					: @PageSize					Número de registros solicitados por página.
**					: @query					Texto a buscar en los registros.
**					: @orderByColumn			Nombre de columna por la que se ordenaran los registros.
**					: @orderDirection			Direccion del orden (Ascendente o Descentende).
**					: @IDUsuario				Identificador del usuario
** IDAzure			: #67

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [App].[spBuscarTiposDeNotificaciones](
	@IDTipoNotificacion	VARCHAR(50) = ''
	, @PageNumber		INT = 1
	, @PageSize			INT = 10
	, @query			VARCHAR(100) = '""'
	, @orderByColumn	VARCHAR(50) = 'IDTipoNotificacion'
	, @orderDirection	VARCHAR(4) = 'ASC'
	, @IDUsuario		INT
)
AS
	BEGIN
		
		SET FMTONLY OFF;  
	
		DECLARE @TotalPaginas		INT = 0
				, @TotalRegistros	INT
				, @IDIdioma			VARCHAR(20)
				, @SI				BIT = 1
				;

		SELECT @IDIdioma = [App].[fnGetPreferencia]('Idioma', 1, 'esmx');

		IF(ISNULL(@PageNumber, 0) = 0) SET @PageNumber = 1;
		IF(ISNULL(@PageSize, 0) = 0) SET @PageSize = 2147483647;

		SET @query = CASE
						WHEN @query IS NULL THEN '""'
						WHEN @query = '' THEN '""'
						WHEN @query = '""' THEN @query
					 ELSE '"' + @query + '*"' END

		SELECT	@orderByColumn = CASE WHEN @orderByColumn IS NULL THEN 'IDTipoNotificacion' ELSE @orderByColumn END,
				@orderDirection = CASE WHEN @orderDirection IS NULL THEN 'ASC' ELSE @orderDirection END


				
		DECLARE @tempResponse AS TABLE (
			IDTipoNotificacion		 VARCHAR(500)
			, Nombre				 [App].[MDDescription]
			, Descripcion			 VARCHAR(500)
			, Asunto				 [App].[MDDescription]
			, IsSpecial				 BIT
			, JsonMediosNotificacion NVARCHAR(MAX)
			, ROWNUMBER				 INT
		);

		INSERT @tempResponse
		SELECT TN.IDTipoNotificacion
				, TN.Nombre
				, TN.Descripcion
				, TN.Asunto
				, TN.IsSpecial
				, ISNULL((
					SELECT MN.IDMedioNotificacion
							, ISNULL(JSON_VALUE(MN.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE(@IDIdioma, '-', '')) + '', 'Descripcion')), '') AS Descripcion
							, MN.Icon
							, MN.Component
					FROM [App].[tblTemplateNotificaciones] TN2
						JOIN [App].[tblMediosNotificaciones] MN ON TN2.IDMedioNotificacion = MN.IDMedioNotificacion
					WHERE TN2.IDTipoNotificacion = TN.IDTipoNotificacion
					GROUP BY MN.IDMedioNotificacion, MN.Traduccion, MN.Icon, MN.Component
					FOR JSON AUTO
				  ), '[]') AS JsonMediosNotificacion
			   , ROWNUMBER = ROW_NUMBER()OVER(ORDER BY TN.IDTipoNotificacion ASC)
		FROM [App].[tblTiposNotificaciones] TN
		WHERE TN.IsActivo = @SI
				AND (TN.IDTipoNotificacion = @IDTipoNotificacion OR ISNULL(@IDTipoNotificacion, '') = '')
				AND (@query = '""' OR CONTAINS(TN.*, @query))
		--SELECT * FROM @tempResponse
		


		SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20,2))/CAST(@PageSize AS DECIMAL(20,2)))
		FROM @tempResponse

		SELECT @TotalRegistros = CAST(COUNT([IDTipoNotificacion]) AS DECIMAL(18,2)) FROM @tempResponse

		SELECT *,
				TotalPages = CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END,
				CAST(@TotalRegistros AS INT) AS TotalRows
		FROM @tempResponse
		ORDER BY
			CASE WHEN @orderByColumn = 'Nombre'		 AND @orderDirection = 'ASC'  THEN Nombre      END,
			CASE WHEN @orderByColumn = 'Nombre'		 AND @orderDirection = 'DESC' THEN Nombre	   END DESC,
			CASE WHEN @orderByColumn = 'Descripcion' AND @orderDirection = 'ASC'  THEN Descripcion END,
			CASE WHEN @orderByColumn = 'Descripcion' AND @orderDirection = 'DESC' THEN Descripcion END DESC,
			CASE WHEN @orderByColumn = 'Asunto'		 AND @orderDirection = 'ASC'  THEN Asunto      END,
			CASE WHEN @orderByColumn = 'Asunto'		 AND @orderDirection = 'DESC' THEN Asunto      END DESC,
			CASE WHEN @orderByColumn = 'IsSpecial'	 AND @orderDirection = 'ASC'  THEN IsSpecial   END,
			CASE WHEN @orderByColumn = 'IsSpecial'	 AND @orderDirection = 'DESC' THEN IsSpecial   END DESC,
			IDTipoNotificacion ASC
		OFFSET @PageSize * (@PageNumber - 1) ROWS
		FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


	END
GO
