USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [zkteco].[spCoreCommand_Reboot](
	@dtUserInfo [zkteco].[dtUserInfo] readonly,
	@DevSN varchar(50) = null,
	@IDUsuario int,
    @ExecuteNow bit = null
)
AS
BEGIN
	declare 
		@IDLector int,
		@LastSync datetime,
		@LastFullDownload datetime,
		@EsMaster bit,
		@IDCliente int,
		@DevName varchar(255),
		@MensajeHistory varchar(max),
		@tempUsers [zkteco].[dtUserInfo]
	;

    SELECT @IDLector = IDLector from Asistencia.tblLectores with(nolock) where NumeroSerial = @DevSN
	if (ISNULL(@IDLector, 0) = 0) 
	begin
		set @MensajeHistory = FORMATMESSAGE('El lector %s no existe', @DevSN)
		exec [log].[spILogHistory]	
			@LogLevel	   = 'info'
			,@Mensaje	   = @MensajeHistory
			,@IDSource	   = 'stored-procedure'
			,@IDCategory   = 'zkteco'
			,@IDAplicacion = 'Asistencia'
			,@Data		   = @DevSN
			,@IDUsuario		= 1

		return
	end

	select 
		@IDLector	= l.IDLector
		,@DevName	= d.DevName
		,@LastSync	= d.LastSync
		,@LastFullDownload	= isnull(d.LastFullDownload, '1990-01-01')
		,@EsMaster	= isnull(l.[Master],0)
		,@IDCliente = l.IDCliente
	from [zkteco].[tblDevice] d with (nolock)
		join [Asistencia].[tblLectores] l with (nolock) on l.NumeroSerial = d.DevSN
	where d.DevSN = @DevSN
    

	update [zkteco].[tblDevice]
		set LastRequestTime = GETDATE()
	where DevSN = @DevSN
		
	
	insert [zkteco].[tblTempDeviceCmds](DevSN,Template,Content, BioDataTemplate)
	SELECT  
		@DevSN,
		'Command_ControlReboot' as Template,
		-- FORMATMESSAGE('%s|%s|%d|%s|%s'						
		-- 	,fpNueva.Fid			
		-- 	,fpNueva.Size			
		-- 	,fpNueva.Valid			
		-- 	,cast(fpNueva.Tmp as varchar(max))
		-- ) as Content,
		'' as content,
		'' BioDataTemplate
	-- FROM [zkteco].[tblTmpFP] fpNueva	
    -- where DevSN=@DevSN			
			--UNION ALL

	
END
GO
