USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc Comedor.spBorrarHistorialDisponibilidadMenu(
	@IDHistorialDisponibilidadMenu int = 0,
	@IDUsuario int
) as

	delete Comedor.tblHistorialDisponibilidadMenu
	where IDHistorialDisponibilidadMenu = @IDHistorialDisponibilidadMenu
GO
