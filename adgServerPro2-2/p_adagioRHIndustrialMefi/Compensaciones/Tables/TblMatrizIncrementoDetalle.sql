USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Compensaciones].[TblMatrizIncrementoDetalle](
	[IDMatrizIncrementoDetalle] [int] IDENTITY(1,1) NOT NULL,
	[IDMatrizIncremento] [int] NOT NULL,
	[ValorNivelAmplitud] [decimal](18, 4) NULL,
	[LabelValorNivelAmplitud] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ValorNivelProgresion] [decimal](18, 4) NULL,
	[LabelValorNivelProgresion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Valor] [decimal](18, 4) NULL,
 CONSTRAINT [PK_CompensacionesTblMatrizIncrementoDetalle_IDMatrizIncrementoDetalle] PRIMARY KEY CLUSTERED 
(
	[IDMatrizIncrementoDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Compensaciones].[TblMatrizIncrementoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_CompensacionesTblMatrizIncremento_CompensacionesTblMatrizIncrementoDetalle_IDMatrizIncremento] FOREIGN KEY([IDMatrizIncremento])
REFERENCES [Compensaciones].[tblMatrizIncremento] ([IDMatrizIncremento])
ON DELETE CASCADE
GO
ALTER TABLE [Compensaciones].[TblMatrizIncrementoDetalle] CHECK CONSTRAINT [FK_CompensacionesTblMatrizIncremento_CompensacionesTblMatrizIncrementoDetalle_IDMatrizIncremento]
GO
