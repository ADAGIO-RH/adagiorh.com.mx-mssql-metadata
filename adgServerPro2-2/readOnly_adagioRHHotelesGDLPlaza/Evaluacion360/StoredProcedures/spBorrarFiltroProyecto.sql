USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spBorrarFiltroProyecto](
	@IDFiltroProyecto int
	,@IDUsuario int
)
as
	declare @IDProyecto int = 0;

	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Evaluacion360].[spBorrarFiltroProyecto]',
		@Tabla		varchar(max) = '[Evaluacion360].[tblFiltrosProyectos]',
		@Accion		varchar(20) = 'DELETE',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;

	select @IDProyecto = IDProyecto
	from [Evaluacion360].[tblFiltrosProyectos]
	where IDFiltroProyecto = @IDFiltroProyecto

	begin try
		EXEC [Evaluacion360].[spSePuedoModificarElProyecto] @IDProyecto = @IDProyecto,@IDUsuario = @IDUsuario
	end try
	begin catch
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318003';
		return 0;
	end catch

	select @OldJSON = a.JSON 
	from [Evaluacion360].[tblFiltrosProyectos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	WHERE IDFiltroProyecto = @IDFiltroProyecto

	delete from [Evaluacion360].[tblFiltrosProyectos]
	where IDFiltroProyecto = @IDFiltroProyecto

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
		,@Mensaje		= @Mensaje
		,@InformacionExtra		= @InformacionExtra

	exec [Evaluacion360].[spAsginarEmpleadosAProyecto] @IDProyecto = @IDProyecto, @IDUsuario = @IDUsuario
GO
