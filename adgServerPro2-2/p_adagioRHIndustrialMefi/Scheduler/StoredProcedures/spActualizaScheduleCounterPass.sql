USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc Scheduler.spActualizaScheduleCounterPass(
	@IDSchedule int
) as
	update Scheduler.tblSchedule
		set CounterPass = ISNULL(CounterPass,0) + 1
	where IDSchedule = @IDSchedule
GO
