USE [p_adagioRHRHUniversal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spPDFGenerado](
	@IDEmpleadoProyecto int,
	@IDNotificacion int = null
) as
	update [Evaluacion360].[tblEmpleadosProyectos]
		set PDFGenerado = 1,
			IDNotificacion = @IDNotificacion
	where IDEmpleadoProyecto = @IDEmpleadoProyecto
GO
