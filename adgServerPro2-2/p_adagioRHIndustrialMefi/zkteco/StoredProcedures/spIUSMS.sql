USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spIUSMS] 
	@ID int = 0,
    @SMSId int = NULL,
    @Type int = NULL,
    @ValidTime int = NULL,
    @BeginTime datetime = NULL,
    @UserID char(50) = NULL,
    @Content char(320) = NULL
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN
	
	if (ISNULL(@ID, 0) = 0)
	begin
		INSERT INTO [zkteco].[tblSMS] ([SMSId], [Type], [ValidTime], [BeginTime], [UserID], [Content])
		SELECT @SMSId, @Type, @ValidTime, @BeginTime, @UserID, @Content

		set @ID = SCOPE_IDENTITY()
	end else
	begin
		UPDATE [zkteco].[tblSMS]
		SET    [SMSId] = @SMSId, [Type] = @Type, [ValidTime] = @ValidTime, [BeginTime] = @BeginTime, [UserID] = @UserID, [Content] = @Content
		WHERE  [ID] = @ID
	end
	-- Begin Return Select <- do not remove
	SELECT [ID], [SMSId], [Type], [ValidTime], [BeginTime], [UserID], [Content]
	FROM   [zkteco].[tblSMS]
	WHERE  [ID] = @ID
	-- End Return Select <- do not remove
               
	COMMIT
GO
