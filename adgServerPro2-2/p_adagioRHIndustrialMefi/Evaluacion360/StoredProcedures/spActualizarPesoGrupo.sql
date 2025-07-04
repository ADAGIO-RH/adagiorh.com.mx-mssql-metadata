USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spActualizarPesoGrupo](
	@IDGrupo int
	,@Peso decimal(18,2)
	,@IDUsuario int
) as
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Evaluacion360].[spActualizarPesoGrupo]',
		@Tabla		varchar(max) = '[Evaluacion360].[tblCatGrupos]',
		@Accion		varchar(20)	= 'UPDATE',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;

	select @OldJSON = a.JSON 
	from [Evaluacion360].[tblCatGrupos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.IDGrupo,IDTipoGrupo,Nombre, Peso For XML Raw)) ) a
	WHERE IDGrupo = @IDGrupo

	update Evaluacion360.tblCatGrupos
		set Peso = @Peso
	where IDGrupo = @IDGrupo

	select @NewJSON = a.JSON 
	from [Evaluacion360].[tblCatGrupos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.IDGrupo,IDTipoGrupo,Nombre, Peso For XML Raw)) ) a
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
