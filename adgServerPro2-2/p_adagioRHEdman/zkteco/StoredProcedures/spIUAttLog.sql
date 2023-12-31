USE [p_adagioRHEdman]
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
		@IDLector int
	;

	BEGIN TRAN
	
		select @IDLector = l.IDLector
		from zkteco.tblDevice d 
			join Asistencia.tblLectores l on l.NumeroSerial = d.DevSN
		where d.DevSN = @DeviceID

		INSERT INTO [zkteco].[tblAttLog] ([PIN], [AttTime], [Status], [Verify], [WorkCode], [Reserved1], [Reserved2], [DeviceID], [MaskFlag], [Temperature])
		SELECT @PIN, @AttTime, @Status, @Verify, @WorkCode, @Reserved1, @Reserved2, @DeviceID, @MaskFlag, @Temperature
	
		if (isnull(@IDLector, 0) > 0)
		begin
			exec [Asistencia].[spRegistrarZKChecada]	
				@IDLector = @IDLector
				,@IDEmpleado = @PIN
				,@FechaHora = @AttTime
		end
		
		-- Begin Return Select <- do not remove
		SELECT [ID], [PIN], [AttTime], [Status], [Verify], [WorkCode], [Reserved1], [Reserved2], [DeviceID], [MaskFlag], [Temperature]
		FROM   [zkteco].[tblAttLog]
		WHERE  [ID] = SCOPE_IDENTITY()
		-- End Return Select <- do not remove
               
	COMMIT
GO
