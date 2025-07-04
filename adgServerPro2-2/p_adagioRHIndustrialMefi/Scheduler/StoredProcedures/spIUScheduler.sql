USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Scheduler].[spIUScheduler]
(
	 @IDSchedule int
	,@IDTipoSchedule int
	,@Nombre varchar(100)
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
	,@CreatedAutomatically bit = 1
	,@IDUsuario int 
)
AS
BEGIN
	IF(isnull(@IDSchedule,0) = 0)
	BEGIN
		INSERT INTO [Scheduler].[tblSchedule](
										 IDTipoSchedule
										,Nombre
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
										,RunForever
										,CreatedAutomatically
									)
		VALUES( 
				@IDTipoSchedule
				,upper(@Nombre)
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
				,@RunForever
				,@CreatedAutomatically	
			)

			set @IDSchedule = @@IDENTITY
	END
	ELSE
	BEGIN
		UPDATE [Scheduler].[tblSchedule]
			set  IDTipoSchedule						= @IDTipoSchedule 
				,Nombre								= upper(@Nombre)
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
				,CreatedAutomatically				= @CreatedAutomatically
		WHERE IDSchedule = @IDSchedule
	END

	EXEC [Scheduler].[spBuscarSchedule] @IDSchedule = @IDSchedule 

END
GO
