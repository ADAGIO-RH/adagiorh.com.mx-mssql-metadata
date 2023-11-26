USE [p_adagioRHGrupoEnergy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE Schedule.spBorrarTask
(
	@IDTask int,
	@IDUsuario int
)
AS
BEGIN
	EXEC Schedule.spBuscarTasks @IDSchedule = 0,@IDTask = @IDTask

	Delete [Schedule].[tblTask]
	Where IDTask = @IDTask
END
GO
