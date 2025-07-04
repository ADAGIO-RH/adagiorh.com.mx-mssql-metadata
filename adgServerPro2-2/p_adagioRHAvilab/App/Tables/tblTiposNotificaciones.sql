USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblTiposNotificaciones](
	[IDTipoNotificacion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Asunto] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Nombre] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IsSpecial] [bit] NULL,
	[IsActivo] [bit] NULL,
 CONSTRAINT [Pk_ApptblTiposNotificaciones_IDTipoNotificacion] PRIMARY KEY CLUSTERED 
(
	[IDTipoNotificacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [App].[tblTiposNotificaciones] ADD  DEFAULT ((0)) FOR [IsSpecial]
GO
ALTER TABLE [App].[tblTiposNotificaciones] ADD  DEFAULT ((0)) FOR [IsActivo]
GO
