USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spIUDevice] 
    @DevSN varchar(50) = NULL,
    @DevName varchar(50) = NULL,
    @ATTLOGStamp varchar(50) = NULL,
    @OPERLOGStamp varchar(50) = NULL,
    @ATTPHOTOStamp varchar(50) = NULL,
    @ErrorDelay varchar(50) = '120',
    @Delay varchar(50) = '10',
    @TransFlag varchar(100) = NULL,
    @Realtime varchar(1) = '1',
    @TransInterval varchar(10) = '30',
    @TransTimes varchar(60) = NULL,
    @Encrypt varchar(1) = NULL,
    @LastRequestTime datetime = '2000-01-01 00:00:01',
    @DevIP varchar(50) = NULL,
    @DevMac varchar(50) = NULL,
    @DevFPVersion varchar(50) = NULL,
    @DevFirmwareVersion varchar(50) = NULL,
    @UserCount int = NULL,
    @AttCount int = NULL,
    @FpCount int = NULL,
    @TimeZone varchar(50) = '-06:00',
    @Timeout int = NULL,
    @SyncTime int = NULL,
    @VendorName varchar(50) = 'ZK',
    @IRTempDetectionFunOn varchar(1) = '0',
    @MaskDetectionFunOn varchar(1) = '0',
    @UserPicURLFunOn varchar(1) = NULL,
    @MultiBioDataSupport varchar(50) = NULL,
    @MultiBioPhotoSupport varchar(50) = NULL,
    @MultiBioVersion varchar(100) = NULL,
    @MultiBioCount varchar(100) = NULL,
    @MaxMultiBioDataCount varchar(100) = NULL,
    @MaxMultiBioPhotoCount varchar(100) = NULL
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN
	
	if not exists (select top 1 1 from [zkteco].[tblDevice] where DevSN = @DevSN) 
	begin
		INSERT INTO [zkteco].[tblDevice] ([DevSN], [DevName], [ATTLOGStamp], [OPERLOGStamp], [ATTPHOTOStamp], [ErrorDelay], [Delay], [TransFlag], [Realtime], [TransInterval], [TransTimes], [Encrypt], [LastRequestTime], [DevIP], [DevMac], [DevFPVersion], [DevFirmwareVersion], [UserCount], [AttCount], [FpCount], [TimeZone], [Timeout], [SyncTime], [VendorName], [IRTempDetectionFunOn], [MaskDetectionFunOn], [UserPicURLFunOn], [MultiBioDataSupport], [MultiBioPhotoSupport], [MultiBioVersion], [MultiBioCount], [MaxMultiBioDataCount], [MaxMultiBioPhotoCount])
		SELECT @DevSN, @DevName, @ATTLOGStamp, @OPERLOGStamp, @ATTPHOTOStamp, @ErrorDelay, @Delay, @TransFlag, @Realtime, @TransInterval, @TransTimes, @Encrypt, @LastRequestTime, @DevIP, @DevMac, @DevFPVersion, @DevFirmwareVersion, @UserCount, @AttCount, @FpCount, @TimeZone, @Timeout, @SyncTime, @VendorName, @IRTempDetectionFunOn, @MaskDetectionFunOn, @UserPicURLFunOn, @MultiBioDataSupport, @MultiBioPhotoSupport, @MultiBioVersion, @MultiBioCount, @MaxMultiBioDataCount, @MaxMultiBioPhotoCount
	end else
	begin
		UPDATE [zkteco].[tblDevice]
		SET    [DevName] = @DevName, [ATTLOGStamp] = @ATTLOGStamp, [OPERLOGStamp] = @OPERLOGStamp, [ATTPHOTOStamp] = @ATTPHOTOStamp, [ErrorDelay] = @ErrorDelay, [Delay] = @Delay, [TransFlag] = @TransFlag, [Realtime] = @Realtime, [TransInterval] = @TransInterval, [TransTimes] = @TransTimes, [Encrypt] = @Encrypt, [LastRequestTime] = @LastRequestTime, [DevIP] = @DevIP, [DevMac] = @DevMac, [DevFPVersion] = @DevFPVersion, [DevFirmwareVersion] = @DevFirmwareVersion, [UserCount] = @UserCount, [AttCount] = @AttCount, [FpCount] = @FpCount, [TimeZone] = @TimeZone, [Timeout] = @Timeout, [SyncTime] = @SyncTime, [VendorName] = @VendorName, [IRTempDetectionFunOn] = @IRTempDetectionFunOn, [MaskDetectionFunOn] = @MaskDetectionFunOn, [UserPicURLFunOn] = @UserPicURLFunOn, [MultiBioDataSupport] = @MultiBioDataSupport, [MultiBioPhotoSupport] = @MultiBioPhotoSupport, [MultiBioVersion] = @MultiBioVersion, [MultiBioCount] = @MultiBioCount, [MaxMultiBioDataCount] = @MaxMultiBioDataCount, [MaxMultiBioPhotoCount] = @MaxMultiBioPhotoCount
		WHERE  [DevSN] = @DevSN
	end
	-- Begin Return Select <- do not remove
	SELECT [ID], [DevSN], [DevName], [ATTLOGStamp], [OPERLOGStamp], [ATTPHOTOStamp], [ErrorDelay], [Delay], [TransFlag], [Realtime], [TransInterval], [TransTimes], [Encrypt], [LastRequestTime], [DevIP], [DevMac], [DevFPVersion], [DevFirmwareVersion], [UserCount], [AttCount], [FpCount], [TimeZone], [Timeout], [SyncTime], [VendorName], [IRTempDetectionFunOn], [MaskDetectionFunOn], [UserPicURLFunOn], [MultiBioDataSupport], [MultiBioPhotoSupport], [MultiBioVersion], [MultiBioCount], [MaxMultiBioDataCount], [MaxMultiBioPhotoCount]
	FROM   [zkteco].[tblDevice]
	WHERE [DevSN] = @DevSN
	-- End Return Select <- do not remove
               
	COMMIT
GO
