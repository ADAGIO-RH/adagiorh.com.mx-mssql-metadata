USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spIUUserInfo] 
    @DevSN varchar(50) = NULL,
    @PIN varchar(50) = NULL,
    @UserName varchar(20) = NULL,
    @Pri varchar(2) = NULL,
    @Passwd varchar(20) = NULL,
    @IDCard varchar(50) = NULL,
    @Grp varchar(50) = NULL,
    @TZ varchar(50) = NULL
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRY
		BEGIN TRAN TransUserInfo
			set @PIN = CAST(@PIN as int)
			
			INSERT INTO [zkteco].[tblUserInfo] ([DevSN], [PIN], [UserName], [Passwd], [IDCard], [Grp], [TZ], [Pri])
			SELECT @DevSN, @PIN, @UserName, @Passwd, @IDCard, @Grp, @TZ, @Pri
	
			-- Begin Return Select <- do not remove
			SELECT [ID], [DevSN], [PIN], [UserName], [Passwd], [IDCard], [Grp], [TZ], [Pri]
			FROM   [zkteco].[tblUserInfo]
			WHERE  [ID] = SCOPE_IDENTITY()
			-- End Return Select <- do not remove
               
		COMMIT TRAN TransUserInfo
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN TransUserInfo
	END CATCH
GO
