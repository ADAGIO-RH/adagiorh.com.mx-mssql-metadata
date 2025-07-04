USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc Evaluacion360.spIUImportarPregunta(
	@IDProyectoSource		int,
	@IDProyectoTarget		int,
	@IDPreguntaSource		int,
	@IDPreguntaTarget		int,
	@IDUsuario int
) as
	
	insert Evaluacion360.tblImportarRespuestas(IDProyectoSource,IDProyectoTarget,IDPreguntaSource,IDPreguntaTarget,IDUsuario)
	values(@IDProyectoSource,@IDProyectoTarget,@IDPreguntaSource,@IDPreguntaTarget,@IDUsuario)
GO
