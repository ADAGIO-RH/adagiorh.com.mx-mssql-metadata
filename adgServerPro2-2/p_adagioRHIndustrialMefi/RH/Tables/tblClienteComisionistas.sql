USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblClienteComisionistas](
	[IDClienteComisionista] [int] IDENTITY(1,1) NOT NULL,
	[IDCliente] [int] NOT NULL,
	[IDCatComisionista] [int] NOT NULL,
	[Porcentaje] [decimal](18, 4) NULL,
 CONSTRAINT [PK_RHTblClienteComisionistas_IDClienteComisionista] PRIMARY KEY CLUSTERED 
(
	[IDClienteComisionista] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_RHTblClienteComisionistas_IDCliente_IDCatComisionista] UNIQUE NONCLUSTERED 
(
	[IDCliente] ASC,
	[IDCatComisionista] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblClienteComisionistas]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblCatComisionistas_RHTblClienteComisionista] FOREIGN KEY([IDCatComisionista])
REFERENCES [Nomina].[tblCatComisionistas] ([IDCatComisionista])
GO
ALTER TABLE [RH].[tblClienteComisionistas] CHECK CONSTRAINT [FK_NominaTblCatComisionistas_RHTblClienteComisionista]
GO
ALTER TABLE [RH].[tblClienteComisionistas]  WITH CHECK ADD  CONSTRAINT [FK_RHTblcatClientes_RHTblClienteComisionistas_IDCliente] FOREIGN KEY([IDCliente])
REFERENCES [RH].[tblCatClientes] ([IDCliente])
GO
ALTER TABLE [RH].[tblClienteComisionistas] CHECK CONSTRAINT [FK_RHTblcatClientes_RHTblClienteComisionistas_IDCliente]
GO
