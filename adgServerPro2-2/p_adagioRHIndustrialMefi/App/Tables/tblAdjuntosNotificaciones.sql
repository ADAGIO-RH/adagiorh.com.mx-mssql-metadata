USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblAdjuntosNotificaciones](
	[IDAdjuntoNotificacion] [int] IDENTITY(1,1) NOT NULL,
	[IDEnviarNotificacionA] [int] NOT NULL,
	[FileName] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Extension] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Data] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaReg] [datetime] NULL,
 CONSTRAINT [Pk_AppTblAdjuntosNotificaciones_IDAdjuntoNotificacion] PRIMARY KEY CLUSTERED 
(
	[IDAdjuntoNotificacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [App].[tblAdjuntosNotificaciones] ADD  CONSTRAINT [D_AppTblAdjuntosNotificaciones_FechaReg]  DEFAULT (getdate()) FOR [FechaReg]
GO
ALTER TABLE [App].[tblAdjuntosNotificaciones]  WITH CHECK ADD  CONSTRAINT [Fk_AppTblAdjuntosNotificaciones_AppTblEnviarNotificacionA_IDEnviarNotificacionA] FOREIGN KEY([IDEnviarNotificacionA])
REFERENCES [App].[tblEnviarNotificacionA] ([IDEnviarNotificacionA])
ON DELETE CASCADE
GO
ALTER TABLE [App].[tblAdjuntosNotificaciones] CHECK CONSTRAINT [Fk_AppTblAdjuntosNotificaciones_AppTblEnviarNotificacionA_IDEnviarNotificacionA]
GO
