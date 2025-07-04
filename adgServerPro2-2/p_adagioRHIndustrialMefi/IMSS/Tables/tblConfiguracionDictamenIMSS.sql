USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [IMSS].[tblConfiguracionDictamenIMSS](
	[IDConfiguracionDictamenIMSS] [int] NOT NULL,
	[SueldosSalarios] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[GratificacionAnual] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ParticipacionUtilidades] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ReembolsoGastosMedicos] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FondoAhorroPatron] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FondoAhorroTrabajador] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CajaAhorro] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ContribucionesTrabajador] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PremiosPuntualidad] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PrimaSeguroVida] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SeguroGastosMedicosMayores] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CuotasSindicales] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SubsidiosIncapacidad] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[BecasTrabajadoresHijos] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[HoraExtra] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PrimaDominical] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PrimaVacacional] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PrimaAntiguedad] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PagosSeparacion] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SeguroRetiro] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Indemnizaciones] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ReembolsoFuneral] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CuotasSeguridadSocial] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Comisiones] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ValesDespensa] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ValesRestaurante] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ValesGasolina] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ValesRopa] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[AyudaRenta] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[AyudaArticulosEscolares] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[AyudaAnteojos] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[AyudaTransporte] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[AyudaGastosFuneral] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[OtrosIngresosSalarios] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[JubilacionesPensionesRetiro] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[JubilacionesPensionesRetiroParcialidades] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IngresosAccionesTitulos] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Alimentacion] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Habitacion] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PremiosAsistencia] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Viaticos] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_IMSSTblConfiguracionDictamenIMSS_IDConfiguracionDictamenIMSS] PRIMARY KEY CLUSTERED 
(
	[IDConfiguracionDictamenIMSS] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
