USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Compensaciones].[TblCompensaciones](
	[IDCompensacion] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDCatTipoCompensacion] [int] NOT NULL,
	[IDCliente] [int] NULL,
	[IDTipoNomina] [int] NULL,
	[IDPeriodo] [int] NULL,
	[IDMatrizIncremento] [int] NULL,
	[IDEvaluacion] [int] NULL,
	[Fecha] [date] NOT NULL,
	[bPorcentaje] [bit] NULL,
	[bDiasSueldo] [bit] NULL,
	[bMonto] [bit] NULL,
	[Porcentaje] [decimal](18, 4) NULL,
	[DiasSueldo] [decimal](18, 4) NULL,
	[Monto] [decimal](18, 4) NULL,
	[IDConcepto] [int] NULL,
 CONSTRAINT [PK_CompensacionesTblCompensaciones_IDCompensacion] PRIMARY KEY CLUSTERED 
(
	[IDCompensacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Compensaciones].[TblCompensaciones] ADD  CONSTRAINT [d_CompensacionesTblCompensaciones_bPorcentaje]  DEFAULT ((0)) FOR [bPorcentaje]
GO
ALTER TABLE [Compensaciones].[TblCompensaciones] ADD  CONSTRAINT [d_CompensacionesTblCompensaciones_bDiasSueldo]  DEFAULT ((0)) FOR [bDiasSueldo]
GO
ALTER TABLE [Compensaciones].[TblCompensaciones] ADD  CONSTRAINT [d_CompensacionesTblCompensaciones_bMonto]  DEFAULT ((0)) FOR [bMonto]
GO
ALTER TABLE [Compensaciones].[TblCompensaciones]  WITH CHECK ADD  CONSTRAINT [FK_CompensacionesTblCatTiposCompensaciones_CompensacionesTblCompensaciones_IDCatTipoCompensacion] FOREIGN KEY([IDCatTipoCompensacion])
REFERENCES [Compensaciones].[tblCatTiposCompensaciones] ([IDCatTipoCompensacion])
GO
ALTER TABLE [Compensaciones].[TblCompensaciones] CHECK CONSTRAINT [FK_CompensacionesTblCatTiposCompensaciones_CompensacionesTblCompensaciones_IDCatTipoCompensacion]
GO
ALTER TABLE [Compensaciones].[TblCompensaciones]  WITH CHECK ADD  CONSTRAINT [FK_CompensacionesTblMatrizIncremento_CompensacionesTblCompensaciones_IDMatrizIncremento] FOREIGN KEY([IDMatrizIncremento])
REFERENCES [Compensaciones].[tblMatrizIncremento] ([IDMatrizIncremento])
GO
ALTER TABLE [Compensaciones].[TblCompensaciones] CHECK CONSTRAINT [FK_CompensacionesTblMatrizIncremento_CompensacionesTblCompensaciones_IDMatrizIncremento]
GO
ALTER TABLE [Compensaciones].[TblCompensaciones]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblCatConceptos_CompensacionesTblCompensaciones_IDConcepto] FOREIGN KEY([IDConcepto])
REFERENCES [Nomina].[tblCatConceptos] ([IDConcepto])
GO
ALTER TABLE [Compensaciones].[TblCompensaciones] CHECK CONSTRAINT [FK_NominaTblCatConceptos_CompensacionesTblCompensaciones_IDConcepto]
GO
ALTER TABLE [Compensaciones].[TblCompensaciones]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblCatPeriodo_CompensacionesTblCompensaciones_IDPeriodo] FOREIGN KEY([IDPeriodo])
REFERENCES [Nomina].[tblCatPeriodos] ([IDPeriodo])
GO
ALTER TABLE [Compensaciones].[TblCompensaciones] CHECK CONSTRAINT [FK_NominaTblCatPeriodo_CompensacionesTblCompensaciones_IDPeriodo]
GO
ALTER TABLE [Compensaciones].[TblCompensaciones]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblCatTipoNomina_CompensacionesTblCompensaciones_IDTipoNomina] FOREIGN KEY([IDTipoNomina])
REFERENCES [Nomina].[tblCatTipoNomina] ([IDTipoNomina])
GO
ALTER TABLE [Compensaciones].[TblCompensaciones] CHECK CONSTRAINT [FK_NominaTblCatTipoNomina_CompensacionesTblCompensaciones_IDTipoNomina]
GO
ALTER TABLE [Compensaciones].[TblCompensaciones]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatClientes_CompensacionesTblCatCompensaciones_IDCliente] FOREIGN KEY([IDCliente])
REFERENCES [RH].[tblCatClientes] ([IDCliente])
GO
ALTER TABLE [Compensaciones].[TblCompensaciones] CHECK CONSTRAINT [FK_RHTblCatClientes_CompensacionesTblCatCompensaciones_IDCliente]
GO
