USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seguridad].[tblCatFiltrosUsuarios](
	[IDCatFiltroUsuario] [int] IDENTITY(1,1) NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[Nombre] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDUsuarioCreo] [int] NOT NULL,
	[FechaHora] [datetime] NULL,
 CONSTRAINT [Pk_SeguridadTblCatFiltrosUsuarios_IDCatFiltroUsuario] PRIMARY KEY CLUSTERED 
(
	[IDCatFiltroUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Seguridad].[tblCatFiltrosUsuarios] ADD  CONSTRAINT [D_SeguridadTblCatFiltrosUsuarios_FechaHora]  DEFAULT (getdate()) FOR [FechaHora]
GO
ALTER TABLE [Seguridad].[tblCatFiltrosUsuarios]  WITH CHECK ADD  CONSTRAINT [Fk_SeguridadTblCatFiltrosUsuarios_SeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
ON DELETE CASCADE
GO
ALTER TABLE [Seguridad].[tblCatFiltrosUsuarios] CHECK CONSTRAINT [Fk_SeguridadTblCatFiltrosUsuarios_SeguridadTblUsuarios_IDUsuario]
GO
ALTER TABLE [Seguridad].[tblCatFiltrosUsuarios]  WITH CHECK ADD  CONSTRAINT [Fk_SeguridadTblCatFiltrosUsuarios_SeguridadTblUsuarios_IDUsuarioCreo] FOREIGN KEY([IDUsuarioCreo])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Seguridad].[tblCatFiltrosUsuarios] CHECK CONSTRAINT [Fk_SeguridadTblCatFiltrosUsuarios_SeguridadTblUsuarios_IDUsuarioCreo]
GO
