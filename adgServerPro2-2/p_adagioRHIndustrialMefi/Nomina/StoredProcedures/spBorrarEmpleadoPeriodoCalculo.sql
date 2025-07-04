USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBorrarEmpleadoPeriodoCalculo]
(
	@IDEmpleado int,
	@IDPeriodo int,
	@IDUsuario int
)
AS
BEGIN
	declare 
		 @ClaveEmpleado varchar(20)
		,@Colaborador varchar(500)
		,@Periodo varchar(500)
		,@Usuario varchar(max) 
		,@Mensaje varchar(max)

		,@NewJSON Varchar(Max)
		,@OldJSON Varchar(Max) = ''
		,@NombreSP	varchar(max) = '[Nomina].[spBorrarEmpleadoPeriodoCalculo]'
		,@Tabla		varchar(max) = '[Nomina].[tblDetallePeriodo]'
		,@Accion	varchar(20)	= 'DELETE'
	;

	if object_id('tempdb..#tempActividad') is not null drop table #tempActivida;

	create table #tempActividad (
		 IDEmpleado int
		,ClaveEmpleado varchar(20)
		,Colaborador varchar(500)
		,IDPeriodo int
		,Periodo varchar(250)
		,IDUsuario int 
		,Usuario varchar(max) 
	)

	select 
		@ClaveEmpleado = ClaveEmpleado
		,@Colaborador = NOMBRECOMPLETO
	from RH.tblEmpleadosMaster with (nolock)
	where IDEmpleado = @IDEmpleado

	select
		@Periodo = coalesce(ClavePeriodo,'')+' - '+coalesce(Descripcion,'')
	from Nomina.tblCatPeriodos with (nolock)
	where IDPeriodo = @IDPeriodo

	select 
		@Usuario = coalesce(Nombre,'')+' '+coalesce(Apellido,'')+' ('+coalesce(Email,'')+')'
	from Seguridad.tblUsuarios with (nolock)
	where IDUsuario = @IDUsuario

	insert #tempActividad
	select
		@IDEmpleado
		,@ClaveEmpleado
		,@Colaborador
		,@IDPeriodo
		,@Periodo
		,@IDUsuario
		,@Usuario
	
	select @OldJSON = a.JSON 
		,@Accion = 'INSERT'
	from #tempActividad b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a

	IF((SELECT ISNULL(Cerrado,0) FROM Nomina.tblCatPeriodos WHERE IDPeriodo = @IDPeriodo) = 1)
	BEGIN
		set @Mensaje = 'Los datos del periodo que selecciono estan cerrados y no se pueden eliminar.'

		EXEC [Auditoria].[spIAuditoria]
			@IDUsuario		= @IDUsuario
			,@Tabla			= @Tabla
			,@Procedimiento	= @NombreSP
			,@Accion		= @Accion
			,@NewData		= @NewJSON
			,@OldData		= @OldJSON
			,@Mensaje		= @Mensaje

		RAISERROR(@Mensaje,16,1);
		RETURN 0;
	END
	ELSE
	BEGIN
		DELETE Nomina.tblDetallePeriodo
		where IDEmpleado = @IDEmpleado and IDPeriodo = @IDPeriodo

		EXEC [Auditoria].[spIAuditoria]
			@IDUsuario		= @IDUsuario
			,@Tabla			= @Tabla
			,@Procedimiento	= @NombreSP
			,@Accion		= @Accion
			,@NewData		= @NewJSON
			,@OldData		= @OldJSON
	END
END
GO
