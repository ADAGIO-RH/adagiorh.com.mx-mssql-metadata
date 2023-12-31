USE [p_adagioRHBeHoteles]
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
	[IDTipoLector] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDZonaHoraria] [int] NULL,
	[IP] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Puerto] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Estatus] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDCliente] [int] NULL,
	[EsComedor] [bit] NULL,
	[Comida] [bit] NULL,
	[NumeroSerial] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaHoraUltimaSincronizacion] [datetime] NULL,
	[FechaHoraUltimaDescargaChecada] [datetime] NULL,
	[Master] [bit] NOT NULL,
 CONSTRAINT [PK_AsistenciaTblLectores_IDLector] PRIMARY KEY CLUSTERED 
(
	[IDLector] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Asistencia].[tblLectores] ADD  CONSTRAINT [DF__tblLector__EsCom__6CD8F421]  DEFAULT ((0)) FOR [EsComedor]
GO
ALTER TABLE [Asistencia].[tblLectores] ADD  CONSTRAINT [DF__tblLector__Comid__15FB0545]  DEFAULT ((0)) FOR [Comida]
GO
ALTER TABLE [Asistencia].[tblLectores] ADD  CONSTRAINT [DF_tblLectores_Master]  DEFAULT ((0)) FOR [Master]
GO
