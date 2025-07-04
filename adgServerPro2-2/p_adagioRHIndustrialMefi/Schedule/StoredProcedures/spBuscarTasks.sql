USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Schedule.spBuscarTasks-- 1,0
(
	@IDSchedule int = 0,
	@IDTask int = 0
)
AS
BEGIN
	Select 
		 t.IDTask
		,t.IDScheduler
		,s.Nombre as Scheduler
		,t.IDTipoSchedule
		,ts.Descripcion as TipoScheduler
		,isnull(t.OneTimeDate,getdate()) as OneTimeDate
		,t.OneTimeTime
		,t.OcurrsFrecuency
		,t.RecursEveryDaily
		,t.RecursEveryWeek
		,t.WeekDays
		,t.MonthlyType
		,t.MonthlyAbsoluteDayOfMonth
		,t.MonthlyAbsoluteNumberOfMonths
		,t.MonthlyRelativeDay
		,t.MonthlyRelativeDayOfWeek
		,t.MonthlyRelativeDayOfWeekShort
		,t.MonthlyRelativeNumberOfMonths
		,t.FrecuencyType
		,isnull(t.DailyFrecuencyOnce,getdate())as DailyFrecuencyOnce
		,t.MultipleFrecuencyValues
		,t.MultipleFrecuencyValueTypes
		,t.MultipleFrecuencyStartTime
		,t.MultipleFrecuencyEndTime
		,isnull(t.DurationStartDate,getdate())as DurationStartDate
		,isnull(t.DurationEndDate,getdate()) as DurationEndDate
		,t.RunForever
		,t.LastRun
		,t.LastResult
		,t.CounterPass
		,t.CounterFail 
	from [Schedule].[tblTask] t
		inner join Schedule.tblTipoSchedule ts
			on t.IDTipoSchedule = ts.IDTipoSchedule
		Inner join Schedule.tblSchedule s
			on s.IDSchedule =  t.IDScheduler
	where (T.IDTask = @IDTask or @IDTask = 0) and( t.IDScheduler = @IDSchedule or @IDSchedule = 0)
END
GO
