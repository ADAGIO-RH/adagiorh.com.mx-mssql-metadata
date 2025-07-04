USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spWorkcodeUpdate] 
    @ID int,
    @workcode varchar(4),
    @workname varchar(50) = NULL
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN

	UPDATE [zkteco].[tblWorkcode]
	SET    [workcode] = @workcode, [workname] = @workname
	WHERE  [ID] = @ID
	
	-- Begin Return Select <- do not remove
	SELECT [ID], [workcode], [workname]
	FROM   [zkteco].[tblWorkcode]
	WHERE  [ID] = @ID	
	-- End Return Select <- do not remove

	COMMIT
GO
