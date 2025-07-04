USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblCatalogosConfiguracionAvanzada](
	[IDCatalogoConfiguracionAvanzada] [int] IDENTITY(1,1) NOT NULL,
	[IDConfiguracionAvanzada] [int] NOT NULL,
	[IDCatalogo] [int] NULL,
	[DescripcionCatalogo] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_Evaluacion360TblCatalogosConfiguracionAvanzadas_IDCatalogoConfiguracionAvanzada] PRIMARY KEY CLUSTERED 
(
	[IDCatalogoConfiguracionAvanzada] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblCatalogosConfiguracionAvanzada]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblConfiguracionesAvanzadas_Evaluacion360TblConfiguracionesAvanzadas_IDConfiguracionAvanzada] FOREIGN KEY([IDConfiguracionAvanzada])
REFERENCES [Evaluacion360].[tblConfiguracionesAvanzadas] ([IDConfiguracionAvanzada])
ON DELETE CASCADE
GO
ALTER TABLE [Evaluacion360].[tblCatalogosConfiguracionAvanzada] CHECK CONSTRAINT [Fk_Evaluacion360TblConfiguracionesAvanzadas_Evaluacion360TblConfiguracionesAvanzadas_IDConfiguracionAvanzada]
GO
