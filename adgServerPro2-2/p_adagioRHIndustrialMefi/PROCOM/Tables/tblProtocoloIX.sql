USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PROCOM].[tblProtocoloIX](
	[IDProtocoloIX] [int] IDENTITY(1,1) NOT NULL,
	[IDCliente] [int] NOT NULL,
	[IDClienteModelo] [int] NOT NULL,
	[IDClienteRazonSocial] [int] NOT NULL,
	[FechaIni] [date] NOT NULL,
	[FechaFin] [date] NOT NULL,
	[Ejercicio] [int] NOT NULL,
	[IDMes] [int] NOT NULL,
 CONSTRAINT [PK_ProcomTblProtocoloIX_IDProtocoloIX] PRIMARY KEY CLUSTERED 
(
	[IDProtocoloIX] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [PROCOM].[tblProtocoloIX]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblCatMeses_ProcomTblProtocoloIX_IDMes] FOREIGN KEY([IDMes])
REFERENCES [Nomina].[tblCatMeses] ([IDMes])
GO
ALTER TABLE [PROCOM].[tblProtocoloIX] CHECK CONSTRAINT [FK_NominaTblCatMeses_ProcomTblProtocoloIX_IDMes]
GO
ALTER TABLE [PROCOM].[tblProtocoloIX]  WITH CHECK ADD  CONSTRAINT [FK_ProcomTblClienteModelos_ProcomTblProtocoloIX_IDModelo] FOREIGN KEY([IDClienteModelo])
REFERENCES [PROCOM].[tblClienteModelos] ([IDClienteModelo])
GO
ALTER TABLE [PROCOM].[tblProtocoloIX] CHECK CONSTRAINT [FK_ProcomTblClienteModelos_ProcomTblProtocoloIX_IDModelo]
GO
ALTER TABLE [PROCOM].[tblProtocoloIX]  WITH CHECK ADD  CONSTRAINT [FK_ProcomTblClienteRazonSocial_ProcomTblProtocoloIX_IDClienteRazonSocial] FOREIGN KEY([IDClienteRazonSocial])
REFERENCES [PROCOM].[tblClienteRazonSocial] ([IDClienteRazonSocial])
GO
ALTER TABLE [PROCOM].[tblProtocoloIX] CHECK CONSTRAINT [FK_ProcomTblClienteRazonSocial_ProcomTblProtocoloIX_IDClienteRazonSocial]
GO
ALTER TABLE [PROCOM].[tblProtocoloIX]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatclientes_ProcomTblProtocoloIX_IDCliente] FOREIGN KEY([IDCliente])
REFERENCES [RH].[tblCatClientes] ([IDCliente])
GO
ALTER TABLE [PROCOM].[tblProtocoloIX] CHECK CONSTRAINT [FK_RHTblCatclientes_ProcomTblProtocoloIX_IDCliente]
GO
