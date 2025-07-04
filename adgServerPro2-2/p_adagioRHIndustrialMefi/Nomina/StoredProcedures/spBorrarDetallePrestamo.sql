USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBorrarDetallePrestamo]
(
	@IDPrestamoDetalle int
	,@IDUsuario int
)
AS
BEGIN	
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spBorrarDetallePrestamo]',
		@Tabla		varchar(max) = '[Nomina].[tblPrestamosDetalles]',
		@Accion		varchar(20)	= 'DELETE'
	;
	

	select @OldJSON = a.JSON 
	from [Nomina].[tblPrestamosDetalles] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	WHERE  IDPrestamoDetalle = @IDPrestamoDetalle

	Delete [Nomina].[tblPrestamosDetalles]
	where IDPrestamoDetalle = @IDPrestamoDetalle

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON

    SELECT 'Se ha eliminado correctamente' as Mensaje

END
GO
