USE [p_adagioRHEdman]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarRegionEmpleado]
(
	@IDEmpleado int
)
AS
BEGIN
		Select 
		    PE.IDRegionEmpleado,
			PE.IDEmpleado,
			PE.IDRegion,
			P.Codigo,
			P.Descripcion,
			PE.FechaIni,
			PE.FechaFin
		From RH.tblRegionEmpleado PE
			Inner join RH.tblCatRegiones P
				on PE.IDRegion = P.IDRegion
		Where PE.IDEmpleado = @IDEmpleado
		ORDER BY PE.FechaIni Desc

END
GO
