USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarCatTipoJornada]
(
	@IDTipoJornada int,
	@IDUsuario int 
)
AS
BEGIN

	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	select @OldJSON = a.JSON from [RH].[tblCatTipoJornada] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDTipoJornada = @IDTipoJornada

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatTipoJornada]','[RH].[spBorrarCatTipoJornada]','DELETE','',@OldJSON

	Delete [RH].[tblCatTipoJornada] 
	WHERE IDTipoJornada = @IDTipoJornada
		
END
GO
