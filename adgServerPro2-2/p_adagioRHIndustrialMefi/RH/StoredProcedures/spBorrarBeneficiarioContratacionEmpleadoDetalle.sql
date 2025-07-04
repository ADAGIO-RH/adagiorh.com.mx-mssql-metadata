USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [RH].[spBorrarBeneficiarioContratacionEmpleadoDetalle]
(
	@IDBeneficiarioContratacionEmpleadoDetalle int ,
	@IDUsuario int
)
AS
BEGIN
    declare @IDEmpleado int = 0;

	
 	
	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	select @OldJSON = a.JSON from [RH].tblBeneficiarioContratacionEmpleadoDetalle b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b. IDBeneficiarioContratacionEmpleadoDetalle = @IDBeneficiarioContratacionEmpleadoDetalle

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblBeneficiarioContratacionEmpleadoDetalle]','[RH].[spBorrarBeneficiarioContratacionEmpleadoDetalle]','DELETE','',@OldJSON


   DELETE RH.tblBeneficiarioContratacionEmpleadoDetalle
   WHERE IDBeneficiarioContratacionEmpleadoDetalle = @IDBeneficiarioContratacionEmpleadoDetalle

END
GO
