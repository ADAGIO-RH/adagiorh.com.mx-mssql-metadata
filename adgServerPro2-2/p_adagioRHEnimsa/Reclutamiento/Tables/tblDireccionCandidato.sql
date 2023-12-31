USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reclutamiento].[tblDireccionCandidato](
	[IDDireccionCandidato] [int] NOT NULL,
	[IDCandidato] [int] NOT NULL,
	[IDPais] [int] NOT NULL,
	[IDEstado] [int] NOT NULL,
	[IDMunicipio] [int] NOT NULL,
	[IDLocalidad] [int] NOT NULL,
	[CodigoPostal] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDColonia] [int] NOT NULL,
	[Calle] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NumExt] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NumInt] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
PRIMARY KEY CLUSTERED 
(
	[IDDireccionCandidato] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Reclutamiento].[tblDireccionCandidato]  WITH CHECK ADD  CONSTRAINT [FK_ReclutamientotblDireccionCandidato_ReclutamientotblDocumentosTrabajoCandidato_IDCandidato] FOREIGN KEY([IDCandidato])
REFERENCES [Reclutamiento].[tblCandidatos] ([IDCandidato])
GO
ALTER TABLE [Reclutamiento].[tblDireccionCandidato] CHECK CONSTRAINT [FK_ReclutamientotblDireccionCandidato_ReclutamientotblDocumentosTrabajoCandidato_IDCandidato]
GO
ALTER TABLE [Reclutamiento].[tblDireccionCandidato]  WITH CHECK ADD  CONSTRAINT [FK_SattblCatColoniass_ReclutamientotblDireccionCandidato_IDColonia] FOREIGN KEY([IDColonia])
REFERENCES [Sat].[tblCatColonias] ([IDColonia])
GO
ALTER TABLE [Reclutamiento].[tblDireccionCandidato] CHECK CONSTRAINT [FK_SattblCatColoniass_ReclutamientotblDireccionCandidato_IDColonia]
GO
ALTER TABLE [Reclutamiento].[tblDireccionCandidato]  WITH CHECK ADD  CONSTRAINT [FK_SattblCatLocalidades_ReclutamientotblDireccionCandidato_IDLocalidad] FOREIGN KEY([IDLocalidad])
REFERENCES [Sat].[tblCatLocalidades] ([IDLocalidad])
GO
ALTER TABLE [Reclutamiento].[tblDireccionCandidato] CHECK CONSTRAINT [FK_SattblCatLocalidades_ReclutamientotblDireccionCandidato_IDLocalidad]
GO
ALTER TABLE [Reclutamiento].[tblDireccionCandidato]  WITH CHECK ADD  CONSTRAINT [FK_SattblCatMunicipioss_ReclutamientotblDireccionCandidato_IDMunicipio] FOREIGN KEY([IDMunicipio])
REFERENCES [Sat].[tblCatMunicipios] ([IDMunicipio])
GO
ALTER TABLE [Reclutamiento].[tblDireccionCandidato] CHECK CONSTRAINT [FK_SattblCatMunicipioss_ReclutamientotblDireccionCandidato_IDMunicipio]
GO
ALTER TABLE [Reclutamiento].[tblDireccionCandidato]  WITH CHECK ADD  CONSTRAINT [FK_SattblCatPaises_ReclutamientotblDireccionCandidato_IDPais] FOREIGN KEY([IDPais])
REFERENCES [Sat].[tblCatPaises] ([IDPais])
GO
ALTER TABLE [Reclutamiento].[tblDireccionCandidato] CHECK CONSTRAINT [FK_SattblCatPaises_ReclutamientotblDireccionCandidato_IDPais]
GO
ALTER TABLE [Reclutamiento].[tblDireccionCandidato]  WITH CHECK ADD  CONSTRAINT [FK_SattbltblCatEstados_ReclutamientotblDireccionCandidato_IDEstado] FOREIGN KEY([IDEstado])
REFERENCES [Sat].[tblCatEstados] ([IDEstado])
GO
ALTER TABLE [Reclutamiento].[tblDireccionCandidato] CHECK CONSTRAINT [FK_SattbltblCatEstados_ReclutamientotblDireccionCandidato_IDEstado]
GO
