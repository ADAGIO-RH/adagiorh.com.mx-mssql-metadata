USE [p_adagioRHElPro]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblEnviarNotificacionA](
	[IDEnviarNotificacionA] [int] IDENTITY(1,1) NOT NULL,
	[IDNotifiacion] [int] NOT NULL,
	[IDMedioNotificacion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Destinatario] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Enviado] [bit] NULL,
	[FechaHoraEnvio] [datetime] NULL,
	[FechaHoraCreacion] [datetime] NULL,
	[Adjuntos] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDTipoAdjunto] [int] NULL,
	[Parametros] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TipoReferencia] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDReferencia] [int] NULL,
	[IDUsuario] [int] NULL,
 CONSTRAINT [Pk_ApptblEnviarNotificacionA_IDEnviarNotificacionA] PRIMARY KEY CLUSTERED 
(
	[IDEnviarNotificacionA] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_apptblEnviarNotificacionA_Enviado] ON [App].[tblEnviarNotificacionA]
(
	[Enviado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_apptblEnviarNotificacionA_IDMedioNotificacion] ON [App].[tblEnviarNotificacionA]
(
	[IDMedioNotificacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_apptblEnviarNotificacionA_IDNotificacion] ON [App].[tblEnviarNotificacionA]
(
	[IDNotifiacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [App].[tblEnviarNotificacionA] ADD  DEFAULT ((0)) FOR [Enviado]
GO
ALTER TABLE [App].[tblEnviarNotificacionA] ADD  DEFAULT (getdate()) FOR [FechaHoraCreacion]
GO
ALTER TABLE [App].[tblEnviarNotificacionA]  WITH CHECK ADD  CONSTRAINT [FK_ApptblCatTiposReferenciasNotificaciones_ApptblEnviarNotificacionA_TipoReferencia] FOREIGN KEY([TipoReferencia])
REFERENCES [App].[tblCatTiposReferenciasNotificaciones] ([TipoReferencia])
GO
ALTER TABLE [App].[tblEnviarNotificacionA] CHECK CONSTRAINT [FK_ApptblCatTiposReferenciasNotificaciones_ApptblEnviarNotificacionA_TipoReferencia]
GO
ALTER TABLE [App].[tblEnviarNotificacionA]  WITH CHECK ADD  CONSTRAINT [Fk_ApptblEnviarNotificacionA_IDMedioNotificacion] FOREIGN KEY([IDMedioNotificacion])
REFERENCES [App].[tblMediosNotificaciones] ([IDMedioNotificacion])
GO
ALTER TABLE [App].[tblEnviarNotificacionA] CHECK CONSTRAINT [Fk_ApptblEnviarNotificacionA_IDMedioNotificacion]
GO
ALTER TABLE [App].[tblEnviarNotificacionA]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadtblUsuarios_ApptblEnviarNotificacionAs_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [App].[tblEnviarNotificacionA] CHECK CONSTRAINT [FK_SeguridadtblUsuarios_ApptblEnviarNotificacionAs_IDUsuario]
GO
ALTER TABLE [App].[tblEnviarNotificacionA]  WITH CHECK ADD  CONSTRAINT [Fk_tblEnviarNotificacionA_IDNotificacion] FOREIGN KEY([IDNotifiacion])
REFERENCES [App].[tblNotificaciones] ([IDNotifiacion])
GO
ALTER TABLE [App].[tblEnviarNotificacionA] CHECK CONSTRAINT [Fk_tblEnviarNotificacionA_IDNotificacion]
GO
ALTER TABLE [App].[tblEnviarNotificacionA]  WITH CHECK ADD  CONSTRAINT [Ck_AppTblEnviarNotificacionA_ValidarEmail] CHECK  (([IDMedioNotificacion]<>'Email' OR [Destinatario] like '%_@__%.__%'))
GO
ALTER TABLE [App].[tblEnviarNotificacionA] CHECK CONSTRAINT [Ck_AppTblEnviarNotificacionA_ValidarEmail]
GO
