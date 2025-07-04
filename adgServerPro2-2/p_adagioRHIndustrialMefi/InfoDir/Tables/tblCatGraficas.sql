USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [InfoDir].[tblCatGraficas](
	[IDGrafica] [int] NOT NULL,
	[Descripcion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TipoGrafica] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IsActive] [bit] NULL,
	[Icon] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_InfoDirtblCatGraficas_IDGrafica] PRIMARY KEY CLUSTERED 
(
	[IDGrafica] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
