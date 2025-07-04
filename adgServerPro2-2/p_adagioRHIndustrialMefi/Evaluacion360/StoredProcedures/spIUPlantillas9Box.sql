USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************
** Descripción		: Insertar o actualizar plantillas 9Box
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-02-29
** Paremetros		: @IDPlantilla	- Identificador de la plantilla.
					  @Nombre		- Nombre de la plantilla.
					  @EjeX	-		- Cordenadas del eje x.
					  @EjeY			- Cordenadas del eje y.
					  @IsDefault	- Indica si la plantilla es una default
					  @Cuadros		- Cuadros del 9Box (detalle).
					  @IDUsuario	- Identificador de usuario
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE    PROCEDURE [Evaluacion360].[spIUPlantillas9Box](
	@IDPlantilla	INT = 0
	, @Nombre		VARCHAR(150) = NULL
	, @EjeX			NVARCHAR(MAX)
	, @EjeY			NVARCHAR(MAX)
	, @IsDefault	BIT
	, @Cuadros		NVARCHAR(MAX)
	, @IDUsuario	INT
)
AS
	
	SET FMTONLY OFF;

	DECLARE @ID_PLANTILLA_BASE INT = 1
			, @OldJSON_Grl VARCHAR(MAX)
			, @OldJSON_Detalle VARCHAR(MAX)
			, @NewJSON_Grl VARCHAR(MAX)
			, @NewJSON_Detalle VARCHAR(MAX)
			, @ContCuadro INT = 1
			, @Error VARCHAR(MAX)
			;

	DECLARE @TblCuadros TABLE(
		[IDCuadro] INT  NOT NULL
		, [NoCuadro] INT NOT NULL
		, [Traduccion] NVARCHAR(MAX) NOT NULL
		, [Coordenada_X_DE] DECIMAL(18,2) NOT NULL
		, [Coordenada_X_A] DECIMAL(18,2) NOT NULL
		, [Coordenada_Y_DE] DECIMAL(18,2) NOT NULL
		, [Coordenada_Y_A] DECIMAL(18,2) NOT NULL
		, [BackgroundColor] VARCHAR(50) NOT NULL
		, [Color] VARCHAR(50) NOT NULL
		, [IDPlantilla] INT NOT NULL
	)

	DECLARE @TblCuadrosOld TABLE(
		[IDCuadro] INT  NOT NULL
		, [NoCuadro] INT NOT NULL
		, [Traduccion] NVARCHAR(MAX) NOT NULL
		, [Coordenada_X_DE] DECIMAL(18,2) NOT NULL
		, [Coordenada_X_A] DECIMAL(18,2) NOT NULL
		, [Coordenada_Y_DE] DECIMAL(18,2) NOT NULL
		, [Coordenada_Y_A] DECIMAL(18,2) NOT NULL
		, [BackgroundColor] VARCHAR(50) NOT NULL
		, [Color] VARCHAR(50) NOT NULL
		, [IDPlantilla] INT NOT NULL
	)


	IF (@Nombre IS NULL OR @Nombre = '')
	BEGIN
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318006'
		RETURN;
	END

	IF (@IDPlantilla = @ID_PLANTILLA_BASE)
	BEGIN
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318008'
		RETURN;
	END


	BEGIN TRY
	
		BEGIN TRAN			
			
			-- OBTENEMOS LOS CUADROS DEL 9BOX
			INSERT INTO @TblCuadros
			SELECT IDCuadro
					, NoCuadro
					, Traduccion
					, Coordenada_X_DE
					, Coordenada_X_A
					, Coordenada_Y_DE
					, Coordenada_Y_A
					, BackgroundColor
					, Color
					, @IDPlantilla AS IDPlantilla
			FROM OPENJSON(@Cuadros)
			WITH (
				IDCuadro INT '$.IDCuadro'
				, NoCuadro INT '$.NoCuadro'
				, Traduccion NVARCHAR(MAX) '$.Traduccion'
				, Coordenada_X_DE FLOAT '$.Coordenada_X_DE'
				, Coordenada_X_A FLOAT '$.Coordenada_X_A'
				, Coordenada_Y_DE FLOAT '$.Coordenada_Y_DE'
				, Coordenada_Y_A FLOAT '$.Coordenada_Y_A'
				, BackgroundColor NVARCHAR(7) '$.BackgroundColor'
				, Color NVARCHAR(7) '$.Color'				
			) AS Cuadros;
			

			IF(@IDPlantilla = 0)
				BEGIN

					INSERT INTO [Evaluacion360].[tblCatPlantillas9Box] VALUES(@Nombre, @EjeX, @EjeY, @IsDefault)
					SET @IDPlantilla = @@IDENTITY

					IF @@ROWCOUNT = 1
						COMMIT TRAN
					ELSE
						ROLLBACK TRAN


					INSERT INTO [Evaluacion360].[tblDetalleCuadros9Box] (NoCuadro, Traduccion, Coordenada_X_DE, Coordenada_X_A, Coordenada_Y_DE, Coordenada_Y_A, BackgroundColor, Color, IDPlantilla)
					SELECT NoCuadro
							, Traduccion
							, Coordenada_X_DE
							, Coordenada_X_A
							, Coordenada_Y_DE
							, Coordenada_Y_A
							, BackgroundColor
							, Color
							, @IDPlantilla 
					FROM @TblCuadros;
					
					-- <AUDITORIA>
					SELECT @NewJSON_Grl = (SELECT * FROM [Evaluacion360].[tblCatPlantillas9Box] WHERE IDPlantilla = @IDPlantilla FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
					EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Evaluacion360].[tblCatPlantillas9Box]', '[Evaluacion360].[spIUPlantillas9Box]', 'INSERT', @NewJSON_Grl, '';
										
					WHILE @ContCuadro <= 9
					BEGIN
						SELECT @NewJSON_Detalle = (SELECT * FROM [Evaluacion360].[tblDetalleCuadros9Box] WHERE IDPlantilla = @IDPlantilla AND NoCuadro = @ContCuadro FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
						EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Evaluacion360].[tblDetalleCuadros9Box]', '[Evaluacion360].[spIUPlantillas9Box]', 'INSERT', @NewJSON_Detalle, '';
						SET @ContCuadro = @ContCuadro + 1;
					END;
					-- </AUDITORIA>
					
				END
			ELSE
				BEGIN

					IF EXISTS(SELECT IDPlantilla FROM [Evaluacion360].[tblCatPlantillas9Box] WHERE IDPlantilla = @IDPlantilla)
						BEGIN							
							
							-- <AUDITORIA>
							SELECT @OldJSON_Grl = (SELECT * FROM [Evaluacion360].[tblCatPlantillas9Box] WHERE IDPlantilla = @IDPlantilla FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
							INSERT INTO @TblCuadrosOld
							SELECT * FROM [Evaluacion360].[tblDetalleCuadros9Box] WHERE IDPlantilla = @IDPlantilla;
							-- </AUDITORIA>

							
							UPDATE [Evaluacion360].[tblCatPlantillas9Box]
								SET Nombre = @Nombre
									, EjeX = @EjeX
									, EjeY = @EjeY
								WHERE IDPlantilla = @IDPlantilla;

							IF @@ROWCOUNT = 1
								COMMIT TRAN
							ELSE
								ROLLBACK TRAN
							

							UPDATE TBL_DESTINO
							SET TBL_DESTINO.Traduccion			= TBL_ORIGEN.Traduccion
								, TBL_DESTINO.Coordenada_X_DE	= TBL_ORIGEN.Coordenada_X_DE
								, TBL_DESTINO.Coordenada_X_A	= TBL_ORIGEN.Coordenada_X_A
								, TBL_DESTINO.Coordenada_Y_DE	= TBL_ORIGEN.Coordenada_Y_DE
								, TBL_DESTINO.Coordenada_Y_A	= TBL_ORIGEN.Coordenada_Y_A
								, TBL_DESTINO.BackgroundColor	= TBL_ORIGEN.BackgroundColor
								, TBL_DESTINO.Color = TBL_ORIGEN.Color
							FROM [Evaluacion360].[tblDetalleCuadros9Box] TBL_DESTINO
								JOIN @TblCuadros TBL_ORIGEN ON TBL_DESTINO.IDCuadro = TBL_ORIGEN.IDCuadro
							WHERE TBL_DESTINO.IDPlantilla = @IDPlantilla;
							
							-- </AUDITORIA>
							SELECT @NewJSON_Grl = (SELECT * FROM [Evaluacion360].[tblCatPlantillas9Box] WHERE IDPlantilla = @IDPlantilla FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
							IF(@NewJSON_Grl <> @OldJSON_Grl)
								BEGIN
									EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Evaluacion360].[tblCatPlantillas9Box]', '[Evaluacion360].[spIUPlantillas9Box]', 'UPDATE', @NewJSON_Grl, @OldJSON_Grl;
								END

							WHILE @ContCuadro <= 9
							BEGIN
								SELECT @NewJSON_Detalle = (SELECT * FROM @TblCuadros WHERE NoCuadro = @ContCuadro FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
								SELECT @OldJSON_Detalle = (SELECT * FROM @TblCuadrosOld WHERE NoCuadro = @ContCuadro FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
								IF(@NewJSON_Detalle <> @OldJSON_Detalle)
									BEGIN
										EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Evaluacion360].[tblDetalleCuadros9Box]', '[Evaluacion360].[spIUPlantillas9Box]', 'UPDATE', @NewJSON_Detalle, @OldJSON_Detalle;
									END
								SET @ContCuadro = @ContCuadro + 1;
							END;
							-- </AUDITORIA>
														
						END
					ELSE
						BEGIN							
							EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318007'
							RETURN;
						END
				END

	END TRY
		BEGIN CATCH
			ROLLBACK TRAN
				SELECT @Error = ERROR_MESSAGE()
				RAISERROR(@Error, 16, 1); 				
		END CATCH
GO
