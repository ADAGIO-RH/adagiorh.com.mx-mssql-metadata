USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : PROCEDIMIENTO PARA MODIFICAR LOS LECTORES  
** Autor   : JOSE ROMAN  
** Email   : jose.roman@adagio.com.mx  
** FechaCreacion : 2018-09-19  
** Paremetros  :                
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd)	Autor						Comentario  
------------------- ------------------- ------------------------------------------------------------  
2021-09-09			Aneudy Abreu				Se quitó la actualización de la contraseña
***************************************************************************************************/  
CREATE PROCEDURE [Asistencia].[spUILectores](  
	@IDLector int = 0  
	,@Lector varchar(100)  
	,@CodigoLector varchar(100)  
	,@PasswordLector varchar(100)  
	,@IDTipoLector nvarchar(200)  
	,@IDZonaHoraria int = 0  
	,@IP Varchar(50)  
	,@Puerto Varchar(50) 
	,@Estatus Varchar(max) = null 
	,@EsComedor bit = 0
	,@Comida bit = 0
    ,@Master bit = 0
	,@IDCliente int = 0
	,@NumeroSerial varchar(50) = null 
	,@Configuracion nvarchar(max)
	,@AsignarTodosLosColaboradores bit = 0
	,@IDUsuario int  
)  
AS  
BEGIN  
 
	DECLARE 
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max),

		@DevSN varchar(50) = NULL,
		@DevName varchar(50) = NULL,
		@ATTLOGStamp varchar(50) = NULL,
		@OPERLOGStamp varchar(50) = NULL,
		@ATTPHOTOStamp varchar(50) = NULL,
		@ErrorDelay varchar(50) = '120',
		@Delay varchar(50) = '10',
		@TransFlag varchar(100) = '1111111111',
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
	;
	

	SET @Lector       = UPPER(ISNULL(@Lector,'')  )              
	SET @CodigoLector = UPPER(ISNULL(@CodigoLector,''))
	SET @NumeroSerial = UPPER(ISNULL(@NumeroSerial,''))

	select 
		@IDZonaHoraria = CASE WHEN @IDZonaHoraria = 0 THEN NULL ELSE @IDZonaHoraria END
		,@IDCliente = CASE WHEN @IDCliente = 0 THEN NULL ELSE @IDCliente END


	declare @tmpDevice as table (
		[ID] [int] NOT NULL,
		[DevSN] [varchar](50) NULL,
		[DevName] [varchar](50) NULL,
		[ATTLOGStamp] [varchar](50) NULL,
		[OPERLOGStamp] [varchar](50) NULL,
		[ATTPHOTOStamp] [varchar](50) NULL,
		[ErrorDelay] [varchar](50) NULL,
		[Delay] [varchar](50) NULL,
		[TransFlag] [varchar](100) NULL,
		[Realtime] [varchar](1) NULL,
		[TransInterval] [varchar](10) NULL,
		[TransTimes] [varchar](60) NULL,
		[Encrypt] [varchar](1) NULL,
		[LastRequestTime] [datetime] NULL,
		[DevIP] [varchar](50) NULL,
		[DevMac] [varchar](50) NULL,
		[DevFPVersion] [varchar](50) NULL,
		[DevFirmwareVersion] [varchar](50) NULL,
		[UserCount] [int] NULL,
		[AttCount] [int] NULL,
		[FpCount] [int] NULL,
		[TimeZone] [varchar](50) NULL,
		[Timeout] [int] NULL,
		[SyncTime] [int] NULL,
		[VendorName] [varchar](50) NULL,
		[IRTempDetectionFunOn] [varchar](1) NULL,
		[MaskDetectionFunOn] [varchar](1) NULL,
		[UserPicURLFunOn] [varchar](1) NULL,
		[MultiBioDataSupport] [varchar](50) NULL,
		[MultiBioPhotoSupport] [varchar](50) NULL,
		[MultiBioVersion] [varchar](100) NULL,
		[MultiBioCount] [varchar](100) NULL,
		[MaxMultiBioDataCount] [varchar](100) NULL,
		[MaxMultiBioPhotoCount] [varchar](100) NULL
	)

	IF(ISNULL(@IDLector,0) = 0)  
	BEGIN  
		INSERT INTO Asistencia.tblLectores(Lector,CodigoLector,PasswordLector,IDTipoLector,IDZonaHoraria,[IP],Puerto,IDCliente,EsComedor,Comida, Master, NumeroSerial, Configuracion, AsignarTodosLosColaboradores)  
		VALUES(@Lector,@CodigoLector,@PasswordLector,@IDTipoLector,@IDZonaHoraria,@IP, @Puerto,@IDCliente, isnull(@EsComedor,0), isnull(@Comida,0), @Master, @NumeroSerial, @Configuracion, isnull(@AsignarTodosLosColaboradores,0))  
  
		SET @IDLector = @@IDENTITY  

		if (@IDTipoLector = 'ZK' and isjson(@Configuracion) > 0 and (json_value(@Configuracion, '$.connectivity') = 'ADMS'))
		begin
			insert @tmpDevice
			exec [zkteco].[spIUDevice] 
				@DevSN		= @NumeroSerial,
				@DevName	= @Lector,
				@ErrorDelay	= @ErrorDelay,
				@Delay		= @Delay,
				@TransFlag	= @TransFlag,
				@Realtime	= @Realtime,
				@TransInterval	=@TransInterval,
				@VendorName		= @VendorName,
				@TimeZone		= @TimeZone,
				@IRTempDetectionFunOn	= @IRTempDetectionFunOn,
				@MaskDetectionFunOn		= @MaskDetectionFunOn,
				@LastRequestTime		= @LastRequestTime
		end

		select @NewJSON = (SELECT Lector
                            ,CodigoLector
                            ,PasswordLector
                            ,IDTipoLector
                            ,IDZonaHoraria
                            ,[IP]
                            ,Puerto
                            ,IDCliente
                            ,EsComedor
                            ,Comida
                            ,Master
                            ,NumeroSerial
                            ,Configuracion
                            ,AsignarTodosLosColaboradores
                            FROM  [Asistencia].[tblLectores]
                            WHERE IDLector = @IDLector FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblLectores]','[Asistencia].[spUILectores]','INSERT',@NewJSON,''
	END  
	ELSE  
	BEGIN  
		select @OldJSON = (SELECT Lector
                            ,CodigoLector
                            ,PasswordLector
                            ,IDTipoLector
                            ,IDZonaHoraria
                            ,[IP]
                            ,Puerto
                            ,IDCliente
                            ,EsComedor
                            ,Comida
                            ,Master
                            ,NumeroSerial
                            ,Configuracion
                            ,AsignarTodosLosColaboradores
                            FROM  [Asistencia].[tblLectores]
                            WHERE IDLector = @IDLector FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		
		UPDATE Asistencia.tblLectores  
		set Lector = @Lector,  
			CodigoLector = @CodigoLector,  
		 	PasswordLector = @PasswordLector,  
			IDTipoLector = @IDTipoLector,  
			IDZonaHoraria = @IDZonaHoraria,  
			[IP] = @IP,  
			Puerto = @Puerto ,
			Estatus = @Estatus ,
			IDCliente = @IDCliente,
			EsComedor = ISNULL(@EsComedor,0),
			Comida = ISNULL(@Comida,0),
            Master = @Master,
			NumeroSerial = @NumeroSerial,
			Configuracion = @Configuracion,
			AsignarTodosLosColaboradores = isnull(@AsignarTodosLosColaboradores,0)
		WHERE IDLector = @IDLector  
        
select @NewJSON = (SELECT Lector
                            ,CodigoLector
                            ,PasswordLector
                            ,IDTipoLector
                            ,IDZonaHoraria
                            ,[IP]
                            ,Puerto
                            ,IDCliente
                            ,EsComedor
                            ,Comida
                            ,Master
                            ,NumeroSerial
                            ,Configuracion
                            ,AsignarTodosLosColaboradores
                            FROM  [Asistencia].[tblLectores]
                            WHERE IDLector = @IDLector FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

		if (@IDTipoLector = 'ZK' and isjson(@Configuracion) > 0 and (json_value(@Configuracion, '$.connectivity') = 'ADMS'))
		begin
			select 
				 @ATTLOGStamp			 = ATTLOGStamp		
				,@OPERLOGStamp			 = OPERLOGStamp		
				,@ATTPHOTOStamp			 = ATTPHOTOStamp		
				,@ErrorDelay				 = ErrorDelay			
				,@Delay					 = [Delay]				
				,@TransFlag				 = TransFlag			
				,@Realtime				 = Realtime			
				,@TransInterval			 = TransInterval		
				,@TransTimes				 = TransTimes			
				,@Encrypt				 = Encrypt			
				,@LastRequestTime		 = LastRequestTime	
				,@DevIP					 = DevIP				
				,@DevMac					 = DevMac				
				,@DevFPVersion			 = DevFPVersion		
				,@DevFirmwareVersion		 = DevFirmwareVersion	
				,@UserCount				 = UserCount			
				,@AttCount				 = AttCount			
				,@FpCount				 = FpCount			
				,@TimeZone				 = TimeZone			
				,@Timeout				 = [Timeout]			
				,@SyncTime				 = SyncTime			
				,@VendorName				 = VendorName			
				,@IRTempDetectionFunOn	 = IRTempDetectionFunOn
				,@MaskDetectionFunOn		 = MaskDetectionFunOn	
				,@UserPicURLFunOn		 = UserPicURLFunOn	
				,@MultiBioDataSupport	 = MultiBioDataSupport
				,@MultiBioPhotoSupport	 = MultiBioPhotoSupport
				,@MultiBioVersion		 = MultiBioVersion	
				,@MultiBioCount			 = MultiBioCount		
				,@MaxMultiBioDataCount	 = MaxMultiBioDataCount
				,@MaxMultiBioPhotoCount	 = MaxMultiBioPhotoCount
			from zkteco.tblDevice
			where DevSN = @NumeroSerial

			insert @tmpDevice
			exec [zkteco].[spIUDevice] 
				@DevSN = @NumeroSerial
				,@DevName = @Lector
				,@ATTLOGStamp			= @ATTLOGStamp			
				,@OPERLOGStamp			= @OPERLOGStamp			
				,@ATTPHOTOStamp			= @ATTPHOTOStamp			
				,@ErrorDelay			= @ErrorDelay			
				,@Delay					= @Delay					
				,@TransFlag				= @TransFlag				
				,@Realtime				= @Realtime				
				,@TransInterval			= @TransInterval			
				,@TransTimes			= @TransTimes			
				,@Encrypt				= @Encrypt				
				,@LastRequestTime		= @LastRequestTime		
				,@DevIP					= @DevIP					
				,@DevMac				= @DevMac				
				,@DevFPVersion			= @DevFPVersion			
				,@DevFirmwareVersion	= @DevFirmwareVersion	
				,@UserCount				= @UserCount				
				,@AttCount				= @AttCount				
				,@FpCount				= @FpCount				
				,@TimeZone				= @TimeZone				
				,@Timeout				= @Timeout				
				,@SyncTime				= @SyncTime				
				,@VendorName			= @VendorName			
				,@IRTempDetectionFunOn	= @IRTempDetectionFunOn	
				,@MaskDetectionFunOn	= @MaskDetectionFunOn	
				,@UserPicURLFunOn		= @UserPicURLFunOn		
				,@MultiBioDataSupport	= @MultiBioDataSupport	
				,@MultiBioPhotoSupport	= @MultiBioPhotoSupport	
				,@MultiBioVersion		= @MultiBioVersion		
				,@MultiBioCount			= @MultiBioCount			
				,@MaxMultiBioDataCount	= @MaxMultiBioDataCount	
				,@MaxMultiBioPhotoCount	= @MaxMultiBioPhotoCount
		end

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblLectores]','[Asistencia].[spUILectores]','UPDATE',@NewJSON,@OldJSON
	END  
  
	IF(isnull(@AsignarTodosLosColaboradores,0) = 1)
	BEGIN
		exec [Asistencia].[spAsignarEmpleadosALectoresPorFiltro] @IDLector = @IDLector, @IDUsuarioLogin = @IDUsuario 
	END

	EXEC Asistencia.spBuscarLectores 
        @IDLector = @IDLector , @IDUsuario = @IDUsuario
END
GO
