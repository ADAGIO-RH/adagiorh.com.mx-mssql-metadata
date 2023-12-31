USE [p_adagioRHDXN-Mexico]
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
	[NumInt] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
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
