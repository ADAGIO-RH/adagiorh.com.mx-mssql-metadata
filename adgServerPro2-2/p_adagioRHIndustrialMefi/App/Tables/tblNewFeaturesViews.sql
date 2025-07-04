USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblNewFeaturesViews](
	[IDNewFeatureView] [int] IDENTITY(1,1) NOT NULL,
	[IDFeature] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[FechaReg] [datetime] NOT NULL,
 CONSTRAINT [Pk_AppTblNewFeaturesViews_IDNewFeatureView] PRIMARY KEY CLUSTERED 
(
	[IDNewFeatureView] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [App].[tblNewFeaturesViews] ADD  CONSTRAINT [D_AppTblNewFeaturesViews_FechaReg]  DEFAULT (getdate()) FOR [FechaReg]
GO
ALTER TABLE [App].[tblNewFeaturesViews]  WITH CHECK ADD  CONSTRAINT [Fk_AppTblNewFeatures_AppTblNewFeaturesViews_IDFeature] FOREIGN KEY([IDFeature])
REFERENCES [App].[tblNewFeatures] ([IDFeature])
ON DELETE CASCADE
GO
ALTER TABLE [App].[tblNewFeaturesViews] CHECK CONSTRAINT [Fk_AppTblNewFeatures_AppTblNewFeaturesViews_IDFeature]
GO
ALTER TABLE [App].[tblNewFeaturesViews]  WITH CHECK ADD  CONSTRAINT [Fk_SeguridadTblUsuarios_AppTblNewFeaturesViews_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
ON DELETE CASCADE
GO
ALTER TABLE [App].[tblNewFeaturesViews] CHECK CONSTRAINT [Fk_SeguridadTblUsuarios_AppTblNewFeaturesViews_IDUsuario]
GO
