USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblBitacoraChecadas20250522](
	[IDBitacoraChecada] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NULL,
	[Fecha] [datetime] NOT NULL,
	[IDLector] [int] NULL,
	[Mensaje] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Latitud] [float] NULL,
	[Longitud] [float] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
