USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [IMSS].[tblCatPorcentajesPago](
	[IDPorcentajesPago] [int] IDENTITY(1,1) NOT NULL,
	[Fecha] [date] NOT NULL,
	[CuotaFija] [decimal](18, 6) NULL,
	[ExcedentePatronal] [decimal](18, 6) NULL,
	[ExcedenteObrera] [decimal](18, 6) NULL,
	[PrestacionesDineroPatronal] [decimal](18, 6) NULL,
	[PrestacionesDineroObrera] [decimal](18, 6) NULL,
	[GMPensionadosPatronal] [decimal](18, 6) NULL,
	[GMPensionadosObrera] [decimal](18, 6) NULL,
	[RiesgosTrabajo] [decimal](18, 6) NULL,
	[InvalidezVidaPatronal] [decimal](18, 6) NULL,
	[InvalidezVidaObrera] [decimal](18, 6) NULL,
	[GuarderiasPrestacionesSociales] [decimal](18, 6) NULL,
	[CesantiaVejezPatron] [decimal](18, 6) NULL,
	[SeguroRetiro] [decimal](18, 6) NULL,
	[Infonavit] [decimal](18, 6) NULL,
	[CesantiaVejezObrera] [decimal](18, 6) NULL,
	[ReservaPensionado] [decimal](18, 6) NULL,
	[CuotaProporcionalObrera] [decimal](18, 6) NULL,
 CONSTRAINT [PK_IMSSTblCatPorcentajesPago_IDPorcentajesPago] PRIMARY KEY CLUSTERED 
(
	[IDPorcentajesPago] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
