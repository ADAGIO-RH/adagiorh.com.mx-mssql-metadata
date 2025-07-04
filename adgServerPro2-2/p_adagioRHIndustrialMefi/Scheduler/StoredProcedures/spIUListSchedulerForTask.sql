USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Scheduler].[spIUListSchedulerForTask](
	 @IDListScheduleForTask	int = 0
	,@IDTask				int
	,@IDSchedule			int
	,@IDUsuario int
) as

	IF (@IDListScheduleForTask = 0)
	BEGIN
		IF exists(SELECT TOP 1 1 FROM [Scheduler].[tblListSchedulersForTask] WHERE IDTask = @IDTask AND IDSchedule = @IDSchedule)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		end;

		INSERT Scheduler.tblListSchedulersForTask
		(
		    --IDListScheduleForTask - this column value is auto-generated
		    IDTask,
		    IDSchedule
		)
		VALUES
		(
		    -- IDListScheduleForTask - int
		    @IDTask, -- IDTask - int
		    @IDSchedule -- IDSchedule - int
		)

		SET @IDListScheduleForTask = @@IDENTITY

	END ELSE
	BEGIN
		IF exists(SELECT TOP 1 1 FROM [Scheduler].[tblListSchedulersForTask] WHERE IDTask = @IDTask AND IDSchedule = @IDSchedule AND IDListScheduleForTask <> @IDListScheduleForTask)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		end;

		UPDATE Scheduler.tblListSchedulersForTask
		SET
		    --IDListScheduleForTask - this column value is auto-generated
		    Scheduler.tblListSchedulersForTask.IDTask = @IDTask, -- int
		    Scheduler.tblListSchedulersForTask.IDSchedule = @IDSchedule -- int
		WHERE IDListScheduleForTask = @IDListScheduleForTask
	end;


	EXEC [Scheduler].[spBuscarListSchederForTask] @IDListScheduleForTask=@IDListScheduleForTask
GO
