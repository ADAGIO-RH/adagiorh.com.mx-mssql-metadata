USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spBorrarDetalleEscalaValoracion](
	@IDDetalleEscalaValoracion	int
	,@IDUsuario int
) as
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Evaluacion360].[spBorrarDetalleEscalaValoracion]',
		@Tabla		varchar(max) = '[Evaluacion360].[tblDetalleEscalaValoracion]',
		@Accion		varchar(20)	= 'DELETE',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;

	select @OldJSON = a.JSON 
	from [Evaluacion360].[tblDetalleEscalaValoracion] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	WHERE IDDetalleEscalaValoracion = @IDDetalleEscalaValoracion

	DELETE FROM [Evaluacion360].[tblDetalleEscalaValoracion]
	WHERE IDDetalleEscalaValoracion = @IDDetalleEscalaValoracion

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
