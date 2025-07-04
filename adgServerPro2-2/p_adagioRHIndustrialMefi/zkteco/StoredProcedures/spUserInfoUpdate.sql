USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spUserInfoUpdate] 
    @ID int = 0,
    @DevSN varchar(50) = NULL,
    @PIN varchar(50) = NULL,
    @UserName varchar(20) = NULL,
    @Passwd varchar(20) = NULL,
    @IDCard varchar(50) = NULL,
    @Grp varchar(50) = NULL,
    @TZ varchar(50) = NULL,
    @Pri varchar(2) = NULL
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	BEGIN TRY
		BEGIN TRAN TransUserInfoUp
			set @PIN = CAST(@PIN as int)
			
			UPDATE [zkteco].[tblUserInfo]
				SET  [UserName] = @UserName, [Passwd] = @Passwd, [IDCard] = @IDCard, [Grp] = @Grp, [TZ] = @TZ, [Pri] = @Pri
			WHERE  [DevSN] = @DevSN and [PIN] = @PIN
	
			-- Begin Return Select <- do not remove
			SELECT [ID], [DevSN], [PIN], [UserName], [Passwd], [IDCard], [Grp], [TZ], [Pri]
			FROM   [zkteco].[tblUserInfo]
			WHERE  [DevSN] = @DevSN and [PIN] = @PIN
			-- End Return Select <- do not remove
               
		COMMIT TRAN TransUserInfoUp
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN TransUserInfoUp
	END CATCH
GO
