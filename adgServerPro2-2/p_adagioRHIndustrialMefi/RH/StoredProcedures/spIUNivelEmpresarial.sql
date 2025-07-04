USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spIUNivelEmpresarial]
(
	@IDNivelEmpresarial int = 0
	,@Nombre varchar(20)
	,@Orden int
	,@IDUsuario int =1
)
AS
BEGIN

	SET @Nombre				= UPPER(@Nombre			)	

	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

	IF(@IDNivelEmpresarial = 0 OR @IDNivelEmpresarial Is null)
	BEGIN
	
		INSERT INTO [RH].[tblCatNivelesEmpresariales] ( [Nombre] ,[Orden]					 )
            VALUES (@Nombre ,@Orden )

		Set @IDNivelEmpresarial= @@IDENTITY
	
		select @NewJSON = a.JSON from [RH].[tblCatNivelesEmpresariales] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDNivelEmpresarial = @IDNivelEmpresarial

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatDepartamentos]','[RH].[spIUCatDepartamentos]','INSERT',@NewJSON,''


	END
	ELSE
	BEGIN
        IF EXISTS(Select Top 1 1 from RH.[tblCatNivelesEmpresariales] where  (Nombre = @Nombre and IDNivelEmpresarial <> @IDNivelEmpresarial)  or (Orden= @Orden AND IDNivelEmpresarial <>@IDNivelEmpresarial) )
        BEGIN
            EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
            RETURN 0;
        END
	    
		select @OldJSON = a.JSON from [RH].[tblCatNivelesEmpresariales] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDNivelEmpresarial = @IDNivelEmpresarial

		UPDATE [RH].[tblCatNivelesEmpresariales]
		   SET [Nombre]=@Nombre,
                [Orden] =@Orden
		 WHERE IDNivelEmpresarial = @IDNivelEmpresarial		 	

		select @NewJSON = a.JSON from [RH].[tblCatNivelesEmpresariales] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDNivelEmpresarial = @IDNivelEmpresarial

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatNivelesEmpresariales]','[RH].[spIUNivelEmpresarial]','UPDATE',@NewJSON,@OldJSON
	END
    select @IDNivelEmpresarial as IDNivelEmpresarial
END
GO
