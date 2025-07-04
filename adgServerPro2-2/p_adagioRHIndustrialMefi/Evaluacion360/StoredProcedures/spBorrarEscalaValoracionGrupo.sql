USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spBorrarEscalaValoracionGrupo](
	@IDEscalaValoracionGrupo	int = 0
	,@IDGrupo	int = 0
	,@IDUsuario int 
) as
	declare @IDProyecto int
			,@TipoReferencia int ;

	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Evaluacion360].[spBorrarEscalaValoracionGrupo]',
		@Tabla		varchar(max) = '[Evaluacion360].[tblEscalasValoracionesGrupos]',
		@Accion		varchar(20)	= 'DELETE',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;
	
	select top 1 @TipoReferencia = TipoReferencia from Evaluacion360.tblCatGrupos where IDGrupo  = @IDGrupo
	
	if (@IDEscalaValoracionGrupo <> 0)
	begin
		delete from [Evaluacion360].[tblEscalasValoracionesGrupos]
		where IDEscalaValoracionGrupo = @IDEscalaValoracionGrupo
	end;

	if (@IDGrupo <> 0)
	begin
		if (@TipoReferencia = 1)
		begin
			if exists(select top 1 1
					from evaluacion360.tblcatgrupos cg
						join Evaluacion360.tblCatProyectos p on p.IDProyecto =  cg.IDReferencia
					where cg.IDGrupo = @IDGrupo and cg.TipoReferencia = @TipoReferencia)
			begin
				select top 1 @IDProyecto = p.IDProyecto
				from evaluacion360.tblcatgrupos cg
					join Evaluacion360.tblCatProyectos p on p.IDProyecto =  cg.IDReferencia
				where cg.IDGrupo = @IDGrupo and cg.TipoReferencia = @TipoReferencia
			end;
		end;

		if (@TipoReferencia = 4)
		begin
			if exists(select top 1 1
					from evaluacion360.tblcatgrupos cg
						join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEvaluacionEmpleado =  cg.IDReferencia
						join Evaluacion360.tblEmpleadosProyectos ep on ep.IDEmpleadoProyecto = ee.IDEmpleadoProyecto
					where cg.IDGrupo = @IDGrupo and cg.TipoReferencia = @TipoReferencia)
			begin
				select top 1 @IDProyecto = ep.IDProyecto
				from evaluacion360.tblcatgrupos cg
					join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEvaluacionEmpleado =  cg.IDReferencia
						join Evaluacion360.tblEmpleadosProyectos ep on ep.IDEmpleadoProyecto = ee.IDEmpleadoProyecto
				where cg.IDGrupo = @IDGrupo and cg.TipoReferencia = @TipoReferencia
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
		from [Evaluacion360].[tblEscalasValoracionesGrupos] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDGrupo = @IDGrupo

		delete from [Evaluacion360].[tblEscalasValoracionesGrupos]
		where IDGrupo = @IDGrupo

		EXEC [Auditoria].[spIAuditoria]
			@IDUsuario		= @IDUsuario
			,@Tabla			= @Tabla
			,@Procedimiento	= @NombreSP
			,@Accion		= @Accion
			,@NewData		= @NewJSON
			,@OldData		= @OldJSON
			,@Mensaje		= @Mensaje
			,@InformacionExtra		= @InformacionExtra
	end;
GO
