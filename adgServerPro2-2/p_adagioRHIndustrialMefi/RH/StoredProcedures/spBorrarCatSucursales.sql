USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarCatSucursales]
(
	@IDSucursal int,
	@IDUsuario int
)
AS
BEGIN

    exec [RH].[spBuscarCatSucursales] @IDSucursal;

		DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	select @OldJSON = a.JSON from [RH].[tblCatSucursales] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDSucursal = @IDSucursal

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatSucursales]','[RH].[spBorrarCatSucursales]','DELETE','',@OldJSON

    BEGIN TRY  
	    DELETE [RH].[tblCatSucursales] 
	    WHERE IDSucursal = @IDSucursal
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;


		
END
GO
