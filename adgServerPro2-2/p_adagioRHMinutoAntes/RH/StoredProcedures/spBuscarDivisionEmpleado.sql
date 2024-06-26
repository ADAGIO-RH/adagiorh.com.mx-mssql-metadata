USE [p_adagioRHMinutoAntes]
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
			P.Descripcion,
			PE.FechaIni,
			PE.FechaFin
		From RH.tblDivisionEmpleado PE
			Inner join RH.tblCatDivisiones P
				on PE.IDDivision = P.IDDivision
		Where PE.IDEmpleado = @IDEmpleado
		ORDER BY PE.FechaIni Desc

END
GO
