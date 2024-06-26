USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [Nomina].[spIUSalariosMinimos](
	@IDSalarioMinimo int = 0 
	,@Fecha date
	,@SalarioMinimo decimal(9,2)
	,@UMA decimal(9,2)    
	,@FactorDescuento decimal(9,2) 
	,@IDUsuario int
)
as
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spIUSalariosMinimos]',
		@Tabla		varchar(max) = '[Nomina].[tblSalariosMinimos]',
		@Accion		varchar(20)	= ''
	;

	if (@IDSalarioMinimo is null or @IDSalarioMinimo = 0)
	begin
		insert into [Nomina].[tblSalariosMinimos](Fecha, SalarioMinimo,UMA,FactorDescuento)
		select @Fecha,@SalarioMinimo,@UMA,@FactorDescuento

		select @IDSalarioMinimo=@@IDENTITY

		select @NewJSON = a.JSON
			,@Accion = 'INSERT'
		from [Nomina].[tblSalariosMinimos] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDSalarioMinimo = @IDSalarioMinimo
    end else
    begin
		select @OldJSON = a.JSON
			,@Accion = 'UPDATE'
		from [Nomina].[tblSalariosMinimos] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDSalarioMinimo = @IDSalarioMinimo

		update [Nomina].[tblSalariosMinimos]
			set Fecha = @Fecha
				,SalarioMinimo = @SalarioMinimo
				,UMA = @UMA
				,FactorDescuento = @FactorDescuento
		where IDSalarioMinimo = @IDSalarioMinimo

		select @NewJSON = a.JSON
		from [Nomina].[tblSalariosMinimos] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDSalarioMinimo = @IDSalarioMinimo
    end;

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON

    exec [Nomina].[spBuscarSalariosMinimos] @IDSalarioMinimo=@IDSalarioMinimo
GO
