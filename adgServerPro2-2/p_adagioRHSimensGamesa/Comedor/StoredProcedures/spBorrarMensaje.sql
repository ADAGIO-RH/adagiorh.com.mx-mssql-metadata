USE [p_adagioRHSimensGamesa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc Comedor.spBorrarMensaje(
	@IDMensaje int,
	@IDUsuario int
) as

	delete Comedor.tblMensajes where IDMensaje = @IDMensaje
GO
