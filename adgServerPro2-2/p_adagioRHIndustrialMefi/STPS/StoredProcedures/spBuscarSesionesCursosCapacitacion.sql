USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [STPS].[spBuscarSesionesCursosCapacitacion]
(
	@IDProgramacionCursoCapacitacion int = 0,
	@IDSesion int = 0,
	@FechaInicio date,
	@FechaFin date,
	@IDUsuario int
)
AS
BEGIN
	
	SELECT PCC.IDProgramacionCursoCapacitacion
		,ISNULL(PCC.IDCursoCapacitacion,0) as IDCursoCapacitacion
		,CC.Codigo +' - '+ CC.Nombre as Curso
		,isnull(CC.Color,'#446db2') as Color
		,ISNULL(SCC.IDSesion,0) as IDSesion
		,ISNULL(SCC.IDSalaCapacitacion,0) as IDSalaCapacitacion
		,SC.Nombre as Sala
		,SCC.FechaHoraInicial
		,SCC.FechaHoraFinal
	FROM STPS.tblSesionesCursosCapacitacion SCC
		inner join  STPS.tblProgramacionCursosCapacitacion PCC
			on SCC.IDProgramacionCursoCapacitacion = PCC.IDProgramacionCursoCapacitacion
		inner join STPS.tblCursosCapacitacion CC
			on PCC.IDCursoCapacitacion = CC.IDCursoCapacitacion
		left join STPS.tblSalasCapacitacion SC
			on SC.IDSalaCapacitacion = SCC.IDSalaCapacitacion
	WHERE ((PCC.IDProgramacionCursoCapacitacion = @IDProgramacionCursoCapacitacion) OR (@IDProgramacionCursoCapacitacion = 0))
		AND ((SCC.IDSesion = @IDSesion)OR(@IDSesion = 0))
		AND (CAST(SCC.FechaHoraInicial as DATE) BETWEEN @FechaInicio AND @FechaFin)
		AND (CAST(SCC.FechaHoraFinal as DATE) BETWEEN @FechaInicio AND @FechaFin)
END;
GO
