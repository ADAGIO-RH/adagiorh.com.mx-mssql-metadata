USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [zkteco].[spCoreCommand_DeleteUser](
	@dtUserInfo [zkteco].[dtUserInfo] readonly,
	@DevSN varchar(50) = null,
	@IDEmpleado int = null,
	@ExecSchedulerQueryUsers bit = 0,
	@IDUsuario int
)
AS
BEGIN
	Declare @dtUserInfoLocal [zkteco].[dtUserInfo]
	IF((Select count(*) from @dtUserInfo) > 0)
	BEGIN
		insert into @dtUserInfoLocal
		select * from @dtUserInfo
	END
	ELSE
	BEGIN
		Insert into @dtUserInfoLocal
		Exec zkteco.spCoreBuscarEmpleadosMasterByLector @DevSN= @DevSN, @IDEmpleado = @IDEmpleado, @IDUsuario = @IDUsuario
	END

	insert [zkteco].[tblTempDeviceCmds](DevSN,Template,Content, BioDataTemplate)
	SELECT  
		tw.DevSN,
		'Command_DeleteUser' as Template,
		FORMATMESSAGE('%s',
			tw.PIN								
		) as Content,
		null as  BioDataTemplate
	FROM (
		select distinct PIN,DevSN
		from @dtUserInfoLocal 
	) tw


	--IF(isnull(@ExecSchedulerQueryUsers,0) = 1)
	--BEGIN
	--	EXEC zkteco.spCoreCreateSchedulerQueryUsersDataZKTECO @DevSN = @DevSN, @dtUserInfo = @dtUserInfoLocal, @IDUsuario = @IDUsuario
	--END
	

END
GO
