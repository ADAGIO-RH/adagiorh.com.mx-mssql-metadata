USE [p_adagioRHStark]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spIUDeviceCmds] 
	@ID int = 0,
    @DevSN varchar(50) = NULL,
    @Content text = NULL,
    @CommitTime datetime = NULL,
    @TransTime datetime = NULL,
    @ResponseTime datetime = NULL,
    @ReturnValue varchar(8000) = NULL
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN
	
	if (ISNULL(@ID, 0) = 0)
	begin
		INSERT INTO [zkteco].[tblDeviceCmds] ([DevSN], [Content], [CommitTime], [TransTime], [ResponseTime], [ReturnValue])
		SELECT @DevSN, @Content, @CommitTime, @TransTime, @ResponseTime, @ReturnValue

		set @ID = SCOPE_IDENTITY()
	end else
	begin
		update  [zkteco].[tblDeviceCmds]
			set 
				ResponseTime = @ResponseTime,
				ReturnValue = @ReturnValue
		where ID = @ID
	end
	-- Begin Return Select <- do not remove
	SELECT [ID], [DevSN], [Content], [CommitTime], [TransTime], [ResponseTime], [ReturnValue], Executed
	FROM   [zkteco].[tblDeviceCmds]
	WHERE  [ID] = @ID
	-- End Return Select <- do not remove
               
	COMMIT
GO
