USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarCatDatosExtraClientes]
(
	@IDCatDatoExtraCliente int 
	,@IDUsuario int
)
AS
BEGIN	

	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON = a.JSON from [RH].[tblCatDatosExtraClientes] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCatDatoExtraCliente = @IDCatDatoExtraCliente

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatDatosExtraClientes]','[RH].[spBorrarCatDatosExtraClientes]','DELETE','',@OldJSON




	EXEC [RH].[spBuscarCatDatosExtraClientes] @IDCatDatoExtraCliente

	DELETE RH.[tblCatDatosExtraClientes]
	WHERE IDCatDatoExtraCliente = @IDCatDatoExtraCliente

END
GO
