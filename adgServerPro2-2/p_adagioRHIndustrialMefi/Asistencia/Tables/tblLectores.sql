USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Asistencia].[tblLectores](
	[IDLector] [int] IDENTITY(1,1) NOT NULL,
	[Lector] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[CodigoLector] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PasswordLector] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDTipoLector] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDZonaHoraria] [int] NULL,
	[IP] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Puerto] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Estatus] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDCliente] [int] NULL,
	[EsComedor] [bit] NULL,
	[Comida] [bit] NULL,
	[NumeroSerial] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaHoraUltimaSincronizacion] [datetime] NULL,
	[FechaHoraUltimaDescargaChecada] [datetime] NULL,
	[Master] [bit] NOT NULL,
	[Configuracion] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[AsignarTodosLosColaboradores] [bit] NULL,
 CONSTRAINT [PK_AsistenciaTblLectores_IDLector] PRIMARY KEY CLUSTERED 
(
	[IDLector] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Asistencia].[tblLectores] ADD  CONSTRAINT [D_AsistenciaTblLectores_EsComedor]  DEFAULT ((0)) FOR [EsComedor]
GO
ALTER TABLE [Asistencia].[tblLectores] ADD  CONSTRAINT [D_AsistenciaTblLectores_Comida]  DEFAULT ((0)) FOR [Comida]
GO
ALTER TABLE [Asistencia].[tblLectores] ADD  CONSTRAINT [DF_tblLectores_Master]  DEFAULT ((0)) FOR [Master]
GO
ALTER TABLE [Asistencia].[tblLectores] ADD  CONSTRAINT [d_AsistenciaLectores_AsignarTodosLosColaboradores]  DEFAULT ((0)) FOR [AsignarTodosLosColaboradores]
GO
ALTER TABLE [Asistencia].[tblLectores]  WITH CHECK ADD  CONSTRAINT [FK_AsistenciaTblCatTiposLectores_AsistenciatblLectores_IDTipoLector] FOREIGN KEY([IDTipoLector])
REFERENCES [Asistencia].[tblCatTiposLectores] ([IDTipoLector])
GO
ALTER TABLE [Asistencia].[tblLectores] CHECK CONSTRAINT [FK_AsistenciaTblCatTiposLectores_AsistenciatblLectores_IDTipoLector]
GO
ALTER TABLE [Asistencia].[tblLectores]  WITH CHECK ADD  CONSTRAINT [Fk_AsistenciaTblLectores_RHTblCatClientes_IDCliente] FOREIGN KEY([IDCliente])
REFERENCES [RH].[tblCatClientes] ([IDCliente])
ON DELETE CASCADE
GO
ALTER TABLE [Asistencia].[tblLectores] CHECK CONSTRAINT [Fk_AsistenciaTblLectores_RHTblCatClientes_IDCliente]
GO
ALTER TABLE [Asistencia].[tblLectores]  WITH CHECK ADD  CONSTRAINT [FK_TzdbZones_AsistenciatblLectores_IDZonaHoraria] FOREIGN KEY([IDZonaHoraria])
REFERENCES [Tzdb].[Zones] ([Id])
GO
ALTER TABLE [Asistencia].[tblLectores] CHECK CONSTRAINT [FK_TzdbZones_AsistenciatblLectores_IDZonaHoraria]
GO
ALTER TABLE [Asistencia].[tblLectores]  WITH CHECK ADD  CONSTRAINT [Chk_AsistenciaTblLectores_Configuracion_is_json] CHECK  ((isjson([Configuracion])>(0)))
GO
ALTER TABLE [Asistencia].[tblLectores] CHECK CONSTRAINT [Chk_AsistenciaTblLectores_Configuracion_is_json]
GO
