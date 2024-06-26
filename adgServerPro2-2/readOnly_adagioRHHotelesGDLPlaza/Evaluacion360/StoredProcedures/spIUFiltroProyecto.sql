USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spIUFiltroProyecto](
	 @IDFiltroProyecto int
	,@IDProyecto int 
	,@TipoFiltro varchar(255) 
	,@ID varchar(255) 
	,@Descripcion varchar(255)
	,@IDUsuario int
) as
	begin try
		EXEC [Evaluacion360].[spSePuedoModificarElProyecto] @IDProyecto = @IDProyecto,@IDUsuario = @IDUsuario
	end try
	begin catch
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318003';
		return 0;
	end catch

	if (@IDFiltroProyecto = 0) 
	begin
		insert into [Evaluacion360].[tblFiltrosProyectos](IDProyecto,TipoFiltro,ID,Descripcion)
		select @IDProyecto,@TipoFiltro,@ID,@Descripcion

		set @IDFiltroProyecto = @@IDENTITY
	end else
	begin
		update [Evaluacion360].[tblFiltrosProyectos]
		set TipoFiltro = @TipoFiltro
			,ID = @ID
			,Descripcion = @Descripcion
		where IDFiltroProyecto = @IDFiltroProyecto
	end; 

	exec [Evaluacion360].[spAsginarEmpleadosAProyecto] @IDProyecto = @IDProyecto, @IDUsuario = @IDUsuario
	exec [Evaluacion360].[spBuscarFiltrosProyecto] @IDFiltroProyecto = @IDFiltroProyecto
GO
