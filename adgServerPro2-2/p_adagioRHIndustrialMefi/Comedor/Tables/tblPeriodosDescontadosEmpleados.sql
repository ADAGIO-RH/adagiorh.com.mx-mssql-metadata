USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Comedor].[tblPeriodosDescontadosEmpleados](
	[IDEmpleado] [int] NOT NULL,
	[IDPeriodo] [int] NOT NULL,
	[IdsPeriodos] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Comedor].[tblPeriodosDescontadosEmpleados]  WITH CHECK ADD  CONSTRAINT [Fk_ComedorTblPeriodosDescontadosEmpleados_NominaTblCatPeriodos_IDPeriodo] FOREIGN KEY([IDPeriodo])
REFERENCES [Nomina].[tblCatPeriodos] ([IDPeriodo])
ON DELETE CASCADE
GO
ALTER TABLE [Comedor].[tblPeriodosDescontadosEmpleados] CHECK CONSTRAINT [Fk_ComedorTblPeriodosDescontadosEmpleados_NominaTblCatPeriodos_IDPeriodo]
GO
ALTER TABLE [Comedor].[tblPeriodosDescontadosEmpleados]  WITH CHECK ADD  CONSTRAINT [Fk_ComedorTblPeriodosDescontadosEmpleados_RHTblEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Comedor].[tblPeriodosDescontadosEmpleados] CHECK CONSTRAINT [Fk_ComedorTblPeriodosDescontadosEmpleados_RHTblEmpleados_IDEmpleado]
GO
