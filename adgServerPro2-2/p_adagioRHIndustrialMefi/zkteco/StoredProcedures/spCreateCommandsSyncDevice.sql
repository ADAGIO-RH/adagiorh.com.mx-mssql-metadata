USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [zkteco].[spCreateCommandsSyncDevice] (
	@DevSN varchar(50) 
) as
	declare 
		@IDLector int,
		@LastSync datetime,
		@LastFullDownload datetime,
		@EsMaster bit,
		@IDCliente int,
		@DevName varchar(255),
		@MensajeHistory varchar(max)
	;

	update [zkteco].[tblDevice]
		set LastRequestTime = GETDATE()
	where DevSN = @DevSN
	
	select 
		@IDLector	= l.IDLector
		,@DevName	= d.DevName
		,@LastSync	= d.LastSync
		,@LastFullDownload	= isnull(d.LastFullDownload, '1990-01-01')
		,@EsMaster	= isnull(l.[Master],0)
		,@IDCliente = l.IDCliente
	from [zkteco].[tblDevice] d with (nolock)
		join [Asistencia].[tblLectores] l with (nolock) on l.NumeroSerial = d.DevSN
	where d.DevSN = @DevSN

	if exists (
		select top 1 1
		from [zkteco].[tblDeviceCmds] with (nolock)
		WHERE DevSN = @DevSN and (ReturnValue is null or len(ReturnValue)=0)
	)
	begin
		set @MensajeHistory = FORMATMESSAGE('El lector %s (%s) tiene comandos pendientes', @DevName, @DevSN)
		exec [log].[spILogHistory]	
			@LogLevel	   = 'info'
			,@Mensaje	   = @MensajeHistory
			,@IDSource	   = 'stored-procedure'
			,@IDCategory   = 'zkteco'
			,@IDAplicacion = 'Asistencia'
			,@Data		   = @DevSN
			,@IDUsuario		= 1

		return
	end

	if exists (
		select top 1 1
		from [zkteco].[tblTempDeviceCmds] with (nolock)
		WHERE DevSN = @DevSN and (isnull(Executed, 0)=0)
	)
	begin
		set @MensajeHistory = FORMATMESSAGE('El lector %s (%s) tiene comandos temporales pendientes', @DevName, @DevSN)
		exec [log].[spILogHistory]	
			@LogLevel	   = 'info'
			,@Mensaje	   = @MensajeHistory
			,@IDSource	   = 'stored-procedure'
			,@IDCategory   = 'zkteco'
			,@IDAplicacion = 'Asistencia'
			,@Data		   = @DevSN
			,@IDUsuario		= 1

		return
	end

	WHILE 1 = 1
	BEGIN
		delete TOP(1000) [zkteco].[tblDeviceCmds] where DevSN = @DevSN and  (ISNULL(ReturnValue,'') <> '')
		if @@ROWCOUNT = 0 BREAK;
	END

	WHILE 1 = 1
	BEGIN
		delete TOP(1000) [zkteco].[tblTempDeviceCmds] where DevSN = @DevSN and (isnull(Executed, 0)=1)
		if @@ROWCOUNT = 0 BREAK;
	END

	if (ISNULL(@IDLector, 0) = 0) 
	begin
		set @MensajeHistory = FORMATMESSAGE('El lector %s no existe', @DevSN)
		exec [log].[spILogHistory]	
			@LogLevel	   = 'info'
			,@Mensaje	   = @MensajeHistory
			,@IDSource	   = 'stored-procedure'
			,@IDCategory   = 'zkteco'
			,@IDAplicacion = 'Asistencia'
			,@Data		   = @DevSN
			,@IDUsuario		= 1

		return
	end

	if (DATEDIFF(MINUTE, ISNULL(@LastSync, '1990-01-01 00:00:00'), GETDATE()) > 60)
	begin
		update [zkteco].[tblDevice]
			set LastSync = GETDATE()
		where DevSN = @DevSN
		
		if (ISNULL(@EsMaster, 0) = 1)
		begin
			insert [zkteco].[tblTempDeviceCmds](DevSN,Template,Content)
			SELECT  
				@DevSN,
				'Command_UpdateUserInfo' as Template,
				FORMATMESSAGE('%s|%s|%s|%s|%s|%s|%s',
				cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint) as varchar(20))	--as [EnrollNumber] 
				,coalesce(em.Nombre,'')+' '+coalesce(em.Paterno, '')									--as  [NombreUsuario]
				,isnull(cast(pul.IDTipoPrivilegioLectorZK as varchar(2)), '0')							--as Pri
				,ISNULL(ui.Passwd,'') 		--as Passwd
				,ISNULL(ui.IDCard,'')		--as IDCard
				,ISNULL(ui.Grp,'')			--as Grp
				,ISNULL(ui.TZ,'')		--as TZ
) as Content
			FROM rh.tblEmpleadosMaster em with (nolock)
				left join [zkteco].[tblUserInfo] ui on ui.PIN = cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint)
					and ui.DevSN = @DevSN
				left join Asistencia.tblPrivilegiosUsuarioLectoresZK pul with(nolock) on pul.IDEmpleado = em.IDEmpleado and pul.IDLector = @IDLector
			where em.IDCliente = @IDCliente and ISNULL(em.Vigente, 0) = 1 and ui.ID is null
			--UNION ALL
			--select 
			--	@DevSN,
			--	'Command_QueryAllUserInfo' as Template,
			--	''
		end 

		begin
			declare @tempUsers as table (
				DevSN varchar(50),
				PIN varchar(50),
				UserName varchar(max),
                FP int,
                Face int,
				BioData int,
				UserPic int,
				FPMaster int,
                FaceMaster int,
				BioDataMaster int,
				UserPicMaster int,
				DevSNMaster varchar(50),
				NewUser bit,
				Pri		varchar(2),
				Passwd	varchar(20),
				IDCard	varchar(50),
				Grp		varchar(50),
				TZ		varchar(50)
			)

			insert @tempUsers(DevSN, PIN, UserName, FP, Face, BioData, UserPic, FPMaster, FaceMaster, BioDataMaster, UserPicMaster, DevSNMaster, NewUser, Pri, Passwd, IDCard, Grp, TZ)
			SELECT  
				@DevSN
				,cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint) as varchar(20))	
				,coalesce(em.Nombre,'')+' '+coalesce(em.Paterno, '')
                ,(select count(*) from zkteco.tblTmpFP		with(nolock) where PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint) as varchar(20)) and DevSN = @DevSN) as FP									
                ,(select count(*) from zkteco.tblTmpFace	with(nolock) where PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint) as varchar(20)) and DevSN = @DevSN) as Face	
                ,(select count(*) from zkteco.tblTmpBioData	with(nolock) where PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint) as varchar(20)) and DevSN = @DevSN) as BioData	
                ,(select count(*) from zkteco.tblTmpUserPic	with(nolock) where PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint) as varchar(20)) and DevSN = @DevSN) as UserPic	
				,(select count(*) from zkteco.tblTmpFP		with(nolock) where PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint) as varchar(20)) and DevSN = dMaster.DevSN) as FPMaster									
                ,(select count(*) from zkteco.tblTmpFace	with(nolock) where PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint) as varchar(20)) and DevSN = dMaster.DevSN) as FaceMaster
                ,(select count(*) from zkteco.tblTmpBioData	with(nolock) where PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint) as varchar(20)) and DevSN = dMaster.DevSN) as BioDataMaster	
                ,(select count(*) from zkteco.tblTmpUserPic	with(nolock) where PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint) as varchar(20)) and DevSN = dMaster.DevSN) as UserPicMaster	

				,dMaster.DevSN as DevSNMaster
				,case when ui.ID is null then 1 else 0 end as Newuser	
				,isnull(cast(pul.IDTipoPrivilegioLectorZK as varchar(2)), '0')							--as Pri
				,ui.Passwd																				--as Passwd
				,ui.IDCard																				--as IDCard
				,ui.Grp																					--as Grp
				,ui.TZ																					--as TZ
			FROM rh.tblEmpleadosMaster em with (nolock)
				join Asistencia.tblLectoresEmpleados el with(nolock) on em.IDEmpleado = el.IDEmpleado
				join Asistencia.tblLectores l with(nolock) on l.IDLector = el.IDLector and l.NumeroSerial = @DevSN
				left join Asistencia.tblPrivilegiosUsuarioLectoresZK pul with(nolock) on pul.IDEmpleado = em.IDEmpleado and pul.IDLector = l.IDLector 
				left join [zkteco].[tblUserInfo] ui with(nolock) on ui.PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint) as varchar(20))-- cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as varchar(20))
					and ui.DevSN = @DevSN
				cross apply (
					select dm.*
					from zkteco.tblDevice dm with(nolock)
						join Asistencia.tblLectores lm with(nolock) on lm.NumeroSerial = dm.DevSN
					--where isnull(lm.Master, 0) = 1
				) as dMaster 
			where ISNULL(em.Vigente, 0) = 1 
				--em.IDCliente = @IDCliente and 
				--and ui.ID is null

			insert [zkteco].[tblTempDeviceCmds](DevSN,Template,Content, BioDataTemplate)
			SELECT  
				@DevSN,
				'Command_UpdateUserInfo' as Template,
				FORMATMESSAGE('%s|%s|%s|%s|%s|%s|%s',
				PIN				--as [EnrollNumber] 
				,UserName		--as  [NombreUsuario]
				,isnull(cast(Pri as varchar(2)), '0')	--as Pri
				,ISNULL(Passwd,'')	--as Passwd
				,ISNULL(IDCard,'')	--as IDCard
				,ISNULL(Grp	,'')	--as Grp
				,ISNULL(TZ	,'')	--as TZ
				) as Content,
				'' BioDataTemplate
			FROM  (
				select *, ROW_NUMBER()OVER(partition by PIN order by PIN ) as RN
				from @tempUsers 
				where isnull(NewUser, 0) = 1
			) info
			where RN = 1
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
				) as Content,
				'' BioDataTemplate
			FROM (
				select *, ROW_NUMBER()OVER(partition by PIN order by PIN ) as RN
				from @tempUsers 
				where isnull(Face, 0) = 0  and ISNULL(FaceMaster, 0) > 0
			) tw
				join [zkteco].[tblTmpFace] tf on tf.Pin = tw.PIN and tf.DevSN = tw.DevSNMaster and tw.RN = 1
			UNION ALL
			SELECT  
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
					from @tempUsers tww
					where isnull(tww.FP, 0) < isnull(tww.FPMaster, 0)
				) tw on fpNueva.Pin = tw.PIN and fpNueva.DevSN = tw.DevSNMaster 
				left join [zkteco].[tblTmpFP] fpActual on fpActual.Pin = tw.PIN and fpActual.DevSN = tw.DevSN and fpActual.Fid = fpNueva.Fid
			where fpActual.Fid is null and tw.RN = 1
			--UNION ALL
			--SELECT  
			--	tw.DevSN,
			--	'Command_UpdateBioData' as Template,
			--	FORMATMESSAGE('%s|%s|%s|%s|%s|%s|%s|%s|%s',
			--		tw.PIN						
			--		,tf.[No]			
			--		,tf.[Index]		
			--		,tf.Valid	
			--		,tf.Duress		
			--		,tf.[Type]	
			--		,tf.MajorVer
			--		,tf.MinorVer
			--		,tf.[Format]					
			--	) as Content,
			--	tf.Tmp BioDataTemplate
			--FROM (
			--	select *, ROW_NUMBER()OVER(partition by PIN order by PIN ) as RN
			--	from @tempUsers 
			--	where isnull(BioData, 0) = 0  and ISNULL(BioDataMaster, 0) > 0
			--) tw
			--	join [zkteco].[tblTmpBioData] tf with(nolock) on tf.Pin = tw.PIN and tf.DevSN = tw.DevSNMaster and tw.RN = 1
			UNION ALL
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
				from @tempUsers 
				where isnull(BioData, 0) = 0  and ISNULL(BioDataMaster, 0) > 0
			) tw
				join [zkteco].[tblTmpBioData] tf with(nolock) on tf.Pin = tw.PIN and tf.DevSN = tw.DevSNMaster and tw.RN = 1
				join zkteco.tblTmpBioPhoto tb with (nolock) on tb.PIN = tf.PIN and  tf.[Type] = tb.[Type]
			UNION ALL
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
				from @tempUsers 
				where isnull(UserPic, 0) = 0 and isnull(UserPicMaster, 0) > 0
			) tw
				join [zkteco].[tblTmpUserPic] fp on fp.Pin = tw.PIN and fp.DevSN = tw.DevSNMaster and tw.RN = 1
			--UNION ALL
			--select top 1
			--	@DevSN,
			--	'Command_QueryUserInfo' as Template,
			--	FORMATMESSAGE('%s',
			--		PIN					
			--	) as Content,
			--	''
			--FROM @tempUsers
			--where
			--	(isnull(NewUser, 0) = 1)
			--	or (isnull(Face, 0) = 0  and ISNULL(FaceMaster, 0) > 0)
			--	or isnull(FP, 0) = 0 and isnull(FPMaster, 0) > 0
			--	or isnull(BioData, 0) = 0  and ISNULL(BioDataMaster, 0) > 0

			--DECLARE @PINs VARCHAR(MAX)

			--SELECT @PINs = STUFF((
			--	SELECT ',' + PIN
			--	FROM @tempUsers
			--	where
			--		(isnull(NewUser, 0) = 1)
			--		or (isnull(Face, 0) = 0  and ISNULL(FaceMaster, 0) > 0)
			--		or isnull(FP, 0) = 0 and isnull(FPMaster, 0) > 0
			--		or isnull(BioData, 0) = 0  and ISNULL(BioDataMaster, 0) > 0
			--	FOR XML PATH('')
			--), 1, 1, '')

			--if (isnull(@PINs, '') != '')
			--begin
			--	exec [Scheduler].[spSchedulerQueryUsersDataZKTECO] 
			--		@DevSN=@DevSN
			--		,@PINs=@PINs
			--end

			DECLARE @StartRow INT = 1;
			DECLARE @EndRow INT = 10;

			WHILE @StartRow <= (SELECT MAX(RowNumber) FROM (SELECT ROW_NUMBER() OVER (ORDER BY PIN) AS RowNumber, PIN
																	 FROM @tempUsers
																	 WHERE (ISNULL(NewUser, 0) = 1)
																	   OR (ISNULL(Face, 0) = 0 AND ISNULL(FaceMaster, 0) > 0)
																	   OR (ISNULL(FP, 0) = 0 AND ISNULL(FPMaster, 0) > 0)
																	   OR (ISNULL(BioData, 0) = 0 AND ISNULL(BioDataMaster, 0) > 0)) AS Temp)
			BEGIN
				DECLARE @PINs VARCHAR(MAX);
    
				SELECT @PINs = STUFF((
					SELECT ',' + PIN
					FROM (SELECT ROW_NUMBER() OVER (ORDER BY PIN) AS RowNumber, PIN
						  FROM @tempUsers
						  WHERE (ISNULL(NewUser, 0) = 1)
							OR (ISNULL(Face, 0) = 0 AND ISNULL(FaceMaster, 0) > 0)
							OR (ISNULL(FP, 0) = 0 AND ISNULL(FPMaster, 0) > 0)
							OR (ISNULL(BioData, 0) = 0 AND ISNULL(BioDataMaster, 0) > 0)) AS Temp
					WHERE RowNumber BETWEEN @StartRow AND @EndRow
					FOR XML PATH('')), 1, 1, '');

				-- Llamada al stored procedure
				if (isnull(@PINs, '') != '')
				begin
					exec [Scheduler].[spSchedulerQueryUsersDataZKTECO] 
						@DevSN=@DevSN
						,@PINs=@PINs
				end


				SET @StartRow = @EndRow + 1;
				SET @EndRow = @StartRow + 9;
			END
		end
	end

	--if (cast(@LastFullDownload as date) < cast(getdate() as date) )
	--begin
	--	update [zkteco].[tblDevice]
	--		set LastFullDownload = GETDATE()
	--	where DevSN = @DevSN

	--	insert [zkteco].[tblTempDeviceCmds](DevSN,Template,Content)
	--	select 
	--		@DevSN,
	--		'Command_QueryAllUserInfo' as Template,
	--		''
	--end;
	
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
