USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc App.spBorrarCatDatoExtra(
	@IDDatoExtra int = 0,
	@IDUsuario int
) as
	
	delete App.tblValoresDatosExtras
	where IDDatoExtra = @IDDatoExtra

	delete App.tblCatDatosExtras
	where IDDatoExtra = @IDDatoExtra
GO
