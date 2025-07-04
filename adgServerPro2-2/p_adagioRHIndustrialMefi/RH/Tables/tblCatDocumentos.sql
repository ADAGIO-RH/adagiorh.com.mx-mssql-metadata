USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblCatDocumentos](
	[IDDocumento] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Template] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Plantilla] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Codigo] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[EsContrato] [bit] NULL,
	[IDIdioma] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[EsResponsiva] [bit] NOT NULL,
 CONSTRAINT [PK_tblCatDocumentos_IDDocumento] PRIMARY KEY CLUSTERED 
(
	[IDDocumento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [RH].[tblCatDocumentos] ADD  DEFAULT ((0)) FOR [EsContrato]
GO
ALTER TABLE [RH].[tblCatDocumentos] ADD  CONSTRAINT [D_RHTblCatDocumentos_IDIdioma]  DEFAULT ('es-MX') FOR [IDIdioma]
GO
ALTER TABLE [RH].[tblCatDocumentos] ADD  DEFAULT ((0)) FOR [EsResponsiva]
GO
ALTER TABLE [RH].[tblCatDocumentos]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblCatDocumentos_AppTblIdiomas_IDIdioma] FOREIGN KEY([IDIdioma])
REFERENCES [App].[tblIdiomas] ([IDIdioma])
GO
ALTER TABLE [RH].[tblCatDocumentos] CHECK CONSTRAINT [Fk_RHTblCatDocumentos_AppTblIdiomas_IDIdioma]
GO
