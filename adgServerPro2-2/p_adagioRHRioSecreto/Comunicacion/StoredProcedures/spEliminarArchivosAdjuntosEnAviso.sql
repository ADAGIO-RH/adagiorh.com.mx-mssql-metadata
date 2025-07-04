USE [p_adagioRHRioSecreto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Eliminar archivos adjuntos en aviso
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2025-03-10
** Parametros		: @IDAviso					Identificador del aviso
**					: @JsonArchivosGenerales	Lista de archivos generales
**					: @JsonArchivosGeneralesZip		Archivo generale ZIP
**					: @JsonAdjuntosExpDig		Lista de archivos de expediente digital
**					: @IsGeneral				Bandera que indica si los archivos a eliminar son generales o de expediente digital
**					: @IDUsuario	Identificador del usuario
** IDAzure			: 

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [Comunicacion].[spEliminarArchivosAdjuntosEnAviso](
	@IDAviso					INT
	, @JsonArchivosGenerales	NVARCHAR(MAX)
	, @JsonArchivosGeneralesZip	NVARCHAR(MAX)
	, @JsonAdjuntosExpDig		NVARCHAR(MAX)
	, @IsGeneral				BIT
	, @IDUsuario				INT
)
AS
	BEGIN
		
		DECLARE @FileAdjuntosGrls NVARCHAR(MAX)
				, @FileAdjuntosGrls_Zip NVARCHAR(MAX)
				, @SI BIT = 1;

		DECLARE @ArchivosGlsEnBD TABLE(
			[Name] NVARCHAR(MAX)
			, ContentType NVARCHAR(MAX)
			, PathFile NVARCHAR(MAX)
			, Size INT
		);
		
		DECLARE @ArchivosGlsEliminar TABLE(
			[Name] NVARCHAR(MAX)
		);

		DECLARE @ArchivosGlsEnBD_Zip TABLE(
			[Name] NVARCHAR(MAX)
			, ContentType NVARCHAR(MAX)
			, PathFile NVARCHAR(MAX)
			, Size INT
		)

		DECLARE @ArchivosGlsZipUptate TABLE(
			[Name] NVARCHAR(MAX)			
			, Size INT
		);


		IF(@IsGeneral = @SI)
			BEGIN
				
				SELECT @FileAdjuntosGrls = FileAdjuntosGrls
						, @FileAdjuntosGrls_Zip = FileAdjuntosGrlsZip	
				FROM [Comunicacion].[tblAvisos] WHERE IDAviso = @IDAviso;
				
				/* FILE ----------------------------------------------------------------*/

				INSERT INTO @ArchivosGlsEnBD
				SELECT 
					JSON_VALUE(value, '$.Name') AS Name,
					JSON_VALUE(value, '$.ContentType') AS ContentType,
					JSON_VALUE(value, '$.PathFile') AS PathFile,
					JSON_VALUE(value, '$.Size') AS Size
				FROM OPENJSON(@FileAdjuntosGrls);

				INSERT INTO @ArchivosGlsEliminar([Name])
				SELECT JSON_VALUE(value, '$.Name') AS [Name]
				FROM OPENJSON(@JsonArchivosGenerales);

				DELETE FROM @ArchivosGlsEnBD
				WHERE [Name] IN (SELECT [Name] FROM @ArchivosGlsEliminar);

				/* ZIP  ----------------------------------------------------------------*/

				INSERT INTO @ArchivosGlsEnBD_Zip
				SELECT 
					JSON_VALUE(value, '$.Name') AS Name,
					JSON_VALUE(value, '$.ContentType') AS ContentType,
					JSON_VALUE(value, '$.PathFile') AS PathFile,
					JSON_VALUE(value, '$.Size') AS Size
				FROM OPENJSON(@FileAdjuntosGrls_Zip);
								
				INSERT INTO @ArchivosGlsZipUptate
				SELECT 
					JSON_VALUE(value, '$.Name') AS Name,
					JSON_VALUE(value, '$.Size') AS Size
				FROM OPENJSON(@JsonArchivosGeneralesZip);

				UPDATE @ArchivosGlsEnBD_Zip
				SET Size = A.Size
				FROM @ArchivosGlsEnBD_Zip AG
					INNER JOIN @ArchivosGlsZipUptate A ON AG.[Name] = A.[Name];

				/* ----------------------------------------------------------------*/

				-- RESULTADO FINAL
				UPDATE [Comunicacion].[tblAvisos]
					SET FileAdjuntosGrls = REPLACE((SELECT * FROM @ArchivosGlsEnBD FOR JSON AUTO), '\/', '/')
						, FileAdjuntosGrlsZip = REPLACE((SELECT * FROM @ArchivosGlsEnBD_Zip FOR JSON AUTO), '\/', '/')
				WHERE IDAviso = @IDAviso;

			END
		ELSE
			BEGIN
				
				-- RESULTADO FINAL
				UPDATE [Comunicacion].[tblAvisos]
					SET FileAdjuntosExpDig = @JsonAdjuntosExpDig
				WHERE IDAviso = @IDAviso;

			END

	END
GO
