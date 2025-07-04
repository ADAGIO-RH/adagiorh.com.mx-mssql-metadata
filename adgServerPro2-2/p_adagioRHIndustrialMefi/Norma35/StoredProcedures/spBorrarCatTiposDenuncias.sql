USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Norma35].[spBorrarCatTiposDenuncias]
(
	 @IDTipoDenuncia INT 
	,@IDUsuario INT
)
AS
BEGIN
	DECLARE @OldJSON Varchar(Max);

	select @OldJSON = a.JSON from  [Norma35].[tblCatTiposDenuncias] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDTipoDenuncia = @IDTipoDenuncia

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Norma35].[tblCatTiposDenuncias]','[Norma35].[spBorrarCatTiposDenuncias]','DELETE','',@OldJSON

	DELETE FROM [Norma35].[tblCatTiposDenuncias]
    WHERE IDTipoDenuncia = @IDTipoDenuncia

END;
GO
