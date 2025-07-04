USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spBuscarUserInfo] 
    @ID int = 0,
	@PIN varchar(50) = null,
	@DevSN varchar(50) = null
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  

	SELECT [ID], [DevSN], [PIN], [UserName], [Passwd], [IDCard], [Grp], [TZ], [Pri] 
	FROM   [zkteco].[tblUserInfo] 
	WHERE  ([ID] = @ID OR isnull(@ID,0) = 0) 
		and ([PIN] = isnull(@PIN,'') OR isnull(@PIN,'') = '') 
		and ([DevSN] = isnull(@DevSN,'') OR isnull(@DevSN,'') = '')
GO
