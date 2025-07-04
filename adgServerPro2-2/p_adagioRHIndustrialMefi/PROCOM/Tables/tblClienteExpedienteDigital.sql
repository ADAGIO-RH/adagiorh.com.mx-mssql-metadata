USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PROCOM].[tblClienteExpedienteDigital](
	[IDClienteExpedienteDigital] [int] IDENTITY(1,1) NOT NULL,
	[IDCliente] [int] NOT NULL,
	[Nombre] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Name] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ContentType] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PathFile] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Size] [int] NULL,
 CONSTRAINT [PK_ProcomTblClienteExpedienteDigital_IDClienteExpedienteDigital] PRIMARY KEY CLUSTERED 
(
	[IDClienteExpedienteDigital] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [PROCOM].[tblClienteExpedienteDigital]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatCliente_ProcomTblClienteExpedienteDigital_IDCliente] FOREIGN KEY([IDCliente])
REFERENCES [RH].[tblCatClientes] ([IDCliente])
GO
ALTER TABLE [PROCOM].[tblClienteExpedienteDigital] CHECK CONSTRAINT [FK_RHTblCatCliente_ProcomTblClienteExpedienteDigital_IDCliente]
GO
