USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [Nomina].[spBorrarSalariosMinimos]
(
 @IDSalarioMinimo int
 ,@IDUsuario int
)
as
BEGIN
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spBorrarSalariosMinimos]',
		@Tabla		varchar(max) = '[Nomina].[tblSalariosMinimos]',
		@Accion		varchar(20)	= 'DELETE'


	select @OldJSON = a.JSON 
	from Nomina.tblSalariosMinimos b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	WHERE IDSalarioMinimo = @IDSalarioMinimo

    BEGIN TRY  
	    DELETE Nomina.tblSalariosMinimos
	    WHERE IDSalarioMinimo = @IDSalarioMinimo

		EXEC [Auditoria].[spIAuditoria]
			@IDUsuario		= @IDUsuario
			,@Tabla			= @Tabla
			,@Procedimiento	= @NombreSP
			,@Accion		= @Accion
			,@NewData		= @NewJSON
			,@OldData		= @OldJSON
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;
END
GO
