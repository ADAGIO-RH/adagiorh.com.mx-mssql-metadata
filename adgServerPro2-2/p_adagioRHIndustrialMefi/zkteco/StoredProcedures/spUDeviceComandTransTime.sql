USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE zkteco.spUDeviceComandTransTime
(
	@IDs varchar(max)
)
AS
BEGIN
	update [zkteco].[tblDeviceCmds] 
		set TransTime=getdate()
	where ID in(
		select cast(item as int) from app.split(@IDs,',')
	)
END
GO
