USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXEC [zkteco].[spCoreCommand_UpdateFaceTmp]@DevSN = 'CKNN203560072',@IDEmpleado = 166, @IDUsuario= 1
*/

CREATE   PROCEDURE [zkteco].[spCoreCommand_UpdateFaceTmp](
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
		'Command_UpdateFaceTmp' as Template,
		FORMATMESSAGE('%s|%s|%s|%d|%s',
			tw.PIN						
			,tf.Fid			
			,tf.Valid			
			,tf.Size			
			,cast(tf.Tmp as varchar(max))		
		) as Content,
		'' BioDataTemplate
	FROM (
		select *, ROW_NUMBER()OVER(partition by PIN order by PIN ) as RN
		from @dtUserInfoLocal 
		where isnull(Face, 0) = 0  and ISNULL(FaceMaster, 0) > 0
	) tw
		join [zkteco].[tblTmpFace] tf on tf.Pin = tw.PIN and tf.DevSN = tw.DevSNMaster and tw.RN = 1

	IF(isnull(@ExecSchedulerQueryUsers,0) = 1)
	BEGIN
		EXEC zkteco.spCoreCreateSchedulerQueryUsersDataZKTECO @DevSN = @DevSN, @dtUserInfo = @dtUserInfoLocal, @IDUsuario = @IDUsuario
	END

END
GO
