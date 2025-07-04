USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spIUComentarioPregunta](
	 @IDComentarioPregunta	int		
	,@IDPregunta				int		
	,@Comentario				nvarchar(max)
	,@IDUsuario				int		
) as

	if (@IDComentarioPregunta = 0)
	begin
		insert [Evaluacion360].[tblComentariosPregunta](IDPregunta,Comentario,IDUsuario)
		values(@IDPregunta,@Comentario,@IDUsuario)
	end else
	begin
		update [Evaluacion360].[tblComentariosPregunta]
			set Comentario = @Comentario
		where IDComentarioPregunta = @IDComentarioPregunta
	end;
GO
