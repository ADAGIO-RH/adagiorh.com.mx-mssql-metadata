USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Nomina].[IURetiroFondoAhorro](
	 @IDRetiroFondoAhorro int				 
	,@IDFondoAhorro int				
	,@IDEmpleado int					
	,@MontoEmpresa decimal(18,2)		
	,@MontoTrabajador decimal(18,2)
	,@IDPeriodo int					
	,@IDUsuario int					
) as 
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[IURetiroFondoAhorro]',
		@Tabla		varchar(max) = '[Nomina].[tblRetirosFondoAhorro]',
		@Accion		varchar(20)
	
	if (isnull(@IDRetiroFondoAhorro,0) > 0)
	begin
		select @OldJSON = a.JSON 
		from [Nomina].[tblRetirosFondoAhorro] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE  IDRetiroFondoAhorro = @IDRetiroFondoAhorro
	end

	if (@IDRetiroFondoAhorro = 0)
	begin
		insert [Nomina].[tblRetirosFondoAhorro](IDFondoAhorro,IDEmpleado,MontoEmpresa,MontoTrabajador,IDPeriodo,IDUsuario)
		select @IDFondoAhorro,@IDEmpleado,@MontoEmpresa,@MontoTrabajador,@IDPeriodo,@IDUsuario

		set @IDRetiroFondoAhorro = @@IDENTITY

		select @NewJSON = a.JSON 
				,@Accion = 'INSERT'
		from [Nomina].[tblRetirosFondoAhorro] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE  IDRetiroFondoAhorro = @IDRetiroFondoAhorro

	end else 
	begin
		update Nomina.tblRetirosFondoAhorro
			set MontoEmpresa	= @MontoEmpresa
			   ,MontoTrabajador	= @MontoTrabajador
			   ,IDPeriodo		= @IDPeriodo
		where IDRetiroFondoAhorro = @IDRetiroFondoAhorro

		select @NewJSON = a.JSON 
				,@Accion = 'UPDATE'
		from [Nomina].[tblRetirosFondoAhorro] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE  IDRetiroFondoAhorro = @IDRetiroFondoAhorro
	end;

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
GO
