USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE Procom.spIUProtocoloIX(
	@IDProtocoloIX int = 0,
	@IDCliente int,
	@IDClienteModelo int,
	@IDClienteRazonSocial int,
	@FechaIni Date,
	@FechaFin Date,
	@Ejercicio int,
	@IDMes int,
	@IDUsuario int
)
AS
BEGIN
		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

	IF(@IDProtocoloIX = 0 OR @IDProtocoloIX Is null)
	BEGIN

		INSERT INTO [Procom].[tblProtocoloIX]
				   (
					 IDCliente
					,IDClienteModelo
					,IDClienteRazonSocial
					,FechaIni
					,FechaFin
					,Ejercicio
					,IDMes
				   )
			 VALUES
				   (
				     @IDCliente
					,@IDClienteModelo
					,@IDClienteRazonSocial
					,@FechaIni
					,@FechaFin
					,@Ejercicio
					,@IDMes
				   )

		Set @IDProtocoloIX = @@IDENTITY
		

		select @NewJSON = a.JSON from [Procom].[tblProtocoloIX] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDProtocoloIX = @IDProtocoloIX

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[tblProtocoloIX]','[Procom].[spIUProtocoloIX]','INSERT',@NewJSON,''


	END
	ELSE
	BEGIN
	
		select @OldJSON = a.JSON from [Procom].[tblProtocoloIX] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDProtocoloIX = @IDProtocoloIX

		UPDATE [Procom].[tblProtocoloIX]
		   SET       IDCliente				= @IDCliente
					,IDClienteModelo		= @IDClienteModelo
					,IDClienteRazonSocial	= @IDClienteRazonSocial
					,FechaIni				= @FechaIni
					,FechaFin				= @FechaFin
					,Ejercicio				= @Ejercicio
					,IDMes					= @IDMes
		 WHERE IDProtocoloIX = @IDProtocoloIX
		 

		select @NewJSON =  a.JSON from [Procom].[tblProtocoloIX] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDProtocoloIX = @IDProtocoloIX

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[tblProtocoloIX]','[Procom].[spIUProtocoloIX]','UPDATE',@NewJSON,@OldJSON
	END
END
GO
