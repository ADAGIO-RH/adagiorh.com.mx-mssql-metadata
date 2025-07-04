USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seguridad].[spSchedulerActualizarFiltrosUsuarios]  
(  
 @IDUsuario int  
)  
AS  
BEGIN  
  
DECLARE @FechaHora datetime = dateadd(MINUTE,2,getdate()),  
 @IDSchedule int,  
 @IDTask int  ;

     DECLARE @NewJSON Varchar(Max);
  
 select top 1 @IDTask = IDTask from Scheduler.tblTask  
 where Nombre = 'ACTUALIZAR FILTROS USUARIOS MASIVOS'  
 and IDTipoAccion = (select top 1 IDTipoAccion from Scheduler.tblCatTipoAcciones where Descripcion = 'Store Procedure')  
  
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
    ,'ACTUALIZACION DE FILTROS DE USUARIO BAJO DEMANDA'  
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

    Select @NewJSON = (SELECT * FROM Scheduler.tblTipoSchedule WHERE IDTipoSchedule = @IDSchedule  FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
  EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Scheduler].[tblTipoSchedule]','[Seguridad].[spSchedulerActualizarFiltrosUsuarios]','INSERT',@NewJSON,''

insert into Scheduler.tblListSchedulersForTask(IDTask,IDSchedule)  
values(@IDTask,@IDSchedule)  
END
GO
