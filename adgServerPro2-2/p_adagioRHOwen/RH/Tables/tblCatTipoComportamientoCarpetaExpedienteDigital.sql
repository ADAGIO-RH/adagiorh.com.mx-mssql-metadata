USE [p_adagioRHOwen]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblCatTipoComportamientoCarpetaExpedienteDigital](
	[IDTipoComportamientoCarpetaExpedienteDigital] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
 CONSTRAINT [PK_RHtblCatTipoComportamientoCarpetaExpedienteDigital_IDTipoComportamientoCarpetaExpedienteDigital] PRIMARY KEY CLUSTERED 
(
	[IDTipoComportamientoCarpetaExpedienteDigital] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
