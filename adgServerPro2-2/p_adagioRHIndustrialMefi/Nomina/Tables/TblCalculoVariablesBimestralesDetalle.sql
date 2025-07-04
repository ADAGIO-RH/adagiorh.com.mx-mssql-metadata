USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[TblCalculoVariablesBimestralesDetalle](
	[IDCalculoVariablesBimestralesDetalle] [int] IDENTITY(1,1) NOT NULL,
	[IDCalculoVariablesBimestralesMaster] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDConcepto] [int] NOT NULL,
	[Integrable] [decimal](18, 2) NULL,
	[Importetotal1] [decimal](18, 2) NULL,
 CONSTRAINT [PK_NominaTblMasterCalculoVariablesBimestrales_IDCalculoVariablesBimestralesDetalle] PRIMARY KEY CLUSTERED 
(
	[IDCalculoVariablesBimestralesDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[TblCalculoVariablesBimestralesDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpleados_NominaTblCalculoVariablesBimestralesDetalle_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Nomina].[TblCalculoVariablesBimestralesDetalle] CHECK CONSTRAINT [FK_RHTblEmpleados_NominaTblCalculoVariablesBimestralesDetalle_IDEmpleado]
GO
ALTER TABLE [Nomina].[TblCalculoVariablesBimestralesDetalle]  WITH CHECK ADD  CONSTRAINT [FK_TblCalculoVariablesBimestralesMaster_TblCalculoVariablesBimestralesDetalle_IDCalculoVariablesBimestralesMaster] FOREIGN KEY([IDCalculoVariablesBimestralesMaster])
REFERENCES [Nomina].[TblCalculoVariablesBimestralesMaster] ([IDCalculoVariablesBimestralesMaster])
ON DELETE CASCADE
GO
ALTER TABLE [Nomina].[TblCalculoVariablesBimestralesDetalle] CHECK CONSTRAINT [FK_TblCalculoVariablesBimestralesMaster_TblCalculoVariablesBimestralesDetalle_IDCalculoVariablesBimestralesMaster]
GO
