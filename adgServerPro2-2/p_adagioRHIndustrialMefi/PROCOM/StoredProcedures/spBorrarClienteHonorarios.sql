USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Procom.spBorrarClienteHonorarios(
	@IDClienteHonorario int
	,@IDUsuario int
)
AS
BEGIN

DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)


	BEGIN TRY
			select @OldJSON = a.JSON from [Procom].[TblClienteHonorarios] b
				inner join RH.tblCatClientes c with(nolock) on b.IDCliente = c.IDCliente
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.*,c.NombreComercial For XML Raw)) ) a
		WHERE b.IDClienteHonorario = @IDClienteHonorario

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[TblClienteHonorarios]','[Procom].[spBorrarClienteHonorarios]','DELETE','',@OldJSON

		Delete [Procom].[TblClienteHonorarios] 
		where IDClienteHonorario = @IDClienteHonorario
	END TRY
	BEGIN CATCH
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
			return 0;
	END CATCH

END
GO
