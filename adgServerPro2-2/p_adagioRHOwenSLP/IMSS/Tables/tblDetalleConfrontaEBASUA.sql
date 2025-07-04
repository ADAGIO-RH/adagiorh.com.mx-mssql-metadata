USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [IMSS].[tblDetalleConfrontaEBASUA](
	[IDDetalleConfrontaEBASUA] [int] IDENTITY(1,1) NOT NULL,
	[IDControlConfrontaIMSS] [int] NOT NULL,
	[NSS] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Nombre] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Dias] [int] NULL,
	[SalarioDiario] [decimal](18, 2) NULL,
	[Retiro] [decimal](18, 2) NULL,
	[CesantiaVejezPatronal] [decimal](18, 2) NULL,
	[CesantiaVejezObrero] [decimal](18, 2) NULL,
	[AportacionPatronal] [decimal](18, 2) NULL,
	[TipoDescuento] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ValorDescuento] [decimal](18, 2) NULL,
	[NumeroCredito] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Amortizacion] [decimal](18, 2) NULL,
	[SubtotalInfornavit] [decimal](18, 2) NULL,
	[Total] [decimal](18, 2) NULL,
 CONSTRAINT [PK_IMSStblDetalleConfrontaEBASUA_IDDetalleConfrontaEBASUA] PRIMARY KEY CLUSTERED 
(
	[IDDetalleConfrontaEBASUA] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [IMSS].[tblDetalleConfrontaEBASUA]  WITH CHECK ADD  CONSTRAINT [FK_IMSSTblControlConfrontaIMSS_IMSStblDetalleConfrontaEBASUA_IDControlConfrontaIMSS] FOREIGN KEY([IDControlConfrontaIMSS])
REFERENCES [IMSS].[tblControlConfrontaIMSS] ([IDControlConfrontaIMSS])
GO
ALTER TABLE [IMSS].[tblDetalleConfrontaEBASUA] CHECK CONSTRAINT [FK_IMSSTblControlConfrontaIMSS_IMSStblDetalleConfrontaEBASUA_IDControlConfrontaIMSS]
GO
