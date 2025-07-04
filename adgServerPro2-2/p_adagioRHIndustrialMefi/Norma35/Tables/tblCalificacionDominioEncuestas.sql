USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Norma35].[tblCalificacionDominioEncuestas](
	[IDCalificacionDominioEncuesta] [int] NOT NULL,
	[IDDominio] [int] NOT NULL,
	[IDCatEncuesta] [int] NOT NULL,
	[CalificacionLiteral] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Inicio] [int] NOT NULL,
	[Fin] [int] NOT NULL,
 CONSTRAINT [PK_Norma35TblCalificacionDominioEncuestas_IDCalificacionDominioEncuesta] PRIMARY KEY CLUSTERED 
(
	[IDCalificacionDominioEncuesta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Norma35].[tblCalificacionDominioEncuestas]  WITH CHECK ADD  CONSTRAINT [Fk_Norma35TblCalificacionDominioEncuestas_IDCategoria] FOREIGN KEY([IDCatEncuesta])
REFERENCES [Norma35].[tblCatEncuestas] ([IDCatEncuesta])
GO
ALTER TABLE [Norma35].[tblCalificacionDominioEncuestas] CHECK CONSTRAINT [Fk_Norma35TblCalificacionDominioEncuestas_IDCategoria]
GO
ALTER TABLE [Norma35].[tblCalificacionDominioEncuestas]  WITH CHECK ADD  CONSTRAINT [Fk_Norma35TblCalificacionDominioEncuestas_Norma35TblCatDominios_IDDominio] FOREIGN KEY([IDDominio])
REFERENCES [Norma35].[tblCatDominios] ([IDDominio])
GO
ALTER TABLE [Norma35].[tblCalificacionDominioEncuestas] CHECK CONSTRAINT [Fk_Norma35TblCalificacionDominioEncuestas_Norma35TblCatDominios_IDDominio]
GO
