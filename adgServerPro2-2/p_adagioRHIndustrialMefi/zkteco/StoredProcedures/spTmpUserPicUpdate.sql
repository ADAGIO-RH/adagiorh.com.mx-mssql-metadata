USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spTmpUserPicUpdate] 
    @ID int,
    @Pin varchar(50) = NULL,
    @FileName varchar(100) = NULL,
    @Size int = NULL,
    @Content text = NULL
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN

	UPDATE [zkteco].[tblTmpUserPic]
	SET    [Pin] = @Pin, [FileName] = @FileName, [Size] = @Size, [Content] = @Content
	WHERE  [ID] = @ID
	
	-- Begin Return Select <- do not remove
	SELECT [ID], [Pin], [FileName], [Size], [Content]
	FROM   [zkteco].[tblTmpUserPic]
	WHERE  [ID] = @ID	
	-- End Return Select <- do not remove

	COMMIT
GO
