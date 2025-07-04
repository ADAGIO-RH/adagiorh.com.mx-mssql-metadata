USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblAplicacionPerfiles](
	[IDAplicacionPerfil] [int] IDENTITY(1,1) NOT NULL,
	[IDAplicacion] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDPerfil] [int] NOT NULL,
 CONSTRAINT [PK_AppTblAplicacionPerfiles_IDAplicacionPerfil] PRIMARY KEY CLUSTERED 
(
	[IDAplicacionPerfil] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_APPtblAplicacionPerfiles_IDAplicacion] ON [App].[tblAplicacionPerfiles]
(
	[IDAplicacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_APPtblAplicacionPerfiles_IDPerfil] ON [App].[tblAplicacionPerfiles]
(
	[IDPerfil] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [App].[tblAplicacionPerfiles]  WITH CHECK ADD  CONSTRAINT [FK_AppTblCatAplicaciones_AppTblAplicacionesPerfiles_IDAplicacion] FOREIGN KEY([IDAplicacion])
REFERENCES [App].[tblCatAplicaciones] ([IDAplicacion])
GO
ALTER TABLE [App].[tblAplicacionPerfiles] CHECK CONSTRAINT [FK_AppTblCatAplicaciones_AppTblAplicacionesPerfiles_IDAplicacion]
GO
ALTER TABLE [App].[tblAplicacionPerfiles]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblCatPerfiles_AppTblAplicacionPerfiles_IDPerfil] FOREIGN KEY([IDPerfil])
REFERENCES [Seguridad].[tblCatPerfiles] ([IDPerfil])
GO
ALTER TABLE [App].[tblAplicacionPerfiles] CHECK CONSTRAINT [FK_SeguridadTblCatPerfiles_AppTblAplicacionPerfiles_IDPerfil]
GO
