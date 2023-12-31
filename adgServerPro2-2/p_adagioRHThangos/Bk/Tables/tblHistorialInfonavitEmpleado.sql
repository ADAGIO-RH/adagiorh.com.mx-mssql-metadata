USE [p_adagioRHThangos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblHistorialInfonavitEmpleado](
	[IDHistorialInfonavitEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDInfonavitEmpleado] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDRegPatronal] [int] NOT NULL,
	[NumeroCredito] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDTipoMovimiento] [int] NULL,
	[Fecha] [date] NOT NULL,
	[IDTipoDescuento] [int] NOT NULL,
	[ValorDescuento] [decimal](18, 4) NULL,
	[AplicaDisminucion] [bit] NULL,
	[FolioAviso] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaEntraVigor] [date] NULL,
	[IDTipoAvisoInfonavit] [int] NULL,
	[FechaFinVigor] [date] NULL
) ON [PRIMARY]
GO
