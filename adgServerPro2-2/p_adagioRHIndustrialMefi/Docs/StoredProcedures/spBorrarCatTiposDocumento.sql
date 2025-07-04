USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Docs].[spBorrarCatTiposDocumento]
(
	@IDTipoDocumento int 
	,@IDUsuario int
)
AS
BEGIN
	Exec Docs.spBuscarCatTiposDocumento @IDTipoDocumento= @IDTipoDocumento, @IDUsuario = @IDUsuario
	
	BEGIN TRY  
	Delete Docs.tblCatTiposDocumento
	where IDTipoDocumento = @IDTipoDocumento

	
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;

END
GO
