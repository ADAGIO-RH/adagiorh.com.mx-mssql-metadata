USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
  
CREATE proc [Evaluacion360].[spBorrarEvaluacionEmpleado](  
  @IDEvaluacionEmpleado int  
 ,@IDUsuario int  
) as  
	declare  @IDProyecto int = 0
		,@IDTipoRelacion int = 0
		,@IDEstatus int = 0
		,@AutoevaluacionNoEsRequerida varchar(5)
	;

	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Evaluacion360].[spBorrarEvaluacionEmpleado]',
		@Tabla		varchar(max) = '[Evaluacion360].[tblEvaluacionesEmpleados]',
		@Accion		varchar(20)	= 'DELETE',
		@Mensaje	varchar(max) = 'SE ACTUALIZA EL ESTATUS DE [EVALUADOR ASIGNADO] a  [PENDIENTE DE ASIGNACIONES]',
		@InformacionExtra	varchar(max)
	;
	
	if object_id('tempdb..#tempEstatusEva') is not null drop table #tempEstatusEva

	create table #tempEstatusEva (
		IDEvaluacionEmpleado	int	 
		,IDEmpleadoProyecto	int 
		,IDTipoRelacion	int	 
		,IDEvaluador	int	 
		,TotalPreguntas	int	 
		,TotalPreguntasRespondidas	int	 
		,Progreso	int	 
		,IDTipoEvaluacion	int	 
		,IDEstatusEvaluacionEmpleado int
		,IDEstatus int
		,Estatus varchar(255)
		,IDUsuario int
		,FechaCreacion datetime
		,[ROW] int
	 );

	insert #tempEstatusEva
	exec [Evaluacion360].[spBuscarEstatusEvaluacionEmpleado] @IDEvaluacionEmpleado =@IDEvaluacionEmpleado

	select top 1 @IDProyecto = ep.IDProyecto
		,@IDTipoRelacion = ee.IDTipoRelacion
		,@IDEstatus = estatus.IDEstatus
	from [Evaluacion360].[tblEvaluacionesEmpleados] ee with (nolock)
		join [Evaluacion360].tblEmpleadosProyectos ep with (nolock) on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		left join #tempEstatusEva estatus on estatus.IDEvaluacionEmpleado = ee.IDEvaluacionEmpleado
	where ee.IDEvaluacionEmpleado = @IDEvaluacionEmpleado

	select @AutoevaluacionNoEsRequerida = Valor
	from Evaluacion360.tblConfiguracionAvanzadaProyecto with (nolock)
	where IDConfiguracionAvanzada = 9  and IDProyecto = @IDProyecto

	if (@IDEstatus in (12,13,14))
	begin
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318002'
		return 0;
	end;

	if (@IDTipoRelacion != 4)
	begin
		--delete [Evaluacion360].[tblEvaluacionesEmpleados]  
		--where IDEvaluacionEmpleado = @IDEvaluacionEmpleado

		select @OldJSON = a.JSON 
		from [Evaluacion360].[tblEvaluacionesEmpleados] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDEvaluacionEmpleado = @IDEvaluacionEmpleado

		update [Evaluacion360].[tblEvaluacionesEmpleados] 
			set IDEvaluador = null 
		where IDEvaluacionEmpleado = @IDEvaluacionEmpleado

		insert [Evaluacion360].[tblEstatusEvaluacionEmpleado](IDEvaluacionEmpleado,IDEstatus,IDUsuario)
		select @IDEvaluacionEmpleado,10/*E_Pendiente de asignaciones*/,@IDUsuario

		EXEC [Evaluacion360].[spActualizarProgresoProyecto]
				@IDProyecto = @IDProyecto
				, @IDUsuario = @IDUsuario

		EXEC [Auditoria].[spIAuditoria]
			@IDUsuario		= @IDUsuario
			,@Tabla			= @Tabla
			,@Procedimiento	= @NombreSP
			,@Accion		= @Accion
			,@NewData		= @NewJSON
			,@OldData		= @OldJSON
			,@Mensaje		= @Mensaje
			,@InformacionExtra		= @InformacionExtra

		return;
	end else
	begin
		if (exists(
			select top 1 1 
			from [Evaluacion360].[tblEvaluadoresRequeridos]
			where IDProyecto = @IDProyecto and IDTipoRelacion = 4
		) and isnull(@AutoevaluacionNoEsRequerida,'true') = 'true')
		begin
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318001'
			return 0;
		end else
		begin
			select @OldJSON = a.JSON 
			from [Evaluacion360].[tblEvaluacionesEmpleados] b
				Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
			WHERE IDEvaluacionEmpleado = @IDEvaluacionEmpleado

			delete [Evaluacion360].[tblEvaluacionesEmpleados] 
			where IDEvaluacionEmpleado = @IDEvaluacionEmpleado

			EXEC [Evaluacion360].[spActualizarProgresoProyecto]
				@IDProyecto = @IDProyecto
				, @IDUsuario = @IDUsuario

			EXEC [Auditoria].[spIAuditoria]
				@IDUsuario		= @IDUsuario
				,@Tabla			= @Tabla
				,@Procedimiento	= @NombreSP
				,@Accion		= @Accion
				,@NewData		= @NewJSON
				,@OldData		= @OldJSON
				,@Mensaje		= @Mensaje
				,@InformacionExtra		= @InformacionExtra

			insert [Evaluacion360].[tblEstatusEvaluacionEmpleado](IDEvaluacionEmpleado,IDEstatus,IDUsuario)
			select @IDEvaluacionEmpleado,10/*E_Pendiente de asignaciones*/,@IDUsuario

			return;
		end;
	end;
GO
