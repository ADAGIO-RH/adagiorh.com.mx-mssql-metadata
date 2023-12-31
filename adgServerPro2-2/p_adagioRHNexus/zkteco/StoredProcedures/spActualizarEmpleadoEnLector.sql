USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   proc [zkteco].[spActualizarEmpleadoEnLector](
	@IDLector	int, 
	@IDEmpleado int, 
	@IDUsuario	int
) as
	declare @tempUsers as table (
		DevSN varchar(50),
		PIN varchar(50),
		UserName varchar(max),
		Pri varchar(2)
	)

	insert @tempUsers(DevSN, PIN, UserName, Pri)
	SELECT  
		l.NumeroSerial
		,cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as int) as varchar(20))	
		,coalesce(em.Nombre,'')+' '+coalesce(em.Paterno, '')
		,isnull(cast(pul.IDTipoPrivilegioLectorZK as varchar(2)), '0') --as Pri
	FROM rh.tblEmpleadosMaster em with (nolock)
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
		,isnull(cast(Pri as varchar(2)), '0')							--as Pri
		,''				--as Passwd
		,'0'			--as IDCard
		,'0'			--as Grp
		,'0'			--as TZ
		) as Content,
		'' BioDataTemplate
	FROM  @tempUsers
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
