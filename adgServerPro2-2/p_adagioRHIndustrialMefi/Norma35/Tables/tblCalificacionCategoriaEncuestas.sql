USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Norma35].[tblCalificacionCategoriaEncuestas](
	[IDCalificacionCategoriaEncuesta] [int] NOT NULL,
	[IDCategoria] [int] NOT NULL,
	[IDCatEncuesta] [int] NOT NULL,
	[CalificacionLiteral] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Inicio] [int] NOT NULL,
	[Fin] [int] NOT NULL,
 CONSTRAINT [PK_Norma35TblCalificacionCategoriaEncuestas_IDCalificacionCategoriaEncuesta] PRIMARY KEY CLUSTERED 
(
	[IDCalificacionCategoriaEncuesta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Norma35].[tblCalificacionCategoriaEncuestas]  WITH CHECK ADD  CONSTRAINT [Fk_Norma35TblCalificacionCategoriaEncuestas_IDCategoria] FOREIGN KEY([IDCatEncuesta])
REFERENCES [Norma35].[tblCatEncuestas] ([IDCatEncuesta])
GO
ALTER TABLE [Norma35].[tblCalificacionCategoriaEncuestas] CHECK CONSTRAINT [Fk_Norma35TblCalificacionCategoriaEncuestas_IDCategoria]
GO
ALTER TABLE [Norma35].[tblCalificacionCategoriaEncuestas]  WITH CHECK ADD  CONSTRAINT [Fk_Norma35TblCalificacionCategoriaEncuestas_Norma35TblcatCategorias_IDCategoria] FOREIGN KEY([IDCategoria])
REFERENCES [Norma35].[tblcatCategorias] ([IDCategoria])
GO
ALTER TABLE [Norma35].[tblCalificacionCategoriaEncuestas] CHECK CONSTRAINT [Fk_Norma35TblCalificacionCategoriaEncuestas_Norma35TblcatCategorias_IDCategoria]
GO
