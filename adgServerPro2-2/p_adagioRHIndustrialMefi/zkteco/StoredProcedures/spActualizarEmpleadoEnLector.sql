USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [zkteco].[spActualizarEmpleadoEnLector](
	@IDLector	int, 
	@IDEmpleado int, 
	@IDUsuario	int
) as
	declare @tempUsers as table (
		DevSN varchar(50),
		PIN varchar(50),
		UserName varchar(max),
		Pri varchar(2),
		Passwd	varchar(20),
		IDCard	varchar(50),
		Grp		varchar(50),
		TZ		varchar(50)
	)

	insert @tempUsers(DevSN, PIN, UserName, Pri, Passwd, IDCard, Grp, TZ)
	SELECT  
		l.NumeroSerial
		,cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as int) as varchar(20))	
		,coalesce(em.Nombre,'')+' '+coalesce(em.Paterno, '')
		,isnull(cast(pul.IDTipoPrivilegioLectorZK as varchar(2)), '0')	--as Pri
		,isnull(ui.Passwd	, '')	--as Passwd
		,isnull(ui.IDCard	, '')	--as IDCard
		,isnull(ui.Grp		, '')	--as Grp
		,isnull(ui.TZ		, '')	--as TZ
	FROM RH.tblEmpleadosMaster em with (nolock)
		left join (
			select *, ROW_NUMBER()over(partition by PIN order by PIN, IDCard desc, Passwd desc, tz desc) as RN
			from zkteco.tblUserInfo
		) ui on ui.PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint) as varchar(20)) and ui.RN = 1
		left join Asistencia.tblPrivilegiosUsuarioLectoresZK pul with(nolock) on pul.IDEmpleado = em.IDEmpleado and pul.IDLector = @IDLector 
		,Asistencia.tblLectores l
	where em.IDEmpleado = @IDEmpleado  and l.IDLector = @IDLector and l.NumeroSerial is not null

	insert [zkteco].[tblTempDeviceCmds](DevSN,Template,Content, BioDataTemplate)
	SELECT  
		DevSN,
		'Command_UpdateUserInfo' as Template,
		FORMATMESSAGE('%s|%s|%s|%s|%s|%s|%s',
			PIN				--as [EnrollNumber] 
			,UserName		--as  [NombreUsuario]
			,isnull(cast(Pri as varchar(2)), '0')	--as Pri
			,Passwd									--as Passwd
			,IDCard									--as IDCard
			,Grp									--as Grp
			,TZ										--as TZ
		) as Content,
		'' BioDataTemplate
	FROM @tempUsers
	UNION ALL
	select top 1
		DevSN,
		'Command_QueryUserInfo' as Template,
		FORMATMESSAGE('%s',
			PIN					
		) as Content,
		''
	FROM @tempUsers
GO
