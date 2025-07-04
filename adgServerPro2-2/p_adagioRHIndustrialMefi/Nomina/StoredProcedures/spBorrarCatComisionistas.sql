USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE Nomina.spBorrarCatComisionistas
(
	@IDCatComisionista int = 0
	,@IDUsuario int
)
AS
BEGIN	

	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON = a.JSON from [Nomina].[tblCatComisionistas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCatComisionista = @IDCatComisionista

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Nomina].[tblCatComisionistas]','[Nomina].[spBorrarCatComisionistas]','DELETE','',@OldJSON


	DELETE [Nomina].[tblCatComisionistas]
	WHERE IDCatComisionista = @IDCatComisionista

END
GO
