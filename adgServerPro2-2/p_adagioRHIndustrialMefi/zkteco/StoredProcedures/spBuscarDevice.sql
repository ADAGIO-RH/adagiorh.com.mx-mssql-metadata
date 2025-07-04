USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spBuscarDevice] 
    @ID int = 0,
	@DevSN varchar(50) = null
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  

	SELECT 
		d.[ID], 
		d.[DevSN], 
		d.[DevName], 
		d.[ATTLOGStamp], 
		d.[OPERLOGStamp], 
		d.[ATTPHOTOStamp], 
		d.[ErrorDelay], 
		d.[Delay], 
		d.[TransFlag], 
		d.[Realtime], 
		d.[TransInterval], 
		d.[TransTimes], 
		d.[Encrypt], 
		d.[LastRequestTime], 
		d.[DevIP], 
		d.[DevMac], 
		d.[DevFPVersion], 
		d.[DevFirmwareVersion], 
		d.[UserCount], 
		d.[AttCount], 
		d.[FpCount], 
		[Tzdb].[GetTimezone](l.IDZonaHoraria) as TimeZone,
		d.[Timeout], 
		d.[SyncTime], 
		d.[VendorName], 
		d.[IRTempDetectionFunOn], 
		d.[MaskDetectionFunOn], 
		d.[UserPicURLFunOn], 
		d.[MultiBioDataSupport], 
		d.[MultiBioPhotoSupport], 
		d.[MultiBioVersion], 
		d.[MultiBioCount], 
		d.[MaxMultiBioDataCount], 
		d.[MaxMultiBioPhotoCount] ,
		d.LastSync,
		ISNULL(l.Master, 0) as [Master]
	FROM   [zkteco].[tblDevice] d
		left join Asistencia.tblLectores l on l.NumeroSerial = d.DevSN
	WHERE  ([ID] = @ID OR isnull(@ID,0) = 0) 
		and (d.DevSN = @DevSN or ISNULL(@DevSN, '') = '')
GO
