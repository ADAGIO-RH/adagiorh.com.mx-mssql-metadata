USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblEscalasValoracionesGrupos](
	[IDEscalaValoracionGrupo] [int] IDENTITY(1,1) NOT NULL,
	[IDGrupo] [int] NOT NULL,
	[Nombre] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Valor] [float] NOT NULL,
 CONSTRAINT [Pk_Evaluacion360TblEscalasValoracionesGrupos_IDEscalaValoracionGrupo] PRIMARY KEY CLUSTERED 
(
	[IDEscalaValoracionGrupo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblEscalasValoracionesGrupos] ADD  CONSTRAINT [D_Evaluacion360TblEscalasValoracionesGrupos_Valor]  DEFAULT ((0)) FOR [Valor]
GO
ALTER TABLE [Evaluacion360].[tblEscalasValoracionesGrupos]  WITH CHECK ADD  CONSTRAINT [Pk_Evaluacion360TblEscalasValoracionesGrupos_IDGrupo] FOREIGN KEY([IDGrupo])
REFERENCES [Evaluacion360].[tblCatGrupos] ([IDGrupo])
GO
ALTER TABLE [Evaluacion360].[tblEscalasValoracionesGrupos] CHECK CONSTRAINT [Pk_Evaluacion360TblEscalasValoracionesGrupos_IDGrupo]
GO
