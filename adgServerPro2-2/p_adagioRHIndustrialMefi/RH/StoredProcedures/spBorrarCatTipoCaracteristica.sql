USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc RH.spBorrarCatTipoCaracteristica(
	@IDTipoCaracteristica int,
	@IDUsuario int
) as
	
	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	select @OldJSON = a.JSON from RH.tblCatTiposCaracteristicas b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDTipoCaracteristica = @IDTipoCaracteristica;

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'RH.tblCatTiposCaracteristicas','RH.spIUCatTipoCaracteristica','DELETE','',@OldJSON
	
    BEGIN TRY  
		DELETE RH.tblCatTiposCaracteristicas
		WHERE IDTipoCaracteristica = @IDTipoCaracteristica
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;
GO
