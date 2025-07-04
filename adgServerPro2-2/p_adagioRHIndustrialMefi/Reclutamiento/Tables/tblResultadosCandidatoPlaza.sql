USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reclutamiento].[tblResultadosCandidatoPlaza](
	[IDResultadosCandidatoPlaza] [int] IDENTITY(1,1) NOT NULL,
	[IDCandidatoPlaza] [int] NOT NULL,
	[IDRequisitoPuesto] [int] NOT NULL,
	[Resultado] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaAplicacion] [datetime] NOT NULL,
	[RangoResultado] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_ReclutamientoTblResultadosCandidatoPlaza_IDResultadosCandidatoPlaza] PRIMARY KEY CLUSTERED 
(
	[IDResultadosCandidatoPlaza] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Reclutamiento].[tblResultadosCandidatoPlaza] ADD  CONSTRAINT [DF_Reclutamiento.tblResultadosCandidatoPlaza_FechaAplicacion]  DEFAULT (getdate()) FOR [FechaAplicacion]
GO
ALTER TABLE [Reclutamiento].[tblResultadosCandidatoPlaza]  WITH CHECK ADD  CONSTRAINT [FK_ReclutamientoTblCandidatoPlaza_ReclutamientoTblResultadosCandidatoPlaza_IDCandidatoPlaza] FOREIGN KEY([IDCandidatoPlaza])
REFERENCES [Reclutamiento].[tblCandidatoPlaza] ([IDCandidatoPlaza])
GO
ALTER TABLE [Reclutamiento].[tblResultadosCandidatoPlaza] CHECK CONSTRAINT [FK_ReclutamientoTblCandidatoPlaza_ReclutamientoTblResultadosCandidatoPlaza_IDCandidatoPlaza]
GO
ALTER TABLE [Reclutamiento].[tblResultadosCandidatoPlaza]  WITH CHECK ADD  CONSTRAINT [FK_RHTblRequisitosPuestos_ReclutamientooTblResultadosCandidatoPlaza_IDRequisitoPuesto] FOREIGN KEY([IDRequisitoPuesto])
REFERENCES [RH].[tblRequisitosPuestos] ([IDRequisitoPuesto])
GO
ALTER TABLE [Reclutamiento].[tblResultadosCandidatoPlaza] CHECK CONSTRAINT [FK_RHTblRequisitosPuestos_ReclutamientooTblResultadosCandidatoPlaza_IDRequisitoPuesto]
GO
