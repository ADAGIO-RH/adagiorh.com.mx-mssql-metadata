USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: PROCEDIMIENTO PARA OBTENER LOS LECTORES POR SERIAL
** Autor			: DENZEL OVANDO	
** Email			: debzel.ovando@adagio.com.mx
** FechaCreacion	: 2021-11-26
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/

CREATE PROCEDURE [Asistencia].[spIULectoresOpciones]
(
	   @IDLector  int
      ,@DevSN  varchar(100)
      ,@DeviceName  varchar(100)
      ,@AttLogStamp  varchar(100)
      ,@OperLogStamp  varchar(100)
      ,@AttPhotoStamp  varchar(100)
      ,@ErrorDelay  varchar(100)
      ,@Delay  varchar(100)
      ,@TransFlag  varchar(100)
      ,@Realtime  varchar(100)
      ,@TransInterval  varchar(100)
      ,@TransTimes  varchar(100)
      ,@Encrypt  varchar(100)
      ,@LastRequestTime  datetime
      ,@IPAddress  varchar(100)
      ,@MAC  varchar(100)
      ,@FWVersion  varchar(100)
      ,@UserCount  int
      ,@FpCount  int
      ,@AttCount  int
      ,@TimeZone  varchar(100)
      ,@Timeout  int
      ,@SyncTime  int
      ,@OEMVendor  varchar(100)
      ,@IRTempDetectionFunOn  varchar(100)
      ,@MaskDetectionFunOn  varchar(100)
      ,@UserPicURLFunOn  varchar(100)
      ,@MultiBioDataSupport  varchar(100)
      ,@MultiBioPhotoSupport  varchar(100)
      ,@MultiBioVersion  varchar(100)
      ,@MultiBioCount  varchar(100)
      ,@MaxMultiBioDataCount  varchar(100)
      ,@MaxMultiBioPhotoCount  varchar(100)
)
AS
BEGIN

IF NOT EXISTS ( SELECT 1 FROM [Asistencia].[tblLectoresOpciones] WHERE [IDLector] = @IDLector )
BEGIN
	INSERT INTO [Asistencia].[tblLectoresOpciones]
           ([IDLector]
           ,[DevSN]
           ,[DeviceName]
           ,[AttLogStamp]
           ,[OperLogStamp]
           ,[AttPhotoStamp]
           ,[ErrorDelay]
           ,[Delay]
           ,[TransFlag]
           ,[Realtime]
           ,[TransInterval]
           ,[TransTimes]
           ,[Encrypt]
           ,[LastRequestTime]
           ,[IPAddress]
           ,[MAC]
           ,[FWVersion]
           ,[UserCount]
           ,[FpCount]
           ,[AttCount]
           ,[TimeZone]
           ,[Timeout]
           ,[SyncTime]
           ,[OEMVendor]
           ,[IRTempDetectionFunOn]
           ,[MaskDetectionFunOn]
           ,[UserPicURLFunOn]
           ,[MultiBioDataSupport]
           ,[MultiBioPhotoSupport]
           ,[MultiBioVersion]
           ,[MultiBioCount]
           ,[MaxMultiBioDataCount]
           ,[MaxMultiBioPhotoCount])
     VALUES
           ( @IDLector  
			,@DevSN  
			,@DeviceName 
			,@AttLogStamp  
			,@OperLogStamp  
			,@AttPhotoStamp  
			,@ErrorDelay  
			,@Delay  
			,@TransFlag  
			,@Realtime 
			,@TransInterval 
			,@TransTimes  
			,@Encrypt  
			,@LastRequestTime  
			,@IPAddress  
			,@MAC  
			,@FWVersion  
			,@UserCount  
			,@FpCount  
			,@AttCount  
			,@TimeZone  
			,@Timeout  
			,@SyncTime  
			,@OEMVendor  
			,@IRTempDetectionFunOn  
			,@MaskDetectionFunOn  
			,@UserPicURLFunOn
			,@MultiBioDataSupport  
			,@MultiBioPhotoSupport  
			,@MultiBioVersion 
			,@MultiBioCount  
			,@MaxMultiBioDataCount  
			,@MaxMultiBioPhotoCount  )
	END
	ELSE
	BEGIN
		UPDATE [Asistencia].[tblLectoresOpciones]
		   SET [DevSN] = @DevSN
			  ,[DeviceName] = @DeviceName
			  ,[AttLogStamp] = @AttLogStamp
			  ,[OperLogStamp] = @OperLogStamp
			  ,[AttPhotoStamp] = @AttPhotoStamp
			  ,[ErrorDelay] = @ErrorDelay
			  ,[Delay] = @Delay
			  ,[TransFlag] = @TransFlag
			  ,[Realtime] = @Realtime
			  ,[TransInterval] = @TransInterval
			  ,[TransTimes] = @TransTimes
			  ,[Encrypt] = @Encrypt
			  ,[LastRequestTime] = @LastRequestTime
			  ,[IPAddress] = @IPAddress
			  ,[MAC] = @MAC
			  ,[FWVersion] = @FWVersion
			  ,[UserCount] = @UserCount
			  ,[FpCount] = @FpCount
			  ,[AttCount] = @AttCount
			  ,[TimeZone] = @TimeZone
			  ,[Timeout] = @Timeout
			  ,[SyncTime] = @SyncTime
			  ,[OEMVendor] = @OEMVendor
			  ,[IRTempDetectionFunOn] = @IRTempDetectionFunOn
			  ,[MaskDetectionFunOn] = @MaskDetectionFunOn
			  ,[UserPicURLFunOn] = @UserPicURLFunOn
			  ,[MultiBioDataSupport] = @MultiBioDataSupport
			  ,[MultiBioPhotoSupport] = @MultiBioPhotoSupport
			  ,[MultiBioVersion] = @MultiBioVersion
			  ,[MultiBioCount] = @MultiBioCount
			  ,[MaxMultiBioDataCount] = @MaxMultiBioDataCount
			  ,[MaxMultiBioPhotoCount] = @MaxMultiBioPhotoCount
			  WHERE [IDLector] = @IDLector
	END

			EXECUTE [Asistencia].[spBuscarLectoresBySN] 
		   @SerialNumber = @DevSN

END
GO
