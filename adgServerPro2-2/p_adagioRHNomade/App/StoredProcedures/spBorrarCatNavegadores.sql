USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [APP].[spBorrarCatNavegadores]
(
	@IDNavegador INT,
	@IDUsuario INT
)
AS
BEGIN

    EXEC [APP].[spBuscarNavegadores] @IDNavegador, @IDUsuario;
	   
	DECLARE @OldJSON VARCHAR(MAX),
	@NewJSON VARCHAR(MAX)

	SELECT @OldJSON = a.JSON FROM [APP].[tblNavegadores] n
	CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT n.* FOR XML RAW)) ) a
	WHERE n.IDNavegador = @IDNavegador

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[APP].[tblNavegadores]','[APP].[spBorrarCatNavegadores]','DELETE','',@OldJSON

    BEGIN TRY  
	    DELETE [APP].[tblNavegadores] 
	    WHERE IDNavegador = @IDNavegador
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;
	
END
GO
