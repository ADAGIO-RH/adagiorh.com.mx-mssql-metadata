USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spBorrarComentarioPregunta](
	 @IDComentarioPregunta	int		
	,@IDUsuario				int		
) as
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Evaluacion360].[spBorrarComentarioPregunta]',
		@Tabla		varchar(max) = '[Evaluacion360].[tblComentariosPregunta]',
		@Accion		varchar(20)	= 'DELETE',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;

	select @OldJSON = a.JSON 
	from [Evaluacion360].[tblComentariosPregunta] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	WHERE IDComentarioPregunta = @IDComentarioPregunta

	delete from  [Evaluacion360].[tblComentariosPregunta]
	where IDComentarioPregunta = @IDComentarioPregunta

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
