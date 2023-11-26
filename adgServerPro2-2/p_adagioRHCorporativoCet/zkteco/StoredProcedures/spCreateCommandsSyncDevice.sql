USE [p_adagioRHCorporativoCet]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [zkteco].[spCreateCommandsSyncDevice] (
	@DevSN varchar(50) 
) as
	declare 
		--@DevSN varchar(50) = 'AEVB182461126',
		@IDLector int,
		@LastSync datetime,
		@EsMaster bit,
		@DevSNMaster varchar(50),
		@IDCliente int
	;

	--declare
	--	--Control
 --       @Command_ControlReboot		nvarchar(4000) = 'REBOOT',
 --       @Command_ControlUnLock		nvarchar(4000) = 'AC_UNLOCK',
 --       @Command_ControlUnAlarm		nvarchar(4000) = 'AC_UNALARM',
 --       @Command_ControlInfo		nvarchar(4000) = 'INFO',

 --       --Update
 --       @Command_UpdateUserInfo		nvarchar(4000) = 'DATA UPDATE USERINFO PIN={0}\tName={1}\tPri={2}\tPasswd={3}\tCard={4}\tGrp={5}\tTZ={6}',
 --       @Command_UpdateIDCard		nvarchar(4000) = '',
 --       @Command_UpdateFingerTmp	nvarchar(4000) = 'DATA UPDATE FINGERTMP PIN={0}\tFID={1}\tSize={2}\tValid={3}\tTMP={4}',
 --       @Command_UpdateFaceTmp		nvarchar(4000) = 'DATA UPDATE FACE PIN={0}\tFID={1}\tValid={2}\tSize={3}\tTMP={4}',
 --       @Command_UpdateFvein		nvarchar(4000) = 'DATA$ UPDATE FVEIN Pin={0}\tFID={1}\tIndex={2}\tValid={3}\tSize={4}\tTmp={5}',
 --       @Command_UpdateBioData		nvarchar(4000) = 'DATA UPDATE BIODATA Pin={0}\tNo={1}\tIndex={2}\tValid={3}\tDuress={4}\tType={5}\tMajorVer={6}\tMinorVer ={7}\tFormat={8}\tTmp={9}',
 --       @Command_UpdateBioPhoto		nvarchar(4000) = 'DATA UPDATE BIOPHOTO PIN={0}\tType={1}\tSize={2}\tContent={3}\tFormat={4}\tUrl={5}\tPostBackTmpFlag={6}',
 --       @Command_UpdateUserPic		nvarchar(4000) = 'DATA UPDATE USERPIC PIN={0}\tSize={1}\tContent={2}',
 --       @Command_UpdateSMS			nvarchar(4000) = 'DATA UPDATE SMS MSG={0}\tTAG={1}\tUID={2}\tMIN={3}\tStartTime={4}',
 --       @Command_UpdateUserSMS		nvarchar(4000) = 'DATA UPDATE USER_SMS PIN={0}\tUID={1}',
 --       @Command_UpdateAdPic		nvarchar(4000) = 'DATA UPDATE ADPIC Index={0}\tSize={1}\tExtension={2}\tContent={3}',
 --       @Command_UpdateWorkCode		nvarchar(4000) = 'DATA UPDATE WORKCODE PIN={0}\tCODE={1}\tNAME={2}',
 --       @Command_UpdateShortcutKey	nvarchar(4000) = 'DATA UPDATE ShortcutKey KeyID={0}\tKeyFun={1}\tStatusCode=={2}\tShowName={3}\tAutoState={4}\tAutoTime={5}\tSun={6}\tMon={7}\tTue={8}\tWed={9}\tThu={10}\tFri={11}\tSat={12}',
 --       @Command_UpdateAccGroup		nvarchar(4000) = 'DATA UPDATE AccGroup ID={0}\tVerify={1}\tValidHoliday={2}\tTZ={3}',
 --       @Command_UpdateAccTimeZone	nvarchar(4000) = 'DATA UPDATE AccTimeZone UID={0}\tSunStart={1}\tSunEnd={2}\tMonStart={3}\tMonEnd={4}\tTuesStart={5}\tTuesEnd={6}\tWedStart={7}\tWedEnd={8}\tThursStart={9}\tThursEnd={10}\tFriStart={11}\tFriEnd={12}\tSatStart={13}\tSatEnd={14}',
 --       @Command_UpdateAccHoliday	nvarchar(4000) = 'DATA UPDATE AccHoliday UID={0}\tHolidayName={1}\tStartDate={2}\tEndDate={3}\tTimeZone={4}',
 --       @Command_UpdateAccUnLockComb	nvarchar(4000) = 'DATA UPDATE AccUnLockComb UID={0}\tGroup1={1}\tGroup2={2}\tGroup3={3}\tGroup4={4}\tGroup5={5}',
 --       @Command_UpdateBlackList		nvarchar(4000) = 'DATA UPDATE Blacklist IDNum={0}',

 --       --Delete
 --       @Command_DeleteUser			nvarchar(4000) = 'DATA DELETE USERINFO PIN={0}',
 --       @Command_DeleteFingerTmp1	nvarchar(4000) = 'DATA DELETE FINGERTMP PIN={0}',
 --       @Command_DeleteFingerTmp2	nvarchar(4000) = 'DATA DELETE FINGERTMP PIN={0}\tFID={1}',
 --       @Command_DeleteFace			nvarchar(4000) = 'DATA DELETE FACE PIN={0}',
 --       @Command_DeleteFvein1		nvarchar(4000) = 'DATA DELETE FVEIN Pin={0}',
 --       @Command_DeleteFvein2		nvarchar(4000) = 'DATA DELETE FVEIN Pin={0}\tFID={1}',
 --       @Command_DeleteBioData1		nvarchar(4000) = 'DATA DELETE BIODATA Pin={0}',
 --       @Command_DeleteBioData2		nvarchar(4000) = 'DATA DELETE BIODATA Pin={0}\tType={1}',
 --       @Command_DeleteBioData3		nvarchar(4000) = 'DATA DELETE BIODATA Pin={0}\tType={1}\tNo={2}',
 --       @Command_DeleteUserPic		nvarchar(4000) = 'DATA DELETE USERPIC PIN={0}',
 --       @Command_DeleteBioPhoto		nvarchar(4000) = 'DATA DELETE BIOPHOTO PIN={0}',
 --       @Command_DeleteSMS			nvarchar(4000) = 'DATA DELETE SMS UID={0}',
 --       @Command_DeleteWorkCode		nvarchar(4000) = 'DATA DELETE WORKCODE CODE={0}',
 --       @Command_DeleteAdPic		nvarchar(4000) = 'DATA DELETE ADPIC Index={0}',

 --       --Query
 --       @Command_QueryAttLog	nvarchar(4000) = 'DATA QUERY ATTLOG StartTime={0}\tEndTime={1}',
 --       @Command_QueryAttPhoto	nvarchar(4000) = 'DATA QUERY ATTPHOTO StartTime={0}\tEndTime={1}',
 --       @Command_QueryUserInfo	nvarchar(4000) = 'DATA QUERY USERINFO PIN={0}',
 --       @Command_QueryAllUserInfo	nvarchar(4000) = 'DATA QUERY USERINFO',
 --       @Command_QueryFingerTmp nvarchar(4000) = 'DATA QUERY FINGERTMP PIN={0}\tFID={1}',
 --       @Command_QueryBioData1	nvarchar(4000) = 'DATA QUERY BIODATA Type={0}',
 --       @Command_QueryBioData2	nvarchar(4000) = 'DATA QUERY BIODATA Type={0}\tPIN={1}',
 --       @Command_QueryBioData3	nvarchar(4000) = 'DATA QUERY BIODATA Type={0}\tPIN={1}\tNo={2}',

 --       --Clear
 --       @Command_ClearLog		nvarchar(4000) = 'CLEAR LOG',
 --       @Command_ClearPhoto		nvarchar(4000) = 'CLEAR PHOTO',
 --       @Command_ClearData		nvarchar(4000) = 'CLEAR DATA',
 --       @Command_ClearBioData	nvarchar(4000) = 'CLEAR BIODATA',

 --       --Check
 --       @Command_Check nvarchar(4000) = 'CHECK',

 --       --Set
 --       @Command_SetOption			nvarchar(4000) = 'SET OPTION {0}={1}',
 --       @Command_SetReloadOptions	nvarchar(4000) = 'RELOAD OPTIONS',

 --       --File
 --       @Command_PutFile nvarchar(4000) = 'PutFile {0}\t{1}',

 --       --Enroll
 --       @Command_EnrollFP nvarchar(4000) = 'ENROLL_FP PIN={0}\tFID={1}\tRETRY={2}\tOVERWRITE={3}',

 --       --Other
 --       @Command_Unknown nvarchar(4000) = 'UNKNOWN'
	--;

	select 
		@IDLector  = l.IDLector
		,@LastSync = d.LastSync
		,@EsMaster = isnull(l.[Master],0)
		,@IDCliente = l.IDCliente
	from [zkteco].[tblDevice] d with (nolock)
		join [Asistencia].[tblLectores] l with (nolock) on l.NumeroSerial = d.DevSN
	where d.DevSN = @DevSN

	select top 1 
		@DevSNMaster = d.DevSN
	from [zkteco].[tblDevice] d with (nolock)
		join [Asistencia].[tblLectores] l with (nolock) on l.NumeroSerial = d.DevSN
	where l.IDCliente = @IDCliente and ISNULL(l.Master, 0) = 1

	if (ISNULL(@IDLector, 0) = 0) 
	begin
		-- LogError - Device don't exists
		print ' Device don''t exists'
		return
	end

	if (DATEDIFF(MINUTE, ISNULL(@LastSync, '1990-01-01 00:00:00'), GETDATE()) > 30)
	begin
		update [zkteco].[tblDevice]
			set LastSync = GETDATE()
		where DevSN = @DevSN

		print @EsMaster
		if (ISNULL(@EsMaster, 0) = 1)
		begin
			insert [zkteco].[tblTempDeviceCmds](DevSN,Template,Content)
			SELECT  
				@DevSN,
				'Command_UpdateUserInfo' as Template,
				FORMATMESSAGE('%s|%s|%s|%s|%s|%s|%s',
				cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as int) as varchar(20))	--as [EnrollNumber] 
				,coalesce(em.Nombre,'')+' '+coalesce(em.Paterno, '')									--as  [NombreUsuario]
				,'0'																					--as Pri
				,''																						--as Passwd
				,'0'																					--as IDCard
				,'0'																					--as Grp
				,'0'																					--as TZ
				) as Content
			FROM rh.tblEmpleadosMaster em with (nolock)
				left join [zkteco].[tblUserInfo] ui on ui.PIN = cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as int)
			where em.IDCliente = @IDCliente and ISNULL(em.Vigente, 0) = 1 and ui.ID is null
			UNION ALL
			select 
				@DevSN,
				'Command_QueryAllUserInfo' as Template,
				''
		end else
		begin
			declare @tempUsers as table (
				DevSN varchar(50),
				PIN varchar(50),
				UserName varchar(max)
			)

			insert @tempUsers(DevSN, PIN, UserName)
			SELECT  
				@DevSN
				,cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as int) as varchar(20))	
				,coalesce(em.Nombre,'')+' '+coalesce(em.Paterno, '')									
			FROM rh.tblEmpleadosMaster em with (nolock)
				join Asistencia.tblLectoresEmpleados el on em.IDEmpleado = el.IDEmpleado
				join Asistencia.tblLectores l on l.IDLector = el.IDLector and l.NumeroSerial = @DevSN
				left join [zkteco].[tblUserInfo] ui on ui.PIN = cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as int)
			where em.IDCliente = @IDCliente and ISNULL(em.Vigente, 0) = 1 --and ui.ID is null

			insert [zkteco].[tblTempDeviceCmds](DevSN,Template,Content)
			SELECT  
				@DevSN,
				'Command_UpdateUserInfo' as Template,
				FORMATMESSAGE('%s|%s|%s|%s|%s|%s|%s',
				PIN				--as [EnrollNumber] 
				,UserName		--as  [NombreUsuario]
				,'0'			--as Pri
				,''				--as Passwd
				,'0'			--as IDCard
				,'0'			--as Grp
				,'0'			--as TZ
				) as Content
			FROM @tempUsers
			UNION ALL
			SELECT  
				tw.DevSN,
				'Command_UpdateFaceTmp' as Template,
				FORMATMESSAGE('%s|%s|%s|%d|%s',
					tw.PIN						
					,tf.Fid			
					,tf.Valid			
					,tf.Size			
					,cast(tf.Tmp as varchar(max))		
				) as Content
			FROM @tempUsers tw
				join [zkteco].[tblTmpFace] tf on tf.Pin = tw.PIN and tf.DevSN = @DevSNMaster
			UNION ALL
			SELECT  
				tw.DevSN,
				'Command_UpdateFingerTmp' as Template,
				FORMATMESSAGE('%s|%s|%d|%s|%s',
					tw.PIN						
					,fp.Fid			
					,fp.Size			
					,fp.Valid			
					,cast(fp.Tmp as varchar(max))
				) as Content
			FROM @tempUsers tw
				join [zkteco].[tblTmpFP] fp on fp.Pin = tw.PIN and fp.DevSN = @DevSNMaster
			UNION ALL
			select 
				@DevSN,
				'Command_QueryAllUserInfo' as Template,
				''
		end
	end

--	SELECT  
--		@DevSN,
--		@Command_UpdateUserInfo as Template,
--	FORMATMESSAGE('%s|%s|%s|%s|%s|%s|%s',
--	cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as int) as varchar(20))	--as [EnrollNumber] 
--	,coalesce(em.Nombre,'')+' '+coalesce(em.Paterno, '')									--as  [NombreUsuario]
--	,'0'																					--as Pri
--	,''																						--as Passwd
--	,'0'																					--as IDCard
--	,'0'																					--as Grp
--	,'0'																					--as TZ
--	) as Content
--FROM rh.tblEmpleadosMaster em with (nolock)
--	left join [zkteco].[tblUserInfo] ui on ui.PIN = cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as int)
--where em.IDCliente = @IDCliente and ISNULL(em.Vigente, 0) = 1 and ui.ID is null
GO
