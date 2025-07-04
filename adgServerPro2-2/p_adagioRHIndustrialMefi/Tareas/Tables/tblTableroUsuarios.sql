USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tareas].[tblTableroUsuarios](
	[IDTableroUsuario] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoTablero] [int] NULL,
	[IDReferencia] [int] NULL,
	[IDUsuario] [int] NULL,
 CONSTRAINT [Pk_TareastblTableroUsuarios_IDTableroUsuario] PRIMARY KEY CLUSTERED 
(
	[IDTableroUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tareas].[tblTableroUsuarios]  WITH CHECK ADD  CONSTRAINT [FK_TareastblTableroUsuarios_SeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Tareas].[tblTableroUsuarios] CHECK CONSTRAINT [FK_TareastblTableroUsuarios_SeguridadTblUsuarios_IDUsuario]
GO
