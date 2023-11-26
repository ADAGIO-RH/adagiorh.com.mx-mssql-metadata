USE [p_adagioRHCorporativoCet]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblAforeEmpleado](
	[IDAforeEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDAfore] [int] NULL,
 CONSTRAINT [PK_RHTblAforeEmpleado_IDAforeEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDAforeEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblAforeEmpleado_IDAfore] ON [RH].[tblAforeEmpleado]
(
	[IDAfore] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblAforeEmpleado_IDEmpleado] ON [RH].[tblAforeEmpleado]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblAforeEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatAfores_RHTblAforeEmpleado_IDAfore] FOREIGN KEY([IDAfore])
REFERENCES [RH].[tblCatAfores] ([IDAfore])
GO
ALTER TABLE [RH].[tblAforeEmpleado] CHECK CONSTRAINT [FK_RHTblCatAfores_RHTblAforeEmpleado_IDAfore]
GO
ALTER TABLE [RH].[tblAforeEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpleados_RHTblAforeEmpleado_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [RH].[tblAforeEmpleado] CHECK CONSTRAINT [FK_RHTblEmpleados_RHTblAforeEmpleado_IDEmpleado]
GO
