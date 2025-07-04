USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Salud].[tblPreguntas](
	[IDPregunta] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoPregunta] [int] NOT NULL,
	[IDSeccion] [int] NOT NULL,
	[Descripcion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Calificar] [bit] NULL,
	[MaximaCalificacionPosible] [decimal](18, 0) NULL,
 CONSTRAINT [PK_SaludtblPreguntas_IDPregunta] PRIMARY KEY CLUSTERED 
(
	[IDPregunta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Salud].[tblPreguntas]  WITH CHECK ADD  CONSTRAINT [FK_SaludTblSecciones_SaludTblPreguntas_IDSeccion] FOREIGN KEY([IDSeccion])
REFERENCES [Salud].[tblSecciones] ([IDSeccion])
GO
ALTER TABLE [Salud].[tblPreguntas] CHECK CONSTRAINT [FK_SaludTblSecciones_SaludTblPreguntas_IDSeccion]
GO
ALTER TABLE [Salud].[tblPreguntas]  WITH CHECK ADD  CONSTRAINT [FK_SaludTblTiposDePreguntas_SaludTblPreguntas_IDTipoPregunta] FOREIGN KEY([IDTipoPregunta])
REFERENCES [Salud].[tblTiposDePreguntas] ([IDTipoPregunta])
GO
ALTER TABLE [Salud].[tblPreguntas] CHECK CONSTRAINT [FK_SaludTblTiposDePreguntas_SaludTblPreguntas_IDTipoPregunta]
GO
