USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reclutamiento].[tblCandidatos](
	[IDCandidato] [int] NOT NULL,
	[Nombre] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SegundoNombre] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Paterno] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Materno] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Sexo] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaNacimiento] [date] NULL,
	[IDPaisNacimiento] [int] NOT NULL,
	[IDEstadoNacimiento] [int] NOT NULL,
	[IDMunicipioNacimiento] [int] NOT NULL,
	[IDLocalidadNacimiento] [int] NOT NULL,
	[RFC] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CURP] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NSS] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[AFORE] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEstadoCivil] [int] NULL,
	[Estatura] [decimal](10, 2) NULL,
	[Peso] [decimal](10, 2) NULL,
	[TipoSangre] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
PRIMARY KEY CLUSTERED 
(
	[IDCandidato] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Reclutamiento].[tblCandidatos]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatEstadosCiviles_ReclutamientotblCandidatos_IDLocalidadNacimiento] FOREIGN KEY([IDEstadoCivil])
REFERENCES [RH].[tblCatEstadosCiviles] ([IDEstadoCivil])
GO
ALTER TABLE [Reclutamiento].[tblCandidatos] CHECK CONSTRAINT [FK_RHtblCatEstadosCiviles_ReclutamientotblCandidatos_IDLocalidadNacimiento]
GO
ALTER TABLE [Reclutamiento].[tblCandidatos]  WITH CHECK ADD  CONSTRAINT [FK_SattblCatLocalidades_ReclutamientotblCandidatos_IDLocalidadNacimiento] FOREIGN KEY([IDLocalidadNacimiento])
REFERENCES [Sat].[tblCatLocalidades] ([IDLocalidad])
GO
ALTER TABLE [Reclutamiento].[tblCandidatos] CHECK CONSTRAINT [FK_SattblCatLocalidades_ReclutamientotblCandidatos_IDLocalidadNacimiento]
GO
ALTER TABLE [Reclutamiento].[tblCandidatos]  WITH CHECK ADD  CONSTRAINT [FK_SattblCatMunicipioss_ReclutamientotblCandidatos_IDMunicipioNacimiento] FOREIGN KEY([IDMunicipioNacimiento])
REFERENCES [Sat].[tblCatMunicipios] ([IDMunicipio])
GO
ALTER TABLE [Reclutamiento].[tblCandidatos] CHECK CONSTRAINT [FK_SattblCatMunicipioss_ReclutamientotblCandidatos_IDMunicipioNacimiento]
GO
ALTER TABLE [Reclutamiento].[tblCandidatos]  WITH CHECK ADD  CONSTRAINT [FK_SattblCatPaises_ReclutamientotblCandidatos_IDPaisNacimiento] FOREIGN KEY([IDPaisNacimiento])
REFERENCES [Sat].[tblCatPaises] ([IDPais])
GO
ALTER TABLE [Reclutamiento].[tblCandidatos] CHECK CONSTRAINT [FK_SattblCatPaises_ReclutamientotblCandidatos_IDPaisNacimiento]
GO
ALTER TABLE [Reclutamiento].[tblCandidatos]  WITH CHECK ADD  CONSTRAINT [FK_SattbltblCatEstados_ReclutamientotblCandidatos_IDEstadoNacimiento] FOREIGN KEY([IDEstadoNacimiento])
REFERENCES [Sat].[tblCatEstados] ([IDEstado])
GO
ALTER TABLE [Reclutamiento].[tblCandidatos] CHECK CONSTRAINT [FK_SattbltblCatEstados_ReclutamientotblCandidatos_IDEstadoNacimiento]
GO
