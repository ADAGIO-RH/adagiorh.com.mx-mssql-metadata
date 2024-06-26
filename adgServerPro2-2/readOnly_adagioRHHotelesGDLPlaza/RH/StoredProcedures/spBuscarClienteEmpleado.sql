USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarClienteEmpleado]
(
	@IDEmpleado int
)
AS
BEGIN
		Select 
			CE.IDClienteEmpleado,
			CE.IDEmpleado,
			CE.IDCliente,
			C.NombreComercial as Cliente,
			c.Codigo,
			CE.FechaIni,
			CE.FechaFin 
		from RH.tblClienteEmpleado CE
			inner join RH.tblCatClientes C
				on CE.IDCliente = C.IDCliente
		WHERE CE.IDEmpleado = @IDEmpleado
		ORDER by Ce.FechaIni DESC
END
GO
