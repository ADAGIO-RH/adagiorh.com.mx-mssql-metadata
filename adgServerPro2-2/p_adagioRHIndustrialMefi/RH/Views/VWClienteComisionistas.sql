USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [RH].[VWClienteComisionistas] with SCHEMABINDING
AS
	SELECT
		c.IDClienteComisionista,
		cliente.IDCliente,	
		JSON_VALUE(cliente.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('es-MX', '-','')), 'NombreComercial')) as NombreComercial,
		c.IDCatComisionista,
		comisionista.Identificador,
		comisionista.NombreCompleto,
		c.Porcentaje
	FROM RH.TblClienteComisionistas c
		inner join RH.tblcatClientes cliente
			on c.IDCliente = Cliente.IDCliente
		inner join Nomina.tblCatComisionistas comisionista
			on comisionista.IDCatComisionista = c.IDCatComisionista
GO
