USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblTotalRelacionesEmpleados](
	[IDTotalRelacionEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDTipoRelacion] [int] NOT NULL,
	[Total] [int] NOT NULL,
 CONSTRAINT [Pk_RHTblTotalRelacionesEmpleados_IDTotalRelacionEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDTotalRelacionEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblTotalRelacionesEmpleados_IDEmpleado] ON [RH].[tblTotalRelacionesEmpleados]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblTotalRelacionesEmpleados_IDTipoRelacion] ON [RH].[tblTotalRelacionesEmpleados]
(
	[IDTipoRelacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblTotalRelacionesEmpleados] ADD  CONSTRAINT [D_RHTblTotalRelacionesEmpleados_Total]  DEFAULT ((0)) FOR [Total]
GO
ALTER TABLE [RH].[tblTotalRelacionesEmpleados]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblTotalRelacionesEmpleados_RHTblEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
ON DELETE CASCADE
GO
ALTER TABLE [RH].[tblTotalRelacionesEmpleados] CHECK CONSTRAINT [Fk_RHTblTotalRelacionesEmpleados_RHTblEmpleados_IDEmpleado]
GO
ALTER TABLE [RH].[tblTotalRelacionesEmpleados]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblTotalRelacionesEmpleados_RHTblEmpleados_IDTipoRelacion] FOREIGN KEY([IDTipoRelacion])
REFERENCES [Evaluacion360].[tblCatTiposRelaciones] ([IDTipoRelacion])
GO
ALTER TABLE [RH].[tblTotalRelacionesEmpleados] CHECK CONSTRAINT [Fk_RHTblTotalRelacionesEmpleados_RHTblEmpleados_IDTipoRelacion]
GO
