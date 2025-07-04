USE [p_adagioRHSurfax]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [IMSS].[tblDetalleConfrontaEBAIDSE](
	[IDDetalleConfrontaEBAIDSE] [int] IDENTITY(1,1) NOT NULL,
	[IDControlConfrontaIMSS] [int] NOT NULL,
	[NSS] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Nombre] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[OrigenMovimiento] [int] NULL,
	[TipoMovimiento] [int] NULL,
	[FechaMovimiento] [date] NULL,
	[Dias] [int] NULL,
	[SalarioDiario] [decimal](18, 2) NULL,
	[Retiro] [decimal](18, 2) NULL,
	[CesantiaVejezPatronal] [decimal](18, 2) NULL,
	[CesantiaVejezObrero] [decimal](18, 2) NULL,
	[SubTotalRCV] [decimal](18, 2) NULL,
	[AportacionPatronal] [decimal](18, 2) NULL,
	[TipoDescuento] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ValorDescuento] [decimal](18, 2) NULL,
	[NumeroCredito] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Amortizacion] [decimal](18, 2) NULL,
	[SubtotalInfornavit] [decimal](18, 2) NULL,
	[Total] [decimal](18, 2) NULL,
 CONSTRAINT [PK_tblDetalleConfrontaEBAIDSE_IDDetalleConfrontaEBAIDSE] PRIMARY KEY CLUSTERED 
(
	[IDDetalleConfrontaEBAIDSE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [IMSS].[tblDetalleConfrontaEBAIDSE]  WITH CHECK ADD  CONSTRAINT [FK_IMSSTblControlConfrontaIMSS_IMSStblDetalleConfrontaEBAIDSE_IDControlConfrontaIMSS] FOREIGN KEY([IDControlConfrontaIMSS])
REFERENCES [IMSS].[tblControlConfrontaIMSS] ([IDControlConfrontaIMSS])
GO
ALTER TABLE [IMSS].[tblDetalleConfrontaEBAIDSE] CHECK CONSTRAINT [FK_IMSSTblControlConfrontaIMSS_IMSStblDetalleConfrontaEBAIDSE_IDControlConfrontaIMSS]
GO
