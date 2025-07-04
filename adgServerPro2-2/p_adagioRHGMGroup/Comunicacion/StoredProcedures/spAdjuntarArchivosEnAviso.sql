USE [p_adagioRHGMGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Adjunta los archivos generales y archivos de expedientes digital a los comunicados
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2025-03-06
** Parametros		: @IDAviso						Identificador del aviso (comunicado)
**					: @JsonArchivosGenerales		Lista de archivos generales
**					: @JsonArchivosGeneralesZip		Archivo generale ZIP
**					: @JsonAdjuntosExpDig			Lista de archivos de expediente digital
**					: @IDUsuario					Identificador del usuario
** IDAzure			: #1386

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [Comunicacion].[spAdjuntarArchivosEnAviso](
	@IDAviso						INT
	, @JsonArchivosGenerales		NVARCHAR(MAX)
	, @JsonArchivosGeneralesZip		NVARCHAR(MAX)
	, @JsonAdjuntosExpDig			NVARCHAR(MAX)
	, @IDUsuario					INT
)
AS
	BEGIN
		
		-- DECLARACION DE VARIABLES
		DECLARE @FileAdjuntosGrls NVARCHAR(MAX);

		DECLARE @ArchivosGlsEnBD TABLE(
			[Name] NVARCHAR(MAX)
			, ContentType NVARCHAR(MAX)
			, PathFile NVARCHAR(MAX)
			, Size INT
		);

		DECLARE @ArchivosGlsNuevos TABLE(
			[Name] NVARCHAR(MAX)
			, ContentType NVARCHAR(MAX)
			, PathFile NVARCHAR(MAX)
			, Size INT
		);		


		IF EXISTS(SELECT IDAviso FROM [Comunicacion].[tblAvisos] WHERE IDAviso = @IDAviso)  
			BEGIN
								
				SELECT @FileAdjuntosGrls = FileAdjuntosGrls FROM [Comunicacion].[tblAvisos] WHERE IDAviso = @IDAviso;
								
				INSERT INTO @ArchivosGlsEnBD
				SELECT 
					JSON_VALUE(value, '$.Name') AS Name,
					JSON_VALUE(value, '$.ContentType') AS ContentType,
					JSON_VALUE(value, '$.PathFile') AS PathFile,
					JSON_VALUE(value, '$.Size') AS Size
				FROM OPENJSON(@FileAdjuntosGrls);
								
				INSERT INTO @ArchivosGlsNuevos
				SELECT 
					JSON_VALUE(value, '$.Name') AS Name,
					JSON_VALUE(value, '$.ContentType') AS ContentType,
					JSON_VALUE(value, '$.PathFile') AS PathFile,
					JSON_VALUE(value, '$.Size') AS Size
				FROM OPENJSON(@JsonArchivosGenerales);

				DELETE FROM @ArchivosGlsEnBD
				WHERE [Name] IN (SELECT [Name] FROM @ArchivosGlsNuevos);

				INSERT INTO @ArchivosGlsEnBD ([Name], ContentType, PathFile, Size)
				SELECT [Name], ContentType, PathFile, Size FROM @ArchivosGlsNuevos;				

				UPDATE [Comunicacion].[tblAvisos]
					SET FileAdjuntosGrls = REPLACE((SELECT * FROM @ArchivosGlsEnBD FOR JSON AUTO), '\/', '/')
						, FileAdjuntosGrlsZip = CASE 
													WHEN JSON_VALUE(@JsonArchivosGeneralesZip, '$[0].Name') IS NOT NULL
														THEN @JsonArchivosGeneralesZip 
														ELSE FileAdjuntosGrlsZip 
													END
						, FileAdjuntosExpDig = @JsonAdjuntosExpDig
				WHERE IDAviso = @IDAviso;

			END
	END
GO
