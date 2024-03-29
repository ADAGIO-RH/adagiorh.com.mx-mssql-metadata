USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblCatPorcentajesPago_2024_01_10](
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
	[CuotaProporcionalObrera] [decimal](18, 6) NULL
) ON [PRIMARY]
GO
