USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reclutamiento].[tblCandidatos](
	[IDCandidato] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SegundoNombre] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Paterno] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Materno] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Sexo] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaNacimiento] [date] NULL,
	[IDPaisNacimiento] [int] NULL,
	[IDEstadoNacimiento] [int] NULL,
	[IDMunicipioNacimiento] [int] NULL,
	[IDLocalidadNacimiento] [int] NULL,
	[RFC] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CURP] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NSS] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDAFORE] [int] NULL,
	[IDEstadoCivil] [int] NULL,
	[Estatura] [decimal](10, 2) NULL,
	[Peso] [decimal](10, 2) NULL,
	[TipoSangre] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Extranjero] [bit] NULL,
	[Email] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Password] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEmpleado] [int] NULL,
	[ActivationKey] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[AvaibleUntil] [datetime] NULL,
 CONSTRAINT [PK_ReclutamientoTblCandidatos_IDCandidato] PRIMARY KEY CLUSTERED 
(
	[IDCandidato] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [U_ReclutamientoTblCandidatos_Email] ON [Reclutamiento].[tblCandidatos]
(
	[Email] ASC
)
WHERE ([Email] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Reclutamiento].[tblCandidatos]  WITH CHECK ADD  CONSTRAINT [Fk_ReclutamientoTblCandidatos_RHTblCatAfores_IDAFORE] FOREIGN KEY([IDAFORE])
REFERENCES [RH].[tblCatAfores] ([IDAfore])
GO
ALTER TABLE [Reclutamiento].[tblCandidatos] CHECK CONSTRAINT [Fk_ReclutamientoTblCandidatos_RHTblCatAfores_IDAFORE]
GO
ALTER TABLE [Reclutamiento].[tblCandidatos]  WITH CHECK ADD  CONSTRAINT [Fk_ReclutamientoTblCandidatos_RHTblCatEstadosCiviles_IDEstadoCivil] FOREIGN KEY([IDEstadoCivil])
REFERENCES [RH].[tblCatEstadosCiviles] ([IDEstadoCivil])
GO
ALTER TABLE [Reclutamiento].[tblCandidatos] CHECK CONSTRAINT [Fk_ReclutamientoTblCandidatos_RHTblCatEstadosCiviles_IDEstadoCivil]
GO
ALTER TABLE [Reclutamiento].[tblCandidatos]  WITH CHECK ADD  CONSTRAINT [Fk_ReclutamientoTblCandidatos_SatTblCatLocalidades_IDLocalidadNacimiento] FOREIGN KEY([IDLocalidadNacimiento])
REFERENCES [Sat].[tblCatLocalidades] ([IDLocalidad])
GO
ALTER TABLE [Reclutamiento].[tblCandidatos] CHECK CONSTRAINT [Fk_ReclutamientoTblCandidatos_SatTblCatLocalidades_IDLocalidadNacimiento]
GO
ALTER TABLE [Reclutamiento].[tblCandidatos]  WITH CHECK ADD  CONSTRAINT [Fk_ReclutamientoTblCandidatos_SatTblCatMunicipios_IDMunicipioNacimiento] FOREIGN KEY([IDMunicipioNacimiento])
REFERENCES [Sat].[tblCatMunicipios] ([IDMunicipio])
GO
ALTER TABLE [Reclutamiento].[tblCandidatos] CHECK CONSTRAINT [Fk_ReclutamientoTblCandidatos_SatTblCatMunicipios_IDMunicipioNacimiento]
GO
ALTER TABLE [Reclutamiento].[tblCandidatos]  WITH CHECK ADD  CONSTRAINT [Fk_ReclutamientoTblCandidatos_SatTblCatPaises_IDPaisNacimiento] FOREIGN KEY([IDPaisNacimiento])
REFERENCES [Sat].[tblCatPaises] ([IDPais])
GO
ALTER TABLE [Reclutamiento].[tblCandidatos] CHECK CONSTRAINT [Fk_ReclutamientoTblCandidatos_SatTblCatPaises_IDPaisNacimiento]
GO
ALTER TABLE [Reclutamiento].[tblCandidatos]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpleados_ReclutamientoTblCandidatos_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Reclutamiento].[tblCandidatos] CHECK CONSTRAINT [FK_RHTblEmpleados_ReclutamientoTblCandidatos_IDEmpleado]
GO
