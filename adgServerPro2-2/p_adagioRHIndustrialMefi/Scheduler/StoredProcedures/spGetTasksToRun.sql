USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Scheduler].[spGetTasksToRun]--'2020-01-14 01:00:45.400'    
	--DECLARE
	@current datetime 
	,@Accion varchar(100) = null
AS    
	select @Accion = case when @Accion = '' then null else @Accion end

	--DECLARE @current datetime = GETDATE() ;    
	declare @currentdate date    
			,@currenttime time(0)    
	;

	set @currentdate = @current    
	set @currenttime = @current    
	set @currenttime = Schedule.fnHHMM(@currenttime)    
    
	--select @currentdate,@currenttime    

	IF OBJECT_ID('tempdb..#temptaskToRun') is not null
		drop table #temptaskToRun

	CREATE table #temptaskToRun(
		IDTask int null,
		IDSchedule int null,
		StoreProcedure varchar(max) null,
		RunHour datetime null,
		Accion varchar(max) null,
		JsonConfig nvarchar(max) null
	)

    
	-- ******* One time ******************    
	--select @currentdate as currentdate,@currenttime as currenttime    

	insert into #temptaskToRun
	select    
		s.IDTask   
		,t.IDSchedule 
		,s.StoreProcedure    
		,@current as RunHour    
		,ta.Descripcion as Accion
		,s.JsonConfig
	from [Scheduler].[tblSchedule] t    
		JOIN [Scheduler].[tblListSchedulersForTask] ls 
			on t.IDSchedule = ls.IDSchedule    
		JOIN [Scheduler].[tblTask] s    
			on s.IDTask = ls.IDTask    
		JOIN [Scheduler].tblTipoSchedule ts    
			on ts.IDTipoSchedule = t.IDTipoSchedule    
		JOIN [Scheduler].tblCatTipoAcciones ta    
			on s.IDTipoAccion = ta.IDTipoAccion    
	where ts.Value = 'OneTime'    
		and t.OneTimeDate = @currentdate    
		and Schedule.fnHHMM(t.OneTimeTime) = @currenttime    
		and s.active = 1    
		and (ta.Descripcion = @Accion or @Accion is null)
    
	union    
-- ***********************************    

-- ******* Recurring Daily ******************    
	select s.IDTask    
		,t.IDSchedule 
		,s.StoreProcedure     
		,@current as RunHour    
		,ta.Descripcion as Accion
		,s.JsonConfig
	from [Scheduler].[tblSchedule] t    
		JOIN [Scheduler].[tblListSchedulersForTask] ls 
			on t.IDSchedule = ls.IDSchedule    
		JOIN [Scheduler].[tblTask] s    
			on s.IDTask = ls.IDTask    
		JOIN [Scheduler].tblTipoSchedule ts    
			on ts.IDTipoSchedule = t.IDTipoSchedule    
		JOIN [Scheduler].tblCatTipoAcciones ta    
			on s.IDTipoAccion = ta.IDTipoAccion    
	where  ts.Value = 'Recurring' and    
		(
			(FrecuencyType = 'Unica' and @currenttime = Schedule.fnHHMM(DailyFrecuencyOnce))    
				or (FrecuencyType = 'Multiple' and @currenttime between MultipleFrecuencyStartTime and MultipleFrecuencyEndTime    
				and Schedule.fnMustRunHour(MultipleFrecuencyValueTypes, MultipleFrecuencyStartTime, @currenttime,MultipleFrecuencyValues ) = 1)
		)    
		and     
		(
			(RunForever = 1 and  @currentdate between DurationStartDate and '9999-12-31')     
			or (RunForever = 0 and  @currentdate between DurationStartDate and DurationEndDate)
		)    
		and (OcurrsFrecuency = 'Diario' and Schedule.fnMustRunPeriod(DurationStartDate, @currentdate , OcurrsFrecuency, RecursEveryDaily) = 1)    
		and s.Active = 1    
		and (ta.Descripcion = @Accion or @Accion is null)

	union    
    
-- ******* Recurring Weekly ******************    
	select s.IDTask    
		,t.IDSchedule 
		, s.StoreProcedure     
		, @current as RunHour    
		, ta.Descripcion as Accion
		, s.JsonConfig
	from [Scheduler].[tblSchedule] t    
		JOIN [Scheduler].[tblListSchedulersForTask] ls 
			on t.IDSchedule = ls.IDSchedule    
		JOIN [Scheduler].[tblTask] s    
			on s.IDTask = ls.IDTask    
		JOIN [Scheduler].tblTipoSchedule ts    
			on ts.IDTipoSchedule = t.IDTipoSchedule    
		JOIN [Scheduler].tblCatTipoAcciones ta    
			on s.IDTipoAccion = ta.IDTipoAccion    
	where ts.Value = 'Recurring' and    
		(
			(FrecuencyType = 'Unica' and @currenttime = Schedule.fnHHMM(DailyFrecuencyOnce))    
				or (FrecuencyType = 'Multiple' and @currenttime between MultipleFrecuencyStartTime and MultipleFrecuencyEndTime    
				and Schedule.fnMustRunHour(MultipleFrecuencyValueTypes, MultipleFrecuencyStartTime, @currenttime,MultipleFrecuencyValues ) = 1)
		)    
		and     
		(
			(RunForever = 1 and  @currentdate between DurationStartDate and '9999-12-31')     
			or (RunForever = 0 and  @currentdate between DurationStartDate and DurationEndDate)
		)    
		and 
		(
			OcurrsFrecuency = 'Semanal' and Schedule.fnMustRunPeriod(DurationStartDate, @currentdate , OcurrsFrecuency, RecursEveryWeek) = 1    
			and Schedule.fnWeekSelected(@currentdate, WeekDays) = 1
		)    
		and Active = 1    
		and (ta.Descripcion = @Accion or @Accion is null)

	union    
    
---- ************* Recurrente Mensual Absoluto    
    
	select s.IDTask    
		,t.IDSchedule 
		,s.StoreProcedure     
		,@current as RunHour    
		,ta.Descripcion as Accion  
		,s.JsonConfig
	from  [Scheduler].[tblSchedule] t    
		JOIN [Scheduler].[tblListSchedulersForTask] ls 
			on t.IDSchedule = ls.IDSchedule    
		JOIN [Scheduler].[tblTask] s    
			on s.IDTask = ls.IDTask    
		JOIN [Scheduler].tblTipoSchedule ts    
			on ts.IDTipoSchedule = t.IDTipoSchedule    
		JOIN [Scheduler].tblCatTipoAcciones ta    
			on s.IDTipoAccion = ta.IDTipoAccion    
	where ts.Value = 'Recurring' and    
		(
			(FrecuencyType = 'Unica' and @currenttime = Schedule.fnHHMM(DailyFrecuencyOnce))    
			or (FrecuencyType = 'Multiple' and @currenttime between MultipleFrecuencyStartTime and MultipleFrecuencyEndTime    
			and Schedule.fnMustRunHour(MultipleFrecuencyValueTypes, MultipleFrecuencyStartTime, @currenttime,MultipleFrecuencyValues ) = 1)
		)    
		and     
		(
			(RunForever = 1 and  @currentdate between DurationStartDate and '9999-12-31')     
			or (RunForever = 0 and  @currentdate between DurationStartDate and DurationEndDate)
		)    
		and  OcurrsFrecuency = 'Mensual'     
		and MonthlyType = 'Absolute'    
		and Schedule.fnMustRunPeriod(DurationStartDate, @currentdate , OcurrsFrecuency, MonthlyAbsoluteNumberOfMonths) = 1    
		and DATEPART(Day, @currentdate) = MonthlyAbsoluteDayOfMonth     
		and Active = 1    
		and (ta.Descripcion = @Accion or @Accion is null)

	union      
    
---- ************* Recurrente Mensual Relativo    
	select s.IDTask    
		, t.IDSchedule 
		, s.StoreProcedure     
		, @current as RunHour    
		, ta.Descripcion as Accion 
		, s.JsonConfig
	from [Scheduler].[tblSchedule] t    
		JOIN [Scheduler].[tblListSchedulersForTask] ls 
			on t.IDSchedule = ls.IDSchedule    
		JOIN [Scheduler].[tblTask] s    
			on s.IDTask = ls.IDTask    
		JOIN [Scheduler].tblTipoSchedule ts    
			on ts.IDTipoSchedule = t.IDTipoSchedule    
		JOIN [Scheduler].tblCatTipoAcciones ta    
			on s.IDTipoAccion = ta.IDTipoAccion    
	where ts.Value = 'Recurring' and    
		(
			(FrecuencyType = 'Unica' and @currenttime = Schedule.fnHHMM(DailyFrecuencyOnce))    
				or (FrecuencyType = 'Multiple' and @currenttime between MultipleFrecuencyStartTime and MultipleFrecuencyEndTime    
				and Schedule.fnMustRunHour(MultipleFrecuencyValueTypes, MultipleFrecuencyStartTime, @currenttime,MultipleFrecuencyValues ) = 1)
		)    
		and     
		(
			(RunForever = 1 and  @currentdate between DurationStartDate and '9999-12-31')     
			or (RunForever = 0 and  @currentdate between DurationStartDate and DurationEndDate)
		)    
		and OcurrsFrecuency = 'Mensual'     
		and MonthlyType = 'Relative'    
		and Schedule.fnMustRunPeriod(DurationStartDate, @currentdate , OcurrsFrecuency, MonthlyRelativeNumberOfMonths) = 1    
		and MonthlyRelativeDayOfWeekShort =  Schedule.fnGetRelativeWeekOfDay(@currentdate)    
		and Active = 1    
		and (ta.Descripcion = @Accion or @Accion is null)

		Select IDTask, IDSchedule, StoreProcedure, RunHour, Accion, JsonConfig 
		from (
		select  IDTask, IDSchedule, StoreProcedure, RunHour, Accion, JsonConfig, ROW_NUMBER()OVER(Partition by IDTask ORDER BY IDTask asc) as RN 
		from #temptaskToRun
		) t
		WHERE t.RN = 1
GO
