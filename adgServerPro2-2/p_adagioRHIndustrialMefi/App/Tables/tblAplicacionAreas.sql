USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblAplicacionAreas](
	[IDAplicacion] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDArea] [int] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_APPtblAplicacionAreas_IDAplicacion] ON [App].[tblAplicacionAreas]
(
	[IDAplicacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_APPtblAplicacionAreas_IDArea] ON [App].[tblAplicacionAreas]
(
	[IDArea] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [App].[tblAplicacionAreas]  WITH CHECK ADD  CONSTRAINT [FK_AppTblCatAplicaciones_AppTblAplicacionAreas_IDAplicacion] FOREIGN KEY([IDAplicacion])
REFERENCES [App].[tblCatAplicaciones] ([IDAplicacion])
GO
ALTER TABLE [App].[tblAplicacionAreas] CHECK CONSTRAINT [FK_AppTblCatAplicaciones_AppTblAplicacionAreas_IDAplicacion]
GO
ALTER TABLE [App].[tblAplicacionAreas]  WITH CHECK ADD  CONSTRAINT [FK_AppTblCatArea_AppTblAplicacionesAreas_IDArea] FOREIGN KEY([IDArea])
REFERENCES [App].[tblCatAreas] ([IDArea])
GO
ALTER TABLE [App].[tblAplicacionAreas] CHECK CONSTRAINT [FK_AppTblCatArea_AppTblAplicacionesAreas_IDArea]
GO
