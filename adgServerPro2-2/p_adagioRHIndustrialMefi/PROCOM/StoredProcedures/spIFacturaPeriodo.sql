USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Procom.spIFacturaPeriodo(
	@IDFacturaPeriodo int = 0,
	@IDFactura int,
	@IDPeriodo int,
	@IDUsuario int
)
AS
BEGIN
	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

	IF EXISTS(Select Top 1 1 from Procom.TblFacturasPeriodos where IDFactura = @IDFactura and IDPeriodo = @IDPeriodo )
	BEGIN
		Select Top 1 @IDFacturaPeriodo = IDFacturaPeriodo from Procom.TblFacturasPeriodos where IDFactura = @IDFactura and IDPeriodo = @IDPeriodo 
	END

	IF(@IDFacturaPeriodo = 0 OR @IDFacturaPeriodo Is null)
	BEGIN

		INSERT INTO [Procom].[TblFacturasPeriodos]
				   (
					IDFactura
					,IDPeriodo
				   )
			 VALUES
				   (
				     @IDFactura
					,@IDPeriodo
				   )

		Set @IDFacturaPeriodo = @@IDENTITY
		

		select @NewJSON = a.JSON from [Procom].[TblFacturasPeriodos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDFacturaPeriodo = @IDFacturaPeriodo

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[TblFacturasPeriodos]','[Procom].[spIFacturaPeriodo]','INSERT',@NewJSON,''


	END
	ELSE
	BEGIN
	
		select @OldJSON =  a.JSON from [Procom].[TblFacturasPeriodos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDFacturaPeriodo = @IDFacturaPeriodo

		UPDATE [Procom].[TblFacturasPeriodos]
		   SET [IDFactura] = @IDFactura,
				[IDPeriodo] = @IDPeriodo	
		 WHERE IDFacturaPeriodo = @IDFacturaPeriodo


		select @NewJSON =  a.JSON from [Procom].[TblFacturasPeriodos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDFacturaPeriodo = @IDFacturaPeriodo

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[TblFacturasPeriodos]','[Procom].[spIFacturaPeriodo]','UPDATE',@NewJSON,@OldJSON
	END

END
GO
