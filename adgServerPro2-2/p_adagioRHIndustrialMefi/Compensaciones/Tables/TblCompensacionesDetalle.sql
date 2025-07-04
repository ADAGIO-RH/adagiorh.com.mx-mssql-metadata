USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Compensaciones].[TblCompensacionesDetalle](
	[IDCompensacionesDetalle] [int] IDENTITY(1,1) NOT NULL,
	[IDCompensacion] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IndiceSalarial] [decimal](18, 4) NULL,
	[IndiceSalarialNuevo] [decimal](18, 4) NULL,
	[Salario] [decimal](18, 4) NULL,
	[SalarioNuevo] [decimal](18, 4) NULL,
	[SalarioDiario] [decimal](18, 4) NULL,
	[SalarioDiarioNuevo] [decimal](18, 4) NULL,
	[Compensacion] [decimal](18, 4) NULL,
 CONSTRAINT [PK_CompensacionesTblCompensacionesDetalle_IDCompensacionesDetalle] PRIMARY KEY CLUSTERED 
(
	[IDCompensacionesDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Compensaciones].[TblCompensacionesDetalle]  WITH CHECK ADD  CONSTRAINT [FK_CompensacionTblCompensaciones_CompensacionesTblCompensacionesDetalle_ID] FOREIGN KEY([IDCompensacion])
REFERENCES [Compensaciones].[TblCompensaciones] ([IDCompensacion])
GO
ALTER TABLE [Compensaciones].[TblCompensacionesDetalle] CHECK CONSTRAINT [FK_CompensacionTblCompensaciones_CompensacionesTblCompensacionesDetalle_ID]
GO
ALTER TABLE [Compensaciones].[TblCompensacionesDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpleados_CompensacionesTblComepnsacionesDetalle_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Compensaciones].[TblCompensacionesDetalle] CHECK CONSTRAINT [FK_RHTblEmpleados_CompensacionesTblComepnsacionesDetalle_IDEmpleado]
GO
