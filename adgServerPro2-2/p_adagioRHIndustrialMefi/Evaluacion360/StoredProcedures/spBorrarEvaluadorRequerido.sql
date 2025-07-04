USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spBorrarEvaluadorRequerido](
	@IDEvaluadorRequerido int
	,@IDUsuario int
) as

	declare @IDProyecto int ;

	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Evaluacion360].[spBorrarEvaluadorRequerido]',
		@Tabla		varchar(max) = '[Evaluacion360].[tblEvaluadoresRequeridos]',
		@Accion		varchar(20)	= 'DELETE',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;

	select @IDProyecto = IDProyecto
	from [Evaluacion360].[tblEvaluadoresRequeridos] with (nolock)
	where IDEvaluadorRequerido = @IDEvaluadorRequerido

	begin try
		EXEC [Evaluacion360].[spSePuedoModificarElProyecto] @IDProyecto = @IDProyecto,@IDUsuario = @IDUsuario
	end try
	begin catch
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318003';
		return 0;
	end catch

	select @OldJSON = a.JSON 
	from [Evaluacion360].[tblEvaluadoresRequeridos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	WHERE IDEvaluadorRequerido = @IDEvaluadorRequerido

	delete from [Evaluacion360].[tblEvaluadoresRequeridos]
	where IDEvaluadorRequerido = @IDEvaluadorRequerido

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
GO
