USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Procom.spBorrarClienteHonorariosComisionistas(
	@IDClienteHonorarioComisionista int,
	@IDUsuario int
)
AS
BEGIN

DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)
	BEGIN TRY
			select @OldJSON =  a.JSON from [Procom].[TblClienteHonorariosComisionistas] b
				inner join Procom.TblClienteHonorarios H on H.IDClienteHonorario = b.IDClienteHonorario
				inner join RH.tblCatClientes c on C.IDCliente = H.IDCliente
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.*,c.NombreComercial For XML Raw)) ) a
			WHERE b.IDClienteHonorarioComisionista = @IDClienteHonorarioComisionista

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[TblClienteHonorariosComisionistas]','[Procom].[spBorrarClienteHonorariosComisionistas]','DELETE','',@OldJSON

		Delete [Procom].[TblClienteHonorariosComisionistas] 
		where IDClienteHonorarioComisionista = @IDClienteHonorarioComisionista
	END TRY
	BEGIN CATCH
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
			return 0;
	END CATCH
END
GO
