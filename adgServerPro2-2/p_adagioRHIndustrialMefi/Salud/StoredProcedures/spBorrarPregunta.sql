USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Eliminar Pregunta
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2020-05-28
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
create proc [Salud].[spBorrarPregunta](
	@IDPregunta int
	,@IDUsuario int
) as
	Declare 
		@IDCuestionario int 
		,@TipoReferencia int = 0 
		,@IDProyecto int
	;

	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Salud].[spBorrarPregunta]',
		@Tabla		varchar(max) = '[Salud].[tblPreguntas]',
		@Accion		varchar(20)	= 'DELETE',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;

	select top 1 @IDCuestionario = s.IDCuestionario 
	from [Salud].tblPreguntas p with (nolock) 
		JOIN [Salud].[tblSecciones] s on s.IDSeccion = p.IDSeccion
	where p.IDPregunta = @IDPregunta

	select @TipoReferencia = TipoReferencia from [Salud].tblCuestionarios with (nolock) where IDCuestionario = @IDCuestionario

	--if (@TipoReferencia = 1)
	--begin
	--	if exists(select top 1 1
	--			from evaluacion360.tblcatgrupos cg with (nolock)
	--				join Evaluacion360.tblCatProyectos p with (nolock) on p.IDProyecto =  cg.IDReferencia
	--			where cg.IDGrupo = @IDGrupo and cg.TipoReferencia = @TipoReferencia)
	--	begin
	--		select top 1 @IDProyecto = p.IDProyecto
	--		from evaluacion360.tblcatgrupos cg with (nolock)
	--			join Evaluacion360.tblCatProyectos p with (nolock) on p.IDProyecto =  cg.IDReferencia
	--		where cg.IDGrupo = @IDGrupo and cg.TipoReferencia = @TipoReferencia
	--	end;
	--end;

	--if (@TipoReferencia = 4)
	--begin
	--	if exists(select top 1 1
	--			from evaluacion360.tblcatgrupos cg with (nolock)
	--				join Evaluacion360.tblEvaluacionesEmpleados ee with (nolock) on ee.IDEvaluacionEmpleado =  cg.IDReferencia
	--				join Evaluacion360.tblEmpleadosProyectos ep with (nolock) on ep.IDEmpleadoProyecto = ee.IDEmpleadoProyecto
	--			where cg.IDGrupo = @IDGrupo and cg.TipoReferencia = @TipoReferencia)
	--	begin
	--		select top 1 @IDProyecto = ep.IDProyecto
	--		from evaluacion360.tblcatgrupos cg with (nolock)
	--			join Evaluacion360.tblEvaluacionesEmpleados ee with (nolock) on ee.IDEvaluacionEmpleado =  cg.IDReferencia
	--				join Evaluacion360.tblEmpleadosProyectos ep with (nolock) on ep.IDEmpleadoProyecto = ee.IDEmpleadoProyecto
	--		where cg.IDGrupo = @IDGrupo and cg.TipoReferencia = @TipoReferencia
	--	end;
	--end;

	--if (@TipoReferencia in (1,4))
	--begin
	--	begin try
	--		EXEC [Evaluacion360].[spSePuedoModificarElProyecto] @IDProyecto = @IDProyecto,@IDUsuario = @IDUsuario
	--	end try
	--	begin catch
	--		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318003';
	--		return 0;
	--	end catch
	--end


	BEGIN TRY  
		--select @OldJSON = a.JSON 
		--from [Evaluacion360].[tblCatPreguntas] b
		--	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		--WHERE IDPregunta = @IDPregunta

		DELETE [Salud].[tblPosiblesRespuestasPreguntas] WHERE IDPregunta = @IDPregunta
		DELETE [Salud].[tblPreguntas] WHERE IDPregunta = @IDPregunta

		EXEC [Auditoria].[spIAuditoria]
			@IDUsuario		= @IDUsuario
			,@Tabla			= @Tabla
			,@Procedimiento	= @NombreSP
			,@Accion		= @Accion
			,@NewData		= @NewJSON
			,@OldData		= @OldJSON
			,@Mensaje		= @Mensaje
			,@InformacionExtra		= @InformacionExtra
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;
GO
