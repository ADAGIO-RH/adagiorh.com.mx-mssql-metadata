USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spBuscarOpLog] 
    @ID int
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  

	BEGIN TRAN

	SELECT [ID], [Operator], [OpTime], [OpType], [User], [Obj1], [Obj2], [Obj3], [Obj4], [DeviceID] 
	FROM   [zkteco].[tblOpLog] 
	WHERE  ([ID] = @ID OR @ID IS NULL) 

	COMMIT
GO
