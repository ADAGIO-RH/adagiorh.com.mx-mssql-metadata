USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarCatDatosExtra]
(
	@IDDatoExtra int 
	,@IDUsuario int
)
AS
BEGIN	

	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON = a.JSON from [RH].[tblCatDatosExtra] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDatoExtra = @IDDatoExtra

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatDatosExtra]','[RH].[spBorrarCatDatosExtra]','DELETE','',@OldJSON




	EXEC RH.spBuscarCatDatosExtra @IDDatoExtra

	DELETE RH.tblCatDatosExtra
	WHERE IDDatoExtra = @IDDatoExtra

END
GO
