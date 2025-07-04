USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spBuscarSMS] 
    @ID int
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  

	BEGIN TRAN

	SELECT [ID], [SMSId], [Type], [ValidTime], [BeginTime], [UserID], [Content] 
	FROM   [zkteco].[tblSMS] 
	WHERE  ([ID] = @ID OR @ID IS NULL) 

	COMMIT
GO
