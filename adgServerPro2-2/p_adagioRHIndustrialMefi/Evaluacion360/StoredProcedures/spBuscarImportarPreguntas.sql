USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc Evaluacion360.spBuscarImportarPreguntas(
	@IDProyectoSource		int,
	@IDProyectoTarget		int,
	@IDPreguntaSource		int
) as
	select
		ir.*
		,proSource.Nombre as ProyectoSource
		,preSource.Descripcion as PreguntaSource
		,proTarget.Nombre as ProyectoTarget
		,preTarget.Descripcion as PreguntaTarget
	from Evaluacion360.tblImportarRespuestas ir with (nolock)
		join Evaluacion360.tblCatProyectos proSource with (nolock) on proSource.IDProyecto = ir.IDProyectoSource
		join Evaluacion360.tblCatProyectos proTarget with (nolock) on proTarget.IDProyecto = ir.IDProyectoTarget
		join Evaluacion360.tblCatPreguntas preSource with (nolock) on preSource.IDPregunta = ir.IDPreguntaSource
		join Evaluacion360.tblCatPreguntas preTarget with (nolock) on preTarget.IDPregunta = ir.IDPreguntaTarget
	where ir.IDProyectoSource = @IDProyectoSource --and ir.IDProyectoTarget = @IDProyectoTarget and ir.IDPreguntaSource = @IDPreguntaSource
GO
