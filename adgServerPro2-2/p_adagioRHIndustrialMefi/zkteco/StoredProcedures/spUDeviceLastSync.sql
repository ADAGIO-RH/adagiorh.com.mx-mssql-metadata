USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROC [zkteco].[spUDeviceLastSync] 
    @DevSN varchar(50) 
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN
	UPDATE [zkteco].[tblDevice]
		SET    
			LastSync = GETDATE()
	WHERE  [DevSN] = @DevSN

	COMMIT
GO
