USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PROCOM].[tblClienteComisionMixta](
	[IDClienteComisionMixta] [int] IDENTITY(1,1) NOT NULL,
	[IDCliente] [int] NOT NULL,
	[Nombre] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaIni] [date] NULL,
	[FechaFin] [date] NULL,
 CONSTRAINT [PK_ProcomTblClienteComisionMixta_IDClienteComisionMixta] PRIMARY KEY CLUSTERED 
(
	[IDClienteComisionMixta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [PROCOM].[tblClienteComisionMixta]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatClientes_ProcomTblClienteComisionMixta_IDCliente] FOREIGN KEY([IDCliente])
REFERENCES [RH].[tblCatClientes] ([IDCliente])
GO
ALTER TABLE [PROCOM].[tblClienteComisionMixta] CHECK CONSTRAINT [FK_RHTblCatClientes_ProcomTblClienteComisionMixta_IDCliente]
GO
