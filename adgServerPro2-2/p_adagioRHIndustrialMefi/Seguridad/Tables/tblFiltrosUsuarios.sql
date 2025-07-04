USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seguridad].[tblFiltrosUsuarios](
	[IDFiltrosUsuarios] [int] IDENTITY(1,1) NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[Filtro] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[ID] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDCatFiltroUsuario] [int] NOT NULL,
 CONSTRAINT [PK_SeguridadTblFiltrosUsuarios_IDFiltrosUsuarios] PRIMARY KEY CLUSTERED 
(
	[IDFiltrosUsuarios] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_SeguridadtblFiltrosUsuarios_Filtro] ON [Seguridad].[tblFiltrosUsuarios]
(
	[Filtro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_SeguridadtblFiltrosUsuarios_IDCatFiltroUsuario] ON [Seguridad].[tblFiltrosUsuarios]
(
	[IDCatFiltroUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_SeguridadtblFiltrosUsuarios_IDUsuario] ON [Seguridad].[tblFiltrosUsuarios]
(
	[IDUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Seguridad].[tblFiltrosUsuarios]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblCatTipoFiltros_SeguridadTbltblFiltrosUsuarios_Filtro] FOREIGN KEY([Filtro])
REFERENCES [Seguridad].[tblCatTiposFiltros] ([Filtro])
GO
ALTER TABLE [Seguridad].[tblFiltrosUsuarios] CHECK CONSTRAINT [FK_SeguridadTblCatTipoFiltros_SeguridadTbltblFiltrosUsuarios_Filtro]
GO
ALTER TABLE [Seguridad].[tblFiltrosUsuarios]  WITH CHECK ADD  CONSTRAINT [Fk_SeguridadTblFiltrosUsuarios_SeguridadTblCatFiltrosUsuarios_IDCatFiltroUsuario] FOREIGN KEY([IDCatFiltroUsuario])
REFERENCES [Seguridad].[tblCatFiltrosUsuarios] ([IDCatFiltroUsuario])
ON DELETE CASCADE
GO
ALTER TABLE [Seguridad].[tblFiltrosUsuarios] CHECK CONSTRAINT [Fk_SeguridadTblFiltrosUsuarios_SeguridadTblCatFiltrosUsuarios_IDCatFiltroUsuario]
GO
ALTER TABLE [Seguridad].[tblFiltrosUsuarios]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblUsuarios_SeguridadTbltblFiltrosUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Seguridad].[tblFiltrosUsuarios] CHECK CONSTRAINT [FK_SeguridadTblUsuarios_SeguridadTbltblFiltrosUsuarios_IDUsuario]
GO
