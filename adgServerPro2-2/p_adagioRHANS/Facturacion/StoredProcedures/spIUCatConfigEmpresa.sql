USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE   PROCEDURE [Facturacion].[spIUCatConfigEmpresa]  
(  
	@IDConfigEmpresa int = null,  
	@IDEmpresa int,  
	@Usuario Varchar(50) = null,  
	@Password Varchar(50) = null,  
	@PasswordKey Varchar(50) = null,  
	@Token varchar(max) = null,
	@TieneCertificado bit,
	@IDUsuario int
)  
AS  
BEGIN  
  DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);

	IF( isnull(@IDConfigEmpresa,0) = 0)  
	BEGIN  

		IF EXISTS(Select Top 1 1 from Facturacion.[tblCatConfigEmpresa] with(nolock) where IDEmpresa = @IDEmpresa)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		insert into Facturacion.tblCatConfigEmpresa(IDEmpresa,Usuario,[Password],PasswordKey,Token,TieneCertificado)  
		values(@IDEmpresa,@Usuario,@Password,@PasswordKey,@Token,@TieneCertificado)  
		set @IDConfigEmpresa = @@IDENTITY  

		select @NewJSON = a.JSON 
		from Facturacion.[tblCatConfigEmpresa] b with(nolock)
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDConfigEmpresa = @IDConfigEmpresa

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Facturacion].[tblCatConfigEmpresa]','[Facturacion].[spIUCatConfigEmpresa] ','INSERT',@NewJSON,''


	END  
	ELSE  
	BEGIN  
		
		select @OldJSON = a.JSON 
		from Facturacion.[tblCatConfigEmpresa] b with(nolock)
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDConfigEmpresa = @IDConfigEmpresa

		UPDATE Facturacion.tblCatConfigEmpresa  
		set Usuario = @Usuario,  
			[Password] = @Password,  
			[PasswordKey] = @PasswordKey,
			[Token] = @Token,
			TieneCertificado = @TieneCertificado
		where IDConfigEmpresa = @IDConfigEmpresa  
		and IDEmpresa = @IDEmpresa  

		select @NewJSON = a.JSON from Facturacion.[tblCatConfigEmpresa] b with(nolock)
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDConfigEmpresa = @IDConfigEmpresa

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Facturacion].[tblCatConfigEmpresa]','[Facturacion].[spIUCatConfigEmpresa] ','UPDATE',@NewJSON,@OldJSON

	END  
  
END
GO
