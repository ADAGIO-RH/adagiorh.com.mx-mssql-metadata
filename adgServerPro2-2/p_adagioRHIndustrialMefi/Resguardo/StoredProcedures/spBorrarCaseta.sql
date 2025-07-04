USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Resguardo].[spBorrarCaseta](
	@IDCaseta int 
	,@IDUsuario int
) as
	
	BEGIN TRY  
		DELETE [Resguardo].[tblCatCasetas]
		WHERE IDCaseta = @IDCaseta
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;
GO
