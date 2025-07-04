USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE Seguridad.spIUToken(
	@IDToken int = 0,
	@IDTipoToken int,
	@Nombre Varchar(100)= null,
	@Token Varchar(1000) = null,
	@Activo bit = 0,
	@IDUsuario int
)
AS
BEGIN
	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);

	SET @Nombre				= UPPER(@Nombre)

	IF(@IDToken = 0 OR @IDToken Is null)
	BEGIN



		INSERT INTO Seguridad.tblTokens
				   (
					[IDTipoToken]
					 ,[Nombre]
					,[Token]
					,[Activo]
					,[IDUsuario]
				   )
			 VALUES
				   (
					 @IDTipoToken
				    ,@Nombre
					,@Token
					,isnull(@Activo,0)
					,@IDUsuario
				   )
		Set @IDToken = @@IDENTITY

		select @NewJSON = a.JSON from [Seguridad].[tblTokens] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDToken = @IDToken

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Seguridad].[tblTokens]','[Seguridad].[spIUTokenGenericos]','INSERT',@NewJSON,''

	END
	ELSE
	BEGIN
	
		select @OldJSON = a.JSON from [Seguridad].[tblTokens] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDToken = @IDToken

		UPDATE [Seguridad].[tblTokens]
		   SET [Nombre] = @Nombre,
				[Token] = @Token,
				[Activo] = isnull(@Activo,0)
		 WHERE IDToken = @IDToken


		select @NewJSON = a.JSON from [Seguridad].[tblTokens] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDToken = @IDToken

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Seguridad].[tblTokens]','[Seguridad].[spIUToken]','UPDATE',@NewJSON,@OldJSON
	END
END
GO
