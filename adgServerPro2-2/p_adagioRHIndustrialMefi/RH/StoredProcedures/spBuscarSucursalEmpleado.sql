USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarSucursalEmpleado]
(
	@IDEmpleado int
)
AS
BEGIN
		Select 
			SE.IDSucursalEmpleado,
			SE.IDEmpleado,
			SE.IDSucursal,
			S.Codigo,
			S.Descripcion as Sucursal,
			SE.FechaIni,
			Se.FechaFin
		From RH.tblSucursalEmpleado SE
			Inner join RH.tblCatSucursales S
				on SE.IDSucursal = S.IDSucursal
		Where SE.IDEmpleado = @IDEmpleado
		ORDER BY SE.FechaIni Desc
END
GO
