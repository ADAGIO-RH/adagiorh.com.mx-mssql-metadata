USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblPrestacionesEmpleado](
	[IDPrestacionEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDTipoPrestacion] [int] NOT NULL,
	[FechaIni] [date] NOT NULL,
	[FechaFin] [date] NOT NULL,
 CONSTRAINT [PK_RHtblPrestacionesEmpleado_IDPrestacionEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDPrestacionEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblPrestacionesEmpleado_FechaFin] ON [RH].[tblPrestacionesEmpleado]
(
	[FechaFin] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblPrestacionesEmpleado_Fechaini] ON [RH].[tblPrestacionesEmpleado]
(
	[FechaIni] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblPrestacionesEmpleado_IDEmpleado] ON [RH].[tblPrestacionesEmpleado]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblPrestacionesEmpleado_IDTipoPrestacion] ON [RH].[tblPrestacionesEmpleado]
(
	[IDTipoPrestacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblPrestacionesEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatTiposPrestaciones_RHtblPrestacionesEmpleado_IDTipoPrestacion] FOREIGN KEY([IDTipoPrestacion])
REFERENCES [RH].[tblCatTiposPrestaciones] ([IDTipoPrestacion])
GO
ALTER TABLE [RH].[tblPrestacionesEmpleado] CHECK CONSTRAINT [FK_RHtblCatTiposPrestaciones_RHtblPrestacionesEmpleado_IDTipoPrestacion]
GO
ALTER TABLE [RH].[tblPrestacionesEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHtblEmpleado_RHtblPrestacionesEmpleado_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [RH].[tblPrestacionesEmpleado] CHECK CONSTRAINT [FK_RHtblEmpleado_RHtblPrestacionesEmpleado_IDEmpleado]
GO
