USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteSTPSColaboradoresCursos](
	@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
) as


DECLARE @FechaIni Date,
		@FechaFin Date



select top 1 @FechaIni = Cast(Value as date) from @dtFiltros where Catalogo = 'FechaIni'
select top 1 @FechaFin = Cast(Value as date) from @dtFiltros where Catalogo = 'FechaFin'

		Select M.ClaveEmpleado
			,M.NOMBRECOMPLETO as NombreCompleto
			,M.Departamento
			,M.Puesto
			,M.Sucursal
			,CC.Codigo +' - '+CC.Nombre as Curso
			,FORMAT(PCC.FechaIni,'dd/MM/yyyy') as [FECHA INICIAL]
			,FORMAT(PCC.FechaFin,'dd/MM/yyyy') as [FECHA FINAL]
			,FORMAT(SCC.FechaHoraInicial,'dd/MM/yyyy HH:mm') as FechaHoraInicial
			,FORMAT(SCC.FechaHoraFinal ,'dd/MM/yyyy HH:mm') as FechaHoraFinal
			,ECE.Descripcion as APROBADO
			,CASE WHEN M.Vigente = 1 THEN 'SI' ELSE 'NO' END Vigente
			, Instructor = substring(UPPER(COALESCE(agentes.Apellidos,'')+' '+COALESCE(agentes.Nombre,'')),1,1000 )
		From RH.tblEmpleadosMaster M
		inner join STPS.tblProgramacionCursosCapacitacionEmpleados PCCE
			on M.IDEmpleado = PCCE.IDEmpleado
		inner join STPS.tblEstatusCursosEmpleados ECE
			on PCCE.IDEstatusCursoEmpleados = ECE.IDEstatusCursoEmpleados
		inner join STPS.tblProgramacionCursosCapacitacion PCC
			on PCCE.IDProgramacionCursoCapacitacion = PCC.IDProgramacionCursoCapacitacion
		left join STPS.tblSesionesCursosCapacitacion SCC
			on SCC.IDProgramacionCursoCapacitacion = PCC.IDProgramacionCursoCapacitacion
		Inner join STPS.tblCursosCapacitacion CC
			on CC.IDCursoCapacitacion = PCC.IDCursoCapacitacion
		left join STPS.tblCatTematicas Tematica
			on Tematica.IDTematica = CC.IDAreaTematica
		left join STPS.tblAgentesCapacitacion agentes
			on PCC.IDAgenteCapacitacion = agentes.IDAgenteCapacitacion
		left join STPS.tblCatModalidades modalidades
			on modalidades.IDModalidad = PCC.IDModalidad
		left join STPS.tblCatCapacitaciones capacitaciones
			on capacitaciones.IDCapacitaciones = CC.IDCapacitaciones
		left join STPS.tblCatCursos C
			on CC.IDCurso = C.IDCursos
	WHERE  PCC.FechaIni >= @FechaIni and PCC.FechaFin <= @FechaFin
	order by M.ClaveEmpleado, SCC.FechaHoraInicial
GO
