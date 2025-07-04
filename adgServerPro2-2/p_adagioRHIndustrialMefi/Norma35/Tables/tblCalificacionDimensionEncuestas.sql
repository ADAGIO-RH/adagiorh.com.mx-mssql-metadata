USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Norma35].[tblCalificacionDimensionEncuestas](
	[IDCalificacionDimensionEncuesta] [int] NOT NULL,
	[IDDimension] [int] NOT NULL,
	[IDCatEncuesta] [int] NOT NULL,
	[CalificacionLiteral] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Inicio] [int] NOT NULL,
	[Fin] [int] NOT NULL,
 CONSTRAINT [PK_Norma35TblCalificacionDimensionEncuestas_IDCalificacionDimensionEncuesta] PRIMARY KEY CLUSTERED 
(
	[IDCalificacionDimensionEncuesta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Norma35].[tblCalificacionDimensionEncuestas]  WITH CHECK ADD  CONSTRAINT [Fk_Norma35TblCalificacionDimensionEncuestas_IDCategoria] FOREIGN KEY([IDCatEncuesta])
REFERENCES [Norma35].[tblCatEncuestas] ([IDCatEncuesta])
GO
ALTER TABLE [Norma35].[tblCalificacionDimensionEncuestas] CHECK CONSTRAINT [Fk_Norma35TblCalificacionDimensionEncuestas_IDCategoria]
GO
ALTER TABLE [Norma35].[tblCalificacionDimensionEncuestas]  WITH CHECK ADD  CONSTRAINT [Fk_Norma35TblCalificacionDimensionEncuestas_Norma35TblcatDimensiones_IDDimension] FOREIGN KEY([IDDimension])
REFERENCES [Norma35].[tblcatDimensiones] ([IDDimension])
GO
ALTER TABLE [Norma35].[tblCalificacionDimensionEncuestas] CHECK CONSTRAINT [Fk_Norma35TblCalificacionDimensionEncuestas_Norma35TblcatDimensiones_IDDimension]
GO
