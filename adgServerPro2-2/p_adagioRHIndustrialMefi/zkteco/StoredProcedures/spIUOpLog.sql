USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spIUOpLog] 
    @Operator varchar(50) = NULL,
    @OpTime datetime = NULL,
    @OpType varchar(10) = NULL,
    @User varchar(50) = NULL,
    @Obj1 varchar(50) = NULL,
    @Obj2 varchar(50) = NULL,
    @Obj3 varchar(50) = NULL,
    @Obj4 varchar(50) = NULL,
    @DeviceID varchar(50) = NULL
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN
	
	INSERT INTO [zkteco].[tblOpLog] ([Operator], [OpTime], [OpType], [User], [Obj1], [Obj2], [Obj3], [Obj4], [DeviceID])
	SELECT @Operator, @OpTime, @OpType, @User, @Obj1, @Obj2, @Obj3, @Obj4, @DeviceID
	
	-- Begin Return Select <- do not remove
	SELECT [ID], [Operator], [OpTime], [OpType], [User], [Obj1], [Obj2], [Obj3], [Obj4], [DeviceID]
	FROM   [zkteco].[tblOpLog]
	WHERE  [ID] = SCOPE_IDENTITY()
	-- End Return Select <- do not remove
               
	COMMIT
GO
