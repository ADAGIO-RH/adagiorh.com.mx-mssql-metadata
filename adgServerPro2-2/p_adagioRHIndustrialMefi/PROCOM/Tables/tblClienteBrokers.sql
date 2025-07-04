USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PROCOM].[tblClienteBrokers](
	[IDClienteBroker] [int] IDENTITY(1,1) NOT NULL,
	[IDCliente] [int] NOT NULL,
	[IDCatBroker] [int] NOT NULL,
 CONSTRAINT [PK_ProcomTblClienteBrokers_IDClienteBroker] PRIMARY KEY CLUSTERED 
(
	[IDClienteBroker] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [U_ProcomTblBlienteBrokers_IDClienteIDCatBroker] ON [PROCOM].[tblClienteBrokers]
(
	[IDCliente] ASC,
	[IDCatBroker] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [PROCOM].[tblClienteBrokers]  WITH CHECK ADD  CONSTRAINT [FK_ProcomTblCatBrokers_ProcomTblClienteBrokers_IDCatBroker] FOREIGN KEY([IDCatBroker])
REFERENCES [PROCOM].[TblCatBrokers] ([IDCatBroker])
GO
ALTER TABLE [PROCOM].[tblClienteBrokers] CHECK CONSTRAINT [FK_ProcomTblCatBrokers_ProcomTblClienteBrokers_IDCatBroker]
GO
ALTER TABLE [PROCOM].[tblClienteBrokers]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatCliente_ProcomTblClienteBrokers_IDCliente] FOREIGN KEY([IDCliente])
REFERENCES [RH].[tblCatClientes] ([IDCliente])
GO
ALTER TABLE [PROCOM].[tblClienteBrokers] CHECK CONSTRAINT [FK_RHTblCatCliente_ProcomTblClienteBrokers_IDCliente]
GO
