USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reclutamiento].[tblNotasEntrevistaCandidatoPLaza](
	[IDNotasEntrevistaCandidatoPlaza] [int] IDENTITY(1,1) NOT NULL,
	[IDCandidatoPlaza] [int] NULL,
	[IDCandidato] [int] NOT NULL,
	[Nota] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaHora] [datetime] NOT NULL,
	[IDUsuario] [int] NOT NULL,
 CONSTRAINT [PK_ReclutamientoTblNotasEntrevistaCandidatoPlaza_IDNotaEntrevistaCandidatoPlaza] PRIMARY KEY CLUSTERED 
(
	[IDNotasEntrevistaCandidatoPlaza] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Reclutamiento].[tblNotasEntrevistaCandidatoPLaza] ADD  CONSTRAINT [d_ReclutamientoTblNotasEntrevistaCandidatoPlaza_FechaHora]  DEFAULT (getdate()) FOR [FechaHora]
GO
ALTER TABLE [Reclutamiento].[tblNotasEntrevistaCandidatoPLaza]  WITH CHECK ADD  CONSTRAINT [FK_ReclutameintoTblCandidatos_ReclutamientoTblNotasEntrevistaCandidatoPlaza_IDCandidato] FOREIGN KEY([IDCandidato])
REFERENCES [Reclutamiento].[tblCandidatos] ([IDCandidato])
GO
ALTER TABLE [Reclutamiento].[tblNotasEntrevistaCandidatoPLaza] CHECK CONSTRAINT [FK_ReclutameintoTblCandidatos_ReclutamientoTblNotasEntrevistaCandidatoPlaza_IDCandidato]
GO
ALTER TABLE [Reclutamiento].[tblNotasEntrevistaCandidatoPLaza]  WITH CHECK ADD  CONSTRAINT [FK_ReclutamientoTblCandidatoPlaza_ReclutamientoTblNotasEntrevistaCandidatoPlaza_IDCandidatoPlaza] FOREIGN KEY([IDCandidatoPlaza])
REFERENCES [Reclutamiento].[tblCandidatoPlaza] ([IDCandidatoPlaza])
GO
ALTER TABLE [Reclutamiento].[tblNotasEntrevistaCandidatoPLaza] CHECK CONSTRAINT [FK_ReclutamientoTblCandidatoPlaza_ReclutamientoTblNotasEntrevistaCandidatoPlaza_IDCandidatoPlaza]
GO
ALTER TABLE [Reclutamiento].[tblNotasEntrevistaCandidatoPLaza]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblUsuarios_ReclutamientoTblnotasEntrevistaCandidatoPlaza_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Reclutamiento].[tblNotasEntrevistaCandidatoPLaza] CHECK CONSTRAINT [FK_SeguridadTblUsuarios_ReclutamientoTblnotasEntrevistaCandidatoPlaza_IDUsuario]
GO
