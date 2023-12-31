USE [p_adagioRHCorporativoCet]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spBuscarUserInfo] 
    @ID int
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  

	BEGIN TRAN

	SELECT [ID], [DevSN], [PIN], [UserName], [Passwd], [IDCard], [Grp], [TZ], [Pri] 
	FROM   [zkteco].[tblUserInfo] 
	WHERE  ([ID] = @ID OR @ID IS NULL) 

	COMMIT
GO
