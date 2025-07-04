USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Nomina].[spIUDevolucionCajaAhorro](
	 @IDDevolucionesCajaAhorro int = 0
	,@IDCajaAhorro int 
	,@Monto decimal(18,2)  
	,@IDPeriodo int  
	,@IDUsuario int
) as
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spIUDevolucionCajaAhorro]',
		@Tabla		varchar(max) = '[Nomina].[tblDevolucionesCajaAhorro]',
		@Accion		varchar(20)	= ''


	if (@IDDevolucionesCajaAhorro = 0)
	begin
		insert [Nomina].[tblDevolucionesCajaAhorro](IDCajaAhorro,Monto,IDPeriodo,IDUsuario)
		values (@IDCajaAhorro,@Monto,@IDPeriodo,@IDUsuario)

		set @IDDevolucionesCajaAhorro = @@IDENTITY

		select @NewJSON = a.JSON
			,@Accion = 'INSERT'
		from [Nomina].[tblDevolucionesCajaAhorro] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE  IDDevolucionesCajaAhorro = @IDDevolucionesCajaAhorro
	end else
	begin
		select @OldJSON = a.JSON 
			,@Accion = 'UPDATE'
		from [Nomina].[tblDevolucionesCajaAhorro] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDDevolucionesCajaAhorro = @IDDevolucionesCajaAhorro

		update [Nomina].[tblDevolucionesCajaAhorro]
		set Monto = @Monto
			,IDPeriodo = @IDPeriodo
		where IDDevolucionesCajaAhorro = @IDDevolucionesCajaAhorro

		select @NewJSON = a.JSON
		from [Nomina].[tblDevolucionesCajaAhorro] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE  IDDevolucionesCajaAhorro = @IDDevolucionesCajaAhorro
	end;

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON

	exec [Nomina].[spBuscarDevolucionesCajaAhorro] @IDDevolucionesCajaAhorro=@IDDevolucionesCajaAhorro,@IDUsuario=@IDUsuario
GO
