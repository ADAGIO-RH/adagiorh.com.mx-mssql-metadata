USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Sat].[tblCatCodigosPostales](
	[IDCodigoPostal] [int] IDENTITY(1,1) NOT NULL,
	[CodigoPostal] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDEstado] [int] NOT NULL,
	[IDMunicipio] [int] NULL,
	[IDLocalidad] [int] NULL,
	[TimeZone] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_tblCatCodigosPostales_IDCodigoPostal] PRIMARY KEY CLUSTERED 
(
	[IDCodigoPostal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_SatTblCatCodigosPostales_CodigoPostal_IDMunicipio_IDLocalidad] ON [Sat].[tblCatCodigosPostales]
(
	[IDEstado] ASC
)
INCLUDE([CodigoPostal],[IDMunicipio],[IDLocalidad]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Sat].[tblCatCodigosPostales]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatEstados_IDEstado] FOREIGN KEY([IDEstado])
REFERENCES [Sat].[tblCatEstados] ([IDEstado])
GO
ALTER TABLE [Sat].[tblCatCodigosPostales] CHECK CONSTRAINT [FK_SatTblCatEstados_IDEstado]
GO
ALTER TABLE [Sat].[tblCatCodigosPostales]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatLocalidades_IDLocalidad] FOREIGN KEY([IDLocalidad])
REFERENCES [Sat].[tblCatLocalidades] ([IDLocalidad])
GO
ALTER TABLE [Sat].[tblCatCodigosPostales] CHECK CONSTRAINT [FK_SatTblCatLocalidades_IDLocalidad]
GO
ALTER TABLE [Sat].[tblCatCodigosPostales]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatMunicipios_IDMunicipio] FOREIGN KEY([IDMunicipio])
REFERENCES [Sat].[tblCatMunicipios] ([IDMunicipio])
GO
ALTER TABLE [Sat].[tblCatCodigosPostales] CHECK CONSTRAINT [FK_SatTblCatMunicipios_IDMunicipio]
GO
