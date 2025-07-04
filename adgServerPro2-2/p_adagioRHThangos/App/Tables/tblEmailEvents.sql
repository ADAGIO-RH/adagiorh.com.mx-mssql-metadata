USE [p_adagioRHThangos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblEmailEvents](
	[EmailEventId] [uniqueidentifier] NOT NULL,
	[IDEnviarNotificacionA] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDNotifiacion] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Subdomain] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Email] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Event] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IP] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SgContentType] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SgEventId] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SgMachineOpen] [bit] NULL,
	[SgMessageId] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SgTemplateId] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SgTemplateName] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Timestamp] [bigint] NULL,
	[TransactionId] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[UserAgent] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CreatedAt] [datetime] NULL,
	[TipoReferencia] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDReferencia] [int] NULL,
	[IDUsuario] [int] NULL,
	[CurrentEvent] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
PRIMARY KEY CLUSTERED 
(
	[EmailEventId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [App].[tblEmailEvents] ADD  DEFAULT (newid()) FOR [EmailEventId]
GO
ALTER TABLE [App].[tblEmailEvents] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [App].[tblEmailEvents]  WITH CHECK ADD  CONSTRAINT [FK_ApptblCatTiposReferenciasNotificaciones_ApptblEmailEvents_TipoReferencia] FOREIGN KEY([TipoReferencia])
REFERENCES [App].[tblCatTiposReferenciasNotificaciones] ([TipoReferencia])
GO
ALTER TABLE [App].[tblEmailEvents] CHECK CONSTRAINT [FK_ApptblCatTiposReferenciasNotificaciones_ApptblEmailEvents_TipoReferencia]
GO
ALTER TABLE [App].[tblEmailEvents]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadtblUsuarios_ApptblEmailEventss_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [App].[tblEmailEvents] CHECK CONSTRAINT [FK_SeguridadtblUsuarios_ApptblEmailEventss_IDUsuario]
GO
