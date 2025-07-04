USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc Scheduler.spActualizaScheduleCounterFail(
	@IDSchedule int
) as
	update Scheduler.tblSchedule
		set CounterFail = ISNULL(CounterFail,0) + 1
	where IDSchedule = @IDSchedule
GO
