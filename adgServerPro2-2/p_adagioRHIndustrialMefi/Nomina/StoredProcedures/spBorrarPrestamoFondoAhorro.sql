USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Nomina].[spBorrarPrestamoFondoAhorro](
	 @IDPrestamoFondoAhorro	int  
	,@IDUsuario				int
) as
	-- TODO - Validar que no estén dentro del rango de fecha del periodo de cobro
	-- TODO - Validar que el periodo no está cerrado

	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spBorrarPrestamoFondoAhorro]',
		@Tabla		varchar(max) = '[Nomina].[tblPrestamosFondoAhorro]',
		@Accion		varchar(20)	= 'DELETE'


	select @OldJSON = a.JSON 
	from Nomina.tblPrestamosFondoAhorro b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	WHERE IDPrestamoFondoAhorro = @IDPrestamoFondoAhorro


	delete from Nomina.tblPrestamosFondoAhorro
	where IDPrestamoFondoAhorro = @IDPrestamoFondoAhorro

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
GO
