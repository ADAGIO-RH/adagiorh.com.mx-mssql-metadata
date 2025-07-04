USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reclutamiento].[tblPerfilPublicacionVacante](
	[IDPerfilPublicacionVacante] [int] IDENTITY(1,1) NOT NULL,
	[IDPlaza] [int] NOT NULL,
	[IDModalidadTrabajo] [int] NOT NULL,
	[IDTipoTrabajo] [int] NOT NULL,
	[IDTipoContrato] [int] NOT NULL,
	[OcultarSalario] [bit] NULL,
	[LinkVideo] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Beneficios] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Tags] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[VacantePCD] [bit] NULL,
	[EdadMinima] [int] NULL,
	[EdadMaxima] [int] NULL,
	[IDGenero] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[AniosExperiencia] [int] NULL,
	[IDEstudio] [int] NULL,
	[FormacionComplementarioa] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Idiomas] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Habilidades] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[LicenciaConducir] [bit] NULL,
	[DisponibilidadViajar] [bit] NULL,
	[VehiculoPropio] [bit] NULL,
	[DisponibilidadCambioVivienda] [bit] NULL,
	[IncluirPreguntasFiltro] [bit] NULL,
	[DescripcionVacante] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[UUID] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
 CONSTRAINT [PK_ReclutamientoTblPerfilPublicacionVacante_IDPerfilPublicacionVacante] PRIMARY KEY CLUSTERED 
(
	[IDPerfilPublicacionVacante] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_ReclutamientoTblPerfilPublicacionVacante_UUID] UNIQUE NONCLUSTERED 
(
	[UUID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Reclutamiento].[tblPerfilPublicacionVacante] ADD  CONSTRAINT [d_ReclutamientotblPerfilPublicacionVacante_OcultarSalario]  DEFAULT ((0)) FOR [OcultarSalario]
GO
ALTER TABLE [Reclutamiento].[tblPerfilPublicacionVacante] ADD  CONSTRAINT [d_ReclutamientotblPerfilPublicacionVacante_VacantePCD]  DEFAULT ((0)) FOR [VacantePCD]
GO
ALTER TABLE [Reclutamiento].[tblPerfilPublicacionVacante] ADD  CONSTRAINT [d_ReclutamientoTblPerfilPublicacionVacante_LicenciaConducir]  DEFAULT ((0)) FOR [LicenciaConducir]
GO
ALTER TABLE [Reclutamiento].[tblPerfilPublicacionVacante] ADD  CONSTRAINT [d_ReclutamientoTblPerfilPublicacionVacante_DisponibilidadViajar]  DEFAULT ((0)) FOR [DisponibilidadViajar]
GO
ALTER TABLE [Reclutamiento].[tblPerfilPublicacionVacante] ADD  CONSTRAINT [d_ReclutamientoTblPerfilPublicacionVacante_VehiculoPropio]  DEFAULT ((0)) FOR [VehiculoPropio]
GO
ALTER TABLE [Reclutamiento].[tblPerfilPublicacionVacante] ADD  CONSTRAINT [d_ReclutamientoTblPerfilPublicacionVacante_DisponibilidadCambioVivienda]  DEFAULT ((0)) FOR [DisponibilidadCambioVivienda]
GO
ALTER TABLE [Reclutamiento].[tblPerfilPublicacionVacante] ADD  CONSTRAINT [d_ReclutamientoTblPerfilPublicacionVacante_IncluirPreguntasFiltro]  DEFAULT ((0)) FOR [IncluirPreguntasFiltro]
GO
ALTER TABLE [Reclutamiento].[tblPerfilPublicacionVacante]  WITH CHECK ADD  CONSTRAINT [FK_ReclutamientoTblCatmodalidadTrabajo_ReclutamientoTblPerfilPublicacionVacante_IDModalidadTrabajo] FOREIGN KEY([IDModalidadTrabajo])
REFERENCES [Reclutamiento].[tblCatModalidadTrabajo] ([IDModalidadTrabajo])
GO
ALTER TABLE [Reclutamiento].[tblPerfilPublicacionVacante] CHECK CONSTRAINT [FK_ReclutamientoTblCatmodalidadTrabajo_ReclutamientoTblPerfilPublicacionVacante_IDModalidadTrabajo]
GO
ALTER TABLE [Reclutamiento].[tblPerfilPublicacionVacante]  WITH CHECK ADD  CONSTRAINT [FK_ReclutamientoTblCatTipoTrabajo_ReclutamientoTblPerfilPublicacionVacacante_IDTipoTrabajo] FOREIGN KEY([IDTipoTrabajo])
REFERENCES [Reclutamiento].[tblCatTipoTrabajo] ([IDTipoTrabajo])
GO
ALTER TABLE [Reclutamiento].[tblPerfilPublicacionVacante] CHECK CONSTRAINT [FK_ReclutamientoTblCatTipoTrabajo_ReclutamientoTblPerfilPublicacionVacacante_IDTipoTrabajo]
GO
ALTER TABLE [Reclutamiento].[tblPerfilPublicacionVacante]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatGeneros_ReclutamientoTblPerfilPublicacionVacante_IDGenero] FOREIGN KEY([IDGenero])
REFERENCES [RH].[tblCatGeneros] ([IDGenero])
GO
ALTER TABLE [Reclutamiento].[tblPerfilPublicacionVacante] CHECK CONSTRAINT [FK_RHTblCatGeneros_ReclutamientoTblPerfilPublicacionVacante_IDGenero]
GO
ALTER TABLE [Reclutamiento].[tblPerfilPublicacionVacante]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatPlazas_ReclutamientoTblPerfilPublicacionVacante_IDPlaza] FOREIGN KEY([IDPlaza])
REFERENCES [RH].[tblCatPlazas] ([IDPlaza])
GO
ALTER TABLE [Reclutamiento].[tblPerfilPublicacionVacante] CHECK CONSTRAINT [FK_RHTblCatPlazas_ReclutamientoTblPerfilPublicacionVacante_IDPlaza]
GO
ALTER TABLE [Reclutamiento].[tblPerfilPublicacionVacante]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatTiposContratos_ReclutamientotblPerfilPublicacionVacante_IDTipoContrato] FOREIGN KEY([IDTipoContrato])
REFERENCES [Sat].[tblCatTiposContrato] ([IDTipoContrato])
GO
ALTER TABLE [Reclutamiento].[tblPerfilPublicacionVacante] CHECK CONSTRAINT [FK_SatTblCatTiposContratos_ReclutamientotblPerfilPublicacionVacante_IDTipoContrato]
GO
ALTER TABLE [Reclutamiento].[tblPerfilPublicacionVacante]  WITH CHECK ADD  CONSTRAINT [FK_STPSTblCatEstudios_ReclutamientoTblPerfilPublicacionVacante_IDEstudio] FOREIGN KEY([IDEstudio])
REFERENCES [STPS].[tblCatEstudios] ([IDEstudio])
GO
ALTER TABLE [Reclutamiento].[tblPerfilPublicacionVacante] CHECK CONSTRAINT [FK_STPSTblCatEstudios_ReclutamientoTblPerfilPublicacionVacante_IDEstudio]
GO
