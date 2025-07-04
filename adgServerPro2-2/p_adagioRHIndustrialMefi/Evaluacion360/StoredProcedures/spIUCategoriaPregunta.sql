USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Evaluacion360].[spIUCategoriaPregunta](
	@IDCategoriaPregunta int = 0
	,@Nombre varchar(255) 
	,@IDUsuario int
) as 
	select @Nombre = UPPER(@Nombre)

	if (@IDCategoriaPregunta = 0)
	begin
		insert into [Evaluacion360].[tblCatCategoriasPreguntas](Nombre)
		select @Nombre

		set @IDCategoriaPregunta = @@IDENTITY
	end else
	begin
		update [Evaluacion360].[tblCatCategoriasPreguntas]
			set Nombre = @Nombre
		where IDCategoriaPregunta = @IDCategoriaPregunta
	end;

	exec [Evaluacion360].[spBuscarCategoriaPregunta] @IDCategoriaPregunta = @IDCategoriaPregunta
GO
