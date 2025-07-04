USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblNotificaciones](
	[IDNotifiacion] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoNotificacion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[FechaHoraCreacion] [datetime] NULL,
	[Parametros] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDIdioma] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_ApptblNotificaciones_IDNotificacion] PRIMARY KEY CLUSTERED 
(
	[IDNotifiacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_apptblNotificaciones_IDTipoNotificacion] ON [App].[tblNotificaciones]
(
	[IDTipoNotificacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [App].[tblNotificaciones] ADD  DEFAULT (getdate()) FOR [FechaHoraCreacion]
GO
ALTER TABLE [App].[tblNotificaciones]  WITH CHECK ADD  CONSTRAINT [Fk_ApptblNotificaciones_IDTipoNotificacion] FOREIGN KEY([IDTipoNotificacion])
REFERENCES [App].[tblTiposNotificaciones] ([IDTipoNotificacion])
GO
ALTER TABLE [App].[tblNotificaciones] CHECK CONSTRAINT [Fk_ApptblNotificaciones_IDTipoNotificacion]
GO
ALTER TABLE [App].[tblNotificaciones]  WITH CHECK ADD  CONSTRAINT [FK_AppTblNotificacionesAppTblIdiomas_IDIdioma] FOREIGN KEY([IDIdioma])
REFERENCES [App].[tblIdiomas] ([IDIdioma])
GO
ALTER TABLE [App].[tblNotificaciones] CHECK CONSTRAINT [FK_AppTblNotificacionesAppTblIdiomas_IDIdioma]
GO
