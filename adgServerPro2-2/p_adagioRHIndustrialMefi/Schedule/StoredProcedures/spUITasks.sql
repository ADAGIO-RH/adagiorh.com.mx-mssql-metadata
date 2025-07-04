USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Schedule.spUITasks
(
	@IDTask	int = 0
	,@IDScheduler int
	,@IDTipoSchedule int
	,@OneTimeDate DATE = null
	,@OneTimeTime TIME = null 
	,@OcurrsFrecuency varchar(10)= 'Diario'			
	,@RecursEveryDaily int = null
	,@RecursEveryWeek int = null
	,@WeekDays int = null
	,@MonthlyType varchar(20) = null
	,@MonthlyAbsoluteDayOfMonth int = null
	,@MonthlyAbsoluteNumberOfMonths int = null
	,@MonthlyRelativeDay varchar(10) = 'First'
	,@MonthlyRelativeDayOfWeek varchar(20) = null
	,@MonthlyRelativeDayOfWeekShort varchar(10) = null
	,@MonthlyRelativeNumberOfMonths int  = null
	,@FrecuencyType varchar(20) = null
	,@DailyFrecuencyOnce time = null
	,@MultipleFrecuencyValues int = null
	,@MultipleFrecuencyValueTypes varchar(20)
	,@MultipleFrecuencyStartTime time = null
	,@MultipleFrecuencyEndTime time = null
	,@DurationStartDate DATE = getdate
	,@DurationEndDate DATE = null
	,@RunForever bit = null
	,@IDUsuario int 
)
AS
BEGIN
	IF(isnull(@IDTask,0) = 0)
	BEGIN
		INSERT INTO [Schedule].[tblTask](
										IDScheduler
										,IDTipoSchedule
										,OneTimeDate
										,OneTimeTime
										,OcurrsFrecuency
										,RecursEveryDaily
										,RecursEveryWeek
										,WeekDays
										,MonthlyType
										,MonthlyAbsoluteDayOfMonth
										,MonthlyAbsoluteNumberOfMonths
										,MonthlyRelativeDay
										,MonthlyRelativeDayOfWeek
										,MonthlyRelativeDayOfWeekShort
										,MonthlyRelativeNumberOfMonths
										,FrecuencyType
										,DailyFrecuencyOnce
										,MultipleFrecuencyValues
										,MultipleFrecuencyValueTypes
										,MultipleFrecuencyStartTime
										,MultipleFrecuencyEndTime
										,DurationStartDate
										,DurationEndDate
										,RunForever)
		VALUES( 
				@IDScheduler
				,@IDTipoSchedule
				,@OneTimeDate
				,@OneTimeTime
				,isnull(@OcurrsFrecuency,'')
				,@RecursEveryDaily
				,@RecursEveryWeek
				,@WeekDays
				,@MonthlyType
				,@MonthlyAbsoluteDayOfMonth
				,@MonthlyAbsoluteNumberOfMonths
				,@MonthlyRelativeDay
				,@MonthlyRelativeDayOfWeek
				,@MonthlyRelativeDayOfWeekShort
				,@MonthlyRelativeNumberOfMonths
				,@FrecuencyType
				,@DailyFrecuencyOnce
				,@MultipleFrecuencyValues
				,@MultipleFrecuencyValueTypes
				,@MultipleFrecuencyStartTime
				,@MultipleFrecuencyEndTime
				,isnull(@DurationStartDate,getdate())
				,isnull(@DurationEndDate,getdate())
				,@RunForever)
			set @IDTask = @@IDENTITY
	END
	ELSE
	BEGIN
		UPDATE [Schedule].[tblTask]
			set  IDTipoSchedule						= @IDTipoSchedule 
				,OneTimeDate						= @OneTimeDate
				,OneTimeTime						= @OneTimeTime
				,OcurrsFrecuency					= isnull(@OcurrsFrecuency,'')
				,RecursEveryDaily					= @RecursEveryDaily
				,RecursEveryWeek					= @RecursEveryWeek
				,WeekDays							= @WeekDays
				,MonthlyType						= @MonthlyType
				,MonthlyAbsoluteDayOfMonth			= @MonthlyAbsoluteDayOfMonth
				,MonthlyAbsoluteNumberOfMonths		= @MonthlyAbsoluteNumberOfMonths
				,MonthlyRelativeDay					= @MonthlyRelativeDay
				,MonthlyRelativeDayOfWeek			= @MonthlyRelativeDayOfWeek
				,MonthlyRelativeDayOfWeekShort		= @MonthlyRelativeDayOfWeekShort
				,MonthlyRelativeNumberOfMonths		= @MonthlyRelativeNumberOfMonths
				,FrecuencyType						= @FrecuencyType
				,DailyFrecuencyOnce					= @DailyFrecuencyOnce
				,MultipleFrecuencyValues			= @MultipleFrecuencyValues
				,MultipleFrecuencyValueTypes		= @MultipleFrecuencyValueTypes
				,MultipleFrecuencyStartTime			= @MultipleFrecuencyStartTime
				,MultipleFrecuencyEndTime			= @MultipleFrecuencyEndTime
				,DurationStartDate					= isnull(@DurationStartDate,getdate())
				,DurationEndDate					= isnull(@DurationEndDate,getdate())
				,RunForever							= @RunForever
		WHERE IDTask = @IDTask
			and IDScheduler = @IDScheduler
	END

	EXEC Schedule.spBuscarTasks @IDSchedule = @IDScheduler, @IDTask = @IDTask

END
GO
