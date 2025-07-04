USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROC [zkteco].[spBuscarDeviceCmdsPendientes] 
	@DevSN varchar(50)
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  

	BEGIN TRAN
		--if (DATEDIFF(MINUTE, ISNULL((select max(FechaReg) 
		--							from zkteco.spBuscarDeviceCmdsPendientesHistory
		--							WHERE DevSN=@DevSN and Executed = 1), '1990-01-01 00:00:00'), GETDATE()) > 1)
		--begin
			--insert zkteco.spBuscarDeviceCmdsPendientesHistory (DevSN, Executed)
			--values(@DevSN, 1)

			SELECT top 2000 ID, DevSN, replace(cast(Content as varchar(max)),'...','') as Content, CommitTime, TransTime, ResponseTime, ReturnValue 
			FROM [zkteco].[tblDeviceCmds] with (nolock)
			WHERE DevSN=@DevSN and (ReturnValue is null or len(ReturnValue)=0)
			ORDER BY CommitTime ASC
				--and content not like '%FACE%'
		--end else
		--begin
		--	insert zkteco.spBuscarDeviceCmdsPendientesHistory (DevSN, Executed)
		--	values(@DevSN, 0)

		--	SELECT  ID, DevSN, Content, CommitTime, TransTime, ResponseTime, ReturnValue 
		--	FROM [zkteco].[tblDeviceCmds] with (nolock)
		--	WHERE DevSN='xxxxx' and (ReturnValue is null or len(ReturnValue)=0)
		--end

	COMMIT
GO
