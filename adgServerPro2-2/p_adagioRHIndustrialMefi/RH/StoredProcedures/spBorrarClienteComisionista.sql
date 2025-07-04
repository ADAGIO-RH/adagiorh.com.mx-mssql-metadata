USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE RH.spBorrarClienteComisionista(
	@IDClienteComisionista int,
	@IDUsuario int
)
AS
BEGIN
DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max); 


		select @OldJSON = a.JSON from [RH].[TblClienteComisionistas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteComisionista = @IDClienteComisionista


	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[TblClienteComisionistas]','[RH].[spIUClienteComisionista]','DELETE',@NewJSON,@OldJSON

		Delete RH.tblClienteComisionistas
		where IDClienteComisionista = @IDClienteComisionista
	
END
GO
