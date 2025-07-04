USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [STPS].[spBuscarCursosCapacitacion]
(
	@IDCursoCapacitacion int = 0
)
AS
BEGIN
	
	SELECT CC.IDCursoCapacitacion,
		   UPPER(CC.Codigo) as Codigo,
		   UPPER(CC.Nombre) as Nombre,
		   ISNULL(CC.IDAreaTematica, 0) as IDAreaTematica,
		   UPPER(T.Codigo) as CodigoAreaTematica,
		   UPPER(T.Descripcion) as AreaTematica,
		   ISNULL(CC.IDCapacitaciones,0) as IDCapacitaciones,
		   UPPER(CP.Codigo) as CodigoCapacitaciones,
		   UPPER(CP.Descripcion) as Capacitaciones,
		   CC.Color,
		   isnull(CC.IDCurso,0) as IDCurso,
		   UPPER(C.Descripcion) as Curso,
		   ROW_NUMBER()OVER(ORDER BY CC.IDCursoCapacitacion ASC) as ROWNUMBER
	FROM STPS.tblCursosCapacitacion CC
		left join STPS.tblCatTematicas T
			on CC.IDAreaTematica = T.IDTematica
		Left join STPS.tblCatCapacitaciones CP
			on CP.IDCapacitaciones = CC.IDCapacitaciones
		Left Join STPS.tblCatCursos C
			on CC.IDCurso = C.IDCursos
	WHERE ((CC.IDCursoCapacitacion = @IDCursoCapacitacion) OR (@IDCursoCapacitacion = 0))


END;
GO
