USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spIUTmpUserPic] 
    @Pin varchar(50) = NULL,
    @FileName varchar(100) = NULL,
    @Size int = NULL,
    @Content text = NULL
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN
	
	INSERT INTO [zkteco].[tblTmpUserPic] ([Pin], [FileName], [Size], [Content])
	SELECT @Pin, @FileName, @Size, @Content
	
	-- Begin Return Select <- do not remove
	SELECT [ID], [Pin], [FileName], [Size], [Content]
	FROM   [zkteco].[tblTmpUserPic]
	WHERE  [ID] = SCOPE_IDENTITY()
	-- End Return Select <- do not remove
               
	COMMIT
GO
