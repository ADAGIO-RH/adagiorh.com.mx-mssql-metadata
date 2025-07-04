USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblInfonavitEmpleado](
	[IDInfonavitEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDRegPatronal] [int] NOT NULL,
	[NumeroCredito] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDTipoMovimiento] [int] NULL,
	[Fecha] [date] NOT NULL,
	[IDTipoDescuento] [int] NOT NULL,
	[ValorDescuento] [decimal](18, 4) NULL,
	[AplicaDisminucion] [bit] NULL,
 CONSTRAINT [PK_RHTblInfonavitEmpleado_IDInfonavitEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDInfonavitEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblInfonavitEmpleado_Fecha] ON [RH].[tblInfonavitEmpleado]
(
	[Fecha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblInfonavitEmpleado_IDEmpleado] ON [RH].[tblInfonavitEmpleado]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblInfonavitEmpleado_IDRegPatronal] ON [RH].[tblInfonavitEmpleado]
(
	[IDRegPatronal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblInfonavitEmpleado_IDTipoDescuento] ON [RH].[tblInfonavitEmpleado]
(
	[IDTipoDescuento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblInfonavitEmpleado_IDTipoMovimiento] ON [RH].[tblInfonavitEmpleado]
(
	[IDTipoMovimiento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblInfonavitEmpleado] ADD  CONSTRAINT [DF__tblInfona__Aplic__20ACD28B]  DEFAULT ((0)) FOR [AplicaDisminucion]
GO
ALTER TABLE [RH].[tblInfonavitEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatInfonavitTipoDescuento_RHTblInfonavitEmpleado_IDTipoDescuento] FOREIGN KEY([IDTipoDescuento])
REFERENCES [RH].[tblCatInfonavitTipoDescuento] ([IDTipoDescuento])
GO
ALTER TABLE [RH].[tblInfonavitEmpleado] CHECK CONSTRAINT [FK_RHTblCatInfonavitTipoDescuento_RHTblInfonavitEmpleado_IDTipoDescuento]
GO
ALTER TABLE [RH].[tblInfonavitEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatInfonavitTipoMovimiento_RHTblInfonavitEmpleado_IDTipoMovimiento] FOREIGN KEY([IDTipoMovimiento])
REFERENCES [RH].[tblCatInfonavitTipoMovimiento] ([IDTipoMovimiento])
GO
ALTER TABLE [RH].[tblInfonavitEmpleado] CHECK CONSTRAINT [FK_RHTblCatInfonavitTipoMovimiento_RHTblInfonavitEmpleado_IDTipoMovimiento]
GO
ALTER TABLE [RH].[tblInfonavitEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatRegPatronal_RHTblInfonavitEmpleados_IDRegPatronal] FOREIGN KEY([IDRegPatronal])
REFERENCES [RH].[tblCatRegPatronal] ([IDRegPatronal])
GO
ALTER TABLE [RH].[tblInfonavitEmpleado] CHECK CONSTRAINT [FK_RHTblCatRegPatronal_RHTblInfonavitEmpleados_IDRegPatronal]
GO
ALTER TABLE [RH].[tblInfonavitEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHTblInfonavitEmpleado_RHtblEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [RH].[tblInfonavitEmpleado] CHECK CONSTRAINT [FK_RHTblInfonavitEmpleado_RHtblEmpleados_IDEmpleado]
GO
