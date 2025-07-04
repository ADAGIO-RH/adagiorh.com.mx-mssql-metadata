USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE zkteco.spCoreCommand_UpdateUserPic(
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
		'Command_UpdateUserPic' as Template,
		FORMATMESSAGE('%s|%d',
			tw.PIN						
			,fp.Size			
		) as Content,
		fp.Content BioDataTemplate
	FROM (
		select *, ROW_NUMBER()OVER(partition by PIN order by PIN ) as RN
		from @dtUserInfoLocal 
		where isnull(UserPic, 0) = 0 and isnull(UserPicMaster, 0) > 0
	) tw
		join [zkteco].[tblTmpUserPic] fp on fp.Pin = tw.PIN and fp.DevSN = tw.DevSNMaster and tw.RN = 1


	IF(isnull(@ExecSchedulerQueryUsers,0) = 1)
	BEGIN
		EXEC zkteco.spCoreCreateSchedulerQueryUsersDataZKTECO @DevSN = @DevSN, @dtUserInfo = @dtUserInfoLocal, @IDUsuario = @IDUsuario
	END
	

END
GO
