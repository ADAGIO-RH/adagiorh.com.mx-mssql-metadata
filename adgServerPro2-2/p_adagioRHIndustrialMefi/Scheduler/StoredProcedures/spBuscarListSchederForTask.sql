USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Scheduler].[spBuscarListSchederForTask](
	@IDListScheduleForTask int = 0
	,@IDTask int = 0
)AS 
	SELECT 
		 tsft.IDListScheduleForTask
		,tsft.IDTask		
		,tsft.IDSchedule
		,ts.Nombre AS Schedule
		,tts.Descripcion AS TipoSchedule
	FROM [Scheduler].[tblListSchedulersForTask] tsft
		JOIN Scheduler.tblTask tt ON tsft.IDTask = tt.IDTask
		JOIN Scheduler.tblSchedule ts ON tsft.IDSchedule = ts.IDSchedule
		JOIN Scheduler.tblTipoSchedule tts ON ts.IDTipoSchedule = tts.IDTipoSchedule	
	WHERE (tsft.IDListScheduleForTask = @IDListScheduleForTask OR @IDListScheduleForTask = 0)
		AND (tsft.IDTask = @IDTask OR @IDTask = 0)
GO
