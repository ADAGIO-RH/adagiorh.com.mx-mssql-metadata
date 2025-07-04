USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarCatDocumentos]
(
	@IDDocumento Varchar(max) = null,
	@IDUsuario int
)
AS
BEGIN

	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON = a.JSON from [RH].[tblCatDocumentos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDocumento = @IDDocumento

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatDocumentos]','[RH].[spBorrarCatDocumentos]','DELETE','',@OldJSON

	DELETE [RH].[tblCatDocumentos]
	WHERE IDDocumento = @IDDocumento
END
GO
