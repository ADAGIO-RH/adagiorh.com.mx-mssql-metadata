USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Norma35].[spBorrarTipoDenunciasNotificaciones]
(
	 @IDTipoDenunciasNotificacion INT 
	,@IDUsuario INT
)
AS
BEGIN
	DECLARE @OldJSON Varchar(Max);

	select @OldJSON = a.JSON from  [Norma35].[tblTipoDenunciasNotificaciones] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.[IDTipoDenunciasNotificacion] = @IDTipoDenunciasNotificacion

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Norma35].[tblTipoDenunciasNotificaciones]','[Norma35].[spBorrarTipoDenunciasNotificaciones]','DELETE','',@OldJSON


	DELETE FROM [Norma35].[tblTipoDenunciasNotificaciones]
	WHERE [IDTipoDenunciasNotificacion] = @IDTipoDenunciasNotificacion

END;
GO
