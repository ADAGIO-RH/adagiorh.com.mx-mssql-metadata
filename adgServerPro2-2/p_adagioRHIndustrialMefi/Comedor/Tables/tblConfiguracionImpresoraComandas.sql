USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Comedor].[tblConfiguracionImpresoraComandas](
	[IDConfiguracionImpresoraComanda] [int] IDENTITY(1,1) NOT NULL,
	[NombreImpresora] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDRestaurante] [int] NOT NULL,
	[IDSizePapelImpresionComanda] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_ComedorTblConfiguracionImpresoraComandas_IDConfiguracionImpresoraComanda] PRIMARY KEY CLUSTERED 
(
	[IDConfiguracionImpresoraComanda] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Comedor].[tblConfiguracionImpresoraComandas]  WITH CHECK ADD  CONSTRAINT [Fk_ComedorTblConfiguracionImpresoraComandas_ComedorTblCatCatRestaurantes_IDRestaurante] FOREIGN KEY([IDRestaurante])
REFERENCES [Comedor].[tblCatRestaurantes] ([IDRestaurante])
GO
ALTER TABLE [Comedor].[tblConfiguracionImpresoraComandas] CHECK CONSTRAINT [Fk_ComedorTblConfiguracionImpresoraComandas_ComedorTblCatCatRestaurantes_IDRestaurante]
GO
ALTER TABLE [Comedor].[tblConfiguracionImpresoraComandas]  WITH CHECK ADD  CONSTRAINT [Fk_ComedorTblConfiguracionImpresoraComandas_ComedorTblCatSizePapelImpresionComanda_IDConfiguracionImpresoraComanda] FOREIGN KEY([IDSizePapelImpresionComanda])
REFERENCES [Comedor].[tblCatSizePapelImpresionComanda] ([IDSizePapelImpresionComanda])
GO
ALTER TABLE [Comedor].[tblConfiguracionImpresoraComandas] CHECK CONSTRAINT [Fk_ComedorTblConfiguracionImpresoraComandas_ComedorTblCatSizePapelImpresionComanda_IDConfiguracionImpresoraComanda]
GO
