USE [p_adagioRHSurfax]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2022-02-02
** Paremetros:		:

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2025-03-24			Alejandro Paredes	Se agregaron los adjuntos .zip
***************************************************************************************************/

CREATE   PROCEDURE [Comunicacion].[spBuscarEmpleadosForEnvioNotificacion]
(
	@IDAviso		INT = 0
	, @IDUsuario	INT = 0
	, @Reenviar		BIT = 0
	, @IDEmpleado	INT = 0	
)
AS
	BEGIN
		
		DECLARE @SiteURL					VARCHAR(MAX)
				-- TEMPLATE BASE
				, @Container				VARCHAR(MAX) = ''
				, @Head						VARCHAR(MAX) = ''
				, @Body						VARCHAR(MAX) = ''
				, @Footer					VARCHAR(MAX) = ''
				, @HeadCustomer				VARCHAR(MAX) = ''
				, @BodyCustomerContainer	VARCHAR(MAX) = ''
				, @FooterCustomer			VARCHAR(MAX) = ''
				, @CloseDiv					VARCHAR(MAX) = ''
				, @FooterCustomerGral		NVARCHAR(MAX) = ''
				, @CONTAINER_DEFAULT		INT = 1
				-- HTML COMUNICADO
				, @htmlbody					VARCHAR (MAX)
				, @subject					VARCHAR (MAX)
				, @isGeneral				BIT
				, @FileAdjuntosGrls			NVARCHAR(MAX)
				, @FileAdjuntosExpDig		NVARCHAR(MAX)
				-- 
				, @SI						BIT = 1
				;

		
		-- TABLA TEMPORALES
		
		DECLARE @TblFileAdjuntosExpDig TABLE(
			IDExpedienteDigital	INT
			, [Name]			NVARCHAR(MAX)
		)

		DECLARE @TblComunicados TABLE(
			IDMedioNotificacion		VARCHAR(5)
			, Destinatario			NVARCHAR(100)
			, IDUsuario				INT
			, IDEmpleado			INT
			, [Subject]				VARCHAR(100)
			, IDAviso				INT
			, ClaveEmpleado			VARCHAR(30)
			, FilesAdjuntosGrls		NVARCHAR(MAX)
			, FilesAdjuntosExpDig	NVARCHAR(MAX)
		)

		-- OBTENEMOS LA URL DEL SITIO
		SELECT TOP 1 @SiteURL = Valor
		FROM App.tblConfiguracionesGenerales WITH (NOLOCK)
		WHERE IDConfiguracion = 'Url';
		--SELECT @SiteURL

		-- OBTENEMOS EL FOOTER DEL CLIENTE
		SELECT @FooterCustomerGral = Valor FROM App.tblConfiguracionesGenerales WHERE IDConfiguracion = 'FooterEmails';

		-- OBTENEMOS LA ESTRUCTURA DEL TEMPLATE BASE
		SELECT @Container = Container
				, @Head = Head
				, @Body = Body
				, @Footer = Footer
				, @HeadCustomer = HeadCustomer
				, @BodyCustomerContainer = BodyCustomerContainer
				, @FooterCustomer = REPLACE(CAST(FooterCustomer AS VARCHAR(MAX)), '{footerCustomer}', @FooterCustomerGral) + CAST(CloseDiv AS VARCHAR(10))
				, @CloseDiv = CloseDiv
		FROM [App].[tblTemplateContainersEmail]
		WHERE IDContainer = @CONTAINER_DEFAULT


		-- HTML COMUNICADO
		SET @subject='Avisos';
		SELECT @isGeneral = V.isGeneral
				, @htmlbody = '<h1>' + V.Titulo + '</h1><br>' +
							  CASE WHEN V.IDTipoAviso = 1
								THEN '<small>' + V.Ubicacion + ' / ' + FORMAT (V.FechaInicio, 'MMM dd yyyy') + ' / ' + FORMAT(CAST(V.HoraInicio AS DATETIME), 'hh:mm:ss tt') + '</small><br>'
								ELSE ''
							  END + V.DescripcionHTML
				, @subject = CASE WHEN V.IDTipoAviso = 1
								THEN 'Proximo Evento'
								ELSE 'Comunicado de la Empresa'
							  END
				, @FileAdjuntosGrls = FileAdjuntosGrls
				, @FileAdjuntosExpDig = FileAdjuntosExpDig
		FROM [Comunicacion].[tblAvisos] V
		WHERE V.IDAviso = @IDAviso;


		-- ARCHIVOS ADJUNTOS EXPEDIENTE DIGITAL
		INSERT INTO @TblFileAdjuntosExpDig(IDExpedienteDigital, [Name])
		SELECT [value]
				, [text]
		FROM OPENJSON(@FileAdjuntosExpDig)
		WITH (
			[value] INT '$.value'
			, [text] NVARCHAR(MAX) '$.text'
		) AS json_data;
		--SELECT * FROM @TblFileAdjuntosExpDig
		


		-- BUSCAMOS COMUNICADOS
		IF(@isGeneral = 1)
			BEGIN

				INSERT INTO @TblComunicados(IDMedioNotificacion, Destinatario, IDUsuario, IDEmpleado, [Subject], IDAviso, ClaveEmpleado, FilesAdjuntosGrls, FilesAdjuntosExpDig)
				SELECT 'Email' AS IDMedioNotificacion
						, [Utilerias].[fnGetCorreoEmpleado](M.IDEmpleado, U.IDUsuario, 'NuevoAviso') AS Destinatario
						, CAST(U.IDUsuario AS INT) AS IDUsuario
						, CAST(M.IDEmpleado AS INT) AS IDEmpleado
						, @subject AS [Subject]
						, @IDAviso AS IDAviso
						, M.ClaveEmpleado
						, @FileAdjuntosGrls AS FilesAdjuntosGrls
						, (
							SELECT ISNULL(AED.IDExpedienteDigital, 0) AS IDExpedienteDigital									
									, AED.[Name] + CASE WHEN EDE.[Name] IS NULL THEN CASE WHEN ([App].[fnGetPreferencia]('Idioma', U.IDUsuario, 'esmx') = 'es-MX') THEN ' (El archivo no ha sido cargado)' ELSE ' (The file has not been uploaded)' END ELSE '' END AS [Name]
									, ISNULL(EDE.PathFile, '') AS PathFile
							FROM @TblFileAdjuntosExpDig AED
								LEFT JOIN [RH].[TblExpedienteDigitalEmpleado] EDE ON AED.IDExpedienteDigital = EDE.IDExpedienteDigital AND EDE.IDEmpleado = CAST(M.IDEmpleado AS INT)
							FOR JSON PATH
						  ) FilesAdjuntosExpDig
				FROM [RH].[tblEmpleadosMaster] M
					JOIN [Seguridad].[tblUsuarios] U ON M.IDEmpleado = U.IDEmpleado
				WHERE M.Vigente = 1
						AND ((@Reenviar = @SI AND M.IDEmpleado = @IDEmpleado) OR (@Reenviar <> @SI))
						--AND U.IDUsuario = 22291 -- COMENTAR LINEA (SE USA PARA PRUEBAS)
				
			END
		ELSE
			BEGIN
			
				INSERT INTO @TblComunicados(IDMedioNotificacion, Destinatario, IDUsuario, IDEmpleado, [Subject], IDAviso, ClaveEmpleado, FilesAdjuntosGrls, FilesAdjuntosExpDig)
				SELECT 'Email' AS IDMedioNotificacion
						, [Utilerias].[fnGetCorreoEmpleado](M.IDEmpleado, U.IDUsuario, 'NuevoAviso') AS Destinatario
						, CAST(U.IDUsuario AS INT) AS IDUsuario
						, CAST(M.IDEmpleado AS INT) AS IDEmpleado
						, @subject AS [Subject]
						, @IDAviso AS IDAviso
						, M.ClaveEmpleado
						, @FileAdjuntosGrls AS FilesAdjuntosGrls
						, (
							SELECT ISNULL(AED.IDExpedienteDigital, 0) AS IDExpedienteDigital
									, AED.[Name] + CASE WHEN EDE.[Name] IS NULL THEN CASE WHEN ([App].[fnGetPreferencia]('Idioma', U.IDUsuario, 'esmx') = 'es-MX') THEN ' (El archivo no ha sido cargado)' ELSE ' (The file has not been uploaded)' END ELSE '' END AS [Name]
									, ISNULL(EDE.PathFile, '') AS PathFile
							FROM @TblFileAdjuntosExpDig AED
								LEFT JOIN [RH].[TblExpedienteDigitalEmpleado] EDE ON AED.IDExpedienteDigital = EDE.IDExpedienteDigital AND EDE.IDEmpleado = CAST(M.IDEmpleado AS INT)
							FOR JSON PATH
						  ) FilesAdjuntosExpDig
				FROM [RH].[tblEmpleadosMaster] M
					JOIN [Comunicacion].[tblEmpleadosAvisos] EA ON EA.IDEmpleado = M.IDEmpleado AND EA.IDAviso = @IDAviso
					JOIN [Seguridad].[tblUsuarios] U ON M.IDEmpleado = U.IDEmpleado
				WHERE M.Vigente = 1
						AND ((@Reenviar = @SI AND M.IDEmpleado = @IDEmpleado) OR (@Reenviar <> @SI))
						--AND U.IDUsuario = 22291 -- COMENTAR LINEA (SE USA PARA PRUEBAS)

			END
		--SELECT * FROM @TblComunicados


		/*
		-- EJEMPLO DE ENSAMBLADO HTML
			(
				-- BODY
				REPLACE(@Container, '{pixelesWidth}', 600)
					+ @Head
					+ @HeadCustomer
					+ @Body
					+ REPLACE(@BodyCustomerContainer, '{bodyCustomer}', @htmlbody) + @CloseDiv
					+ @DownloaderFileGrls
					+ @DownloaderFileExpDig
					+ @CloseDiv
				-- FOOTER
				+ REPLACE(@Container, '{pixelesWidth}', 600)
					+ @FooterCustomer
					+ @Footer
					+ @CloseDiv
			)
		*/

		
		-- RESULTADO FINAL
		SELECT COMUNICADO.IDMedioNotificacion
				, COMUNICADO.Destinatario
				--, 'aparedes@adagio.com.mx' AS Destinatario -- COMENTAR LINEA (SE USA PARA PRUEBAS)
				, COMUNICADO.IDEmpleado
				, COMUNICADO.IDUsuario
				, COMUNICADO.[Subject]
				, COMUNICADO.IDAviso
				, COMUNICADO.ClaveEmpleado
				, COMUNICADO.FilesAdjuntosExpDig
				, (
					-- BODY
					REPLACE(@Container, '{pixelesWidth}', 800)
						+ @Head
						+ @HeadCustomer
						+ @Body
						+ REPLACE(@BodyCustomerContainer, '{bodyCustomer}', @htmlbody) + @CloseDiv
						+ -- DownloaderFileGrls
						CASE 
							WHEN COMUNICADO.FilesAdjuntosGrls IS NOT NULL 
								THEN 
									(
										'<ul class="listaDownloader">' +
											ISNULL(
													(
														SELECT
															'<li style="padding: 3px;"><a href="' + @SiteURL + REPLACE(JSON_VALUE([value], '$.PathFile'), ' ', '%20') + '" download="' + JSON_VALUE([value], '$.Name') + '" style="text-decoration: underline; color: blue;">' + JSON_VALUE([value], '$.Name') + '</a></li>'
														FROM OPENJSON(COMUNICADO.FilesAdjuntosGrls)
														FOR XML PATH(''), TYPE
													).value('.', 'NVARCHAR(MAX)')
											, '') + '</ul>'
									)
								ELSE ''
							END
						+ -- DownloaderFileExpDig
						CASE 
							WHEN COMUNICADO.FilesAdjuntosExpDig IS NOT NULL 
								THEN 
									(																			
										'<ul class="listaDownloader">' +
											ISNULL(
													(
														SELECT
															'<li style="padding: 3px;"><a href="' + @SiteURL + REPLACE(JSON_VALUE([value], '$.PathFile'), ' ', '%20') + '" download="' + JSON_VALUE([value], '$.Name') + '" style="text-decoration: underline; color: blue;">' + JSON_VALUE([value], '$.Name') + '</a></li>'
														FROM OPENJSON(COMUNICADO.FilesAdjuntosExpDig)
														WHERE JSON_VALUE([value], '$.PathFile') <> ''
														FOR XML PATH(''), TYPE
													).value('.', 'NVARCHAR(MAX)')
											, '') + '</ul>'
										+
										'<ul>' +
											ISNULL(
													(
														SELECT
															'<li style="padding: 3px;">' + JSON_VALUE([value], '$.Name') + '</li>'
														FROM OPENJSON(COMUNICADO.FilesAdjuntosExpDig)
														WHERE JSON_VALUE([value], '$.PathFile') = ''
														FOR XML PATH(''), TYPE
													).value('.', 'NVARCHAR(MAX)')
											, '') + '</ul>'
									)
								ELSE ''
							END
						+ @CloseDiv
					-- FOOTER
					+ REPLACE(@Container, '{pixelesWidth}', 600)
						+ @FooterCustomer
						+ @Footer
						+ @CloseDiv
				  ) AS [Body]
		FROM @TblComunicados COMUNICADO
		--WHERE COMUNICADO.ClaveEmpleado IN ('015104', '008877', '001285') -- COMENTAR LINEA (SE USA PARA PRUEBAS)
		ORDER BY COMUNICADO.IDEmpleado ASC
		

END
GO
