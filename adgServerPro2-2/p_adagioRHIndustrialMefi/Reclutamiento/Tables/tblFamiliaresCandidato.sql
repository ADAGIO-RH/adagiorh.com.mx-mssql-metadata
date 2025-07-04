USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reclutamiento].[tblFamiliaresCandidato](
	[IDFamiliarCandidato] [int] IDENTITY(1,1) NOT NULL,
	[IDCandidato] [int] NOT NULL,
	[IDParentesco] [int] NOT NULL,
	[NombreFamiliar] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaNacimientoFamiliar] [date] NULL,
	[Vivo] [bit] NULL,
 CONSTRAINT [Pk_ReclutamientoTblFamiliaresCandidato_IDFamiliarCandidato] PRIMARY KEY CLUSTERED 
(
	[IDFamiliarCandidato] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Reclutamiento].[tblFamiliaresCandidato]  WITH CHECK ADD  CONSTRAINT [FK_ReclutamientotblCandidatos_ReclutamientotblFamiliaresCandidato_IDCandidato] FOREIGN KEY([IDCandidato])
REFERENCES [Reclutamiento].[tblCandidatos] ([IDCandidato])
GO
ALTER TABLE [Reclutamiento].[tblFamiliaresCandidato] CHECK CONSTRAINT [FK_ReclutamientotblCandidatos_ReclutamientotblFamiliaresCandidato_IDCandidato]
GO
ALTER TABLE [Reclutamiento].[tblFamiliaresCandidato]  WITH CHECK ADD  CONSTRAINT [FK_TblCatParentescos_ReclutamientotblFamiliaresCandidato_IDParentesco] FOREIGN KEY([IDParentesco])
REFERENCES [RH].[TblCatParentescos] ([IDParentesco])
GO
ALTER TABLE [Reclutamiento].[tblFamiliaresCandidato] CHECK CONSTRAINT [FK_TblCatParentescos_ReclutamientotblFamiliaresCandidato_IDParentesco]
GO
