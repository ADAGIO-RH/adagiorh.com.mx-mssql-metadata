USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spIUWorkcode] 
    @workcode varchar(4),
    @workname varchar(50) = NULL
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN
	
	INSERT INTO [zkteco].[tblWorkcode] ([workcode], [workname])
	SELECT @workcode, @workname
	
	-- Begin Return Select <- do not remove
	SELECT [ID], [workcode], [workname]
	FROM   [zkteco].[tblWorkcode]
	WHERE  [ID] = SCOPE_IDENTITY()
	-- End Return Select <- do not remove
               
	COMMIT
GO
