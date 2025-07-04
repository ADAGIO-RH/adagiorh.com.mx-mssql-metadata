USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE PROCOM.spBorrarMiembrosComisionMixta(
	@IDMiembroComisionMixta int,
	@IDUsuario int
)
AS
BEGIN
	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max),
	@IDCliente int

	BEGIN TRY  
		select @OldJSON =a.JSON from [Procom].[tblMiembrosComisionMixta] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDMiembroComisionMixta = @IDMiembroComisionMixta

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[tblMiembrosComisionMixta]','[Procom].[spBorrarMiembrosComisionMixta]','DELETE','',@OldJSON

		Delete [Procom].[tblMiembrosComisionMixta]  
		where IDMiembroComisionMixta = @IDMiembroComisionMixta
	END TRY  
		BEGIN CATCH  
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
			return 0;
	END CATCH ;
END
GO
