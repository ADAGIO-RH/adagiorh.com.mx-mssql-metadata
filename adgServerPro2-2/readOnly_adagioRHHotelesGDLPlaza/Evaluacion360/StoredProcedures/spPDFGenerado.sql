USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [Evaluacion360].[spPDFGenerado](
	@IDEmpleadoProyecto int
) as
	update [Evaluacion360].[tblEmpleadosProyectos]
		set PDFGenerado = 1
	where IDEmpleadoProyecto = @IDEmpleadoProyecto
GO
