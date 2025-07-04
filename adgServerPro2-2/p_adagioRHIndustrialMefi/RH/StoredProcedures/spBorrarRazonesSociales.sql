USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarRazonesSociales]
(
	@IDRazonSocial int 
	,@IDUsuario int
)
AS
BEGIN
	IF EXISTS(Select Top 1 1 from Nomina.[tblHistorialesEmpleadosPeriodos] where IDRazonSocial = @IDRazonSocial)
	BEGIN
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
	END
	IF EXISTS(Select Top 1 1 from RH.[tblRazonSocialEmpleado] where IDRazonSocial = @IDRazonSocial)
	BEGIN
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
	END

			  DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	select @OldJSON = a.JSON from [RH].[tblCatRazonesSociales] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDRazonSocial = @IDRazonSocial
    	

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatRazonesSociales]','[RH].[spBorrarRazonesSociales]','DELETE','',@OldJSON




		DELETE [RH].[tblCatRazonesSociales]
		WHERE IDRazonSocial = @IDRazonSocial

END
GO
