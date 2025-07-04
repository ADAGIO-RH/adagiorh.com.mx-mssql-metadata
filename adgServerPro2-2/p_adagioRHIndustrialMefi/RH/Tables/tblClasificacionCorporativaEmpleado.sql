USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblClasificacionCorporativaEmpleado](
	[IDClasificacionCorporativaEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDClasificacionCorporativa] [int] NOT NULL,
	[FechaIni] [date] NOT NULL,
	[FechaFin] [date] NOT NULL,
 CONSTRAINT [PK_tblClasificacionCorporativaEmpleado_IDClasificacionCorporativaEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDClasificacionCorporativaEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblClasificacionCorporativaEmpleado_FechaFin] ON [RH].[tblClasificacionCorporativaEmpleado]
(
	[FechaFin] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblClasificacionCorporativaEmpleado_FechaIni] ON [RH].[tblClasificacionCorporativaEmpleado]
(
	[FechaIni] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblClasificacionCorporativaEmpleado_IDClasificacionCorporativa] ON [RH].[tblClasificacionCorporativaEmpleado]
(
	[IDClasificacionCorporativa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblClasificacionCorporativaEmpleado_IDEmpleado] ON [RH].[tblClasificacionCorporativaEmpleado]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblClasificacionCorporativaEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatClasificacionesCorporativas_RHtblClasificacionCorporativaEmpleado_IDClasificacionCorporativa] FOREIGN KEY([IDClasificacionCorporativa])
REFERENCES [RH].[tblCatClasificacionesCorporativas] ([IDClasificacionCorporativa])
GO
ALTER TABLE [RH].[tblClasificacionCorporativaEmpleado] CHECK CONSTRAINT [FK_RHtblCatClasificacionesCorporativas_RHtblClasificacionCorporativaEmpleado_IDClasificacionCorporativa]
GO
ALTER TABLE [RH].[tblClasificacionCorporativaEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpleados_tblClasificacionCorporativaEmpleado_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [RH].[tblClasificacionCorporativaEmpleado] CHECK CONSTRAINT [FK_RHTblEmpleados_tblClasificacionCorporativaEmpleado_IDEmpleado]
GO
