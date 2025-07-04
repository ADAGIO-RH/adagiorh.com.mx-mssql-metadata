USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [Salud].[spBorrarPosibleRespuestaPregunta](
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
		@NombreSP	varchar(max) = '[Salud].[spBorrarPosibleRespuestaPregunta]',
		@Tabla		varchar(max) = '[Salud].[tblPosiblesRespuestasPreguntas]',
		@Accion		varchar(20)	= 'DELETE',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;

	select @OldJSON = a.JSON 	
	from [Salud].[tblPosiblesRespuestasPreguntas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	WHERE IDPosibleRespuesta = @IDPosibleRespuesta

	delete from [Salud].[tblPosiblesRespuestasPreguntas]
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
