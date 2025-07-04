USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [IMSS].[tblMovAfiliatorios](
	[IDMovAfiliatorio] [int] IDENTITY(1,1) NOT NULL,
	[Fecha] [date] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDTipoMovimiento] [int] NOT NULL,
	[FechaIMSS] [date] NULL,
	[FechaIDSE] [date] NULL,
	[IDRazonMovimiento] [int] NULL,
	[SalarioDiario] [decimal](18, 2) NULL,
	[SalarioIntegrado] [decimal](18, 2) NULL,
	[SalarioVariable] [decimal](18, 2) NULL,
	[SalarioDiarioReal] [decimal](18, 2) NULL,
	[IDRegPatronal] [int] NULL,
	[RespetarAntiguedad] [bit] NULL,
	[FechaAntiguedad] [date] NULL,
	[IDTipoPrestacion] [int] NULL,
	[Comentario] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaUltimoDiaLaborado] [date] NULL,
	[IDTipoRazonMovimiento] [int] NULL,
 CONSTRAINT [PK_IMSStblMovAfiliatorios_IDMovAfiliatorio] PRIMARY KEY CLUSTERED 
(
	[IDMovAfiliatorio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NONCLUSTERED_MovAfiliatorios_IDEmpledo_Fecha_IDTipoMovimiento] ON [IMSS].[tblMovAfiliatorios]
(
	[IDEmpleado] ASC,
	[Fecha] ASC,
	[IDTipoMovimiento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ImssTblMovAfiliatorios_Fecha] ON [IMSS].[tblMovAfiliatorios]
(
	[Fecha] ASC
)
INCLUDE([IDMovAfiliatorio],[IDEmpleado],[IDTipoMovimiento],[FechaIMSS],[FechaIDSE],[IDRazonMovimiento],[SalarioDiario],[SalarioIntegrado],[SalarioVariable],[SalarioDiarioReal],[IDRegPatronal]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_IMSSTblMovAfiliatorios_IDEmpleado] ON [IMSS].[tblMovAfiliatorios]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [IMSS].[tblMovAfiliatorios] ADD  DEFAULT ((0)) FOR [RespetarAntiguedad]
GO
ALTER TABLE [IMSS].[tblMovAfiliatorios]  WITH CHECK ADD  CONSTRAINT [FK_IMSStblCatRazonesMovAfiliatorios_IMSStblMovAfiliatorios_IDRazonMovimiento] FOREIGN KEY([IDRazonMovimiento])
REFERENCES [IMSS].[tblCatRazonesMovAfiliatorios] ([IDRazonMovimiento])
GO
ALTER TABLE [IMSS].[tblMovAfiliatorios] CHECK CONSTRAINT [FK_IMSStblCatRazonesMovAfiliatorios_IMSStblMovAfiliatorios_IDRazonMovimiento]
GO
ALTER TABLE [IMSS].[tblMovAfiliatorios]  WITH CHECK ADD  CONSTRAINT [FK_IMSStblCatTipoMovimientos_IMSStblMovAfiliatorios_IDTipoMovimiento] FOREIGN KEY([IDTipoMovimiento])
REFERENCES [IMSS].[tblCatTipoMovimientos] ([IDTipoMovimiento])
GO
ALTER TABLE [IMSS].[tblMovAfiliatorios] CHECK CONSTRAINT [FK_IMSStblCatTipoMovimientos_IMSStblMovAfiliatorios_IDTipoMovimiento]
GO
ALTER TABLE [IMSS].[tblMovAfiliatorios]  WITH CHECK ADD  CONSTRAINT [FK_IMSStblCatTiposRazonesMovimientos_IMSStblMovAfiliatorios_IDTipoRazonMovimiento] FOREIGN KEY([IDTipoRazonMovimiento])
REFERENCES [IMSS].[tblCatTiposRazonesMovimientos] ([IDCatTipoRazonMovimiento])
GO
ALTER TABLE [IMSS].[tblMovAfiliatorios] CHECK CONSTRAINT [FK_IMSStblCatTiposRazonesMovimientos_IMSStblMovAfiliatorios_IDTipoRazonMovimiento]
GO
ALTER TABLE [IMSS].[tblMovAfiliatorios]  WITH CHECK ADD  CONSTRAINT [fk_IMSStblMovAfiliatorios_RHtblCatTiposPrestaciones_IDTipoPrestacion] FOREIGN KEY([IDTipoPrestacion])
REFERENCES [RH].[tblCatTiposPrestaciones] ([IDTipoPrestacion])
GO
ALTER TABLE [IMSS].[tblMovAfiliatorios] CHECK CONSTRAINT [fk_IMSStblMovAfiliatorios_RHtblCatTiposPrestaciones_IDTipoPrestacion]
GO
ALTER TABLE [IMSS].[tblMovAfiliatorios]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatRegPatronal_IMSSTblMovAfiliatorio_IDRegPatronal] FOREIGN KEY([IDRegPatronal])
REFERENCES [RH].[tblCatRegPatronal] ([IDRegPatronal])
GO
ALTER TABLE [IMSS].[tblMovAfiliatorios] CHECK CONSTRAINT [FK_RHtblCatRegPatronal_IMSSTblMovAfiliatorio_IDRegPatronal]
GO
ALTER TABLE [IMSS].[tblMovAfiliatorios]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpleados_IMSStblMovAfiliatorio_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [IMSS].[tblMovAfiliatorios] CHECK CONSTRAINT [FK_RHTblEmpleados_IMSStblMovAfiliatorio_IDEmpleado]
GO
