USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [STPS].[spBuscarProgramacionCursosCapacitacion]
(
	@IDProgramacionCursoCapacitacion int = 0
)
AS
BEGIN
	
	SELECT PC.IDProgramacionCursoCapacitacion
		  ,ISNULL(PC.IDCursoCapacitacion,0) as IDCursoCapacitacion
		  ,UPPER(CC.Codigo) as CodigoCurso
		  ,UPPER(CC.Nombre) as NombreCurso
		  ,ISNULL(PC.Duracion,0) as Duracion
		  ,PC.FechaIni as FechaIni
		  ,PC.FechaFin as FechaFin
		  ,ISNULL(PC.IDModalidad,0) as IDModalidad
		  ,UPPER(M.Descripcion) as Modalidad
		  ,ISNULL(PC.IDAgenteCapacitacion,0) as IDAgenteCapacitacion
		  ,UPPER(AC.Nombre)  as NombreAgenteCapacitacion
		  ,UPPER(AC.Apellidos) as ApellidosAgenteCapacitacion
		  ,UPPER(COALESCE(AC.RFC,'')+' - '+COALESCE(AC.Nombre,'')+' '+COALESCE(AC.Apellidos,'')) AS AgenteCapacitacion              
		  ,ROW_NUMBER()Over(Order by PC.IDProgramacionCursoCapacitacion asc) ROWNUMBER
	FROM STPS.tblProgramacionCursosCapacitacion PC with ( nolock)
		INNER JOIN STPS.tblCursosCapacitacion CC with ( nolock)
			on CC.IDCursoCapacitacion = PC.IDCursoCapacitacion
		LEFT JOIN STPS.tblCatModalidades M with ( nolock)
			on M.IDModalidad = PC.IDModalidad
		LEFT JOIN STPS.tblAgentesCapacitacion  AC with ( nolock)
			on PC.IDAgenteCapacitacion = AC.IDAgenteCapacitacion
	where ((PC.IDProgramacionCursoCapacitacion = @IDProgramacionCursoCapacitacion) OR (@IDProgramacionCursoCapacitacion = 0))

END;
GO
