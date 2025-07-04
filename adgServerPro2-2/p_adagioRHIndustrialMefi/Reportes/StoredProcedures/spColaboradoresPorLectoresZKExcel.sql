USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc Reportes.spColaboradoresPorLectoresZKExcel (
	@dtFiltros Nomina.dtFiltrosRH readonly,
	@IDusuario int
) as
	declare 
		@IDLector int,
		@DevSN varchar(20)
	;

	select @IDLector = cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDLector'),',')

	select @DevSN = NumeroSerial
	from Asistencia.tblLectores
	where IDLector = @IDLector

	select *
	from (
		select 
			isnull(d.DevSN,'0000000000000') as [CODIGO LECTOR],
			isnull(d.DevName, 'SIN LECTOR') as LECTOR,
			em.ClaveEmpleado as [CLAVE COLABORADOR], 
			em.NOMBRECOMPLETO as COLABORADOR,		
			case when (select count(*) from Asistencia.tblLectoresEmpleados where IDEmpleado = em.IDEmpleado and IDLEctor = l.IDLector)	> 0 then 'SI' else 'NO' end as [ASIGNADO AL LECTOR],
			case when (select count(*) from zkteco.tblTmpFP			where PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as int) as varchar(20)) and DevSN = d.DevSN)	> 0 then 'SI' else 'NO' end as FingerPrint,
			case when (select count(*) from zkteco.tblTmpFace		where PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as int) as varchar(20)) and DevSN = d.DevSN)	> 0 then 'SI' else 'NO' end as Face,
			case when (select count(*) from zkteco.tblTmpBioData	where PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as int) as varchar(20)) and DevSN = d.DevSN)	> 0 then 'SI' else 'NO' end as BioData
		from RH.tblEmpleadosMaster em
			cross apply zkteco.tblDevice d -- on d.DevSN = u.DevSN
			left join Asistencia.tblLectores l on l.NumeroSerial = d.DevSN
		where isnull(em.Vigente, 0) = 1 and (d.DevSN = @DevSN or isnull(@DevSN, '') ='')
	) as info
	order by LECTOR, [ASIGNADO AL LECTOR], [CLAVE COLABORADOR]
GO
