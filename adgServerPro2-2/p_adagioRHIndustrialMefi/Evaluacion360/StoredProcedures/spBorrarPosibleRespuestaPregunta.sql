USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spBorrarPosibleRespuestaPregunta](
	@IDPosibleRespuesta int
	,@IDUsuario int
) as
	declare @IDGrupo int 
		,@TipoReferencia int = 0 
		,@IDProyecto int
	;

	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Evaluacion360].[spBorrarPosibleRespuestaPregunta]',
		@Tabla		varchar(max) = '[Evaluacion360].[tblPosiblesRespuestasPreguntas]',
		@Accion		varchar(20)	= 'DELETE',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;

	select top 1 @IDGrupo = p.IDGrupo
	from Evaluacion360.tblPosiblesRespuestasPreguntas pr with (nolock)
		join Evaluacion360.tblCatPreguntas p on p.IDPregunta = pr.IDPregunta
	where IDPosibleRespuesta = @IDPosibleRespuesta

	select @TipoReferencia = TipoReferencia from Evaluacion360.tblCatGrupos where IDGrupo  = @IDGrupo

	
	if (@TipoReferencia = 1)
	begin
		if exists(select top 1 1
				from evaluacion360.tblcatgrupos cg with (nolock)
					join Evaluacion360.tblCatProyectos p with (nolock) on p.IDProyecto =  cg.IDReferencia
				where cg.IDGrupo = @IDGrupo and cg.TipoReferencia = @TipoReferencia)
		begin
			select top 1 @IDProyecto = p.IDProyecto
			from evaluacion360.tblcatgrupos cg with (nolock)
				join Evaluacion360.tblCatProyectos p with (nolock) on p.IDProyecto =  cg.IDReferencia
			where cg.IDGrupo = @IDGrupo and cg.TipoReferencia = @TipoReferencia
		end;
	end;

	if (@TipoReferencia = 4)
	begin
		if exists(select top 1 1
				from evaluacion360.tblcatgrupos cg with (nolock)
					join Evaluacion360.tblEvaluacionesEmpleados ee with (nolock) on ee.IDEvaluacionEmpleado =  cg.IDReferencia
					join Evaluacion360.tblEmpleadosProyectos ep with (nolock) on ep.IDEmpleadoProyecto = ee.IDEmpleadoProyecto
				where cg.IDGrupo = @IDGrupo and cg.TipoReferencia = @TipoReferencia)
		begin
			select top 1 @IDProyecto = ep.IDProyecto
			from evaluacion360.tblcatgrupos cg with (nolock)
				join Evaluacion360.tblEvaluacionesEmpleados ee with (nolock) on ee.IDEvaluacionEmpleado =  cg.IDReferencia
					join Evaluacion360.tblEmpleadosProyectos ep with (nolock) on ep.IDEmpleadoProyecto = ee.IDEmpleadoProyecto
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
	from [Evaluacion360].[tblPosiblesRespuestasPreguntas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	WHERE IDPosibleRespuesta = @IDPosibleRespuesta

	delete from [Evaluacion360].[tblPosiblesRespuestasPreguntas]
	where IDPosibleRespuesta = @IDPosibleRespuesta

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
