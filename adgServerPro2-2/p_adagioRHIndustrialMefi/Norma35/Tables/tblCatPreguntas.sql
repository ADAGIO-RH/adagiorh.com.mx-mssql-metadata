USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Norma35].[tblCatPreguntas](
	[IDCatPregunta] [int] IDENTITY(1,1) NOT NULL,
	[IDCatGrupo] [int] NOT NULL,
	[Pregunta] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDCatEscala] [int] NOT NULL,
	[Orden] [int] NULL,
	[IDCategoria] [int] NULL,
	[IDDominio] [int] NULL,
	[IDDimension] [int] NULL,
 CONSTRAINT [PK_Norma35tblCatPreguntas_IDCatPregunta] PRIMARY KEY CLUSTERED 
(
	[IDCatPregunta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Norma35].[tblCatPreguntas]  WITH CHECK ADD  CONSTRAINT [FK_Norma35tblCatEscala_Norma35TblCatPreguntas_IDCatEscala] FOREIGN KEY([IDCatEscala])
REFERENCES [Norma35].[tblCatEscalas] ([IDCatEscala])
GO
ALTER TABLE [Norma35].[tblCatPreguntas] CHECK CONSTRAINT [FK_Norma35tblCatEscala_Norma35TblCatPreguntas_IDCatEscala]
GO
ALTER TABLE [Norma35].[tblCatPreguntas]  WITH CHECK ADD  CONSTRAINT [FK_Norma35TblCatGrupos_Norma35TblCatPreguntas_IDCatGrupo] FOREIGN KEY([IDCatGrupo])
REFERENCES [Norma35].[tblCatGrupos] ([IDCatGrupo])
GO
ALTER TABLE [Norma35].[tblCatPreguntas] CHECK CONSTRAINT [FK_Norma35TblCatGrupos_Norma35TblCatPreguntas_IDCatGrupo]
GO
