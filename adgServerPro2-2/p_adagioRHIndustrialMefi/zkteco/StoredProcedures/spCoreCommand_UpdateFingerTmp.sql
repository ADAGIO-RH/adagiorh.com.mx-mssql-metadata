USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [zkteco].[spCoreCommand_UpdateFingerTmp](
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
	SELECT  distinct
		tw.DevSN,
		'Command_UpdateFingerTmp' as Template,
		FORMATMESSAGE('%s|%s|%d|%s|%s',
			tw.PIN						
			,fpNueva.Fid			
			,fpNueva.Size			
			,fpNueva.Valid			
			,cast(fpNueva.Tmp as varchar(max))
		) as Content,
		'' BioDataTemplate
	FROM [zkteco].[tblTmpFP] fpNueva
			join (
				select tww.*, ROW_NUMBER()OVER(partition by tww.PIN order by tww.PIN asc, tww.FPMaster desc) as RN
				from @dtUserInfoLocal tww
				where isnull(tww.FP, 0) < isnull(tww.FPMaster, 0)
			) tw on fpNueva.Pin = tw.PIN and fpNueva.DevSN = tw.DevSNMaster 
			left join [zkteco].[tblTmpFP] fpActual on fpActual.Pin = tw.PIN and fpActual.DevSN = tw.DevSN and fpActual.Fid = fpNueva.Fid
		where fpActual.Fid is null and tw.RN = 1
			--UNION ALL

	IF(isnull(@ExecSchedulerQueryUsers,0) = 1)
	BEGIN
		EXEC zkteco.spCoreCreateSchedulerQueryUsersDataZKTECO @DevSN = @DevSN, @dtUserInfo = @dtUserInfoLocal, @IDUsuario = @IDUsuario
	END
END
GO
