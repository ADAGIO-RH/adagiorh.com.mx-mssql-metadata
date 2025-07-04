USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reclutamiento].[tblContactoCandidato](
	[IDContactoCandidato] [int] IDENTITY(1,1) NOT NULL,
	[IDCandidato] [int] NOT NULL,
	[IDTipoContacto] [int] NOT NULL,
	[Value] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Predeterminado] [bit] NULL,
 CONSTRAINT [Pk_ReclutamientoTblContactoCandidato_IDContactoCandidato] PRIMARY KEY CLUSTERED 
(
	[IDContactoCandidato] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Reclutamiento].[tblContactoCandidato]  WITH CHECK ADD  CONSTRAINT [FK_ReclutamientotblCatTipoContactoCandidato_ReclutamientotblContactoCandidato_IDTipoContacto] FOREIGN KEY([IDTipoContacto])
REFERENCES [Reclutamiento].[tblCatTipoContactoCandidato] ([IDTipoContacto])
GO
ALTER TABLE [Reclutamiento].[tblContactoCandidato] CHECK CONSTRAINT [FK_ReclutamientotblCatTipoContactoCandidato_ReclutamientotblContactoCandidato_IDTipoContacto]
GO
ALTER TABLE [Reclutamiento].[tblContactoCandidato]  WITH CHECK ADD  CONSTRAINT [FK_ReclutamientotblDireccionCandidato_ReclutamientotblContactoCandidato_IDCandidato] FOREIGN KEY([IDCandidato])
REFERENCES [Reclutamiento].[tblCandidatos] ([IDCandidato])
GO
ALTER TABLE [Reclutamiento].[tblContactoCandidato] CHECK CONSTRAINT [FK_ReclutamientotblDireccionCandidato_ReclutamientotblContactoCandidato_IDCandidato]
GO
