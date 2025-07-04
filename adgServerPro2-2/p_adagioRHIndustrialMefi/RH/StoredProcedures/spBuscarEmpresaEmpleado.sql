USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarEmpresaEmpleado]
(
	@IDEmpleado int
)
AS
BEGIN
		Select 
			EE.IDEmpresaEmpleado,
			EE.IDEmpleado,
			EE.IDEmpresa,
			E.RFC,
			E.NombreComercial as Empresa,
			EE.FechaIni,
			EE.FechaFin
		From RH.tblEmpresaEmpleado EE
			Inner join RH.tblEmpresa E
				on EE.IDEmpresa = E.IdEmpresa
		WHERE EE.IDEmpleado = @IDEmpleado
		ORDER BY EE.FechaIni DESC
END
GO
