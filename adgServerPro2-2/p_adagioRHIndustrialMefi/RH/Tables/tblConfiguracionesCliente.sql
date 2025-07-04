USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblConfiguracionesCliente](
	[IDConfiguracionCliente] [int] IDENTITY(1,1) NOT NULL,
	[IDCliente] [int] NOT NULL,
	[IDTipoConfiguracionCliente] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Valor] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_RHTblConfiguracionesClientes_IDConfiguracionesCliente] PRIMARY KEY CLUSTERED 
(
	[IDConfiguracionCliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblConfiguracionesCliente_IDCliente] ON [RH].[tblConfiguracionesCliente]
(
	[IDCliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_RHtblConfiguracionesCliente_IDTipoConfiguracionCliente] ON [RH].[tblConfiguracionesCliente]
(
	[IDTipoConfiguracionCliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblConfiguracionesCliente]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatClientes_RHtblConfiguracionesCliente_IDCliente] FOREIGN KEY([IDCliente])
REFERENCES [RH].[tblCatClientes] ([IDCliente])
GO
ALTER TABLE [RH].[tblConfiguracionesCliente] CHECK CONSTRAINT [FK_RHtblCatClientes_RHtblConfiguracionesCliente_IDCliente]
GO
ALTER TABLE [RH].[tblConfiguracionesCliente]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatTipoConfiguracionesCliente_RHtblConfiguracionesCliente_IDTipoConfiguracionCliente] FOREIGN KEY([IDTipoConfiguracionCliente])
REFERENCES [RH].[tblCatTipoConfiguracionesCliente] ([IDTipoConfiguracionCliente])
GO
ALTER TABLE [RH].[tblConfiguracionesCliente] CHECK CONSTRAINT [FK_RHtblCatTipoConfiguracionesCliente_RHtblConfiguracionesCliente_IDTipoConfiguracionCliente]
GO
