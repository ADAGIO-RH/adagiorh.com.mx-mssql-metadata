USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Nomina].[spBorrarDevolucionCajaAhorro](
	@IDDevolucionesCajaAhorro int
	,@IDUsuario int
) as
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spBorrarDevolucionCajaAhorro]',
		@Tabla		varchar(max) = '[Nomina].[tblDevolucionesCajaAhorro]',
		@Accion		varchar(20)	= 'DELETE',
		@CustomMessage varchar(max)

	select @OldJSON = a.JSON 
	from (
		select 
			 dev.IDDevolucionesCajaAhorro
			,dev.IDCajaAhorro
			,dev.Monto
			,ca.IDEmpleado
			,e.ClaveEmpleado
			,e.NOMBRECOMPLETO as Colaborador
			,dev.IDPeriodo
			,p.ClavePeriodo
			,p.Descripcion as Periodo
			,dev.IDUsuario
			,coalesce(u.Nombre,'')+' '+coalesce(u.Apellido,'') as Usuario
			,dev.FechaHora
		from [Nomina].[tblDevolucionesCajaAhorro] dev with (nolock)
			join [Nomina].[tblCajaAhorro] ca with (nolock) on ca.IDCajaAhorro = dev.IDCajaAhorro
			join [RH].[tblEmpleadosMaster] e with (nolock) on ca.IDEmpleado = e.IDEmpleado
			join [Nomina].[tblCatPeriodos] p with (nolock) on p.IDPeriodo = dev.IDPeriodo
			join [Seguridad].[tblUsuarios] u with (nolock) on u.IDUsuario = dev.IDUsuario
		where IDDevolucionesCajaAhorro = @IDDevolucionesCajaAhorro
	) b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a

	begin try
		delete from Nomina.tblDevolucionesCajaAhorro
		where IDDevolucionesCajaAhorro = @IDDevolucionesCajaAhorro
	end try
	BEGIN CATCH  
		set @CustomMessage = ERROR_MESSAGE()

		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002',@CustomMessage=@CustomMessage
		return 0;
    END CATCH ;

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
GO
