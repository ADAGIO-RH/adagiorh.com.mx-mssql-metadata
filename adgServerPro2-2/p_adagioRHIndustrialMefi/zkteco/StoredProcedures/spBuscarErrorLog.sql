USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spBuscarErrorLog] 
    @ID int
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  

	BEGIN TRAN

	SELECT [ID], [ErrCode], [ErrMsg], [DataOrigin], [CmdId], [Additional], [DeviceID] 
	FROM   [zkteco].[tblErrorLog] 
	WHERE  ([ID] = @ID OR @ID IS NULL) 

	COMMIT
GO
