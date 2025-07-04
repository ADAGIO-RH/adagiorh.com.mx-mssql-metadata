USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Scheduler].[spBuscarSchedule] -- 1,0
(
	@IDSchedule int = 0
)
AS
BEGIN
	Select 
		 t.IDSchedule
		,t.IDTipoSchedule
		,t.[Nombre]
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
		,isnull(t.CreatedAutomatically, 1) as CreatedAutomatically
		,isnull(t.CreatedDateTime, '1900-01-01 01:00:00') as CreatedDateTime
	from [Scheduler].[tblSchedule] t
		inner join Scheduler.tblTipoSchedule ts
			on t.IDTipoSchedule = ts.IDTipoSchedule
	where ( t.IDSchedule = @IDSchedule or @IDSchedule = 0)
END
GO
