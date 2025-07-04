USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
create proc Reportes.spColaboradoresPorLectoresZK (
	@IDLector int = 0,
	@IDusuario int
) as
	declare 
		@DevSN varchar(20)
	;

	select @DevSN = NumeroSerial
	from Asistencia.tblLectores
	where IDLector = @IDLector

	select 
		isnull(d.DevSN,'0000000000000') as DevSN,
		isnull(d.DevName, 'SIN LECTOR') as Lector,
		em.ClaveEmpleado, 
		em.NOMBRECOMPLETO as Colaborador,		
		case when (select count(*) from Asistencia.tblLectoresEmpleados where IDEmpleado = em.IDEmpleado and IDLEctor = l.IDLector)	> 0 then 'SI' else 'NO' end as AsignadoAlLector,
		case when (select count(*) from zkteco.tblTmpFP			where PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as int) as varchar(20)) and DevSN = d.DevSN)	> 0 then 'SI' else 'NO' end as FingerPrint,
		case when (select count(*) from zkteco.tblTmpFace		where PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as int) as varchar(20)) and DevSN = d.DevSN)	> 0 then 'SI' else 'NO' end as Face,
		case when (select count(*) from zkteco.tblTmpBioData	where PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as int) as varchar(20)) and DevSN = d.DevSN)	> 0 then 'SI' else 'NO' end as BioData
	from RH.tblEmpleadosMaster em
		cross apply zkteco.tblDevice d -- on d.DevSN = u.DevSN
		left join Asistencia.tblLectores l on l.NumeroSerial = d.DevSN
	where isnull(em.Vigente, 0) = 1 and (d.DevSN = @DevSN or isnull(@DevSN, '') ='')
GO
