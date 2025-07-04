USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblCatCentroCosto](
	[IDCentroCosto] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Descripcion] [App].[MDDescription] NULL,
	[CuentaContable] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ConfiguracionEventoCalendario] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Traduccion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_tblCatCentroCosto_IDCentroCosto] PRIMARY KEY CLUSTERED 
(
	[IDCentroCosto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [RH].[tblCatCentroCosto] ADD  CONSTRAINT [D_RHTblCatCentroCosto_ConfiguracionEventoCalendario]  DEFAULT ('{ "BackgroundColor": "#9999ff", "Color": "#ffffff" }') FOR [ConfiguracionEventoCalendario]
GO
ALTER TABLE [RH].[tblCatCentroCosto]  WITH CHECK ADD  CONSTRAINT [Chk_RHTblCatCentroCosto_ConfiguracionEventoCalendario] CHECK  ((isjson([ConfiguracionEventoCalendario])>(0)))
GO
ALTER TABLE [RH].[tblCatCentroCosto] CHECK CONSTRAINT [Chk_RHTblCatCentroCosto_ConfiguracionEventoCalendario]
GO
ALTER TABLE [RH].[tblCatCentroCosto]  WITH CHECK ADD  CONSTRAINT [Chk_RHtblCatCentroCosto_Traduccion] CHECK  ((isjson([Traduccion])>(0)))
GO
ALTER TABLE [RH].[tblCatCentroCosto] CHECK CONSTRAINT [Chk_RHtblCatCentroCosto_Traduccion]
GO
