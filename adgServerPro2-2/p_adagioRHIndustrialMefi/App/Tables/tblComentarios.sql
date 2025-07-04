USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblComentarios](
	[IDComentario] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoComentario] [int] NOT NULL,
	[IDReferencia] [int] NULL,
	[Comentario] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDUsuario] [int] NOT NULL,
	[FechaHora] [datetime] NULL,
 CONSTRAINT [PK_AppTblComentarios_IDComentario] PRIMARY KEY CLUSTERED 
(
	[IDComentario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [App].[tblComentarios] ADD  DEFAULT (getdate()) FOR [FechaHora]
GO
ALTER TABLE [App].[tblComentarios]  WITH CHECK ADD  CONSTRAINT [FK_ApptblCatTiposComentario_ApptblComentarios_IDTipocomentario] FOREIGN KEY([IDTipoComentario])
REFERENCES [App].[tblCatTiposComentario] ([IDTipoComentario])
GO
ALTER TABLE [App].[tblComentarios] CHECK CONSTRAINT [FK_ApptblCatTiposComentario_ApptblComentarios_IDTipocomentario]
GO
ALTER TABLE [App].[tblComentarios]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadtblUsuarios_ApptblComentarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [App].[tblComentarios] CHECK CONSTRAINT [FK_SeguridadtblUsuarios_ApptblComentarios_IDUsuario]
GO
