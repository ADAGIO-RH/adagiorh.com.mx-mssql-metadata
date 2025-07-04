USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Elimina la configuracion del item solicitado
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2022-04-20
** Paremetros		: @IDTipoItem
** IDAzure			: 814

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROC [InfoDir].[spBorrarCatItems]
(
	@IDConfItem INT,
	@IDUsuario INT
)
AS
BEGIN
	   
	DECLARE @OldJSON VARCHAR(MAX),
	@NewJSON VARCHAR(MAX)

	SELECT @OldJSON = (SELECT IDConfItem
                            , IDTipoItem
                            , IDAplicacion
                            , IDDataSource
                            , Nombre
                            , Descripcion
                            , ConfFiltrosItem
                            , PERSONALIZADO
                            FROM  [InfoDir].[tblCatItems]
                            WHERE IDConfItem = @IDConfItem FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

    --  A.JSON FROM [InfoDir].[tblCatItems] I
	-- CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT I.* FOR XML RAW)) ) A
	-- WHERE I.IDConfItem = @IDConfItem
		
	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[InfoDir].[tblCatItems]','[InfoDir].[spBorrarCatItems]', 'DELETE', '', @OldJSON

    BEGIN TRY  
	    DELETE [InfoDir].[tblCatItems] 
	    WHERE IDConfItem = @IDConfItem
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;
	
END
GO
