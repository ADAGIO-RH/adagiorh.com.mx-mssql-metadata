USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [zkteco].[spCoreCommand_DataQueryAttLog](
	@DevSN varchar(50),
	@StartTime datetime = null,
	@EndTime datetime = null,
	@IDUsuario int
)
AS
BEGIN
	insert [zkteco].[tblTempDeviceCmds](DevSN,Template,Content)
	SELECT  
		@DevSN,
		'Command_QueryAttLog' as Template,
		FORMATMESSAGE('%s|%s',
			FORMAT(isnull(@StartTime,'2000-01-01 00:00:00'),'yyyy-MM-dd HH:mm:ss'),						
			FORMAT(isnull(@EndTime,'9999-12-31 23:59:59'),'yyyy-MM-dd HH:mm:ss')			
		) as Content

END
GO
