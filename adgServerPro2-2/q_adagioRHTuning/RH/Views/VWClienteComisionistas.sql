USE [q_adagioRHTuning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW RH.VWClienteComisionistas with SCHEMABINDING
AS
	SELECT
		c.IDClienteComisionista,
		c.IDCliente,
		Cliente.NombreComercial,
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
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF
GO
CREATE UNIQUE CLUSTERED INDEX [PK_RHVWClienteComisionistas_IDClienteComisionista] ON [RH].[VWClienteComisionistas]
(
	[IDClienteComisionista] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
