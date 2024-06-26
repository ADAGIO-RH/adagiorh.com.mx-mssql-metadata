USE [p_adagioRHAC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spUIConfiguracionesCliente](
	@IDCliente int,
	@IDTipoConfiguracionCliente varchar(255),
	@Valor Varchar(255),
	@IDUsuario int
)
AS
BEGIN
DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	IF Exists (select * from RH.tblConfiguracionesCliente where IDCliente = @IDCliente and IDTipoConfiguracionCliente = @IDTipoConfiguracionCliente)
	BEGIN
		select @OldJSON = a.JSON from [RH].[tblConfiguracionesCliente] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoConfiguracionCliente = @IDTipoConfiguracionCliente
		and IDCliente = @IDCliente

		UPDATE RH.tblConfiguracionesCliente
			set valor = @Valor
		WHERE IDTipoConfiguracionCliente = @IDTipoConfiguracionCliente
			and IDCliente = @IDCliente
		
		select @NewJSON = a.JSON from [RH].[tblConfiguracionesCliente] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoConfiguracionCliente = @IDTipoConfiguracionCliente
		and IDCliente = @IDCliente

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblConfiguracionesCliente]','[RH].[spUIConfiguracionesCliente]','UDPATE',@NewJSON,@OldJSON
	END
	ELSE
	BEGIN
		INSERT INTO RH.tblConfiguracionesCliente(IDCliente,IDTipoConfiguracionCliente,Valor)
		VALUES(@IDCliente, @IDTipoConfiguracionCliente,@Valor)

		
		select @NewJSON = a.JSON from [RH].[tblConfiguracionesCliente] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoConfiguracionCliente = @IDTipoConfiguracionCliente
		and IDCliente = @IDCliente

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblConfiguracionesCliente]','[RH].[spUIConfiguracionesCliente]','INSERT',@NewJSON,''


	END


	--EXEC [RH].[spBuscarConfiguracionesCliente] @IDCliente = @IDCliente, @IDTipoConfiguracionCliente = @IDTipoConfiguracionCliente

END
GO
