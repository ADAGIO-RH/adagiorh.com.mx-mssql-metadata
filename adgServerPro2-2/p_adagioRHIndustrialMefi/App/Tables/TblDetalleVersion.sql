USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[TblDetalleVersion](
	[Version] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [App].[TblDetalleVersion]  WITH CHECK ADD  CONSTRAINT [Fk_AppTblDetalleVersion_AppTblVersiones_Version] FOREIGN KEY([Version])
REFERENCES [App].[TblVersiones] ([Version])
ON DELETE CASCADE
GO
ALTER TABLE [App].[TblDetalleVersion] CHECK CONSTRAINT [Fk_AppTblDetalleVersion_AppTblVersiones_Version]
GO
