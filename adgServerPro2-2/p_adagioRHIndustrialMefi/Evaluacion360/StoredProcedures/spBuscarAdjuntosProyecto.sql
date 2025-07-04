USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Evaluacion360.spBuscarAdjuntosProyecto   (
	@IDProyecto int
)
AS
BEGIN
	select an.Data,
		   an.Extension,
		   an.FileName
	from Evaluacion360.tblEmpleadosProyectos ep
		--inner join app.tblNotificaciones n
		--	on ep.IDNotificacion = n.IDNotifiacion
		inner join app.tblEnviarNotificacionA a
			on ep.IDNotificacion = a.IDEnviarNotificacionA
		inner join app.tblAdjuntosNotificaciones an
			on an.IDEnviarNotificacionA = a.IDEnviarNotificacionA
	where ep.IDProyecto = @IDProyecto
		and ep.PDFGenerado = 1
END
GO
