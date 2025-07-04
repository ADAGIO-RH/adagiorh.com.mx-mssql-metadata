USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE RH.spIUCarpetasExpedienteDigital(
	@IDCarpetaExpedienteDigital int = 0
	,@Descripcion varchar(255)
	,@IDUsuario int 
)
AS
BEGIN

	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

	SET @Descripcion 		= UPPER(@Descripcion 	)

	IF(@IDCarpetaExpedienteDigital = 0 OR @IDCarpetaExpedienteDigital Is null)
	BEGIN

	IF EXISTS(Select Top 1 1 from RH.[tblCatCarpetasExpedienteDigital] where Descripcion = @Descripcion and ISNULL(Core,0) = 0)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		INSERT INTO RH.[tblCatCarpetasExpedienteDigital]
				   (
					 [Descripcion]
					,[Core]
					,[IDTipoComportamientoCarpetaExpedienteDigital]
				   )
			 VALUES
				   (
					 @Descripcion
					,0 
					,(SELECT TOP 1 IDTipoComportamientoCarpetaExpedienteDigital FROM RH.tblCatTipoComportamientoCarpetaExpedienteDigital where Descripcion = 'DEFAULT')
				   )

		Set @IDCarpetaExpedienteDigital = @@IDENTITY
		

		select @NewJSON = a.JSON from RH.[tblCatCarpetasExpedienteDigital] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCarpetaExpedienteDigital = @IDCarpetaExpedienteDigital

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatCarpetasExpedienteDigital]','[RH].[spIUCarpetasExpedienteDigital]','INSERT',@NewJSON,''


	END
	ELSE
	BEGIN
	IF EXISTS(Select Top 1 1 from RH.[tblCatCarpetasExpedienteDigital] where ISNULL(CORE,0) = 0 and Descripcion = @Descripcion and IDCarpetaExpedienteDigital <> @IDCarpetaExpedienteDigital)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		select @OldJSON = a.JSON from RH.[tblCatCarpetasExpedienteDigital] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE  b.IDCarpetaExpedienteDigital = @IDCarpetaExpedienteDigital

		UPDATE [RH].[tblCatCarpetasExpedienteDigital]
		   SET 
				[Descripcion] = @Descripcion,
				[Core] = 0,
				[IDTipoComportamientoCarpetaExpedienteDigital] = (SELECT TOP 1 IDTipoComportamientoCarpetaExpedienteDigital FROM RH.tblCatTipoComportamientoCarpetaExpedienteDigital where Descripcion = 'DEFAULT')
		 WHERE IDCarpetaExpedienteDigital = @IDCarpetaExpedienteDigital


		select @NewJSON = a.JSON from RH.[tblCatCarpetasExpedienteDigital] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCarpetaExpedienteDigital = @IDCarpetaExpedienteDigital

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatCarpetasExpedienteDigital]','[RH].[spIUCarpetasExpedienteDigital]','UPDATE',@NewJSON,@OldJSON
	END

	
END
GO
