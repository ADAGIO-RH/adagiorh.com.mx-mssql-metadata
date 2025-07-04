USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spBuscarWorkcode] 
    @ID int
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  

	BEGIN TRAN

	SELECT [ID], [workcode], [workname] 
	FROM   [zkteco].[tblWorkcode] 
	WHERE  ([ID] = @ID OR @ID IS NULL) 

	COMMIT
GO
