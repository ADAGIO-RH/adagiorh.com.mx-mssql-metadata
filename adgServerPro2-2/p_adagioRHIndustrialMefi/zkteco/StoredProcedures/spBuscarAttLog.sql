USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spBuscarAttLog] 
    @ID int = 0,
	@startTime datetime  = null,
	@endTime datetime  = null,
	@userID varchar(50)   = null,
	@DeviceID varchar(50) = null 
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  

	BEGIN TRAN

	SELECT [ID], [PIN], [AttTime], [Status], [Verify], [WorkCode], [Reserved1], [Reserved2], [DeviceID], [MaskFlag], [Temperature] 
	FROM   [zkteco].[tblAttLog] 
	WHERE  ([ID] = @ID OR @ID IS NULL) 
		and (PIN = @userID or ISNULL(@userID, '') = '')
		and (DeviceID = @DeviceID or ISNULL(@DeviceID, '') = '')
		and (AttTime between @startTime and @endTime or @startTime is null)

	COMMIT
GO
