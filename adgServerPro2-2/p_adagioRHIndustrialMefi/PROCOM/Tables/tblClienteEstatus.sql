USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PROCOM].[tblClienteEstatus](
	[IDClienteEstatus] [int] IDENTITY(1,1) NOT NULL,
	[IDCliente] [int] NOT NULL,
	[IDCatEstatusCliente] [int] NOT NULL,
 CONSTRAINT [PK_ProcomTblClienteEstatus_IDClienteEstatus] PRIMARY KEY CLUSTERED 
(
	[IDClienteEstatus] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_ProcomTblClienteEstatus_IDCliente] UNIQUE NONCLUSTERED 
(
	[IDCliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [PROCOM].[tblClienteEstatus]  WITH CHECK ADD  CONSTRAINT [FK_ProcomTblCatEstatusCliente_ProcomTblClienteEstatus_IDCatEstatusCliente] FOREIGN KEY([IDCatEstatusCliente])
REFERENCES [PROCOM].[tblCatEstatusCliente] ([IDCatEstatusCliente])
GO
ALTER TABLE [PROCOM].[tblClienteEstatus] CHECK CONSTRAINT [FK_ProcomTblCatEstatusCliente_ProcomTblClienteEstatus_IDCatEstatusCliente]
GO
ALTER TABLE [PROCOM].[tblClienteEstatus]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatclientes_ProcomTblClienteEstatus_IDCliente] FOREIGN KEY([IDCliente])
REFERENCES [RH].[tblCatClientes] ([IDCliente])
GO
ALTER TABLE [PROCOM].[tblClienteEstatus] CHECK CONSTRAINT [FK_RHTblCatclientes_ProcomTblClienteEstatus_IDCliente]
GO
