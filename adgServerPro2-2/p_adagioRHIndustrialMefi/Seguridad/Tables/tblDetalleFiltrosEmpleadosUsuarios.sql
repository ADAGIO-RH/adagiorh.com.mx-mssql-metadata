USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seguridad].[tblDetalleFiltrosEmpleadosUsuarios](
	[IDDetalleFiltrosEmpleadosUsuarios] [int] IDENTITY(1,1) NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[Filtro] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[ValorFiltro] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDCatFiltroUsuario] [int] NULL,
 CONSTRAINT [PK_SeguridadtblDetalleFiltrosEmpleadosUsuarios_IDDetalleFiltrosEmpleadosUsuarios] PRIMARY KEY CLUSTERED 
(
	[IDDetalleFiltrosEmpleadosUsuarios] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UC_SeguridadtblDetalleFiltrosEmpleadosUsuarios_IDUsuario_IDEmpleado_Filtro] UNIQUE NONCLUSTERED 
(
	[IDUsuario] ASC,
	[IDEmpleado] ASC,
	[Filtro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_SeguridadtblDetalleFiltrosEmpleadosUsuarios_Filtro] ON [Seguridad].[tblDetalleFiltrosEmpleadosUsuarios]
(
	[Filtro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_SeguridadtblDetalleFiltrosEmpleadosUsuarios_IDCatFiltroUsuario] ON [Seguridad].[tblDetalleFiltrosEmpleadosUsuarios]
(
	[IDCatFiltroUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_SeguridadtblDetalleFiltrosEmpleadosUsuarios_IDEmpleado] ON [Seguridad].[tblDetalleFiltrosEmpleadosUsuarios]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_SeguridadtblDetalleFiltrosEmpleadosUsuarios_IDUsuario] ON [Seguridad].[tblDetalleFiltrosEmpleadosUsuarios]
(
	[IDUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_SeguridadtblDetalleFiltrosEmpleadosUsuarios_IDUsuario_Filtro_IDCatFiltroUsuario] ON [Seguridad].[tblDetalleFiltrosEmpleadosUsuarios]
(
	[IDUsuario] ASC,
	[Filtro] ASC,
	[IDCatFiltroUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_SeguridadtblDetalleFiltrosEmpleadosUsuarios_IDUsuario_IDEmpleado_Filtro_ValorFiltro_IDCatFiltroUsuario] ON [Seguridad].[tblDetalleFiltrosEmpleadosUsuarios]
(
	[IDUsuario] ASC
)
INCLUDE([IDEmpleado],[Filtro],[ValorFiltro],[IDCatFiltroUsuario]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Seguridad].[tblDetalleFiltrosEmpleadosUsuarios]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpleados_SeguridadTblDetalleFiltrosEmpleadosUsuarios_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Seguridad].[tblDetalleFiltrosEmpleadosUsuarios] CHECK CONSTRAINT [FK_RHTblEmpleados_SeguridadTblDetalleFiltrosEmpleadosUsuarios_IDEmpleado]
GO
ALTER TABLE [Seguridad].[tblDetalleFiltrosEmpleadosUsuarios]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblCatTiposFiltros_SeguridadTblDetalleFiltrosEmpleadosUsuarios_Filtro] FOREIGN KEY([Filtro])
REFERENCES [Seguridad].[tblCatTiposFiltros] ([Filtro])
GO
ALTER TABLE [Seguridad].[tblDetalleFiltrosEmpleadosUsuarios] CHECK CONSTRAINT [FK_SeguridadTblCatTiposFiltros_SeguridadTblDetalleFiltrosEmpleadosUsuarios_Filtro]
GO
ALTER TABLE [Seguridad].[tblDetalleFiltrosEmpleadosUsuarios]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblUsuarios_SeguridadtblDetalleFiltrosEmpleadosUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Seguridad].[tblDetalleFiltrosEmpleadosUsuarios] CHECK CONSTRAINT [FK_SeguridadTblUsuarios_SeguridadtblDetalleFiltrosEmpleadosUsuarios_IDUsuario]
GO
