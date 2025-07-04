USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [IMSS].[spBorrarCatCesantiaVejezPatronal]
(
	@IDCesantiaVejezPatronal Int,
	@IDUsuario int
)
AS
BEGIN
	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	select @OldJSON = a.JSON from [IMSS].[tblCatCesantiaVejezPatronal] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCesantiaVejezPatronal = @IDCesantiaVejezPatronal

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[IMSS].[tblCatCesantiaVejezPatronal]','[IMSS].[spBorrarCatCesantiaVejezPatronal]','DELETE','',@OldJSON


	BEGIN TRY  
		Delete [IMSS].[tblCatCesantiaVejezPatronalDetalle]
		WHERE IDCesantiaVejezPatronal = @IDCesantiaVejezPatronal

		Delete [IMSS].[tblCatCesantiaVejezPatronal]
		WHERE IDCesantiaVejezPatronal = @IDCesantiaVejezPatronal
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;
END
GO
