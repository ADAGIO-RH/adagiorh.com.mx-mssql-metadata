USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [IMSS].[spBorrarCatCesantiaVejezPatronalDetalle]
(
	@IDCesantiaVejezPatronalDetalle Int,
	@IDUsuario int
)
AS
BEGIN
	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	select @OldJSON = a.JSON from [IMSS].[tblCatCesantiaVejezPatronalDetalle] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCesantiaVejezPatronalDetalle = @IDCesantiaVejezPatronalDetalle

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[IMSS].[tblCatCesantiaVejezPatronalDetalle]','[IMSS].[spBorrarCatCesantiaVejezPatronalDetalle]','DELETE','',@OldJSON


	BEGIN TRY  
		Delete [IMSS].[tblCatCesantiaVejezPatronalDetalle]
		WHERE IDCesantiaVejezPatronalDetalle = @IDCesantiaVejezPatronalDetalle

		
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;
END
GO
