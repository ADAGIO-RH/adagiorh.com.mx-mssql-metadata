USE [p_adagioRHSakata]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblDetallePolizaProrrateoEmpleado](
	[IDDetallePolizaProrrateoEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDPoliza] [int] NOT NULL,
	[IDTipoPoliza] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[Filtro] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDReferencia] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaCreacion] [datetime] NOT NULL,
	[Porcentaje] [float] NULL,
 CONSTRAINT [PK_NominaTblDetallePolizaProrrateoEmpleado_IDDetallePolizaProrrateo] PRIMARY KEY CLUSTERED 
(
	[IDDetallePolizaProrrateoEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblDetallePolizaProrrateoEmpleado] ADD  CONSTRAINT [DF_NominaTblDetallePolizaProrrateoEmpleado_FechaCreacion]  DEFAULT (getdate()) FOR [FechaCreacion]
GO
ALTER TABLE [Nomina].[tblDetallePolizaProrrateoEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblCatTiposPolizas_NominaTblDetallePolizaProrrateoEmpleado_IDTipoPoliza] FOREIGN KEY([IDTipoPoliza])
REFERENCES [Nomina].[tblCatTiposPolizas] ([IDTipoPoliza])
GO
ALTER TABLE [Nomina].[tblDetallePolizaProrrateoEmpleado] CHECK CONSTRAINT [FK_NominaTblCatTiposPolizas_NominaTblDetallePolizaProrrateoEmpleado_IDTipoPoliza]
GO
ALTER TABLE [Nomina].[tblDetallePolizaProrrateoEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblPolizas_NominaTblDetallePolizaProrrateoEmpleado_IDPoliza] FOREIGN KEY([IDPoliza])
REFERENCES [Nomina].[tblPolizas] ([IDPoliza])
GO
ALTER TABLE [Nomina].[tblDetallePolizaProrrateoEmpleado] CHECK CONSTRAINT [FK_NominaTblPolizas_NominaTblDetallePolizaProrrateoEmpleado_IDPoliza]
GO
ALTER TABLE [Nomina].[tblDetallePolizaProrrateoEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpleados_NominaTblDetallePolizaProrrateoEmpleado_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Nomina].[tblDetallePolizaProrrateoEmpleado] CHECK CONSTRAINT [FK_RHTblEmpleados_NominaTblDetallePolizaProrrateoEmpleado_IDEmpleado]
GO
ALTER TABLE [Nomina].[tblDetallePolizaProrrateoEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblCatTiposFiltros_NominaTblDetallePolizaProrrateoEmpleado_Filtro] FOREIGN KEY([Filtro])
REFERENCES [Seguridad].[tblCatTiposFiltros] ([Filtro])
GO
ALTER TABLE [Nomina].[tblDetallePolizaProrrateoEmpleado] CHECK CONSTRAINT [FK_SeguridadTblCatTiposFiltros_NominaTblDetallePolizaProrrateoEmpleado_Filtro]
GO
