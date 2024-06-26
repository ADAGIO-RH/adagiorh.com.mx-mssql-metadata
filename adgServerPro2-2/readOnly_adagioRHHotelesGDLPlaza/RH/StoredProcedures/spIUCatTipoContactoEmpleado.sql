USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spIUCatTipoContactoEmpleado]
(
	@IDTipoContacto int = 0
	,@Descripcion varchar(100)
	,@Mask varchar(100)
	,@IDUsuario int
)
AS
BEGIN
	SET @Descripcion = UPPER(@Descripcion)
	SET @Mask		 = UPPER(@Mask		)

	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)



	IF (@IDTipoContacto = 0 or @IDTipoContacto is null)
	BEGIN
	
		INSERT INTO [RH].[tblCatTipoContactoEmpleado]
				   (
					 [Descripcion]
					 ,[Mask]
				   )
			 VALUES
				   (
				   @Descripcion
					,@Mask
				   )
			set @IDTipoContacto = @@IDENTITY

		select @NewJSON = a.JSON from [RH].[tblCatTipoContactoEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoContacto = @IDTipoContacto

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatTipoContactoEmpleado]','[RH].[spIUCatTipoContactoEmpleado]','INSERT',@NewJSON,''
	END
	ELSE
	BEGIN
		select @OldJSON = a.JSON from [RH].[tblCatTipoContactoEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoContacto = @IDTipoContacto

		UPDATE [RH].[tblCatTipoContactoEmpleado]
		   SET   [Descripcion] = @Descripcion
				,[Mask] = @Mask
		 WHERE [IDTipoContacto] = @IDTipoContacto

		 		select @NewJSON = a.JSON from [RH].[tblCatTipoContactoEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoContacto = @IDTipoContacto

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatTipoContactoEmpleado]','[RH].[spIUCatTipoContactoEmpleado]','UPDATE',@NewJSON,@OldJSON

	END
END
GO
