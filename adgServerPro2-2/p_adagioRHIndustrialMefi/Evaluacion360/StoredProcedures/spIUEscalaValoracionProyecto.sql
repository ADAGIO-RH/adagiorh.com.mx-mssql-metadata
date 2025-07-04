USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spIUEscalaValoracionProyecto](
	 @IDEscalaValoracionProyecto int = 0
	,@IDProyecto int 
	,@Nombre varchar(100)
	,@Descripcion varchar(255)
	,@Valor	DECIMAL(18,2)
	,@IDUsuario int
) as
	begin try
		EXEC [Evaluacion360].[spSePuedoModificarElProyecto] @IDProyecto = @IDProyecto,@IDUsuario = @IDUsuario
	end try
	begin catch
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318003';
		return 0;
	end catch
		
	if (@Nombre is not null)
	begin
		select 
			@Nombre = UPPER(@Nombre)
			,@Descripcion = UPPER(@Descripcion)

		if (@IDEscalaValoracionProyecto = 0)
		begin
			insert [Evaluacion360].[tblEscalasValoracionesProyectos](IDProyecto,Nombre,Descripcion,Valor)
			select @IDProyecto,@Nombre,@Descripcion,@Valor

			select @IDEscalaValoracionProyecto = @@IDENTITY
		end else
		begin
			update [Evaluacion360].[tblEscalasValoracionesProyectos]
				set Nombre = @Nombre
					,Descripcion = @Descripcion 
					,Valor = @Valor
			where IDEscalaValoracionProyecto = @IDEscalaValoracionProyecto
		end;
	end;

	exec  [Evaluacion360].[spBuscarEscalasValoracionesProyecto]
		@IDEscalaValoracionProyecto = @IDEscalaValoracionProyecto
		,@IDUsuario = @IDUsuario
GO
