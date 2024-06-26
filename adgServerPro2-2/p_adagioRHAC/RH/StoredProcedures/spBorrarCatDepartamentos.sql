USE [p_adagioRHAC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarCatDepartamentos]
(
	@IDDepartamento int,
	@IDUsuario int
)
AS
BEGIN


	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

	IF EXISTS(Select Top 1 1 from Nomina.tblHistorialesEmpleadosPeriodos where IDDepartamento = @IDDepartamento)
	BEGIN
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
	END

	IF EXISTS(Select Top 1 1 from RH.tblDepartamentoEmpleado where IDDepartamento = @IDDepartamento)
	BEGIN
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
	END

		exec RH.spBuscarCatDepartamentos @IDDepartamento

		select @OldJSON = a.JSON from [RH].[tblCatDepartamentos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDepartamento = @IDDepartamento

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatDepartamentos]','[RH].[spIUCatDepartamentos]','DELETE',@NewJSON,@OldJSON


		BEGIN TRY  
		  DELETE [RH].[tblCatDepartamentos]
			WHERE IDDepartamento = @IDDepartamento

		  EXEC [Seguridad].[spBorrarFiltrosUsuariosMasivoCatalogo] 
		 @IDFiltrosUsuarios  = 0  
		 ,@IDUsuario  = @IDUsuario   
		 ,@Filtro = 'Departamentos'  
		 ,@ID = @IDDepartamento   
		 ,@Descripcion = ''
		 ,@IDUsuarioLogin = @IDUsuario 

		END TRY  
		BEGIN CATCH  
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
			return 0;
		END CATCH ;
END
GO
