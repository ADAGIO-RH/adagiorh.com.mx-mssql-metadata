USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spBuscarEncabezadoProgramacionCursosCapacitacion] --1002
(
	@IDProgramacionCursoCapacitacion int = 0
)
AS
BEGIN
	SET FMTONLY OFF
	SELECT PC.IDProgramacionCursoCapacitacion
		  ,ISNULL(PC.IDCursoCapacitacion,0) as IDCursoCapacitacion
		  ,UPPER(CC.Codigo) as CodigoCurso
		  ,UPPER(CC.Nombre) as NombreCurso
		  ,ISNULL(PC.Duracion,0) as Duracion
		  ,FORMAT(PC.FechaIni,'dd/MM/yyyy') as FechaIni
		  ,FORMAT(PC.FechaFin,'dd/MM/yyyy') as FechaFin
		  ,ISNULL(PC.IDModalidad,0) as IDModalidad
		  ,UPPER(M.Descripcion) as Modalidad
		  ,ISNULL(PC.IDAgenteCapacitacion,0) as IDAgenteCapacitacion
		  ,UPPER(AC.Nombre)  as NombreAgenteCapacitacion
		  ,UPPER(AC.Apellidos) as ApellidosAgenteCapacitacion
		  ,UPPER(COALESCE(AC.RFC,isnull(AC.RegistroSTPS,AC.codigo))+' '+COALESCE(AC.Nombre,'')+' '+COALESCE(AC.Apellidos,'')) AS AgenteCapacitacion              
		  ,ROW_NUMBER()Over(Order by PC.IDProgramacionCursoCapacitacion asc) ROWNUMBER
	FROM STPS.tblProgramacionCursosCapacitacion PC
		INNER JOIN STPS.tblCursosCapacitacion CC
			on CC.IDCursoCapacitacion = PC.IDCursoCapacitacion
		LEFT JOIN STPS.tblCatModalidades M
			on M.IDModalidad = PC.IDModalidad
		LEFT JOIN STPS.tblAgentesCapacitacion  AC
			on PC.IDAgenteCapacitacion = AC.IDAgenteCapacitacion
	where ((PC.IDProgramacionCursoCapacitacion = @IDProgramacionCursoCapacitacion) OR (@IDProgramacionCursoCapacitacion = 0))

END;
GO
