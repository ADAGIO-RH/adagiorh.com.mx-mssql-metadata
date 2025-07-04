USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROC [zkteco].[spBuscarAttLogPorFecha] 
    @userID int,
	@AttTime datetime  = null
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  

	BEGIN TRAN

	SELECT [ID], [PIN], [AttTime], [Status], [Verify], [WorkCode], [Reserved1], [Reserved2], [DeviceID], [MaskFlag], [Temperature] 
	FROM   [zkteco].[tblAttLog] 
	WHERE  (PIN = @userID )
		and (AttTime = @AttTime)

	COMMIT
GO
