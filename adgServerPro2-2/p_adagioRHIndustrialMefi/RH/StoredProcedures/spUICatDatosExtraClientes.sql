USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spUICatDatosExtraClientes]
(
	@IDCatDatoExtraCliente int = 0
	,@Nombre [App].[MDName]
	,@Descripcion [App].[LGDescription]
	,@TipoDato [App].[SMName]
	,@IDUsuario int
)
AS
BEGIN
	set @Nombre = REPLACE(@Nombre,' ','_')

	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max); 

	if CHARINDEX(' ',@Nombre) > 0   
	begin  
	   raiserror('Se ha producido un error. El Nombre no puede contener espacios.',16,1);
	   return
	end;  

	IF(@IDCatDatoExtraCliente = 0)
	BEGIN
		INSERT INTO RH.tblCatDatosExtraClientes(Nombre,Descripcion,TipoDato)
		VALUES(UPPER(@Nombre),UPPER(@Descripcion),@TipoDato)
		
		set @IDCatDatoExtraCliente = @@IDENTITY

			
		select @NewJSON = a.JSON from [RH].[tblCatDatosExtraClientes] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCatDatoExtraCliente = @IDCatDatoExtraCliente

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatDatosExtraClientes]','[RH].[spUICatDatosExtraClientes]','INSERT',@NewJSON,''

	END
	ELSE
	BEGIN

		select @OldJSON = a.JSON from [RH].[tblCatDatosExtraClientes] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCatDatoExtraCliente = @IDCatDatoExtraCliente

		UPDATE RH.tblCatDatosExtraClientes
			set Nombre = UPPER(@Nombre),
				Descripcion = UPPER(@Descripcion),
				TipoDato = @TipoDato
		WHERE IDCatDatoExtraCliente = @IDCatDatoExtraCliente

		select @NewJSON = a.JSON from [RH].[tblCatDatosExtraClientes] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCatDatoExtraCliente = @IDCatDatoExtraCliente

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatDatosExtraClientes]','[RH].[spUICatDatosExtraClientes]','UPDATE',@NewJSON,@OldJSON
	END

	EXEC [RH].[spBuscarCatDatosExtraClientes] @IDCatDatoExtraCliente

END
GO
