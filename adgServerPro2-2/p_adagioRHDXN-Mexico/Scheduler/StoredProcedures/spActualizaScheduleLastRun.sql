USE [p_adagioRHDXN-Mexico]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc Scheduler.spActualizaScheduleLastRun(
	@IDSchedule int
) as
	update Scheduler.tblSchedule
		set LastRun = GETDATE()
	where IDSchedule = @IDSchedule
GO
