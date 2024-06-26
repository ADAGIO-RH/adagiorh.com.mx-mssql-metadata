USE [p_adagioRHBelmondCSN]
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
		@NewJSON Varchar(Max)
	;
	
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
				@DevSN = @NumeroSerial,
				@DevName = @Lector	
		end

		select @NewJSON = a.JSON from [Asistencia].[tblLectores] b
			cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDLector = @IDLector

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblLectores]','[Asistencia].[spUILectores]','INSERT',@NewJSON,''
	END  
	ELSE  
	BEGIN  
		select @OldJSON = a.JSON from [Asistencia].[tblLectores] b
			cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDLector = @IDLector
		
		UPDATE Asistencia.tblLectores  
		set Lector = @Lector,  
			CodigoLector = @CodigoLector,  
		--	PasswordLector = @PasswordLector,  
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

		select @NewJSON = a.JSON from [Asistencia].[tblLectores] b
			cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDLector = @IDLector

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblLectores]','[Asistencia].[spUILectores]','UPDATE',@NewJSON,@OldJSON
	END  
  
	if (@IDTipoLector = 'ZK' and isjson(@Configuracion) > 0 and (json_value(@Configuracion, '$.connectivity') = 'ADMS'))
	begin
		insert @tmpDevice
		exec [zkteco].[spIUDevice] 
			@DevSN = @NumeroSerial,
			@DevName = @Lector	
	end

	IF(isnull(@AsignarTodosLosColaboradores,0) = 1)
	BEGIN
		exec [Asistencia].[spAsignarEmpleadosALectoresPorFiltro] @IDLector = @IDLector, @IDUsuarioLogin = @IDUsuario 
	END

	EXEC Asistencia.spBuscarLectores 
        @IDLector = @IDLector , @IDUsuario = @IDUsuario
END
GO
