USE [p_adagioRHCSMPresupuesto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Scheduler].[spBorrarListSchedulerForTask](
	 @IDListScheduleForTask	int = 0
	,@IDUsuario int
) as
	BEGIN TRY  
		DELETE Scheduler.tblListSchedulersForTask
		WHERE IDListScheduleForTask = @IDListScheduleForTask
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;
GO
