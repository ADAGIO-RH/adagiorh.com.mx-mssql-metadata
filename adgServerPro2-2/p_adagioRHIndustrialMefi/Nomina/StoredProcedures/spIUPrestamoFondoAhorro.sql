USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Nomina].[spIUPrestamoFondoAhorro](
	 @IDPrestamoFondoAhorro	int = 0
	,@IDFondoAhorro			int
	,@IDEmpleado			int
	,@Monto					money
	,@IDPrestamo			int
	,@IDUsuario				int
) as
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spIUPrestamoFondoAhorro]',
		@Tabla		varchar(max) = '[Nomina].[tblPrestamosFondoAhorro]',
		@Accion		varchar(20)	= ''
	;

	if (@IDPrestamo <> 0)
	begin
		select @IDPrestamoFondoAhorro = IDPrestamoFondoAhorro
		from Nomina.tblPrestamosFondoAhorro
		where IDPrestamo = @IDPrestamo
	end;
	
	if (@IDPrestamoFondoAhorro = 0)
	begin
		insert into Nomina.tblPrestamosFondoAhorro(IDFondoAhorro,IDEmpleado,Monto,FechaHora,IDPrestamo,IDUsuario)
		select @IDFondoAhorro,@IDEmpleado,@Monto,getdate(),@IDPrestamo,@IDUsuario

		set @IDPrestamoFondoAhorro = @@IDENTITY

		select @NewJSON = a.JSON
			,@Accion = 'INSERT'
		from [Nomina].tblPrestamosFondoAhorro b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDPrestamoFondoAhorro = @IDPrestamoFondoAhorro
	end else 
	begin
		select @NewJSON = a.JSON
			,@Accion = 'UPDATE'
		from [Nomina].tblPrestamosFondoAhorro b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDPrestamoFondoAhorro = @IDPrestamoFondoAhorro

		update Nomina.tblPrestamosFondoAhorro
		set  Monto	   = @Monto
			,IDPrestamo = @IDPrestamo
			,IDUsuario = @IDUsuario
		where IDPrestamoFondoAhorro = @IDPrestamoFondoAhorro

		select @NewJSON = a.JSON
		from [Nomina].tblPrestamosFondoAhorro b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDPrestamoFondoAhorro = @IDPrestamoFondoAhorro
	end;

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON

	exec Nomina.spBuscarPrestamosFondoAhorro @IDPrestamoFondoAhorro=@IDPrestamoFondoAhorro, @IDUsuario=@IDUsuario
GO
