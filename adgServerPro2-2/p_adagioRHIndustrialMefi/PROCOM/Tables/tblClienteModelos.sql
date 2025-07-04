USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PROCOM].[tblClienteModelos](
	[IDClienteModelo] [int] IDENTITY(1,1) NOT NULL,
	[IDCliente] [int] NOT NULL,
	[IDEmpresa] [int] NOT NULL,
	[FechaIni] [date] NOT NULL,
	[FechaFin] [date] NULL,
 CONSTRAINT [PK_ProcomTblClienteModelos_IDClienteModelo] PRIMARY KEY CLUSTERED 
(
	[IDClienteModelo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [PROCOM].[tblClienteModelos]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatCliente_ProcomTblClienteModelos_IDCliente] FOREIGN KEY([IDCliente])
REFERENCES [RH].[tblCatClientes] ([IDCliente])
GO
ALTER TABLE [PROCOM].[tblClienteModelos] CHECK CONSTRAINT [FK_RHTblCatCliente_ProcomTblClienteModelos_IDCliente]
GO
ALTER TABLE [PROCOM].[tblClienteModelos]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpresa_ProcomTblClienteModelos_IDEmpresa] FOREIGN KEY([IDEmpresa])
REFERENCES [RH].[tblEmpresa] ([IdEmpresa])
GO
ALTER TABLE [PROCOM].[tblClienteModelos] CHECK CONSTRAINT [FK_RHTblEmpresa_ProcomTblClienteModelos_IDEmpresa]
GO
