USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblCatEstatusCiclosMedicion](
	[IDEstatusCicloMedicion] [int] NOT NULL,
	[Traduccion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Orden] [int] NOT NULL,
 CONSTRAINT [Pk_Evaluacion360TblCatEstatusCiclosMedicion_IDEstatusCicloMedicion] PRIMARY KEY CLUSTERED 
(
	[IDEstatusCicloMedicion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblCatEstatusCiclosMedicion] ADD  CONSTRAINT [D_Evaluacion360TblCatEstatusCiclosMedicion_Orden]  DEFAULT ((0)) FOR [Orden]
GO
ALTER TABLE [Evaluacion360].[tblCatEstatusCiclosMedicion]  WITH CHECK ADD  CONSTRAINT [Chk_Evaluacion360TblCatEstatusCiclosMedicion_Traduccion] CHECK  ((isjson([Traduccion])>(0)))
GO
ALTER TABLE [Evaluacion360].[tblCatEstatusCiclosMedicion] CHECK CONSTRAINT [Chk_Evaluacion360TblCatEstatusCiclosMedicion_Traduccion]
GO
