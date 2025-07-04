USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [RH].[spBorrarCarpetasExpedienteDigital](
	@IDCarpetaExpedienteDigital int 
	,@IDUsuario int 
)
AS
BEGIN
	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

	    select @OldJSON = a.JSON from RH.[tblCatCarpetasExpedienteDigital] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCarpetaExpedienteDigital = @IDCarpetaExpedienteDigital

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatCarpetasExpedienteDigital]','[RH].[spBorrarCarpetasExpedienteDigital]','DELETE',@NewJSON,@OldJSON

	
		
		BEGIN TRY  
		 	UPDATE RH.tblCatExpedientesDigitales
				SET IDCarpetaExpedienteDigital = (SELECT TOP 1 IDCarpetaExpedienteDigital FROM RH.tblCatCarpetasExpedienteDigital WHERE Descripcion = 'OTROS' and CORE = 1 )
			WHERE IDCarpetaExpedienteDigital = @IDCarpetaExpedienteDigital
		 
		 DELETE RH.tblCatCarpetasExpedienteDigital
			WHERE IDCarpetaExpedienteDigital = @IDCarpetaExpedienteDigital

		END TRY  
		BEGIN CATCH  
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
			return 0;
		END CATCH ;
END
GO
