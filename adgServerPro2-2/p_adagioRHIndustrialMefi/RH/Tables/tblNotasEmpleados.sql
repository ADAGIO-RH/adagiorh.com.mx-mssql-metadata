USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblNotasEmpleados](
	[IDNotaEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[Fecha] [date] NOT NULL,
	[Nota] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[FechaHoraReg] [datetime] NOT NULL,
 CONSTRAINT [Pk_RHTblNotasEmpleados_IDNotaEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDNotaEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblNotasEmpleados_Fecha] ON [RH].[tblNotasEmpleados]
(
	[Fecha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblNotasEmpleados_IDEmpleado] ON [RH].[tblNotasEmpleados]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblNotasEmpleados] ADD  CONSTRAINT [D_RHTblNotasEmpleados_Fecha]  DEFAULT (getdate()) FOR [Fecha]
GO
ALTER TABLE [RH].[tblNotasEmpleados] ADD  CONSTRAINT [D_RHTblNotasEmpleados_FechaHoraReg]  DEFAULT (getdate()) FOR [FechaHoraReg]
GO
ALTER TABLE [RH].[tblNotasEmpleados]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblNotasEmpleadosRHTblEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
ON DELETE CASCADE
GO
ALTER TABLE [RH].[tblNotasEmpleados] CHECK CONSTRAINT [Fk_RHTblNotasEmpleadosRHTblEmpleados_IDEmpleado]
GO
ALTER TABLE [RH].[tblNotasEmpleados]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblNotasEmpleadosSeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [RH].[tblNotasEmpleados] CHECK CONSTRAINT [Fk_RHTblNotasEmpleadosSeguridadTblUsuarios_IDUsuario]
GO
