USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [zkteco].[spCoreCommand_ClearLog](
	@DevSN varchar(50),
	@IDUsuario int
)
AS
BEGIN
	insert [zkteco].[tblTempDeviceCmds](DevSN,Template,Content)
	SELECT  
		@DevSN,
		'Command_ClearLog' as Template,
		'' as Content
END
GO
