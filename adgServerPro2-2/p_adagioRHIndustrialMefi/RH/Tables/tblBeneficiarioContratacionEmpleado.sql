USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblBeneficiarioContratacionEmpleado](
	[IDBeneficiarioContratacionEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[FechaIni] [date] NULL,
	[FechaFin] [date] NULL,
 CONSTRAINT [PK_RHTblBeneficiarioContratacionEmpleado_IDBeneficiarioContratacionEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDBeneficiarioContratacionEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblBeneficiarioContratacionEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpleados_RHTblBeneficiarioContratacionEmpleado_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [RH].[tblBeneficiarioContratacionEmpleado] CHECK CONSTRAINT [FK_RHTblEmpleados_RHTblBeneficiarioContratacionEmpleado_IDEmpleado]
GO
