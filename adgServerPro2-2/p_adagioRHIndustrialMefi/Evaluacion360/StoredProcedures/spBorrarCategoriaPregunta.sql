USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Evaluacion360].[spBorrarCategoriaPregunta](
	@IDCategoriaPregunta int 
	,@IDUsuario int
) as
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Evaluacion360].[spBorrarCategoriaPregunta]',
		@Tabla		varchar(max) = '[Evaluacion360].[tblCatCategoriasPreguntas]',
		@Accion		varchar(20)	= 'DELETE',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;

	BEGIN TRY  
		select @OldJSON = a.JSON 
		from [Evaluacion360].[tblCatCategoriasPreguntas] b with (nolock)
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE [IDCategoriaPregunta] = @IDCategoriaPregunta

		DELETE [Evaluacion360].[tblCatCategoriasPreguntas]
		WHERE [IDCategoriaPregunta] = @IDCategoriaPregunta

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
