USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seguridad].[spSchedulerActualizarFiltrosUsuariosOndemand]  
(  
	@IDUsuario int  
)  
AS  
BEGIN  
  
	DECLARE 
		@FechaHora datetime = dateadd(MINUTE,15,getdate()),  
		@IDSchedule int,  
		@IDTask int  
	;
   DECLARE @NewJSON Varchar(Max);
	select top 1 @IDTask = IDTask 
	from Scheduler.tblTask with (nolock)
	where Nombre = 'ACTUALIZAR FILTROS USUARIOS ONDEMAND'  
		and IDTipoAccion = (select top 1 IDTipoAccion 
							from Scheduler.tblCatTipoAcciones with (nolock)
							where Descripcion = 'Store Procedure')  

	if not exists (
		select top 1 1
		from [Scheduler].[tblSchedule] with (nolock)
		where Nombre = 'ACTUALIZAR FILTROS USUARIOS ONDEMAND'  
			and (cast(OneTimeDate AS datetime) + cast(OneTimeTime AS datetime)) between GETDATE() and @FechaHora
	)	
	begin
  
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
			,'ACTUALIZAR FILTROS USUARIOS ONDEMAND'  
			,cast(@FechaHora as date)  
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
			,15  
			,'Minutes'  
			,NULL  
			,NULL  
			,isnull(@FechaHora,getdate())  
			,isnull(@FechaHora,getdate())  
			,0
		)  
  
		set @IDSchedule = @@IDENTITY  
    Select @NewJSON = (SELECT * FROM Scheduler.tblTipoSchedule WHERE IDTipoSchedule = @IDSchedule  FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Scheduler].[tblTipoSchedule]','[Seguridad].[spSchedulerActualizarFiltrosUsuariosOndemand]','INSERT',@NewJSON,''

		insert into Scheduler.tblListSchedulersForTask(IDTask,IDSchedule)  
		values(@IDTask,@IDSchedule)  
	end;
END
GO
