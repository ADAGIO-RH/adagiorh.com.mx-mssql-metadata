USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Procom.spBorrarFacturas
(
	@IDFactura int,
	@IDUsuario int
)
AS
BEGIN


	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

	
		select @OldJSON = a.JSON from [Procom].[TblFacturas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDFactura = @IDFactura

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[TblFacturas]','[RH].[spBorrarFacturas]','DELETE',@NewJSON,@OldJSON


		BEGIN TRY  
		  DELETE [Procom].[TblFacturas]
			WHERE IDFactura = @IDFactura

		END TRY  
		BEGIN CATCH  
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
			return 0;
		END CATCH ;
END
GO
