USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblCatTipoGrupo](
	[IDTipoGrupo] [int] NOT NULL,
	[Nombre] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Orden] [int] NULL,
	[Color] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_Evaluacion360TblCatTipoGrupo_IDTipoGrupo] PRIMARY KEY CLUSTERED 
(
	[IDTipoGrupo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblCatTipoGrupo] ADD  CONSTRAINT [D_Evaluacion360TblCatTipoGrupo_Orden]  DEFAULT ((0)) FOR [Orden]
GO
