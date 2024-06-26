USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarCatClientes]-- 2,1
(
	@IDCliente int,
	@IDUsuario int
)
AS
BEGIN
	IF EXISTS(Select Top 1 1 from Nomina.tblCatTipoNomina where IDCliente = @IDCliente)
	BEGIN
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
	END
	
	IF EXISTS(Select Top 1 1 from Nomina.tblHistorialesEmpleadosPeriodos where IDCliente = @IDCliente)
	BEGIN
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
	END

	IF EXISTS(Select Top 1 1 from RH.tblCatRazonesSociales where IDCliente = @IDCliente)
	BEGIN
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
	END

	IF EXISTS(Select Top 1 1 from RH.tblClienteEmpleado where IDCliente = @IDCliente)
	BEGIN
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
	END
	
	EXEC App.spBorrarConfiguracionCatalogos @IDCliente  = @IDCliente
	
		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON = a.JSON from [RH].[tblCatClientes] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCliente = @IDCliente

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatClientes]','[RH].[spBorrarCatClientes]','DELETE','',@OldJSON




   BEGIN TRY  
	  Delete RH.[tblCatClientes] 
	WHERE IDCliente = @IDCliente

	  EXEC [Seguridad].[spBorrarFiltrosUsuariosMasivoCatalogo] 
	 @IDFiltrosUsuarios  = 0  
	 ,@IDUsuario  = @IDUsuario   
	 ,@Filtro = 'Clientes'  
	 ,@ID = @IDCliente   
	 ,@Descripcion = ''
	 ,@IDUsuarioLogin = @IDUsuario 

    END TRY  
    BEGIN CATCH  
    EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
    END CATCH ;


END
GO
