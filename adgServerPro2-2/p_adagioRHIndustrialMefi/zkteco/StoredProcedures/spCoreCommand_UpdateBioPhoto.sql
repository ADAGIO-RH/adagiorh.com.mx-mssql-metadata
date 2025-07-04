USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE zkteco.spCoreCommand_UpdateBioPhoto(
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
		'Command_UpdateBioPhoto' as Template,
		FORMATMESSAGE('%s|%s|%s|%s|%s|%s',
			tw.PIN						
			,tf.[Type]
			,cast(tb.Size as varchar)
			--,cast(tb.Content as varchar(max))
			,tf.[Format]					
			,'' -- [Url]
			,'0' --tPostBackTmpFlag
		) as Content,
		tb.Content BioDataTemplate
	FROM (
		select *, ROW_NUMBER()OVER(partition by PIN order by PIN ) as RN
		from @dtUserInfoLocal 
		where isnull(BioData, 0) = 0  and ISNULL(BioDataMaster, 0) > 0
	) tw
		join [zkteco].[tblTmpBioData] tf with(nolock) on tf.Pin = tw.PIN and tf.DevSN = tw.DevSNMaster and tw.RN = 1
		join zkteco.tblTmpBioPhoto tb with (nolock) on tb.PIN = tf.PIN and  tf.[Type] = tb.[Type]

	IF(isnull(@ExecSchedulerQueryUsers,0) = 1)
	BEGIN
		EXEC zkteco.spCoreCreateSchedulerQueryUsersDataZKTECO @DevSN = @DevSN, @dtUserInfo = @dtUserInfoLocal, @IDUsuario = @IDUsuario
	END

END
GO
