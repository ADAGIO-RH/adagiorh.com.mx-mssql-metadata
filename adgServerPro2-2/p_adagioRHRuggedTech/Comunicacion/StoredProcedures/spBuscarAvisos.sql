USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Comunicacion].[spBuscarAvisos]
(
	@IDUsuario		INT
	, @dtPagination	[Nomina].[dtFiltrosRH] READONLY
    , @dtFiltros	[Nomina].[dtFiltrosRH] READONLY
)
AS
	BEGIN
		
		DECLARE @IDIdioma			VARCHAR(225)
				, @orderByColumn	VARCHAR(50) = 'Titulo'
				, @orderDirection	VARCHAR(4) = 'asc'
				, @IDAviso			INT = 0
				, @IDEstatus		INT = 0
				, @IDTipoAviso		INT = 0
				, @Search			VARCHAR(MAX) = ''
				, @SiteURL			VARCHAR(MAX)
				, @IdiomaAdjunto	VARCHAR(100)
				;    

		SELECT @IDIdioma = [App].[fnGetPreferencia]('Idioma', @IDUsuario, 'esmx');
		SELECT @orderByColumn = ISNULL(VALUE, 'IDEmpleado') FROM @dtPagination WHERE Catalogo = 'orderByColumn';
		SELECT @orderDirection = ISNULL(VALUE, 'asc') FROM @dtPagination WHERE Catalogo = 'orderDirection';

		SELECT @IDAviso		= ISNULL(VALUE, 0) FROM @dtFiltros WHERE Catalogo = 'IDAviso';
		SELECT @IDEstatus	= ISNULL(VALUE, 0) FROM @dtFiltros WHERE Catalogo = 'IDEstatus';
		SELECT @IDTipoAviso = ISNULL(VALUE, 0) FROM @dtFiltros WHERE Catalogo = 'IDTipoAviso';
		SELECT @Search		= ISNULL(VALUE,'') FROM @dtFiltros WHERE Catalogo = 'search';

		-- OBTENEMOS LA URL DEL SITIO
		SELECT TOP 1 @SiteURL = Valor 
		FROM [App].[tblConfiguracionesGenerales] WITH (NOLOCK)
		WHERE IDConfiguracion = 'Url';
        
		IF OBJECT_ID(N'tempdb..#TempSetPagination') IS NOT NULL
			BEGIN
				DROP TABLE #TempSetPagination
			END
			
		SET @IdiomaAdjunto = CASE
								WHEN @IDIdioma = 'es-MX'
									THEN 'El archivo no ha sido cargado'
									ELSE 'The file has not been uploaded'
								END;

		SELECT A.IDAviso
				, A.Titulo
				, A.Descripcion
				, A.DescripcionHTML,
				-- DownloaderFileGrls
				(
					'<ul>' + 
					(
						SELECT 
							'<li style="padding: 3px;"><a href="' + @SiteURL + JSON_VALUE([value], '$.PathFile') + '" download="' + JSON_VALUE([value], '$.Name') + '" style="text-decoration: underline; color: blue;">' + JSON_VALUE([value], '$.Name') + '</a></li>'
						FROM OPENJSON(A.FileAdjuntosGrls)
						FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') + '</ul>'
				) AS DownloaderFileGrls,
				-- DownloaderFileExpDig
				(
					'<ul>' + 
					(	
						SELECT
							'<li style="padding: 3px;">' + CASE WHEN TBL_EXP_DIG.PathFile <> '' THEN '<a href="' + @SiteURL + ISNULL(TBL_EXP_DIG.PathFile, '') + '" download="' + JSON_VALUE(ADJUNTO.[value], '$.text') + '" style="text-decoration: underline;color: blue;">' + JSON_VALUE(ADJUNTO.[value], '$.text') + '</a>' ELSE JSON_VALUE(ADJUNTO.[value], '$.text') + ' (' + @IdiomaAdjunto + ')' END + '</li>'
						FROM OPENJSON(A.FileAdjuntosExpDig) ADJUNTO
						LEFT JOIN
						(
							SELECT DISTINCT
									ISNULL(ED.IDExpedienteDigital, 0) AS IDExpedienteDigital
									, ISNULL(US.IDUsuario, 0) AS IDUsuario
									, ISNULL(ED.PathFile, '') AS PathFile
							FROM [RH].[TblExpedienteDigitalEmpleado] ED
								JOIN [Seguridad].[tblUsuarios] US ON ED.IDEmpleado = US.IDEmpleado
						) TBL_EXP_DIG ON CAST(JSON_VALUE(ADJUNTO.[value], '$.value') AS INT) = TBL_EXP_DIG.IDExpedienteDigital AND @IDUsuario = TBL_EXP_DIG.IDUsuario
						FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') + '</ul>'
				) AS DownloaderFileExpDig
				, A.FechaInicio
				, A.FechaFin
				, A.IsGeneral
				, A.Ubicacion
				, A.HoraInicio
				, EA.IDEstatus [IDEstatus]
				, EA.Variant [Variant]
				, TA.ClassStyle
				, A.TopPXToBanner
				, A.HeightPXToBanner
				, A.EnviarNotificacion
				, A.Enviado
				, A.FileJson
				, A.FileAdjuntosGrls
				, A.FileAdjuntosExpDig
				, JSON_VALUE(EA.Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE(@IDIdioma, '-', '')), 'Descripcion')) [Estatus]
				, TA.IDTipoAviso [IDTipoAviso]
				, JSON_VALUE(TA.Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE(@IDIdioma, '-', '')), 'Titulo')) [TipoAviso]
				--, TA.Titulo AS tt
				, ROW_NUMBER() OVER
					(
						ORDER BY
							CASE WHEN @orderByColumn = 'Titulo' AND @orderDirection = 'asc'	 THEN A.Titulo END,
							CASE WHEN @orderByColumn = 'Titulo' AND @orderDirection = 'desc' THEN A.Titulo END DESC
					) AS [row]
		INTO #TempSetPagination
		FROM [Comunicacion].[tblAvisos] A
			INNER JOIN [Comunicacion].[tblCatTiposAviso] TA ON TA.IDTipoAviso = A.IDTipoAviso
			INNER JOIN [Comunicacion].[tblCatEstatusAviso] EA ON EA.IDEstatus = A.IDEstatus
		WHERE (A.IDAviso = @IDAviso OR @IDAviso = 0)
				AND (A.IDEstatus = @IDEstatus OR @IDEstatus = 0)
				AND (A.IDTipoAviso = @IDTipoAviso OR @IDTipoAviso = 0)
				AND (@Search = '' OR (A.Titulo LIKE '%' + @Search + '%' OR A.Descripcion LIKE '%' + @Search + '%'))


		IF EXISTS(SELECT TOP 1 * FROM @dtPagination)
			BEGIN
				EXEC [Utilerias].[spAddPagination] @dtPagination = @dtPagination;
			END
		ELSE
			BEGIN
				SELECT * FROM #TempSetPagination ORDER BY ROW DESC
			END

END
GO
