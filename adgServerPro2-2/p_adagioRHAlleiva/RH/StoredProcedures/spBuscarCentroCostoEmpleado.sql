USE [p_adagioRHAlleiva]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCentroCostoEmpleado]
(
	@IDEmpleado int
)
AS
BEGIN
		Select 
			   CCO.IDCentroCostoEmpleado,
		        CCO.IDEmpleado,
			   CCO.IDCentroCosto,
			   CO.Codigo,
			   CO.Descripcion as CentroCosto,
			   CO.CuentaContable,
			   CCO.FechaFin,
			   CCO.FechaIni 
		from RH.tblCentroCostoEmpleado CCO
			inner join RH.tblCatCentroCosto CO
				on CCO.IDCentroCosto = CO.IDCentroCosto
		where CCO.IDEmpleado = @IDEmpleado
		ORDER BY CCO.FechaIni DESC
END
GO
