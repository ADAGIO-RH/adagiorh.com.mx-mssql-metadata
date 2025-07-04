USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblDatosExtraClientes](
	[IDDatoExtraCliente] [int] IDENTITY(1,1) NOT NULL,
	[IDCliente] [int] NOT NULL,
	[IDCatDatoExtraCliente] [int] NOT NULL,
	[Valor] [App].[LGDescription] NULL,
 CONSTRAINT [PK_RHTblDatosExtraClientes_IDDatoExtraCliente] PRIMARY KEY CLUSTERED 
(
	[IDDatoExtraCliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblDatosExtraClientes]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatClientes_RHTblDatosExtraClientes_IDCliente] FOREIGN KEY([IDCliente])
REFERENCES [RH].[tblCatClientes] ([IDCliente])
GO
ALTER TABLE [RH].[tblDatosExtraClientes] CHECK CONSTRAINT [FK_RHTblCatClientes_RHTblDatosExtraClientes_IDCliente]
GO
ALTER TABLE [RH].[tblDatosExtraClientes]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatDatosExtraClientes_RHTblDatosExtraClientes_IDCatDatoExtraCliente] FOREIGN KEY([IDCatDatoExtraCliente])
REFERENCES [RH].[tblCatDatosExtraClientes] ([IDCatDatoExtraCliente])
GO
ALTER TABLE [RH].[tblDatosExtraClientes] CHECK CONSTRAINT [FK_RHTblCatDatosExtraClientes_RHTblDatosExtraClientes_IDCatDatoExtraCliente]
GO
