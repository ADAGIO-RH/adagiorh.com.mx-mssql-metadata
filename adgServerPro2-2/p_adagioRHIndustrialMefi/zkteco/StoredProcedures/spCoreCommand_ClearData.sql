USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [zkteco].[spCoreCommand_ClearData](
	@DevSN varchar(50),
	@IDUsuario int
)
AS
BEGIN
	insert [zkteco].[tblTempDeviceCmds](DevSN,Template,Content)
	SELECT  
		@DevSN,
		'Command_ClearData' as Template,
		'' as Content

	EXEC [zkteco].[spCoreBorrarUserInfo] @DevSN = @DevSN,@IDEmpleado = 0, @IDUsuario = @IDUsuario
	EXEC [zkteco].[spCoreCommand_DataQueryUserInfo] @DevSN = @DevSN,@IDEmpleado = 0, @IDUsuario = @IDUsuario
END
GO
