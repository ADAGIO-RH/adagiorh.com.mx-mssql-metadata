USE [p_adagioRHIndustrialMefi]
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

	Declare @DiasGeneraChecadas int

	if(@StartTime is null and @EndTime is null)
	BEGIN	
		Select  @DiasGeneraChecadas = CAST(isnull(Valor,'0') as int) from App.tblConfiguracionesGenerales with(nolock) where IDConfiguracion = 'DiasGeneraChecadas'
			set @StartTime = dateadd(DAY,(@DiasGeneraChecadas * -1),GETDATE())
			set @EndTime = GETDATE()
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM [zkteco].[tblTempDeviceCmds] WHERE DevSN = @DevSN and Template = 'Command_QueryAttLog' and ISNULL(Executed,0) = 0)
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
END
GO
