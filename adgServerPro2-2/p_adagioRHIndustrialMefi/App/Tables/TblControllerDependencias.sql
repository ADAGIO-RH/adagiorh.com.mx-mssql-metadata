USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[TblControllerDependencias](
	[IDControllerParent] [int] NOT NULL,
	[IDControllerChild] [int] NOT NULL,
	[IDTipoPermiso] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_appTblControllerDependencias_IDControllerChild] ON [App].[TblControllerDependencias]
(
	[IDControllerChild] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_appTblControllerDependencias_IDControllerParent] ON [App].[TblControllerDependencias]
(
	[IDControllerParent] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_appTblControllerDependencias_IDControllerParent_child_TipoPermiso] ON [App].[TblControllerDependencias]
(
	[IDControllerParent] ASC,
	[IDControllerChild] ASC,
	[IDTipoPermiso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_appTblControllerDependencias_IDTipoPermiso] ON [App].[TblControllerDependencias]
(
	[IDTipoPermiso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [App].[TblControllerDependencias]  WITH CHECK ADD  CONSTRAINT [FK_AppTblCatControllers_AppTblControllerDependencias_IDController] FOREIGN KEY([IDControllerParent])
REFERENCES [App].[tblCatControllers] ([IDController])
GO
ALTER TABLE [App].[TblControllerDependencias] CHECK CONSTRAINT [FK_AppTblCatControllers_AppTblControllerDependencias_IDController]
GO
ALTER TABLE [App].[TblControllerDependencias]  WITH CHECK ADD  CONSTRAINT [FK_AppTblCatControllers_AppTblControllerDependencias_IDControllerChild] FOREIGN KEY([IDControllerChild])
REFERENCES [App].[tblCatControllers] ([IDController])
GO
ALTER TABLE [App].[TblControllerDependencias] CHECK CONSTRAINT [FK_AppTblCatControllers_AppTblControllerDependencias_IDControllerChild]
GO
ALTER TABLE [App].[TblControllerDependencias]  WITH CHECK ADD  CONSTRAINT [FK_AppTblCatTipoPermiso_AppTblControllerDependencias_IDTipoPermiso] FOREIGN KEY([IDTipoPermiso])
REFERENCES [App].[tblCatTipoPermiso] ([IDTipoPermiso])
GO
ALTER TABLE [App].[TblControllerDependencias] CHECK CONSTRAINT [FK_AppTblCatTipoPermiso_AppTblControllerDependencias_IDTipoPermiso]
GO
