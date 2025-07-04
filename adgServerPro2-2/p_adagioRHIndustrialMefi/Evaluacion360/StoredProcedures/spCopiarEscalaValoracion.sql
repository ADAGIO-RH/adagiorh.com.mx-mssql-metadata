USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	@Tipo :	1 - Proyecto
		  : 2 - Grupo
*/
CREATE proc [Evaluacion360].[spCopiarEscalaValoracion](
	 @IDEscalaValoracion int 
	,@Tipo int 
	,@ID int 
	,@IDUsuario int
) as
	declare 
		@IDProyecto int
		,@TipoReferencia int 
	;
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Evaluacion360].[spCopiarEscalaValoracion]',
		@Tabla		varchar(max) = '[Evaluacion360].[tblEscalasValoracionesProyectos]',
		@Accion		varchar(20)	= 'UPDATE',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;

	if (@Tipo = 1) -- Escala de Proyecto
	begin
		-- Validar el estatus del Proyecto
		begin try
			EXEC [Evaluacion360].[spSePuedoModificarElProyecto] @IDProyecto = @ID,@IDUsuario = @IDUsuario
		end try
		begin catch
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318003';
			return 0;
		end catch

		select @OldJSON = a.JSON 
			,@Tabla = '[Evaluacion360].[tblEscalasValoracionesProyectos]'
		from [Evaluacion360].[tblEscalasValoracionesProyectos] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDProyecto = @ID

		delete from [Evaluacion360].[tblEscalasValoracionesProyectos]
		where IDProyecto = @ID

		insert [Evaluacion360].[tblEscalasValoracionesProyectos](IDProyecto,Nombre,Valor)
		select @ID,Nombre,Valor
		from [Evaluacion360].[tblDetalleEscalaValoracion]
		where IDEscalaValoracion = @IDEscalaValoracion

		select @NewJSON = a.JSON 
		from [Evaluacion360].[tblEscalasValoracionesProyectos] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDProyecto = @ID
	end;

 	if (@Tipo = 2) -- Escala de Grupo
	begin
		-- En caso de la el grupo sea TipoReferencia = 4 entonces validar el estatus del Proyecto
		select top 1 @TipoReferencia = TipoReferencia from Evaluacion360.tblCatGrupos where IDGrupo  = @ID

		if (@TipoReferencia = 1)
		begin
			if exists(select top 1 1
					from evaluacion360.tblcatgrupos cg
						join Evaluacion360.tblCatProyectos p on p.IDProyecto =  cg.IDReferencia
					where cg.IDGrupo = @ID and cg.TipoReferencia = @TipoReferencia)
			begin
				select top 1 @IDProyecto = p.IDProyecto
				from evaluacion360.tblcatgrupos cg
					join Evaluacion360.tblCatProyectos p on p.IDProyecto =  cg.IDReferencia
				where cg.IDGrupo = @ID and cg.TipoReferencia = @TipoReferencia
			end;
		end;

		if (@TipoReferencia = 4)
		begin
			if exists(select top 1 1
					from evaluacion360.tblcatgrupos cg
						join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEvaluacionEmpleado =  cg.IDReferencia
						join Evaluacion360.tblEmpleadosProyectos ep on ep.IDEmpleadoProyecto = ee.IDEmpleadoProyecto
					where cg.IDGrupo = @ID and cg.TipoReferencia = @TipoReferencia)
			begin
				select top 1 @IDProyecto = ep.IDProyecto
				from evaluacion360.tblcatgrupos cg
					join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEvaluacionEmpleado =  cg.IDReferencia
						join Evaluacion360.tblEmpleadosProyectos ep on ep.IDEmpleadoProyecto = ee.IDEmpleadoProyecto
				where cg.IDGrupo = @ID and cg.TipoReferencia = @TipoReferencia
			end;
		end;

		if (@TipoReferencia in (1,4))
		begin
			begin try
				EXEC [Evaluacion360].[spSePuedoModificarElProyecto] @IDProyecto = @IDProyecto,@IDUsuario = @IDUsuario
			end try
			begin catch
				EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318003';
				return 0;
			end catch
		end

		select @OldJSON = a.JSON 
			,@Tabla = '[Evaluacion360].[tblEscalasValoracionesGrupos]'
		from [Evaluacion360].[tblEscalasValoracionesGrupos] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDGrupo = @ID

		delete from [Evaluacion360].[tblEscalasValoracionesGrupos]
		where IDGrupo = @ID

		insert [Evaluacion360].[tblEscalasValoracionesGrupos](IDGrupo,Nombre,Valor)
		select @ID,Nombre,Valor
		from [Evaluacion360].[tblDetalleEscalaValoracion]
		where IDEscalaValoracion = @IDEscalaValoracion

		select @NewJSON = a.JSON 
		from [Evaluacion360].[tblEscalasValoracionesGrupos] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDGrupo = @ID
		
	end;

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
		,@Mensaje		= @Mensaje
		,@InformacionExtra		= @InformacionExtra
GO
