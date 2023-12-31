USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[AsistenciaTblLectores20220328](
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
	[Master] [bit] NOT NULL
) ON [PRIMARY]
GO
