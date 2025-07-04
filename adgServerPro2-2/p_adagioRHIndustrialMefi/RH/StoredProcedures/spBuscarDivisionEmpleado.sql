USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarDivisionEmpleado]
(
	@IDEmpleado int
)
AS
BEGIN
		Select 
		    PE.IDDivisionEmpleado,
			PE.IDEmpleado,
			PE.IDDivision,
			P.Codigo,
			JSON_VALUE(P.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion,
			PE.FechaIni,
			PE.FechaFin
		From RH.tblDivisionEmpleado PE
			Inner join RH.tblCatDivisiones P
				on PE.IDDivision = P.IDDivision
		Where PE.IDEmpleado = @IDEmpleado
		ORDER BY PE.FechaIni Desc

END
GO
