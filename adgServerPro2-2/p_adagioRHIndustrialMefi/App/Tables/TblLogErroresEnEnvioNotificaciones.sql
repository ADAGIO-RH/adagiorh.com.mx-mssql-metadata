USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[TblLogErroresEnEnvioNotificaciones](
	[IDLogErrorEnEnvioNotificacion] [int] IDENTITY(1,1) NOT NULL,
	[IDEnviarNotificacionA] [int] NULL,
	[Mensaje] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaHora] [datetime] NULL,
 CONSTRAINT [Pk_AppTblLogErroresEnEnvioNotificaciones_IDLogErrorEnEnvioNotificacion] PRIMARY KEY CLUSTERED 
(
	[IDLogErrorEnEnvioNotificacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [App].[TblLogErroresEnEnvioNotificaciones] ADD  CONSTRAINT [D_AppTblLogErroresEnEnvioNotificaciones_FechaHora]  DEFAULT (getdate()) FOR [FechaHora]
GO
