USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblCatCarpetasExpedienteDigital](
	[IDCarpetaExpedienteDigital] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Core] [bit] NULL,
	[IDTipoComportamientoCarpetaExpedienteDigital] [int] NULL,
	[Icono] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_RHTblCatCarpetasExpedienteDigital_IDCarpetaExpedienteDigital] PRIMARY KEY CLUSTERED 
(
	[IDCarpetaExpedienteDigital] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblCatCarpetasExpedienteDigital] ADD  DEFAULT ((0)) FOR [Core]
GO
ALTER TABLE [RH].[tblCatCarpetasExpedienteDigital]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatTipoComportamientoCarpetaExpedienteDigital_RHtblCatCarpetasExpedienteDigital_IDTipoComportamientoCarpetaExp] FOREIGN KEY([IDTipoComportamientoCarpetaExpedienteDigital])
REFERENCES [RH].[tblCatTipoComportamientoCarpetaExpedienteDigital] ([IDTipoComportamientoCarpetaExpedienteDigital])
GO
ALTER TABLE [RH].[tblCatCarpetasExpedienteDigital] CHECK CONSTRAINT [FK_RHtblCatTipoComportamientoCarpetaExpedienteDigital_RHtblCatCarpetasExpedienteDigital_IDTipoComportamientoCarpetaExp]
GO
