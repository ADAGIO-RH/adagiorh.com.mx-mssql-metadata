USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [RH].[spBorrarJefeEmpleado](
	@IDJefeEmpleado int 
	,@IDUsuario int
) as

	
	declare @IDEmpleado int
	,@IDUsuarioTrabajando int
	,@IDJefe int ;

	 
  
  DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	select @OldJSON = a.JSON from [RH].[tblJefesEmpleados] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDJefeEmpleado = @IDJefeEmpleado
    	

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblJefesEmpleados]','[RH].[spBorrarJefeEmpleado]','DELETE','',@OldJSON




	select @IDEmpleado = IDEmpleado
		,@IDJefe = IDJefe
	from [RH].[tblJefesEmpleados] with (nolock)
	where IDJefeEmpleado = @IDJefeEmpleado

	delete [RH].[tblJefesEmpleados]
	where IDJefeEmpleado = @IDJefeEmpleado

	exec [RH].[spActualizarTotalesRelacionesEmpleados] @IDEmpleado, @IDEmpleado

	select top 1 @IDUsuarioTrabajando = IDUsuario from Seguridad.tblUsuarios where IDEmpleado = @IDJefe

	 exec [RH].[spSchedulerActualizarTotalesRelacionesEmpleados] @IDUsuario = @IDUsuarioTrabajando, @IDUsuarioLogin = @IDUsuario 	 
	--exec [Seguridad].[spAsginarEmpleadosAUsuarioPorFiltro] @IDUsuario = @IDUsuarioTrabajando, @IDUsuarioLogin = @IDUsuario 
GO
