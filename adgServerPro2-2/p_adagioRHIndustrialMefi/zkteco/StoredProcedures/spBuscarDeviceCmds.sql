USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [zkteco].[spBuscarDeviceCmds] 
    @ID int = null,
	@DevSN varchar(50) = null,
	@Executed bit = 0
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  

	BEGIN TRAN

	SELECT [ID], [DevSN], [Content], [CommitTime], [TransTime], [ResponseTime], [ReturnValue], Executed
	FROM   [zkteco].[tblDeviceCmds] 
	WHERE 
    --  ([ID] = @ID OR @ID IS NULL) 
	-- 	and   
        ([DevSN] = @DevSN OR ISNULL(@DevSN, '') = '') 
		and   (isnull(Executed,0) = @Executed OR @Executed IS NULL) 

	COMMIT
GO
