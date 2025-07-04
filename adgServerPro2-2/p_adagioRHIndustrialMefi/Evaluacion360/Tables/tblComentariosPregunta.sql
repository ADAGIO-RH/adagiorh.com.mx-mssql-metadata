USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblComentariosPregunta](
	[IDComentarioPregunta] [int] IDENTITY(1,1) NOT NULL,
	[IDPregunta] [int] NOT NULL,
	[Comentario] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[FechaHora] [datetime] NOT NULL,
 CONSTRAINT [Pk_Evaluacion360TblComentariosPregunta_IDComentarioPregunta] PRIMARY KEY CLUSTERED 
(
	[IDComentarioPregunta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblComentariosPregunta] ADD  CONSTRAINT [D_Evaluacion360TblComentariosPregunta_FechaHora]  DEFAULT (getdate()) FOR [FechaHora]
GO
ALTER TABLE [Evaluacion360].[tblComentariosPregunta]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblComentariosPregunta_Evaluacion360TblCatPreguntas_IDPregunta] FOREIGN KEY([IDPregunta])
REFERENCES [Evaluacion360].[tblCatPreguntas] ([IDPregunta])
ON DELETE CASCADE
GO
ALTER TABLE [Evaluacion360].[tblComentariosPregunta] CHECK CONSTRAINT [Fk_Evaluacion360TblComentariosPregunta_Evaluacion360TblCatPreguntas_IDPregunta]
GO
ALTER TABLE [Evaluacion360].[tblComentariosPregunta]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblComentariosPregunta_SeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
ON DELETE CASCADE
GO
ALTER TABLE [Evaluacion360].[tblComentariosPregunta] CHECK CONSTRAINT [Fk_Evaluacion360TblComentariosPregunta_SeguridadTblUsuarios_IDUsuario]
GO
