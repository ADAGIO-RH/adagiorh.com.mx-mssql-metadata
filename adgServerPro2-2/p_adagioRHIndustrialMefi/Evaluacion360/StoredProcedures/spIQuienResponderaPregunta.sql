USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE proc [Evaluacion360].[spIQuienResponderaPregunta](
	@IDPregunta int
	,@IDTipoRelacion int
	,@Chk bit
	,@IDUsuario int 
 ) as
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Evaluacion360].[spIQuienResponderaPregunta]',
		@Tabla		varchar(max) = '[Evaluacion360].[tblQuienResponderaPregunta]',
		@Accion		varchar(20)	= '',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max),

		@ID int
	;

	if (not exists (
				select top 1 1
				from [Evaluacion360].[tblQuienResponderaPregunta] with (nolock)
				where IDPregunta = @IDPregunta and IDTipoRelacion = @IDTipoRelacion) and (@Chk = 1))
	begin
		insert into [Evaluacion360].[tblQuienResponderaPregunta](IDPregunta,IDTipoRelacion)
		select @IDPregunta,@IDTipoRelacion

		set @ID = @@IDENTITY

		select @NewJSON = a.JSON
			,@Accion = 'INSERT'
		from [Evaluacion360].[tblQuienResponderaPregunta] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDQuienResponderaPregunta = @ID

	end else begin
		select @OldJSON = a.JSON
			,@Accion = 'DELETE'
		from [Evaluacion360].[tblQuienResponderaPregunta] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDQuienResponderaPregunta = @ID

		delete from  [Evaluacion360].[tblQuienResponderaPregunta]
		where IDPregunta = @IDPregunta and IDTipoRelacion = @IDTipoRelacion
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
