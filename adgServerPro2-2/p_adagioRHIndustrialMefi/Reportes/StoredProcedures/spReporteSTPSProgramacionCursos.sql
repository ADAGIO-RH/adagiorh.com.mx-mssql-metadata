USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteSTPSProgramacionCursos](
	@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
) as


DECLARE @FechaIni Date,
		@FechaFin Date



select top 1 @FechaIni = Cast(Value as date) from @dtFiltros where Catalogo = 'FechaIni'
select top 1 @FechaFin = Cast(Value as date) from @dtFiltros where Catalogo = 'FechaFin'

		Select c.Codigo as [Codigo STPS]
			, c.Descripcion as [Curso STPS]
			,FORMAT(PCC.FechaIni,'dd/MM/yyyy') as [Fecha Inicio]
			,FORMAT(PCC.FechaFin,'dd/MM/yyyy') as [Fecha Fin]
			,PCC.Duracion
			,CC.Codigo +' - '+ cc.Nombre as [Curso/Capacitacion] 
			,agentes.Codigo +' - '+ agentes.Apellidos +'  '+agentes.Nombre as Instructor
		From STPS.tblProgramacionCursosCapacitacion PCC
		
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
	order by c.Descripcion,CC.Codigo,cc.Nombre, pcc.FechaFin
GO
