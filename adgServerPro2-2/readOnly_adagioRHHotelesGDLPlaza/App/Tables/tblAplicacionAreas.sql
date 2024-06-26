USE [readOnly_adagioRHHotelesGDLPlaza]
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
