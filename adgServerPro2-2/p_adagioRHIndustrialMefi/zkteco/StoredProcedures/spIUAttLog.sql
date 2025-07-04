USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [zkteco].[spIUAttLog] 
    @PIN varchar(50) = NULL,
    @AttTime datetime = NULL,
    @Status varchar(10) = NULL,
    @Verify varchar(10) = NULL,
    @WorkCode varchar(50) = NULL,
    @Reserved1 varchar(50) = NULL,
    @Reserved2 varchar(50) = NULL,
    @DeviceID varchar(50) = NULL,
    @MaskFlag int = NULL,
    @Temperature varchar(50) = NULL
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	declare 
		@IDLector int,
		@IDCliente int,
		@spCustomRegistrarChecadaADMS	Varchar(500)
	;

	BEGIN TRAN
	
		select @IDLector = l.IDLector,
			@IDCliente = l.IDCliente
		from zkteco.tblDevice d 
			join Asistencia.tblLectores l on l.NumeroSerial = d.DevSN
		where d.DevSN = @DeviceID

		INSERT INTO [zkteco].[tblAttLog] ([PIN], [AttTime], [Status], [Verify], [WorkCode], [Reserved1], [Reserved2], [DeviceID], [MaskFlag], [Temperature])
		SELECT @PIN, @AttTime, @Status, @Verify, @WorkCode, @Reserved1, @Reserved2, @DeviceID, @MaskFlag, @Temperature
	
		if (isnull(@IDLector, 0) > 0)
		begin
			select
				 @spCustomRegistrarChecadaADMS	= isnull(config.Valor,'')
			from RH.[TblConfiguracionesCliente] config with (nolock)
			where config.IDCliente = @IDCliente and config.IDTipoConfiguracionCliente = 'spCustomRegistrarChecadaADMS'

			IF(@spCustomRegistrarChecadaADMS <> '')
			BEGIN
			print 'custom'
				/*
					EXEC CUSTOM STORE PROCEDURE 
				*/
				exec sp_executesql N'exec @miSP @IDEmpleado,@Proporcional,@FechaBaja,@IDUsuario'                   
					,N' @IDLector int      
						,@IDEmpleado int                   
						,@FechaHora Datetime               
						,@miSP			varchar(255)'                          
						,@IDLector		= @IDLector                  
						,@IDEmpleado	= @PIN                 
						,@FechaHora		= @AttTime                  
						,@miSP			= @spCustomRegistrarChecadaADMS ;  
			END
			ELSE
			BEGIN
			print 'core'
				/*
					EXEC CORE STORE PROCEDURE 
				*/
				exec [Asistencia].[spRegistrarZKChecada]	
					@IDLector = @IDLector
					,@IDEmpleado = @PIN
					,@FechaHora = @AttTime
			END
		
		end
		
		-- Begin Return Select <- do not remove
		SELECT [ID], [PIN], [AttTime], [Status], [Verify], [WorkCode], [Reserved1], [Reserved2], [DeviceID], [MaskFlag], [Temperature]
		FROM   [zkteco].[tblAttLog]
		WHERE  [ID] = SCOPE_IDENTITY()
		-- End Return Select <- do not remove
               
	COMMIT
GO
