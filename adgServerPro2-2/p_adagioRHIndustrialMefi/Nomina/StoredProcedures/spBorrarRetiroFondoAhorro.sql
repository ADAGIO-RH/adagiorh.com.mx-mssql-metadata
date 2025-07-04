USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Nomina].[spBorrarRetiroFondoAhorro](
	@IDRetiroFondoAhorro int				 
	,@IDUsuario int	
) as
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spBorrarRetiroFondoAhorro]',
		@Tabla		varchar(max) = '[Nomina].[tblRetirosFondoAhorro]',
		@Accion		varchar(20)	= 'DELETE'


	select @OldJSON = a.JSON 
	from Nomina.tblRetirosFondoAhorro b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	WHERE  IDRetiroFondoAhorro = @IDRetiroFondoAhorro
		
	if exists (select top 1 1 from  Nomina.tblRetirosFondoAhorro rfa
		Inner join Nomina.tblCatPeriodos P on rfa.IDPeriodo = P.IDPeriodo
	where rfa.IDRetiroFondoAhorro = @IDRetiroFondoAhorro and p.Cerrado = 1)
	begin
		raiserror('No se puede eliminar un movimiento de un periodo cerrado',16,1);
		return;
	end;

	delete from Nomina.tblRetirosFondoAhorro
	where IDRetiroFondoAhorro = @IDRetiroFondoAhorro 

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
GO
