USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE RH.spIUClienteComisionista(
	@IDClienteComisionista int = 0 ,
	@IDCliente int,
	@IDCatComisionista int,
	@Porcentaje decimal(18,4),
	@IDUsuario int
)
AS
BEGIN
DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max); 

	IF(isnull(@IDClienteComisionista,0) = 0)
	BEGIN
		insert into RH.TblClienteComisionistas(IDCliente,IDCatComisionista,Porcentaje)
		values(@IDCliente,@IDCatComisionista,@Porcentaje)

		set @IDClienteComisionista = @@IDENTITY
		select @NewJSON = a.JSON from [RH].[TblClienteComisionistas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteComisionista = @IDClienteComisionista

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[TblClienteComisionistas]','[RH].[spIUClienteComisionista]','INSERT',@NewJSON,''
	END
	ELSE
	BEGIN

		select @OldJSON = a.JSON from [RH].[TblClienteComisionistas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteComisionista = @IDClienteComisionista

		UPDATE [RH].[TblClienteComisionistas]
			set IDCliente = @IDCliente,
				IDCatComisionista = @IDCatComisionista,
				Porcentaje = @Porcentaje
		WHERE IDClienteComisionista = @IDClienteComisionista

		select @NewJSON = a.JSON from [RH].[TblClienteComisionistas]  b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteComisionista = @IDClienteComisionista

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[TblClienteComisionistas]','[RH].[spIUClienteComisionista]','UPDATE',@NewJSON,@OldJSON
	END
END
GO
