USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarEmpresa]
(
	@IDEmpresa int,
	@IDUsuario int
)
AS
BEGIN

	IF EXISTS(Select Top 1 1 from Facturacion.tblCatConfigEmpresa where IDEmpresa = @IDEmpresa)
	BEGIN
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
	END
	IF EXISTS(Select Top 1 1 from Nomina.tblHistorialesEmpleadosPeriodos where IDEmpresa = @IDEmpresa)
	BEGIN
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
	END
	IF EXISTS(Select Top 1 1 from RH.tblEmpresaEmpleado where IDEmpresa = @IDEmpresa)
	BEGIN
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
	END

		DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	select @OldJSON = a.JSON from [RH].[tblEmpresa] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IdEmpresa = @IDEmpresa
    	

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblEmpresa]','[RH].[spBorrarEmpresa]','DELETE','',@OldJSON



	 BEGIN TRY  
	   Delete RH.[tblEmpresa] 
	WHERE IdEmpresa = @IDEmpresa

	    EXEC [Seguridad].[spBorrarFiltrosUsuariosMasivoCatalogo] 
		 @IDFiltrosUsuarios  = 0  
		 ,@IDUsuario  = @IDUsuario   
		 ,@Filtro = 'RazonesSociales'  
		 ,@ID = @IDEmpresa   
		 ,@Descripcion = ''
		 ,@IDUsuarioLogin = @IDUsuario 

    END TRY  
    BEGIN CATCH  
    EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
    END CATCH ;

END
GO
