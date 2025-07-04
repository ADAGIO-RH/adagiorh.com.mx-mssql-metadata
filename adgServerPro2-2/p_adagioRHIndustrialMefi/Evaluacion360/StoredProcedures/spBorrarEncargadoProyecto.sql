USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Elimina un Encargado de proyecto
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-01-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-06-14			Aneudy Abreu	Se agregó validación para que no se pueda eliminar un grupo de un 
									proyecto que esté en progreso o finalizado
***************************************************************************************************/
CREATE proc [Evaluacion360].[spBorrarEncargadoProyecto](	
	@IDEncargadoProyecto int
	,@IDUsuario int 
) as
	declare @IDProyecto int ;

	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Evaluacion360].[spBorrarEncargadoProyecto]',
		@Tabla		varchar(max) = '[Evaluacion360].[tblEncargadosProyectos]',
		@Accion		varchar(20)	= 'DELETE',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)


	select @IDProyecto = IDProyecto
	from [Evaluacion360].[tblEncargadosProyectos] with (nolock)
	where IDEncargadoProyecto = @IDEncargadoProyecto

	begin try
		EXEC [Evaluacion360].[spSePuedoModificarElProyecto] @IDProyecto = @IDProyecto,@IDUsuario = @IDUsuario
	end try
	begin catch
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318003';
		return 0;
	end catch

	select @OldJSON = a.JSON 
	from [Evaluacion360].[tblEncargadosProyectos] b with (nolock)
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	WHERE IDEncargadoProyecto = @IDEncargadoProyecto

	delete from [Evaluacion360].[tblEncargadosProyectos]
	where IDEncargadoProyecto = @IDEncargadoProyecto

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
