USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spIUCatExpedientesDigitales]
(
	 @IDExpedienteDigital int = 0 
	,@Codigo Varchar(20)
	,@Descripcion Varchar(MAX) = null
	,@Requerido bit = 0
	,@IDUsuario int
)
AS
BEGIN
	
	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

	SET @Codigo = UPPER(@Codigo)
	SET @Descripcion = UPPER(@Descripcion)

	IF(@IDExpedienteDigital is null OR @IDExpedienteDigital = 0)
	BEGIN
		IF EXISTS(Select Top 1 1 from RH.[tblCatExpedientesDigitales] WITH(NOLOCK) where Codigo = @Codigo)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		INSERT INTO RH.tblCatExpedientesDigitales(Codigo,Descripcion,Requerido)
		VALUES(@Codigo,@Descripcion,@Requerido)
		
		SET @IDExpedienteDigital = @@IDENTITY

		SELECT @NewJSON = a.JSON 
		FROM [RH].[tblCatExpedientesDigitales] b WITH(NOLOCK)
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDExpedienteDigital = @IDExpedienteDigital

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatExpedientesDigitales]','[RH].[spIUCatExpedientesDigitales]','INSERT',@NewJSON,''


	END ELSE
	BEGIN
		IF EXISTS(Select Top 1 1 from RH.[tblCatExpedientesDigitales] WITH(NOLOCK) where Codigo = @Codigo and IDExpedienteDigital <> @IDExpedienteDigital)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END
		
		SELECT @OldJSON = a.JSON from [RH].[tblCatExpedientesDigitales] b  WITH(NOLOCK)
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDExpedienteDigital = @IDExpedienteDigital

		UPDATE [RH].[tblCatExpedientesDigitales]
			SET Codigo = @Codigo
				, Descripcion = @Descripcion
				, Requerido = @Requerido
		WHERE IDExpedienteDigital = @IDExpedienteDigital

		select @NewJSON = a.JSON from [RH].[tblCatExpedientesDigitales] b WITH(NOLOCK)
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDExpedienteDigital = @IDExpedienteDigital

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatExpedientesDigitales]','[RH].[spIUCatExpedientesDigitales]','UPDATE',@NewJSON,@OldJSON
	END

	EXEC [RH].[spBuscarCatExpedientesDigitales] @IDExpedienteDigital

END;
GO
