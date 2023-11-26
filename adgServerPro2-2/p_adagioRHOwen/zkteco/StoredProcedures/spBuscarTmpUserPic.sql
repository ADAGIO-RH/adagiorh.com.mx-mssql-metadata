USE [p_adagioRHOwen]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spBuscarTmpUserPic] 
    @ID int
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  

	BEGIN TRAN

	SELECT [ID], [Pin], [FileName], [Size], [Content] 
	FROM   [zkteco].[tblTmpUserPic] 
	WHERE  ([ID] = @ID OR @ID IS NULL) 

	COMMIT
GO
