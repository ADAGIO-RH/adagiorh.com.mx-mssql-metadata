USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spIUErrorLog] 
    @ErrCode varchar(100),
    @ErrMsg text = NULL,
    @DataOrigin varchar(50) = NULL,
    @CmdId varchar(100) = NULL,
    @Additional text = NULL,
    @DeviceID varchar(50) = NULL
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN
	
	INSERT INTO [zkteco].[tblErrorLog] ([ErrCode], [ErrMsg], [DataOrigin], [CmdId], [Additional], [DeviceID])
	SELECT @ErrCode, @ErrMsg, @DataOrigin, @CmdId, @Additional, @DeviceID
	
	-- Begin Return Select <- do not remove
	SELECT [ID], [ErrCode], [ErrMsg], [DataOrigin], [CmdId], [Additional], [DeviceID]
	FROM   [zkteco].[tblErrorLog]
	WHERE  [ID] = SCOPE_IDENTITY()
	-- End Return Select <- do not remove
               
	COMMIT
GO
