USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Asistencia].[spSchedulerDescargarChecadas]
(
	@IDUsuario int
)
AS
BEGIN

DECLARE @FechaHora datetime = dateadd(MINUTE,2,getdate()),
	@IDSchedule int,
	@IDTask int

	select top 1 @IDTask = IDTask from Scheduler.tblTask
	where Nombre = 'DESCARGAR CHECADAS ZK ONDEMAND'
	and IDTipoAccion = (select top 1 IDTipoAccion from Scheduler.tblCatTipoAcciones where Descripcion = 'Lectores')

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
										,RunForever)
		VALUES( 
				(SELECT top 1 IDTipoSchedule FROM Scheduler.tblTipoSchedule where [Value] = 'OneTime')
				,'DESCARGA BAJO DEMANDA DE ZK CHECADAS'
				, cast(@FechaHora as date)
				,cast(@FechaHora as time)
				,isnull('Diario','')
				,0
				,0
				,0
				,'Absolute'
				,0
				,0
				,'First'
				,'Some'
				,NULL
				,0
				,'Unica'
				,NULL
				,0
				,'Minutes'
				,NULL
				,NULL
				,isnull(@FechaHora,getdate())
				,isnull(@FechaHora,getdate())
				,0)


				set @IDSchedule = @@IDENTITY


insert into Scheduler.tblListSchedulersForTask(IDTask,IDSchedule)
values(@IDTask,@IDSchedule)
END
GO
