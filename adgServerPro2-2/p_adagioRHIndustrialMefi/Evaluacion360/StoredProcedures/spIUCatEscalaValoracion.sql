USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spIUCatEscalaValoracion](
	@IDEscalaValoracion int = 0
	,@Nombre varchar(50) 
	,@IDUsuario int
) as

	set @Nombre = UPPER(@Nombre);

	if (@IDEscalaValoracion = 0)
	begin
		IF EXISTS(Select Top 1 1 from [Evaluacion360].[tblCatEscalaValoracion] where Nombre = @Nombre)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003',@CustomMessage= 'El Nombre de la escala no se puede repetir.'
			RETURN 0;
		END;

		insert into [Evaluacion360].[tblCatEscalaValoracion](Nombre)
		select @Nombre

		set @IDEscalaValoracion = @@IDENTITY
	end else
	begin
		IF EXISTS(Select Top 1 1 from [Evaluacion360].[tblCatEscalaValoracion] where Nombre = @Nombre and IDEscalaValoracion <> @IDEscalaValoracion)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003',@CustomMessage= 'El Nombre de la escala no se puede repetir.'
			RETURN 0;
		END;

		update [Evaluacion360].[tblCatEscalaValoracion] 
			set Nombre = @Nombre
		where IDEscalaValoracion = @IDEscalaValoracion
	end;

	exec [Evaluacion360].[spBuscarCatEscalaValoracion] @IDEscalaValoracion = @IDEscalaValoracion
GO
