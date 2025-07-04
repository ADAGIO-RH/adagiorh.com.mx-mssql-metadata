USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Comunicacion].[tblAvisos](
	[IDAviso] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoAviso] [int] NULL,
	[Titulo] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DescripcionHTML] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Descripcion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IsGeneral] [bit] NULL,
	[Ubicacion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[HoraInicio] [time](7) NULL,
	[FechaInicio] [date] NULL,
	[FechaFin] [date] NULL,
	[IDEstatus] [int] NULL,
	[FechaCreacion] [datetime] NULL,
	[IDUsuario] [int] NULL,
	[TopPXToBanner] [int] NULL,
	[EnviarNotificacion] [bit] NULL,
	[HeightPXToBanner] [int] NULL,
	[Enviado] [bit] NULL,
	[FileJson] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FileAdjuntosGrls] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FileAdjuntosGrlsZip] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FileAdjuntosExpDig] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_ComunicaciontblAvisos_IDAviso] PRIMARY KEY CLUSTERED 
(
	[IDAviso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Comunicacion].[tblAvisos] ADD  DEFAULT ((0)) FOR [EnviarNotificacion]
GO
ALTER TABLE [Comunicacion].[tblAvisos] ADD  DEFAULT ((0)) FOR [Enviado]
GO
ALTER TABLE [Comunicacion].[tblAvisos]  WITH CHECK ADD  CONSTRAINT [FK_ComunicaciontblAvisos_ComunicaciontblCatTiposAviso_IDTipoAviso] FOREIGN KEY([IDTipoAviso])
REFERENCES [Comunicacion].[tblCatTiposAviso] ([IDTipoAviso])
GO
ALTER TABLE [Comunicacion].[tblAvisos] CHECK CONSTRAINT [FK_ComunicaciontblAvisos_ComunicaciontblCatTiposAviso_IDTipoAviso]
GO
ALTER TABLE [Comunicacion].[tblAvisos]  WITH CHECK ADD  CONSTRAINT [FK_ComunicaciontblAvisos_ComunicaciontblEstatusAviso_IDEstatus] FOREIGN KEY([IDEstatus])
REFERENCES [Comunicacion].[tblCatEstatusAviso] ([IDEstatus])
GO
ALTER TABLE [Comunicacion].[tblAvisos] CHECK CONSTRAINT [FK_ComunicaciontblAvisos_ComunicaciontblEstatusAviso_IDEstatus]
GO
