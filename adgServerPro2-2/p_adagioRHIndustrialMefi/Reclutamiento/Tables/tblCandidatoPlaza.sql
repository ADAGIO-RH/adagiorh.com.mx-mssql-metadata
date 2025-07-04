USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reclutamiento].[tblCandidatoPlaza](
	[IDCandidatoPlaza] [int] IDENTITY(1,1) NOT NULL,
	[IDCandidato] [int] NOT NULL,
	[IDPlaza] [int] NOT NULL,
	[FechaAplicacion] [datetime] NOT NULL,
	[IDProceso] [int] NULL,
	[SueldoDeseado] [decimal](18, 2) NULL,
	[IDReclutador] [int] NULL,
 CONSTRAINT [PK_Reclutamiento.tblCandidatoPlaza] PRIMARY KEY CLUSTERED 
(
	[IDCandidatoPlaza] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Reclutamiento].[tblCandidatoPlaza]  WITH CHECK ADD  CONSTRAINT [Fk_ReclutamientoTblCandidatoPlaza_RHTblEmpleados_IDReclutador] FOREIGN KEY([IDReclutador])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
ON DELETE CASCADE
GO
ALTER TABLE [Reclutamiento].[tblCandidatoPlaza] CHECK CONSTRAINT [Fk_ReclutamientoTblCandidatoPlaza_RHTblEmpleados_IDReclutador]
GO
ALTER TABLE [Reclutamiento].[tblCandidatoPlaza]  WITH CHECK ADD  CONSTRAINT [FK_ReclutamientoTblCandidatos_ReclutamientoTblCandidatoPlaza_IDCandidato] FOREIGN KEY([IDCandidato])
REFERENCES [Reclutamiento].[tblCandidatos] ([IDCandidato])
GO
ALTER TABLE [Reclutamiento].[tblCandidatoPlaza] CHECK CONSTRAINT [FK_ReclutamientoTblCandidatos_ReclutamientoTblCandidatoPlaza_IDCandidato]
GO
ALTER TABLE [Reclutamiento].[tblCandidatoPlaza]  WITH CHECK ADD  CONSTRAINT [FK_ReclutamientoTblCatEstatusProceso_ReclutamientoTblCandidatoPlaza_IDProceso] FOREIGN KEY([IDProceso])
REFERENCES [Reclutamiento].[tblCatEstatusProceso] ([IDEstatusProceso])
GO
ALTER TABLE [Reclutamiento].[tblCandidatoPlaza] CHECK CONSTRAINT [FK_ReclutamientoTblCatEstatusProceso_ReclutamientoTblCandidatoPlaza_IDProceso]
GO
ALTER TABLE [Reclutamiento].[tblCandidatoPlaza]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatPlazas_ReclutamientoTblCandidatoPlaza_IDPlaza] FOREIGN KEY([IDPlaza])
REFERENCES [RH].[tblCatPlazas] ([IDPlaza])
GO
ALTER TABLE [Reclutamiento].[tblCandidatoPlaza] CHECK CONSTRAINT [FK_RHTblCatPlazas_ReclutamientoTblCandidatoPlaza_IDPlaza]
GO
