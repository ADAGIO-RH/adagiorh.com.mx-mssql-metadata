USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROC [Evaluacion360].[spActualizarComentario](
	@IDGrupo INT,
	@Comentario VARCHAR(MAX),
	@IDUsuario INT
) AS

	DECLARE	 
		@OldJSON			VARCHAR(MAX) = '',
		@NewJSON			VARCHAR(MAX),
		@NombreSP			VARCHAR(MAX) = '[Evaluacion360].[spActualizarComentario]',
		@Tabla				VARCHAR(MAX) = '[Evaluacion360].[tblCatGrupos]',
		@Accion				VARCHAR(20)	 = 'UPDATE',
		@Mensaje			VARCHAR(MAX),
		@InformacionExtra	VARCHAR(MAX)
	;

	SELECT @OldJSON = a.JSON 
	FROM [Evaluacion360].[tblCatGrupos] b
		CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.IDGrupo, IDTipoGrupo, Nombre, Comentario FOR XML RAW)) ) a
	WHERE IDGrupo = @IDGrupo

	UPDATE Evaluacion360.tblCatGrupos
		SET Comentario = @Comentario
	WHERE IDGrupo = @IDGrupo

	SELECT @NewJSON = a.JSON 
	FROM [Evaluacion360].[tblCatGrupos] b
		CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.IDGrupo, IDTipoGrupo, Nombre, Comentario FOR XML RAW)) ) a
	WHERE IDGrupo = @IDGrupo

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
