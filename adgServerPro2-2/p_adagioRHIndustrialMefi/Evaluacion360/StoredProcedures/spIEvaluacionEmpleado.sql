USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Evaluacion360].[spIEvaluacionEmpleado](
	@IDEvaluacionEmpleado int
	,@IDEmpleadoProyecto int
	,@IDTipoRelacion int
	,@IDEvaluador int
	,@IDUsuario int
) as
	declare
		@IDEstatusEvaluacionEmpleado int = 0
		,@IDProyecto int
	;

	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Evaluacion360].[spIEvaluacionEmpleado]',
		@Tabla		varchar(max) = '[Evaluacion360].[tblEvaluacionesEmpleados]',
		@Accion		varchar(20)	= 'INSERT',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)

	select @IDProyecto = IDProyecto from Evaluacion360.tblEmpleadosProyectos where IDEmpleadoProyecto = @IDEmpleadoProyecto

	begin try
		EXEC [Evaluacion360].[spSePuedoModificarElProyecto] @IDProyecto = @IDProyecto,@IDUsuario = @IDUsuario
	end try
	begin catch
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318003';
		return 0;
	end catch

	if (@IDEvaluacionEmpleado = 0) 
	begin
		insert into  [Evaluacion360].[tblEvaluacionesEmpleados](IDEmpleadoProyecto,IDTipoRelacion,IDEvaluador)
		select @IDEmpleadoProyecto,@IDTipoRelacion,@IDEvaluador

		set @IDEvaluacionEmpleado = @@IDENTITY

		insert [Evaluacion360].[tblEstatusEvaluacionEmpleado](IDEvaluacionEmpleado,IDEstatus,IDUsuario)
		select @IDEvaluacionEmpleado,11/*E_Evaluador asignado*/,@IDUsuario

		select @NewJSON = a.JSON
		from [Evaluacion360].[tblEvaluacionesEmpleados] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDEvaluacionEmpleado = @IDEvaluacionEmpleado
	end else
	begin
		select top 1 @IDEstatusEvaluacionEmpleado = IDEstatus
		from [Evaluacion360].[tblEstatusEvaluacionEmpleado]
		where IDEvaluacionEmpleado = @IDEvaluacionEmpleado
		order by FechaCreacion desc

		if (@IDEstatusEvaluacionEmpleado in (12,13,14))
		begin
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318002'
			return 0;
		end;

		insert [Evaluacion360].[tblEstatusEvaluacionEmpleado](IDEvaluacionEmpleado,IDEstatus,IDUsuario)
		select @IDEvaluacionEmpleado,11,@IDUsuario

		update [Evaluacion360].[tblEvaluacionesEmpleados]
			set IDEvaluador = @IDEvaluador
		where IDEvaluacionEmpleado = @IDEvaluacionEmpleado

		select @NewJSON = a.JSON
		from [Evaluacion360].[tblEvaluacionesEmpleados] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDEvaluacionEmpleado = @IDEvaluacionEmpleado
	end;
	

	EXEC [Evaluacion360].[spActualizarProgresoProyecto]
		@IDProyecto = @IDProyecto
		, @IDUsuario = @IDUsuario

	EXEC [Evaluacion360].[spEstatusEsperandoAprobacion]
		@IDProyecto = @IDProyecto,
		@IDUsuario = @IDUsuario

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
		,@Mensaje		= @Mensaje
		,@InformacionExtra		= @InformacionExtra
--	select * from Evaluacion360.tblCatEstatus

	--select * from [Evaluacion360].[tblEvaluacionesEmpleados]
	--delete [Evaluacion360].[tblEvaluacionesEmpleados]
GO
