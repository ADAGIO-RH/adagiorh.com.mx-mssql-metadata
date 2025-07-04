USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblHistorialInfonavitEmpleado](
	[IDHistorialInfonavitEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDInfonavitEmpleado] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDRegPatronal] [int] NOT NULL,
	[NumeroCredito] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDTipoMovimiento] [int] NULL,
	[Fecha] [date] NOT NULL,
	[IDTipoDescuento] [int] NOT NULL,
	[ValorDescuento] [decimal](18, 4) NULL,
	[AplicaDisminucion] [bit] NULL,
	[FolioAviso] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaEntraVigor] [date] NULL,
	[IDTipoAvisoInfonavit] [int] NULL,
	[FechaFinVigor] [date] NULL,
 CONSTRAINT [PK_RHtblHistorialInfonavitEmpleado_IDHistorialInfonavitEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDHistorialInfonavitEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblHistorialInfonavitEmpleado_Fecha] ON [RH].[tblHistorialInfonavitEmpleado]
(
	[Fecha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblHistorialInfonavitEmpleado_IDEmpleado] ON [RH].[tblHistorialInfonavitEmpleado]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblHistorialInfonavitEmpleado_IDInfonavitEmpleado] ON [RH].[tblHistorialInfonavitEmpleado]
(
	[IDInfonavitEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblHistorialInfonavitEmpleado_IDRegPatronal] ON [RH].[tblHistorialInfonavitEmpleado]
(
	[IDRegPatronal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblHistorialInfonavitEmpleado_IDTipoDEscuento] ON [RH].[tblHistorialInfonavitEmpleado]
(
	[IDTipoDescuento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblHistorialInfonavitEmpleado_IDTipoMovimiento] ON [RH].[tblHistorialInfonavitEmpleado]
(
	[IDTipoMovimiento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblHistorialInfonavitEmpleado] ADD  DEFAULT ((0)) FOR [AplicaDisminucion]
GO
ALTER TABLE [RH].[tblHistorialInfonavitEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatInfonavitTipoDescuento_RHtblHistorialInfonavitEmpleado_IDTipoDescuento] FOREIGN KEY([IDTipoDescuento])
REFERENCES [RH].[tblCatInfonavitTipoDescuento] ([IDTipoDescuento])
GO
ALTER TABLE [RH].[tblHistorialInfonavitEmpleado] CHECK CONSTRAINT [FK_RHTblCatInfonavitTipoDescuento_RHtblHistorialInfonavitEmpleado_IDTipoDescuento]
GO
ALTER TABLE [RH].[tblHistorialInfonavitEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatInfonavitTipoMovimiento_RHtblHistorialInfonavitEmpleado_IDTipoMovimiento] FOREIGN KEY([IDTipoMovimiento])
REFERENCES [RH].[tblCatInfonavitTipoMovimiento] ([IDTipoMovimiento])
GO
ALTER TABLE [RH].[tblHistorialInfonavitEmpleado] CHECK CONSTRAINT [FK_RHTblCatInfonavitTipoMovimiento_RHtblHistorialInfonavitEmpleado_IDTipoMovimiento]
GO
ALTER TABLE [RH].[tblHistorialInfonavitEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatRegPatronal_tblHistorialInfonavitEmpleado_IDRegPatronal] FOREIGN KEY([IDRegPatronal])
REFERENCES [RH].[tblCatRegPatronal] ([IDRegPatronal])
GO
ALTER TABLE [RH].[tblHistorialInfonavitEmpleado] CHECK CONSTRAINT [FK_RHTblCatRegPatronal_tblHistorialInfonavitEmpleado_IDRegPatronal]
GO
ALTER TABLE [RH].[tblHistorialInfonavitEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHtblcatTiposAvisosInfonavit_rhtblHistorialInfonavitEmpleado_IDTipoAvisoInfonavit] FOREIGN KEY([IDTipoAvisoInfonavit])
REFERENCES [RH].[tblcatTiposAvisosInfonavit] ([IDTipoAvisoInfonavit])
GO
ALTER TABLE [RH].[tblHistorialInfonavitEmpleado] CHECK CONSTRAINT [FK_RHtblcatTiposAvisosInfonavit_rhtblHistorialInfonavitEmpleado_IDTipoAvisoInfonavit]
GO
ALTER TABLE [RH].[tblHistorialInfonavitEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHTblInfonavitEmpleado_RHtblHistorialInfonavitEmpleado_IDInfonavitEmpleado] FOREIGN KEY([IDInfonavitEmpleado])
REFERENCES [RH].[tblInfonavitEmpleado] ([IDInfonavitEmpleado])
GO
ALTER TABLE [RH].[tblHistorialInfonavitEmpleado] CHECK CONSTRAINT [FK_RHTblInfonavitEmpleado_RHtblHistorialInfonavitEmpleado_IDInfonavitEmpleado]
GO
ALTER TABLE [RH].[tblHistorialInfonavitEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_tblHistorialInfonavitEmpleado_RHtblEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [RH].[tblHistorialInfonavitEmpleado] CHECK CONSTRAINT [FK_tblHistorialInfonavitEmpleado_RHtblEmpleados_IDEmpleado]
GO
