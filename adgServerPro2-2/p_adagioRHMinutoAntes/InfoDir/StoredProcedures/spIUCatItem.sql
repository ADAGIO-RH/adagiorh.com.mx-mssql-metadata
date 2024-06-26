USE [p_adagioRHMinutoAntes]
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
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
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
		
		DECLARE @OldJSON VARCHAR(MAX), @NewJSON VARCHAR(MAX);		
		
		IF(@IDConfItem = 0 OR @IDConfItem = NULL)
			BEGIN
				
				INSERT INTO [InfoDir].[tblCatItems]([IDTipoItem], [IDAplicacion], [IDDataSource], [Nombre], [Descripcion], [ConfFiltrosItem])
				VALUES(@IDTipoItem, @IDAplicacion, @IDDataSource, @Nombre, @Descripcion, @ConfFiltrosItem)

				/* BITACORA AUDITORIA */

				SET @IDConfItem = @@identity  

				SELECT @NewJSON = A.JSON 
				FROM [InfoDir].[tblCatItems] S
					CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT S.* FOR XML RAW)) ) A
				WHERE S.IDConfItem = @IDConfItem

				EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[InfoDir].[tblCatItems]', '[InfoDir].[spIUCatItem]', 'INSERT', @NewJSON, ''

			END
		ELSE
			BEGIN

				SELECT @OldJSON = A.JSON 
				FROM [InfoDir].[tblCatItems] S
					CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT S.* FOR XML RAW)) ) A
				WHERE S.IDConfItem = @IDConfItem


				UPDATE [InfoDir].[tblCatItems] SET [IDTipoItem] = @IDTipoItem,
												   [IDAplicacion] = @IDAplicacion,
												   [IDDataSource] = @IDDataSource,
												   [Nombre] = @Nombre,
												   [Descripcion] = @Descripcion,
												   [ConfFiltrosItem] = @ConfFiltrosItem
											   WHERE [IDConfItem] = @IDConfItem


				/* BITACORA AUDITORIA */

				SELECT @NewJSON = A.JSON 
				FROM [InfoDir].[tblCatItems] S
					CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT S.* FOR XML RAW)) ) A
				WHERE S.IDConfItem = @IDConfItem

				EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[InfoDir].[tblCatItems]', '[InfoDir].[spIUCatItem]', 'UPDATE', @NewJSON, @OldJSON

			END		
	END
GO
