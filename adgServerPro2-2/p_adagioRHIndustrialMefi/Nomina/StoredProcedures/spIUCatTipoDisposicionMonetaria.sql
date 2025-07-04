USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE Nomina.spIUCatTipoDisposicionMonetaria(
	@IDTipoDisposicionMonetaria int = null,
	@Descripcion Varchar(500),
	@IDUsuario int
)
AS
BEGIN

	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)


	SET @Descripcion 		= UPPER(@Descripcion 	)

	IF(@IDTipoDisposicionMonetaria = 0 OR @IDTipoDisposicionMonetaria Is null)
	BEGIN
		INSERT INTO Nomina.tblCatTipoDisposicionMonetaria(Descripcion)
		VALUES (@Descripcion)

		Set @IDTipoDisposicionMonetaria = @@IDENTITY

		select @NewJSON = a.JSON from [Nomina].[tblCatTipoDisposicionMonetaria] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoDisposicionMonetaria = @IDTipoDisposicionMonetaria

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Nomina].[tblCatTipoDisposicionMonetaria]','[Nomina].[spIUCatTipoDisposicionMonetaria]','INSERT',@NewJSON,''

	END
	ELSE
	BEGIN
		select @OldJSON = a.JSON from [Nomina].[tblCatTipoDisposicionMonetaria] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoDisposicionMonetaria = @IDTipoDisposicionMonetaria

		UPDATE Nomina.tblCatTipoDisposicionMonetaria
		   SET [Descripcion] = @Descripcion
		 WHERE IDTipoDisposicionMonetaria = @IDTipoDisposicionMonetaria

		select @NewJSON = a.JSON from [Nomina].[tblCatTipoDisposicionMonetaria] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoDisposicionMonetaria = @IDTipoDisposicionMonetaria

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Nomina].[tblCatTipoDisposicionMonetaria]','[Nomina].[spIUCatTipoDisposicionMonetaria]','UPDATE',@NewJSON,@OldJSON

	END

END
GO
