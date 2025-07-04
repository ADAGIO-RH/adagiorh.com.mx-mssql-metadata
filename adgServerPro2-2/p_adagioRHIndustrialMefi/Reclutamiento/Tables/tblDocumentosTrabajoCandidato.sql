USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reclutamiento].[tblDocumentosTrabajoCandidato](
	[IDDocumentoTrabajoCandidato] [int] IDENTITY(1,1) NOT NULL,
	[IDDocumentoTrabajo] [int] NOT NULL,
	[IDCandidato] [int] NOT NULL,
	[Validacion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_ReclutamientoTblDocumentosTrabajoCandidato_IDDocumentoTrabajoCandidato] PRIMARY KEY CLUSTERED 
(
	[IDDocumentoTrabajoCandidato] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Reclutamiento].[tblDocumentosTrabajoCandidato]  WITH CHECK ADD  CONSTRAINT [FK_ReclutamientotblCandidatos_ReclutamientotblDocumentosTrabajoCandidato_IDCandidato] FOREIGN KEY([IDCandidato])
REFERENCES [Reclutamiento].[tblCandidatos] ([IDCandidato])
GO
ALTER TABLE [Reclutamiento].[tblDocumentosTrabajoCandidato] CHECK CONSTRAINT [FK_ReclutamientotblCandidatos_ReclutamientotblDocumentosTrabajoCandidato_IDCandidato]
GO
ALTER TABLE [Reclutamiento].[tblDocumentosTrabajoCandidato]  WITH CHECK ADD  CONSTRAINT [FK_ReclutamientotblCatDocumentosTrabajo_ReclutamientotblDocumentosTrabajoCandidato_IDDocumentoTrabajo] FOREIGN KEY([IDDocumentoTrabajo])
REFERENCES [Reclutamiento].[tblCatDocumentosTrabajo] ([IDDocumentoTrabajo])
GO
ALTER TABLE [Reclutamiento].[tblDocumentosTrabajoCandidato] CHECK CONSTRAINT [FK_ReclutamientotblCatDocumentosTrabajo_ReclutamientotblDocumentosTrabajoCandidato_IDDocumentoTrabajo]
GO
