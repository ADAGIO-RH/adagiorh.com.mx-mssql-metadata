USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spBorrarUserInfo] 
    @ID int
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN

	DELETE
	FROM   [zkteco].[tblUserInfo]
	WHERE  [ID] = @ID

	COMMIT
GO
