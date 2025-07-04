USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   PROC [zkteco].[spUDeviceCmdsResponse] 
	@ID int = 0,
    @ReturnValue varchar(8000) = NULL
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN
	
		DECLARE @Error varchar(10)
		select top 1 @Error = item 
		from 
		App.Split(
				(select item
				from App.split(
				@ReturnValue,'&')
				where item like '%Return%'
				)
			,'=')
		where item <> 'Return'
		
		if(@Error <> '0')
		BEGIN
			insert into log.tblLogHistory(LogLevel,Mensaje,IDSource,IDCategory,IDAplicacion, [Data], IDUsuario, FechaHora)		
			select 
				'Error', 
				CAST('Error al ejecutar Comando:'+ cast(c.Content as varchar(max)) +'  || Response: '+ cast(@ReturnValue as varchar(max)) + '.' as varchar(max)),'stored-procedure', 'zkteco', 'Asistencia', null, 1, GETDATE()
			from zkteco.tblDeviceCmds c with(nolock)
			where ID = @ID
		END

		update  [zkteco].[tblDeviceCmds]
			set 
				ResponseTime = GETDATE(),
				ReturnValue = @ReturnValue
		where ID = @ID

		-- Begin Return Select <- do not remove
		SELECT [ID], [DevSN], [Content], [CommitTime], [TransTime], [ResponseTime], [ReturnValue], Executed
		FROM   [zkteco].[tblDeviceCmds] with(nolock)
		WHERE  [ID] = @ID
		-- End Return Select <- do not remove
               
	COMMIT
GO
