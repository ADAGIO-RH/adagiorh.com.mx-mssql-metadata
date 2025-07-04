USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spIUEvaluadorRequerido](
	 @IDEvaluadorRequerido int 
	,@IDProyecto		   int 
	,@IDTipoRelacion	   int 
	,@Minimo			   int 
	,@Maximo			   int 
	,@IDUsuario int
	,@WithResult bit = 1
) as
	
	begin try
		EXEC [Evaluacion360].[spSePuedoModificarElProyecto] @IDProyecto = @IDProyecto,@IDUsuario = @IDUsuario
	end try
	begin catch
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318003';
		return 0;
	end catch

	if (@IDEvaluadorRequerido = 0)
	begin

		if exists(SELECT TOP 1 1
			FROM [Evaluacion360].[tblEvaluadoresRequeridos] WITH (nolock)
			WHERE IDProyecto = @IDProyecto and IDTipoRelacion = @IDTipoRelacion)
		begin
			raiserror('Este tipo de restricción ya existe en el proyecto.',16,1);  
			return;
		end;

		insert into [Evaluacion360].[tblEvaluadoresRequeridos](IDProyecto,IDTipoRelacion,Minimo,Maximo)
		select @IDProyecto,@IDTipoRelacion,@Minimo,@Maximo	
		
		select @IDEvaluadorRequerido=@@IDENTITY			
	end else
	begin
		update [Evaluacion360].[tblEvaluadoresRequeridos]
		set  IDTipoRelacion = @IDTipoRelacion
			,Minimo = @Minimo
			,Maximo = @Maximo
		where IDEvaluadorRequerido = @IDEvaluadorRequerido
	end;

	exec [Evaluacion360].[spAsginarEmpleadosAProyecto] 
		@IDProyecto = @IDProyecto
		,@IDUsuario = @IDUsuario
		
	IF (@WithResult = 1)
	 exec [Evaluacion360].[spBuscarEvaluadoresRequeridos] @IDProyecto=@IDProyecto, @IDEvaluadorRequerido = @IDEvaluadorRequerido
GO
