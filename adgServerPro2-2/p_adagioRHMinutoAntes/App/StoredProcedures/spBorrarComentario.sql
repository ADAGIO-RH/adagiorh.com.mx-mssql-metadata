USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [App].[spBorrarComentario](
	 @IDComentario	int		
	,@IDUsuario				int		
) as
	delete from  [App].[tblComentarios]
	where IDComentario = @IDComentario
GO
