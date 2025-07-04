USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Comedor].[tblComidasConsumidas](
	[IDComidaConsumida] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[Fecha] [datetime] NOT NULL,
	[IDLector] [int] NULL,
 CONSTRAINT [PK_ComedorTblComidasConsumidas_IDComidaConsumida] PRIMARY KEY CLUSTERED 
(
	[IDComidaConsumida] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Comedor].[tblComidasConsumidas] ADD  DEFAULT (getdate()) FOR [Fecha]
GO
ALTER TABLE [Comedor].[tblComidasConsumidas]  WITH CHECK ADD  CONSTRAINT [FK_AsistenciatblLectores_ComedorTblComidasConsumidas_IDLector] FOREIGN KEY([IDLector])
REFERENCES [Asistencia].[tblLectores] ([IDLector])
GO
ALTER TABLE [Comedor].[tblComidasConsumidas] CHECK CONSTRAINT [FK_AsistenciatblLectores_ComedorTblComidasConsumidas_IDLector]
GO
ALTER TABLE [Comedor].[tblComidasConsumidas]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpleados_ComedorTblComidasConsumidas_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Comedor].[tblComidasConsumidas] CHECK CONSTRAINT [FK_RHTblEmpleados_ComedorTblComidasConsumidas_IDEmpleado]
GO
