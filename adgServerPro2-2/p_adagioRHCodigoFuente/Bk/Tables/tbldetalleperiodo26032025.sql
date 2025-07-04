USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tbldetalleperiodo26032025](
	[IDDetallePeriodo] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDPeriodo] [int] NOT NULL,
	[IDConcepto] [int] NOT NULL,
	[CantidadMonto] [decimal](18, 2) NULL,
	[CantidadDias] [decimal](18, 2) NULL,
	[CantidadVeces] [decimal](18, 2) NULL,
	[CantidadOtro1] [decimal](18, 2) NULL,
	[CantidadOtro2] [decimal](18, 2) NULL,
	[ImporteGravado] [decimal](18, 2) NULL,
	[ImporteExcento] [decimal](18, 2) NULL,
	[ImporteOtro] [decimal](18, 2) NULL,
	[ImporteTotal1] [decimal](18, 2) NULL,
	[ImporteTotal2] [decimal](18, 2) NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDReferencia] [int] NULL,
	[ImporteAcumuladoTotales] [decimal](19, 2) NULL
) ON [PRIMARY]
GO
