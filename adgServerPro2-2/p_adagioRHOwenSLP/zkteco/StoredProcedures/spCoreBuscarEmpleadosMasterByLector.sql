USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [zkteco].[spCoreBuscarEmpleadosMasterByLector](
	@DevSN varchar(50),
	@IDEmpleado int = null,
	@IDUsuario int
)
AS
BEGIN
	declare 
		@IDLector int,
		@LastSync datetime,
		@LastFullDownload datetime,
		@EsMaster bit,
		@IDCliente int,
		@DevName varchar(255),
		@MensajeHistory varchar(max),
		@NoFiltrarEmpleadosPorClienteLector bit = 0
	;

	select @NoFiltrarEmpleadosPorClienteLector = cast(isnull(Valor,0) as bit) 
	from app.tblConfiguracionesGenerales with(nolock) 
	where IDConfiguracion = 'NoFiltrarEmpleadosPorClienteLector'


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

	SELECT  
		@DevSN as DevSN
		,cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint) as varchar(20)) as PIN	
		,coalesce(em.Nombre,'')+' '+coalesce(em.Paterno, '') as UserName
        ,(select count(*) from zkteco.tblTmpFP		with(nolock) where PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint) as varchar(20)) and DevSN = @DevSN) as FP									
        ,(select count(*) from zkteco.tblTmpFace	with(nolock) where PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint) as varchar(20)) and DevSN = @DevSN) as Face	
        ,(select count(*) from zkteco.tblTmpBioData	with(nolock) where PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint) as varchar(20)) and DevSN = @DevSN) as BioData	
        ,(select count(*) from zkteco.tblTmpUserPic	with(nolock) where PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint) as varchar(20)) and DevSN = @DevSN) as UserPic
        ,ISNULL((select top 1 CASE WHEN ISNULL(Passwd,'') <> '' THEN 1 ELSE 0 END  from zkteco.tblUserInfo	with(nolock) where PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint) as varchar(20)) and DevSN = @DevSN),0) as UserPasswd
        ,ISNULL((select top 1 CASE WHEN ISNULL(IDCard,'') <> '' THEN 1 ELSE 0 END  from zkteco.tblUserInfo	with(nolock) where PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint) as varchar(20)) and DevSN = @DevSN),0) as UserIDCard
			
		,(select count(*) from zkteco.tblTmpFP		with(nolock) where PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint) as varchar(20)) and DevSN = dMaster.DevSN) as FPMaster									
        ,(select count(*) from zkteco.tblTmpFace	with(nolock) where PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint) as varchar(20)) and DevSN = dMaster.DevSN) as FaceMaster
        ,(select count(*) from zkteco.tblTmpBioData	with(nolock) where PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint) as varchar(20)) and DevSN = dMaster.DevSN) as BioDataMaster	
        ,(select count(*) from zkteco.tblTmpUserPic	with(nolock) where PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint) as varchar(20)) and DevSN = dMaster.DevSN) as UserPicMaster	
		,ISNULL((select top 1 CASE WHEN ISNULL(Passwd,'') <> '' THEN 1 ELSE 0 END  from zkteco.tblUserInfo	with(nolock) where PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint) as varchar(20)) and DevSN = dMaster.DevSN),0) as UserPasswdMaster
        ,ISNULL((select top 1 CASE WHEN ISNULL(IDCard,'') <> '' THEN 1 ELSE 0 END  from zkteco.tblUserInfo	with(nolock) where PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint) as varchar(20)) and DevSN = dMaster.DevSN),0) as UserIDCardMaster
		,dMaster.DevSN as DevSNMaster
		,case when ui.ID is null then 1 else 0 end as Newuser	
		,isnull(cast(pul.IDTipoPrivilegioLectorZK as varchar(2)), '0')	as Pri
		,isnull(ui.Passwd		, '')									as Passwd
		,isnull(ui.IDCard		, '')									as IDCard
		,isnull(ui.Grp			, '')									as Grp
		,isnull(ui.TZ			, '')									as TZ
		,isnull(uiMaster.Passwd	, '')									as PasswdMaster
		,isnull(uiMaster.IDCard	, '')									as IDCardMaster
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
			where ((lm.IDCliente = @IDCliente) or (isnull(@NoFiltrarEmpleadosPorClienteLector,0) = 1))
		) as dMaster 
		left join [zkteco].[tblUserInfo] uiMaster with(nolock) on uiMaster.PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint) as varchar(20))-- cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as varchar(20))
			and uiMaster.DevSN = dMaster.DevSN
	where
	    ((em.IDCliente = @IDCliente ) or (isnull(@NoFiltrarEmpleadosPorClienteLector,0) = 1))  
		and ISNULL(em.Vigente, 0) = 1 --and ui.ID is null
		and (em.IDEmpleado = isnull(@IDEmpleado,0) or isnull(@IDEmpleado,0) = 0 )

END
GO
