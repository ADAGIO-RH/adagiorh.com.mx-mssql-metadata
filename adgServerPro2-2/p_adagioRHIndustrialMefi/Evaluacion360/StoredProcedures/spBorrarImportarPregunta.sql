USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc Evaluacion360.spBorrarImportarPregunta(
	@IDImportarRespuestas int,
	@IDUsuario int
) as
	delete Evaluacion360.tblImportarRespuestas
	where IDImportarRespuestas = @IDImportarRespuestas
GO
