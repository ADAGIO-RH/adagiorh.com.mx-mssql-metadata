USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reclutamiento].[tblDireccionResidenciaCandidato](
	[IDDireccionCandidato] [int] IDENTITY(1,1) NOT NULL,
	[IDCandidato] [int] NOT NULL,
	[IDPais] [int] NULL,
	[IDEstado] [int] NULL,
	[IDMunicipio] [int] NULL,
	[IDLocalidad] [int] NULL,
	[IDCodigoPostal] [int] NULL,
	[IDColonia] [int] NULL,
	[Calle] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NumExt] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NumInt] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_ReclutamientoTblDireccionResidenciaCandidato_IDDireccionCandidato] PRIMARY KEY CLUSTERED 
(
	[IDDireccionCandidato] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Reclutamiento].[tblDireccionResidenciaCandidato]  WITH CHECK ADD  CONSTRAINT [FK_ReclutamientotblDireccionResidenciaCandidato_ReclutamientotblDocumentosTrabajoCandidato_IDCandidato] FOREIGN KEY([IDCandidato])
REFERENCES [Reclutamiento].[tblCandidatos] ([IDCandidato])
GO
ALTER TABLE [Reclutamiento].[tblDireccionResidenciaCandidato] CHECK CONSTRAINT [FK_ReclutamientotblDireccionResidenciaCandidato_ReclutamientotblDocumentosTrabajoCandidato_IDCandidato]
GO
ALTER TABLE [Reclutamiento].[tblDireccionResidenciaCandidato]  WITH CHECK ADD  CONSTRAINT [FK_SattblCatMunicipioss_ReclutamientotblDireccionResidenciaCandidato_IDMunicipio] FOREIGN KEY([IDMunicipio])
REFERENCES [Sat].[tblCatMunicipios] ([IDMunicipio])
GO
ALTER TABLE [Reclutamiento].[tblDireccionResidenciaCandidato] CHECK CONSTRAINT [FK_SattblCatMunicipioss_ReclutamientotblDireccionResidenciaCandidato_IDMunicipio]
GO
ALTER TABLE [Reclutamiento].[tblDireccionResidenciaCandidato]  WITH CHECK ADD  CONSTRAINT [FK_SattblCatPaises_ReclutamientotblDireccionResidenciaCandidato_IDPais] FOREIGN KEY([IDPais])
REFERENCES [Sat].[tblCatPaises] ([IDPais])
GO
ALTER TABLE [Reclutamiento].[tblDireccionResidenciaCandidato] CHECK CONSTRAINT [FK_SattblCatPaises_ReclutamientotblDireccionResidenciaCandidato_IDPais]
GO
ALTER TABLE [Reclutamiento].[tblDireccionResidenciaCandidato]  WITH CHECK ADD  CONSTRAINT [FK_SattbltblCatEstados_ReclutamientotblDireccionResidenciaCandidato_IDEstado] FOREIGN KEY([IDEstado])
REFERENCES [Sat].[tblCatEstados] ([IDEstado])
GO
ALTER TABLE [Reclutamiento].[tblDireccionResidenciaCandidato] CHECK CONSTRAINT [FK_SattbltblCatEstados_ReclutamientotblDireccionResidenciaCandidato_IDEstado]
GO
