USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Eliminar plantillas
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-03-04
** Paremetros		: @IDPlantilla			- Identificador de la plantilla.
					  @IDUsuario			- Identificador del usuario.
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE   PROCEDURE [Evaluacion360].[spBorrarPlantillas9Box]
(
	@IDPlantilla INT,
	@IDUsuario INT
)
AS	

	DECLARE	@ID_PLANTILLA_BASE INT = 1
			, @Error VARCHAR(MAX)
			, @OldJSON_Grl VARCHAR(MAX)
			, @OldJSON_Detalle VARCHAR(MAX)
			, @ContCuadro INT = 1
			;

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

	IF (@IDPlantilla = @ID_PLANTILLA_BASE)
		BEGIN				
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318009'
			RETURN;					
		END

	BEGIN TRY
		
		BEGIN TRAN
		
		IF EXISTS(SELECT IDPlantilla FROM [Evaluacion360].[tblCatPlantillas9Box] WHERE IDPlantilla = @IDPlantilla)
			BEGIN
				
				-- <AUDITORIA>
				SELECT @OldJSON_Grl = (SELECT * FROM [Evaluacion360].[tblCatPlantillas9Box] WHERE IDPlantilla = @IDPlantilla FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
				INSERT INTO @TblCuadrosOld
				SELECT * FROM [Evaluacion360].[tblDetalleCuadros9Box] WHERE IDPlantilla = @IDPlantilla;
				-- </AUDITORIA>


				DELETE [Evaluacion360].[tblDetalleCuadros9Box]
				WHERE IDPlantilla = @IDPlantilla

				DELETE [Evaluacion360].[tblCatPlantillas9Box] 
				WHERE IDPlantilla = @IDPlantilla

				IF @@ROWCOUNT = 1
						COMMIT TRAN
					ELSE
						ROLLBACK TRAN


				-- </AUDITORIA>					
					EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Evaluacion360].[tblCatPlantillas9Box]', '[Evaluacion360].[spBorrarPlantillas9Box]', 'DELETE', '', @OldJSON_Grl;

					WHILE @ContCuadro <= 9
					BEGIN						
						SELECT @OldJSON_Detalle = (SELECT * FROM @TblCuadrosOld WHERE NoCuadro = @ContCuadro FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);	
						EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Evaluacion360].[tblDetalleCuadros9Box]', '[Evaluacion360].[spBorrarPlantillas9Box]', 'DELETE', '', @OldJSON_Detalle;
							
						SET @ContCuadro = @ContCuadro + 1;
					END;
				-- </AUDITORIA>				

			END
		ELSE
			BEGIN
				EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318007';	
				RETURN
			END

	END TRY
	BEGIN CATCH		
		ROLLBACK TRAN;
			SELECT @Error = ERROR_MESSAGE();			
			RAISERROR(@Error, 16, 1);
	END CATCH
GO
