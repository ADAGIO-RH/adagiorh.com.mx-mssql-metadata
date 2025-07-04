USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	CREATE   PROCEDURE [zkteco].[spCoreCommand_UpdateUserInfo](
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
			DevSN,
			'Command_UpdateUserInfo' as Template,
			FORMATMESSAGE('%s|%s|%s|%s|%s|%s|%s',
			PIN				--as [EnrollNumber] 
			,UserName		--as  [NombreUsuario]
			,isnull(cast(Pri as varchar(2)), '0')							--as Pri
			,isnull(CASE WHEN isnull(info.Passwd	,'') <> '' THEN isnull(info.Passwd	,'') else (Select top 1 PasswdMaster from @dtUserInfoLocal where PIN = info.PIN and ISNULL(PasswdMaster,'') <> '' )	END,'') --as Passwd
			,isnull(CASE WHEN isnull(info.IDCard	,'') <> '' THEN isnull(info.IDCard	,'') else (Select top 1 IDCardMaster from @dtUserInfoLocal where PIN = info.PIN and isnull(info.IDCard	,'') <> '' ) END,'') --as IDCard
			,isnull(info.Grp	,'')		--as Grp
			,isnull(info.TZ		,'')	--as TZ
			) as Content,
			'' BioDataTemplate
		FROM  (
			select *, ROW_NUMBER()OVER(partition by PIN order by PIN ) as RN
			from @dtUserInfoLocal 
			where 
			(isnull(NewUser, 0) = 1
			OR (isnull(UserPasswd, 0) = 0  and ISNULL(UserPasswdMaster, 0) > 0) 
			OR  (isnull(UserIDCard, 0) = 0  and ISNULL(UserIDCardMaster, 0) > 0) 
			) 

		
		) info
		where info.RN = 1

		IF(isnull(@ExecSchedulerQueryUsers,0) = 1)
		BEGIN
			EXEC zkteco.spCoreCreateSchedulerQueryUsersDataZKTECO @DevSN = @DevSN, @dtUserInfo = @dtUserInfoLocal, @IDUsuario = @IDUsuario
		END
	END
GO
