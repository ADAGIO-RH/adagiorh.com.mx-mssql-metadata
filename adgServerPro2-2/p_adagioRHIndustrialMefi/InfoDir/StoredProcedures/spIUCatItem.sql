USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Inserta ó actualiza un item (metrica, indicador, kpi)
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2022-04-18
** Paremetros		: @IDConfItem
**					: @IDTipoItem
**					: @IDAplicacion
**					: @IDDataSource
**					: @Nombre
**					: @Descripcion
**					: @ConfFiltrosItem
**					: @IDUsuario
** IDAzure			: 814

** DataTypes Relacionados: 

** Reglas de Negocio: Toda solicitud que utilice este procedimiento almacenado (SP) debe cumplir con las siguientes condiciones:
	1.- Prefijo del IDConfItem: El campo IDConfItem debe comenzar con el prefijo "2".
	2.- Campo Personalizado: El campo Personalizado debe estar establecido en TRUE.

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
2024-08-22			Alejandro Paredes	Se agrego el valor a la columna "Persinalizado"
***************************************************************************************************/

CREATE PROC [InfoDir].[spIUCatItem]
(
	@IDConfItem INT = 0,
	@IDTipoItem INT,
	@IDAplicacion NVARCHAR(100),
	@IDDataSource INT,
	@Nombre VARCHAR(100),
	@Descripcion VARCHAR(255),
	@ConfFiltrosItem NVARCHAR(MAX),
	@IDUsuario INT	
)
AS
	BEGIN  
		
		DECLARE 
			@OldJSON VARCHAR(MAX)
			, @NewJSON VARCHAR(MAX)
			, @PREFIJO INT = 2
			, @PERSONALIZADO BIT = 1
			, @NuevoID VARCHAR(20)
			;		
		
		IF(@IDConfItem = 0 OR @IDConfItem = NULL)
			BEGIN

				-- GENERAR NUEVO ID CON PREFIJO
				EXEC [InfoDir].[fnGenerarNuevoIDConPrefijo] 
					@Prefijo		= @PREFIJO
					, @Tabla		= '[InfoDir].[TblCatItems]'
					, @ColumnaID	= 'IDConfItem'
					, @NuevoID		= @NuevoID OUTPUT
					, @IDUsuario	= @IDUsuario;
				--SELECT @NuevoID AS NuevoID;
				
				INSERT INTO [InfoDir].[tblCatItems](IDConfItem, IDTipoItem, IDAplicacion, IDDataSource, Nombre, Descripcion, ConfFiltrosItem, PERSONALIZADO)
				VALUES(@NuevoID, @IDTipoItem, @IDAplicacion, @IDDataSource, @Nombre, @Descripcion, @ConfFiltrosItem, @PERSONALIZADO)

				/* BITACORA AUDITORIA */

				SET @IDConfItem = @NuevoID  

				SELECT @NewJSON =(SELECT IDConfItem
                            , IDTipoItem
                            , IDAplicacion
                            , IDDataSource
                            , Nombre
                            , Descripcion
                            , ConfFiltrosItem
                            , PERSONALIZADO
                            FROM  [InfoDir].[tblCatItems]
                            WHERE IDConfItem = @IDConfItem FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
				
				EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[InfoDir].[tblCatItems]', '[InfoDir].[spIUCatItem]', 'INSERT', @NewJSON, ''

			END
		ELSE
			BEGIN

				SELECT @OldJSON =(SELECT IDConfItem
                            , IDTipoItem
                            , IDAplicacion
                            , IDDataSource
                            , Nombre
                            , Descripcion
                            , ConfFiltrosItem
                            , PERSONALIZADO
                            FROM  [InfoDir].[tblCatItems]
                            WHERE IDConfItem = @IDConfItem FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)


				UPDATE [InfoDir].[tblCatItems] SET [IDTipoItem] = @IDTipoItem,
												   [IDAplicacion] = @IDAplicacion,
												   [IDDataSource] = @IDDataSource,
												   [Nombre] = @Nombre,
												   [Descripcion] = @Descripcion,
												   [ConfFiltrosItem] = @ConfFiltrosItem
											   WHERE [IDConfItem] = @IDConfItem


				/* BITACORA AUDITORIA */

				SELECT @NewJSON =(SELECT IDConfItem
                            , IDTipoItem
                            , IDAplicacion
                            , IDDataSource
                            , Nombre
                            , Descripcion
                            , ConfFiltrosItem
                            , PERSONALIZADO
                            FROM  [InfoDir].[tblCatItems]
                            WHERE IDConfItem = @IDConfItem FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

				EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[InfoDir].[tblCatItems]', '[InfoDir].[spIUCatItem]', 'UPDATE', @NewJSON, @OldJSON

			END		
	END
GO
