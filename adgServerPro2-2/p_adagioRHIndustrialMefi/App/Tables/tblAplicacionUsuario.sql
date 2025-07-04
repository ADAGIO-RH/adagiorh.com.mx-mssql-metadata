USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblAplicacionUsuario](
	[IDAplicacionUsuario] [int] IDENTITY(1,1) NOT NULL,
	[IDAplicacion] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[AplicacionPersonalizada] [bit] NULL,
 CONSTRAINT [PK_AppTblAplicacionUsuario_IDAplicacionUsuario] PRIMARY KEY CLUSTERED 
(
	[IDAplicacionUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_APPtblAplicacionUsuario_IDAplicacion] ON [App].[tblAplicacionUsuario]
(
	[IDAplicacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_APPtblAplicacionUsuario_IDAplicacion_IDusuario] ON [App].[tblAplicacionUsuario]
(
	[IDAplicacion] ASC,
	[IDUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_APPtblAplicacionUsuario_IDUsuario] ON [App].[tblAplicacionUsuario]
(
	[IDUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [App].[tblAplicacionUsuario] ADD  CONSTRAINT [DF_tblAplicacionUsuario_PermisoPersonalizado]  DEFAULT ((0)) FOR [AplicacionPersonalizada]
GO
ALTER TABLE [App].[tblAplicacionUsuario]  WITH CHECK ADD  CONSTRAINT [FK_AppTblCatAplicaciones_AppTblAplicacionesUsuario_IDAplicacion] FOREIGN KEY([IDAplicacion])
REFERENCES [App].[tblCatAplicaciones] ([IDAplicacion])
GO
ALTER TABLE [App].[tblAplicacionUsuario] CHECK CONSTRAINT [FK_AppTblCatAplicaciones_AppTblAplicacionesUsuario_IDAplicacion]
GO
ALTER TABLE [App].[tblAplicacionUsuario]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblUsuarios_AppTblAplicacionUsuario_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [App].[tblAplicacionUsuario] CHECK CONSTRAINT [FK_SeguridadTblUsuarios_AppTblAplicacionUsuario_IDUsuario]
GO
