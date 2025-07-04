USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblUltimaActualizacionEmpleados](
	[IDUltimaActualizacionEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[Fecha] [datetime] NOT NULL,
 CONSTRAINT [Pk_RHTblUltimaActualizacionEmpleados_IDUltimaActualizacionEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDUltimaActualizacionEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblUltimaActualizacionEmpleados]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblUltimaActualizacionEmpleados_RHTblEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
ON DELETE CASCADE
GO
ALTER TABLE [RH].[tblUltimaActualizacionEmpleados] CHECK CONSTRAINT [Fk_RHTblUltimaActualizacionEmpleados_RHTblEmpleados_IDEmpleado]
GO
