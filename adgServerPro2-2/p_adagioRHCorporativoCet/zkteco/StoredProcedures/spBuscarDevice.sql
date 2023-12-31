USE [p_adagioRHCorporativoCet]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spBuscarDevice] 
    @ID int
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  

	BEGIN TRAN

	SELECT [ID], 
	[DevSN], 
	[DevName], 
	[ATTLOGStamp], 
	[OPERLOGStamp], 
	[ATTPHOTOStamp], 
	[ErrorDelay], 
	[Delay], 
	[TransFlag], 
	[Realtime], 
	[TransInterval], 
	[TransTimes], 
	[Encrypt], 
	[LastRequestTime], 
	[DevIP], 
	[DevMac], 
	[DevFPVersion], 
	[DevFirmwareVersion], 
	[UserCount], 
	[AttCount], 
	[FpCount], 
	[TimeZone], 
	[Timeout], 
	[SyncTime], 
	[VendorName], 
	[IRTempDetectionFunOn], 
	[MaskDetectionFunOn], 
	[UserPicURLFunOn], 
	[MultiBioDataSupport], 
	[MultiBioPhotoSupport], 
	[MultiBioVersion], 
	[MultiBioCount], 
	[MaxMultiBioDataCount], 
	[MaxMultiBioPhotoCount] ,
	LastSync
	FROM   [zkteco].[tblDevice] 
	WHERE  ([ID] = @ID OR @ID IS NULL) 

	COMMIT
GO
