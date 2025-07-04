USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblContratoEmpleado](
	[IDContratoEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDTipoContrato] [int] NULL,
	[IDDocumento] [int] NULL,
	[FechaIni] [date] NOT NULL,
	[FechaFin] [date] NOT NULL,
	[Duracion] [int] NULL,
	[IDTipoDocumento] [int] NULL,
	[FechaGeneracion] [datetime] NULL,
	[IDTipoTrabajador] [int] NULL,
	[IDReferencia] [int] NULL,
	[CalificacionEvaluacion] [decimal](18, 2) NULL,
 CONSTRAINT [PK_tblContratoEmpleado_IDContratoEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDContratoEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_NC_RHTblContratoEmpleado_IDTipoContrato] ON [RH].[tblContratoEmpleado]
(
	[IDTipoContrato] ASC
)
INCLUDE([IDContratoEmpleado],[IDEmpleado],[IDDocumento],[FechaIni],[FechaFin]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblContratoEmpleado_FechaFin] ON [RH].[tblContratoEmpleado]
(
	[FechaFin] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblContratoEmpleado_FechaIni] ON [RH].[tblContratoEmpleado]
(
	[FechaIni] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblContratoEmpleado_IDDocumento] ON [RH].[tblContratoEmpleado]
(
	[IDDocumento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblContratoEmpleado_IDEmpleado] ON [RH].[tblContratoEmpleado]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblContratoEmpleado_IDTipoContrato] ON [RH].[tblContratoEmpleado]
(
	[IDTipoContrato] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblContratoEmpleado_IDTipoDocumento] ON [RH].[tblContratoEmpleado]
(
	[IDTipoDocumento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblContratoEmpleado_IDTipoTrabajador] ON [RH].[tblContratoEmpleado]
(
	[IDTipoTrabajador] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblContratoEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_IMSSTblCatTipoTrabajador_RHTblContratoEmpleado_IDTipoTrabajador] FOREIGN KEY([IDTipoTrabajador])
REFERENCES [IMSS].[tblCatTipoTrabajador] ([IDTipoTrabajador])
GO
ALTER TABLE [RH].[tblContratoEmpleado] CHECK CONSTRAINT [FK_IMSSTblCatTipoTrabajador_RHTblContratoEmpleado_IDTipoTrabajador]
GO
ALTER TABLE [RH].[tblContratoEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatDocumentos_RHtblContratoEmpleado_IDDocumento] FOREIGN KEY([IDDocumento])
REFERENCES [RH].[tblCatDocumentos] ([IDDocumento])
GO
ALTER TABLE [RH].[tblContratoEmpleado] CHECK CONSTRAINT [FK_RHtblCatDocumentos_RHtblContratoEmpleado_IDDocumento]
GO
ALTER TABLE [RH].[tblContratoEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatTipoDocumento_RHTblContratoEmpleado_IDTipoDocumento] FOREIGN KEY([IDTipoDocumento])
REFERENCES [RH].[tblCatTipoDocumento] ([IDTipoDocumento])
GO
ALTER TABLE [RH].[tblContratoEmpleado] CHECK CONSTRAINT [FK_RHTblCatTipoDocumento_RHTblContratoEmpleado_IDTipoDocumento]
GO
ALTER TABLE [RH].[tblContratoEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpleados_RHtblContratoEmpleado_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [RH].[tblContratoEmpleado] CHECK CONSTRAINT [FK_RHTblEmpleados_RHtblContratoEmpleado_IDEmpleado]
GO
ALTER TABLE [RH].[tblContratoEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_SattblCatTiposContrato_RHtblContratoEmpleado_IDTipoContrato] FOREIGN KEY([IDTipoContrato])
REFERENCES [Sat].[tblCatTiposContrato] ([IDTipoContrato])
GO
ALTER TABLE [RH].[tblContratoEmpleado] CHECK CONSTRAINT [FK_SattblCatTiposContrato_RHtblContratoEmpleado_IDTipoContrato]
GO
