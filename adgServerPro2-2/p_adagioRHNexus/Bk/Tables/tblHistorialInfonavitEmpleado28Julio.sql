USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblHistorialInfonavitEmpleado28Julio](
	[IDHistorialInfonavitEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDInfonavitEmpleado] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDRegPatronal] [int] NOT NULL,
	[NumeroCredito] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDTipoMovimiento] [int] NOT NULL,
	[Fecha] [date] NOT NULL,
	[IDTipoDescuento] [int] NOT NULL,
	[ValorDescuento] [decimal](18, 4) NULL,
	[AplicaDisminucion] [bit] NULL
) ON [PRIMARY]
GO
