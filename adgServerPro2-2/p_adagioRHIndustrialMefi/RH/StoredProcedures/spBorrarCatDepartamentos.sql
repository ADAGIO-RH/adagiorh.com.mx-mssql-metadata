USE [p_adagioRHIndustrialMefi]
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

		select @OldJSON = (SELECT IDDepartamento
                                ,Codigo
                                ,CuentaContable
                                ,JefeDepartamento                                                 
                             ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
                            FROM  [RH].[tblCatDepartamentos]
                            WHERE IDDepartamento = @IDDepartamento FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

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
