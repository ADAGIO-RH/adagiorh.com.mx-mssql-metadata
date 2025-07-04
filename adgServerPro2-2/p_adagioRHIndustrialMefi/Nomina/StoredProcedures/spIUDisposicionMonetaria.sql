USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE Nomina.spIUDisposicionMonetaria(
	@IDDisposicionMonetaria int = null,
	@IDTipoDisposicionMonetaria int,
	@IDPeriodo int,
	@FechaTransferencia date,
	@Monto decimal(18,2),
	@IDUsuario int
)
AS
BEGIN

	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)



	IF(@IDDisposicionMonetaria = 0 OR @IDDisposicionMonetaria Is null)
	BEGIN
		INSERT INTO Nomina.tblDisposicionMonetaria(IDTipoDisposicionMonetaria,IDPeriodo,FechaTransferencia,Monto)
		VALUES (@IDTipoDisposicionMonetaria,@IDPeriodo,@FechaTransferencia,@Monto)

		Set @IDDisposicionMonetaria = @@IDENTITY

		select @NewJSON = a.JSON from [Nomina].[tblDisposicionMonetaria] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDisposicionMonetaria = @IDDisposicionMonetaria

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Nomina].[tblDisposicionMonetaria','[Nomina].[spIUDisposicionMonetaria]','INSERT',@NewJSON,''

	END
	ELSE
	BEGIN
		select @OldJSON = a.JSON from [Nomina].[tblDisposicionMonetaria] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDisposicionMonetaria = @IDDisposicionMonetaria

		UPDATE [Nomina].[tblDisposicionMonetaria]
		   SET [IDTipoDisposicionMonetaria] = @IDTipoDisposicionMonetaria,
				[IDPeriodo] = @IDPeriodo,
				[FechaTransferencia] = @FechaTransferencia,
				[Monto] = @Monto
		WHERE IDDisposicionMonetaria = @IDDisposicionMonetaria

		select @NewJSON = a.JSON from [Nomina].[tblDisposicionMonetaria] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDisposicionMonetaria = @IDDisposicionMonetaria

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Nomina].[tblDisposicionMonetaria]','[Nomina].[spIUDisposicionMonetaria]','UPDATE',@NewJSON,@OldJSON

	END

END
GO
