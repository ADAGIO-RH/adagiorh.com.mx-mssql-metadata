USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblTemplateNotificaciones](
	[IDTemplateNotificacion] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoNotificacion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDMedioNotificacion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Template] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDIdioma] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_ApptblTemplateNotificaciones_IDTemplateNotificacion] PRIMARY KEY CLUSTERED 
(
	[IDTemplateNotificacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_AppTblTemplateNotificaciones_IDTipoNotificacion_IDMedioNotificacion_IDIdioma] UNIQUE NONCLUSTERED 
(
	[IDTipoNotificacion] ASC,
	[IDMedioNotificacion] ASC,
	[IDIdioma] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [App].[tblTemplateNotificaciones]  WITH CHECK ADD  CONSTRAINT [Fk_ApptblTemplateNotificaciones_IDMedioNotificacion] FOREIGN KEY([IDMedioNotificacion])
REFERENCES [App].[tblMediosNotificaciones] ([IDMedioNotificacion])
GO
ALTER TABLE [App].[tblTemplateNotificaciones] CHECK CONSTRAINT [Fk_ApptblTemplateNotificaciones_IDMedioNotificacion]
GO
ALTER TABLE [App].[tblTemplateNotificaciones]  WITH CHECK ADD  CONSTRAINT [Fk_ApptblTemplateNotificaciones_IDTipoNotificacion] FOREIGN KEY([IDTipoNotificacion])
REFERENCES [App].[tblTiposNotificaciones] ([IDTipoNotificacion])
GO
ALTER TABLE [App].[tblTemplateNotificaciones] CHECK CONSTRAINT [Fk_ApptblTemplateNotificaciones_IDTipoNotificacion]
GO
ALTER TABLE [App].[tblTemplateNotificaciones]  WITH CHECK ADD  CONSTRAINT [FK_AppTblTemplateNotificacionesAppTblIdiomas_IDIdioma] FOREIGN KEY([IDIdioma])
REFERENCES [App].[tblIdiomas] ([IDIdioma])
GO
ALTER TABLE [App].[tblTemplateNotificaciones] CHECK CONSTRAINT [FK_AppTblTemplateNotificacionesAppTblIdiomas_IDIdioma]
GO
