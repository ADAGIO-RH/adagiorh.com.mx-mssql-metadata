USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBorrarPrestamo]
(
	@IDPrestamo int
	,@IDUsuario int
)
AS
BEGIN	
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spBorrarPrestamo]',
		@Tabla		varchar(max) = '[Nomina].[tblPrestamo]',
		@Accion		varchar(20)	= 'DELETE'
	;

	exec [Nomina].[spBuscarPrestamos] @IDPrestamo = @IDPrestamo, @IDUsuario=@IDUsuario

	select @OldJSON = a.JSON 
	from [Nomina].[tblPrestamos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	WHERE  IDPrestamo = @IDPrestamo

	Delete [Nomina].[tblPrestamos]
	where IDPrestamo = @IDPrestamo

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON

END
GO
