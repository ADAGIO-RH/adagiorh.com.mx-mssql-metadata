USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spSchedulerActualizarTotalesRelacionesEmpleados]
(
	@IDUsuario int
	,@IDUsuarioLogin int
)
AS
BEGIN

DECLARE @FechaHora datetime = dateadd(MINUTE,2,getdate()),
	@IDSchedule int,
	@IDTask int,
	@SQLScript nvarchar(max) = 'exec [Seguridad].[spAsginarEmpleadosAUsuarioPorFiltro] @IDUsuario = '+cast(isnull(@IDUsuario,0) as varchar(20))+', @IDUsuarioLogin = '+cast(@IDUsuarioLogin as varchar(20));
	
	insert into Scheduler.tblTask(
	Nombre
	,StoreProcedure
	,interval
	,active
	,IDTipoAccion
	)
	Values('ASIGNA EMPLEADOS A USUARIO POR FILTROS',@SQLScript,0,1,(select Top 1 IDTipoAccion from Scheduler.tblCatTipoAcciones where Descripcion = 'SQLScript'))
	
	SET @IDTask = @@IDENTITY

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
				,'ASIGNA EMPLEADOS A USUARIO POR FILTROS'
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
