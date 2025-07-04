USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Nomina].[spIUCajaAhorro](
	 @IDCajaAhorro int = 0
	,@IDEmpleado int
	,@Monto decimal(18,2) 
	,@IDEstatus int 
	,@IDUsuario int 
) as 
	
	declare 
		@Accion varchar(255) = case when @IDCajaAhorro = 0 then 'Caja de ahorro creada' else 'Caja de ahorro actualizada' end,
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spIUCajaAhorro]',
		@Tabla		varchar(max) = '[Nomina].[tblCajaAhorro]',
		@AccionAuditoria		varchar(20)	= ''

	if (@IDCajaAhorro = 0)
	begin
		IF EXISTS(Select Top 1 1 from  [Nomina].[tblCajaAhorro] where IDEmpleado = @IDEmpleado)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '',@CustomMessage= 'El colaborador ya tiene una caja de ahorro registrada.'
			RETURN 0;
		END;

		insert [Nomina].[tblCajaAhorro](IDEmpleado,Monto,IDEstatus)
		values(@IDEmpleado,@Monto,@IDEstatus)

		set @IDCajaAhorro = @@IDENTITY
		
		select 
			@NewJSON = a.JSON,
			@AccionAuditoria	= 'INSERT'
		from [tblCajaAhorro] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE  IDCajaAhorro = @IDCajaAhorro

	end else
	begin
		select @OldJSON = a.JSON,
			@AccionAuditoria	= 'UPDATE' 
		from  [Nomina].[tblCajaAhorro] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE  IDCajaAhorro = @IDCajaAhorro
	
		update  [Nomina].[tblCajaAhorro]
			set Monto = @Monto
				,IDEstatus = @IDEstatus
		where IDCajaAhorro = @IDCajaAhorro
		
		select @NewJSON = a.JSON
		from [Nomina].[tblCajaAhorro] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE  IDCajaAhorro = @IDCajaAhorro
	end;
	
	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @AccionAuditoria
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
	
	insert [Nomina].[tblLogCajaAhorro](Accion,IDCajaAhorro,IDEmpleado,Monto,IDEstatus,IDUsuario)
	select @Accion,@IDCajaAhorro,@IDEmpleado,@Monto,@IDEstatus,@IDUsuario

	exec [Nomina].[spBuscarCajasAhorro] @IDCajaAhorro= @IDCajaAhorro,@IDUsuario=@IDUsuario
GO
