USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Schedule].[spGetTasksToRun] --'2018-07-12 16:29:30.560'
@current datetime
AS

--DECLARE @current datetime = GETDATE() ;

declare @currentdate date
declare @currenttime time(0)
set @currentdate = @current
set @currenttime = @current
set @currenttime = Schedule.fnHHMM(@currenttime)

--select @currentdate,@currenttime

-- ******* One time ******************
select @currentdate as currentdate,@currenttime as currenttime
select
	s.IDTask
	,s.StoreProcedure
	,@current as RunHour
	,ta.Descripcion as Accion
from [Scheduler].[tblSchedule] t
	JOIN [Scheduler].[tblListSchedulersForTask] ls on t.IDSchedule = ls.IDSchedule
	JOIN [Scheduler].[tblTask] s
		on s.IDTask = ls.IDTask
	JOIN [Scheduler].tblTipoSchedule ts
		on ts.IDTipoSchedule = t.IDTipoSchedule
	JOIN [Scheduler].tblCatTipoAcciones ta
		on s.IDTipoAccion = ta.IDTipoAccion
where ts.Value = 'OneTime'
and t.OneTimeDate = @currentdate
and t.OneTimeTime = @currenttime
and s.active = 1

union
-- ***********************************
-- ******* Recurring Daily ******************

select s.IDTask
		,s.StoreProcedure 
		,@current as RunHour
		,ta.Descripcion as Accion
from [Scheduler].[tblSchedule] t
	JOIN [Scheduler].[tblListSchedulersForTask] ls on t.IDSchedule = ls.IDSchedule
	JOIN [Scheduler].[tblTask] s
		on s.IDTask = ls.IDTask
	JOIN [Scheduler].tblTipoSchedule ts
		on ts.IDTipoSchedule = t.IDTipoSchedule
	JOIN [Scheduler].tblCatTipoAcciones ta
		on s.IDTipoAccion = ta.IDTipoAccion
where  ts.Value = 'Recurring' and
	((FrecuencyType = 'Unica' and @currenttime = DailyFrecuencyOnce)
    or (FrecuencyType = 'Multiple' and @currenttime between MultipleFrecuencyStartTime and MultipleFrecuencyEndTime
								   and Schedule.fnMustRunHour(MultipleFrecuencyValueTypes, MultipleFrecuencyStartTime, @currenttime,MultipleFrecuencyValues )=1 ))
and 
(    (RunForever = 1 and  @currentdate between DurationStartDate and '9999-12-31') 
  or (RunForever = 0 and  @currentdate between DurationStartDate and DurationEndDate))
and (OcurrsFrecuency = 'Diario' and Schedule.fnMustRunPeriod(DurationStartDate, @currentdate , OcurrsFrecuency, RecursEveryDaily) = 1)
and s.Active = 1

union

-- ******* Recurring Weekly ******************

select s.IDTask
	, s.StoreProcedure 
	, @current as RunHour
	, ta.Descripcion as Accion
from [Scheduler].[tblSchedule] t
	JOIN [Scheduler].[tblListSchedulersForTask] ls on t.IDSchedule = ls.IDSchedule
	JOIN [Scheduler].[tblTask] s
		on s.IDTask = ls.IDTask
	JOIN [Scheduler].tblTipoSchedule ts
		on ts.IDTipoSchedule = t.IDTipoSchedule
	JOIN [Scheduler].tblCatTipoAcciones ta
		on s.IDTipoAccion = ta.IDTipoAccion
where ts.Value = 'Recurring' and
	((FrecuencyType = 'Unica' and @currenttime = DailyFrecuencyOnce)
    or (FrecuencyType = 'Multiple' and @currenttime between MultipleFrecuencyStartTime and MultipleFrecuencyEndTime
								   and Schedule.fnMustRunHour(MultipleFrecuencyValueTypes, MultipleFrecuencyStartTime, @currenttime,MultipleFrecuencyValues )=1 ))
and 
(    (RunForever = 1 and  @currentdate between DurationStartDate and '9999-12-31') 
  or (RunForever = 0 and  @currentdate between DurationStartDate and DurationEndDate))
and (OcurrsFrecuency = 'Semanal' 
     and Schedule.fnMustRunPeriod(DurationStartDate, @currentdate , OcurrsFrecuency, RecursEveryWeek) = 1
	 and Schedule.fnWeekSelected(@currentdate, WeekDays)=1)
and Active = 1

union

-- ************* Recurrente Mensual Absoluto

select s.IDTask
	, s.StoreProcedure 
	, @current as RunHour
	,ta.Descripcion as Accion
from  [Scheduler].[tblSchedule] t
	JOIN [Scheduler].[tblListSchedulersForTask] ls on t.IDSchedule = ls.IDSchedule
	JOIN [Scheduler].[tblTask] s
		on s.IDTask = ls.IDTask
	JOIN [Scheduler].tblTipoSchedule ts
		on ts.IDTipoSchedule = t.IDTipoSchedule
	JOIN [Scheduler].tblCatTipoAcciones ta
		on s.IDTipoAccion = ta.IDTipoAccion
where ts.Value = 'Recurring' and
	((FrecuencyType = 'Unica' and @currenttime = DailyFrecuencyOnce)
    or (FrecuencyType = 'Multiple' and @currenttime between MultipleFrecuencyStartTime and MultipleFrecuencyEndTime
								   and Schedule.fnMustRunHour(MultipleFrecuencyValueTypes, MultipleFrecuencyStartTime, @currenttime,MultipleFrecuencyValues )=1 ))
and 
(    (RunForever = 1 and  @currentdate between DurationStartDate and '9999-12-31') 
  or (RunForever = 0 and  @currentdate between DurationStartDate and DurationEndDate))
and  OcurrsFrecuency = 'Mensual' 
and MonthlyType = 'Absolute'
and Schedule.fnMustRunPeriod(DurationStartDate, @currentdate , OcurrsFrecuency, MonthlyAbsoluteNumberOfMonths) = 1
and DATEPART(Day, @currentdate) = MonthlyAbsoluteDayOfMonth 
and Active = 1
union	 

-- ************* Recurrente Mensual Relativo

select s.IDTask
	, s.StoreProcedure 
	, @current as RunHour
	, ta.Descripcion as Accion
from [Scheduler].[tblSchedule] t
	JOIN [Scheduler].[tblListSchedulersForTask] ls on t.IDSchedule = ls.IDSchedule
	JOIN [Scheduler].[tblTask] s
		on s.IDTask = ls.IDTask
	JOIN [Scheduler].tblTipoSchedule ts
		on ts.IDTipoSchedule = t.IDTipoSchedule
	JOIN [Scheduler].tblCatTipoAcciones ta
		on s.IDTipoAccion = ta.IDTipoAccion
where ts.Value = 'Recurring' and
	((FrecuencyType = 'Unica' and @currenttime = DailyFrecuencyOnce)
    or (FrecuencyType = 'Multiple' and @currenttime between MultipleFrecuencyStartTime and MultipleFrecuencyEndTime
								   and Schedule.fnMustRunHour(MultipleFrecuencyValueTypes, MultipleFrecuencyStartTime, @currenttime,MultipleFrecuencyValues )=1 ))
and 
(    (RunForever = 1 and  @currentdate between DurationStartDate and '9999-12-31') 
  or (RunForever = 0 and  @currentdate between DurationStartDate and DurationEndDate))
and  OcurrsFrecuency = 'Mensual' 
and MonthlyType = 'Relative'
and Schedule.fnMustRunPeriod(DurationStartDate, @currentdate , OcurrsFrecuency, MonthlyRelativeNumberOfMonths) = 1
and MonthlyRelativeDayOfWeekShort =  Schedule.fnGetRelativeWeekOfDay(@currentdate)
and Active = 1

--GO
GO
