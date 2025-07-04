USE [p_adagioRHOwen]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblCatExpedientesDigitales](
	[IDExpedienteDigital] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Requerido] [bit] NULL,
	[RequeridoTexto] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDCarpetaExpedienteDigital] [int] NULL,
	[IDPeriodicidad] [int] NULL,
	[Caduca] [bit] NOT NULL,
	[FechaHoraActualizacion] [datetime] NULL,
	[PeriodoVigenciaDocumento] [int] NULL,
	[Intranet] [bit] NULL,
	[Reclutamiento] [bit] NULL,
	[IntranetConfig] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_RHTblCatExpedientesDigitales_IDCatExpedienteDigital] PRIMARY KEY CLUSTERED 
(
	[IDExpedienteDigital] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_RHtblCatExpedientesDigitales_Codigo] UNIQUE NONCLUSTERED 
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [RH].[tblCatExpedientesDigitales] ADD  CONSTRAINT [d_RHtblCatExpedientesDigitales_Requerido]  DEFAULT ((0)) FOR [Requerido]
GO
ALTER TABLE [RH].[tblCatExpedientesDigitales] ADD  CONSTRAINT [D_RHTblCatExpedientesDigitales_Caduca]  DEFAULT ((0)) FOR [Caduca]
GO
ALTER TABLE [RH].[tblCatExpedientesDigitales] ADD  DEFAULT ((0)) FOR [Intranet]
GO
ALTER TABLE [RH].[tblCatExpedientesDigitales] ADD  DEFAULT ((0)) FOR [Reclutamiento]
GO
ALTER TABLE [RH].[tblCatExpedientesDigitales]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatCarpetasExpedienteDigital_RHtblCatExpedientesDigitales_IDCarpetaExpedienteDigital] FOREIGN KEY([IDCarpetaExpedienteDigital])
REFERENCES [RH].[tblCatCarpetasExpedienteDigital] ([IDCarpetaExpedienteDigital])
GO
ALTER TABLE [RH].[tblCatExpedientesDigitales] CHECK CONSTRAINT [FK_RHtblCatCarpetasExpedienteDigital_RHtblCatExpedientesDigitales_IDCarpetaExpedienteDigital]
GO
ALTER TABLE [RH].[tblCatExpedientesDigitales]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblCatExpedientesDigitales_AppTblCatPeriodicidades_IDPeriodicidad] FOREIGN KEY([IDPeriodicidad])
REFERENCES [App].[tblCatPeriodicidades] ([IDPeriodicidad])
GO
ALTER TABLE [RH].[tblCatExpedientesDigitales] CHECK CONSTRAINT [Fk_RHTblCatExpedientesDigitales_AppTblCatPeriodicidades_IDPeriodicidad]
GO
ALTER TABLE [RH].[tblCatExpedientesDigitales]  WITH CHECK ADD  CONSTRAINT [CHK_RHtblCatExpedientesDigitales_IntranetConfig] CHECK  ((isjson([IntranetConfig])>(0)))
GO
ALTER TABLE [RH].[tblCatExpedientesDigitales] CHECK CONSTRAINT [CHK_RHtblCatExpedientesDigitales_IntranetConfig]
GO
