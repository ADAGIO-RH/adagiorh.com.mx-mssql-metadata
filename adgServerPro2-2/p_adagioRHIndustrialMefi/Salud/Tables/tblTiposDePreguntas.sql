USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Salud].[tblTiposDePreguntas](
	[IDTipoPregunta] [int] NOT NULL,
	[TipoPregunta] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TiempoEstimadoRespuesta] [int] NULL,
	[IDUnidadDeTiempo] [int] NULL,
	[IDTemplateEdicion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CssClass] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_SaludTblTiposDePreguntas_IDTipoPregunta] PRIMARY KEY CLUSTERED 
(
	[IDTipoPregunta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_SaludTblTiposDePreguntas_TipoPregunta] UNIQUE NONCLUSTERED 
(
	[TipoPregunta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
