USE [p_adagioRHGMGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [IMSS].[tblDetalleConfrontaEMAIDSE](
	[IDDetalleConfrontaIDSE] [int] IDENTITY(1,1) NOT NULL,
	[IDControlConfrontaIMSS] [int] NOT NULL,
	[NSS] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Nombre] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[OrigenMovimiento] [int] NULL,
	[TipoMovimiento] [int] NULL,
	[FechaMovimiento] [date] NULL,
	[Dias] [int] NULL,
	[SalarioDiario] [decimal](18, 2) NULL,
	[CuotaFija] [decimal](18, 2) NULL,
	[ExcedentePatronal] [decimal](18, 2) NULL,
	[ExcedenteObrera] [decimal](18, 2) NULL,
	[PrestacionesDineroPatronal] [decimal](18, 2) NULL,
	[PrestacionesDineroObrera] [decimal](18, 2) NULL,
	[GastosMedicosPensionadosPatronal] [decimal](18, 2) NULL,
	[GastosMedicosPensionadosObrera] [decimal](18, 2) NULL,
	[RiesgoTrabajo] [decimal](18, 2) NULL,
	[InvalidezVidaPatronal] [decimal](18, 2) NULL,
	[InvalidezVidaObreara] [decimal](18, 2) NULL,
	[GuarderiasPrestacionesSociales] [decimal](18, 2) NULL,
	[Total] [decimal](18, 2) NULL,
 CONSTRAINT [PK_IMSSTblDetalleConfrontaIDSE_IDDEtalleConfrontaIDSE] PRIMARY KEY CLUSTERED 
(
	[IDDetalleConfrontaIDSE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [IMSS].[tblDetalleConfrontaEMAIDSE]  WITH CHECK ADD  CONSTRAINT [FK_IMSSTblControlConfrontaIMSS_IMSStblDetalleConfrontaEMAIDSE_IDControlConfrontaIMSS] FOREIGN KEY([IDControlConfrontaIMSS])
REFERENCES [IMSS].[tblControlConfrontaIMSS] ([IDControlConfrontaIMSS])
GO
ALTER TABLE [IMSS].[tblDetalleConfrontaEMAIDSE] CHECK CONSTRAINT [FK_IMSSTblControlConfrontaIMSS_IMSStblDetalleConfrontaEMAIDSE_IDControlConfrontaIMSS]
GO
