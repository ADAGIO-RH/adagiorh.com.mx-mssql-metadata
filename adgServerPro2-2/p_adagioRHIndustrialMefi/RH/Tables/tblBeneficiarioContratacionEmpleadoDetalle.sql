USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblBeneficiarioContratacionEmpleadoDetalle](
	[IDBeneficiarioContratacionEmpleadoDetalle] [int] IDENTITY(1,1) NOT NULL,
	[IDBeneficiarioContratacionEmpleado] [int] NOT NULL,
	[IDCatBeneficiarioContratacion] [int] NOT NULL,
	[Porcentaje] [decimal](18, 2) NULL,
 CONSTRAINT [PK_RHTblBeneficiarioContratacionEmpleadoDetalle_IDBeneficiarioContratacionEmpleadoDetalle] PRIMARY KEY CLUSTERED 
(
	[IDBeneficiarioContratacionEmpleadoDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblBeneficiarioContratacionEmpleadoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RHTblBeneficiarioContratacionEmpleado_RHTblBeneficiarioContratacionEmpleadoDetalle_IDBeneficiarioContratacionEmpleado] FOREIGN KEY([IDBeneficiarioContratacionEmpleado])
REFERENCES [RH].[tblBeneficiarioContratacionEmpleado] ([IDBeneficiarioContratacionEmpleado])
GO
ALTER TABLE [RH].[tblBeneficiarioContratacionEmpleadoDetalle] CHECK CONSTRAINT [FK_RHTblBeneficiarioContratacionEmpleado_RHTblBeneficiarioContratacionEmpleadoDetalle_IDBeneficiarioContratacionEmpleado]
GO
ALTER TABLE [RH].[tblBeneficiarioContratacionEmpleadoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatBeneficiarioContratacion_RHTblBeneficiarioContratacionEmpleadoDetalle_IDCatBeneficiarioContratacion] FOREIGN KEY([IDCatBeneficiarioContratacion])
REFERENCES [RH].[tblCatBeneficiariosContratacion] ([IDCatBeneficiarioContratacion])
GO
ALTER TABLE [RH].[tblBeneficiarioContratacionEmpleadoDetalle] CHECK CONSTRAINT [FK_RHTblCatBeneficiarioContratacion_RHTblBeneficiarioContratacionEmpleadoDetalle_IDCatBeneficiarioContratacion]
GO
