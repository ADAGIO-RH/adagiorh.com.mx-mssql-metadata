USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [zkteco].[spTempDeviceCmdExecuted](
		@ID	int
	) as
		update [zkteco].[tblTempDeviceCmds]
			set 
				ExecutedAt  = GETDATE(),
				Executed = 1
		where ID = @ID
GO
