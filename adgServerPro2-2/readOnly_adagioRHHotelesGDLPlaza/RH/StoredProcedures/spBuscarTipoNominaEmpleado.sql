USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [RH].[spBuscarTipoNominaEmpleado]
(
	@IDEmpleado int
)
AS
BEGIN
		Select 
		    PE.IDTipoNominaEmpleado,
			PE.IDEmpleado,
			c.IDCliente,
			c.NombreComercial as Cliente,
			PE.IDTipoNomina,
			P.Descripcion,
			PE.FechaIni,
			PE.FechaFin
		From RH.tblTipoNominaEmpleado PE
			Inner join Nomina.tblCatTipoNomina P
				on PE.IDTipoNomina = P.IDTipoNomina
			Inner join RH.tblCatClientes c 
				on p.IDCliente = c.IDCliente
		Where PE.IDEmpleado = @IDEmpleado
		ORDER BY PE.FechaIni Desc

END
GO
