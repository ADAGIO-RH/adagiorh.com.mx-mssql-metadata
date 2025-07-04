USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create    PROCEDURE zkteco.[spQueryPins](  
	@DevSN varchar(50),
	@PINs varchar(max)
)  
AS 
	insert zkteco.tblDeviceCmds(DevSN, Content, CommitTime, Executed)
	select distinct @DevSN,FORMATMESSAGE('DATA QUERY USERINFO PIN=%s',item), getdate(), 0
	from App.Split(@PINs, ',')
GO
