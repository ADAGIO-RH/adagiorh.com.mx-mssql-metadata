USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PROCOM].[tblClienteContacto](
	[IDClienteContacto] [int] IDENTITY(1,1) NOT NULL,
	[IDCliente] [int] NOT NULL,
	[IDCatTipoContacto] [int] NOT NULL,
	[Valor] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_ProcomTblClienteContacto_IDClienteContacto] PRIMARY KEY CLUSTERED 
(
	[IDClienteContacto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [PROCOM].[tblClienteContacto]  WITH CHECK ADD  CONSTRAINT [FK_ProcomTblCatTipoContacto_ProcomTblClienteContacto_IDCatTipoContacto] FOREIGN KEY([IDCatTipoContacto])
REFERENCES [PROCOM].[TblCatTipoContacto] ([IDCatTipoContacto])
GO
ALTER TABLE [PROCOM].[tblClienteContacto] CHECK CONSTRAINT [FK_ProcomTblCatTipoContacto_ProcomTblClienteContacto_IDCatTipoContacto]
GO
ALTER TABLE [PROCOM].[tblClienteContacto]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatClientes_ProcomTblClienteContacto_IDCliente] FOREIGN KEY([IDCliente])
REFERENCES [RH].[tblCatClientes] ([IDCliente])
GO
ALTER TABLE [PROCOM].[tblClienteContacto] CHECK CONSTRAINT [FK_RHTblCatClientes_ProcomTblClienteContacto_IDCliente]
GO
