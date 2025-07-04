USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblLayoutPagoParametros](
	[IDLayoutPagoParametros] [int] IDENTITY(1,1) NOT NULL,
	[IDLayoutPago] [int] NOT NULL,
	[IDTipoLayoutParametro] [int] NOT NULL,
	[Valor] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
PRIMARY KEY CLUSTERED 
(
	[IDLayoutPagoParametros] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_NominatblLayoutPagoParametros_IDLayoutPago_IDTipoLayoutParametro] UNIQUE NONCLUSTERED 
(
	[IDLayoutPago] ASC,
	[IDTipoLayoutParametro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblLayoutPagoParametros]  WITH CHECK ADD  CONSTRAINT [FK_NominatblCatTiposLayoutParametros_NominatblLayoutPagoParametros_IDTipoLayoutParametro] FOREIGN KEY([IDTipoLayoutParametro])
REFERENCES [Nomina].[tblCatTiposLayoutParametros] ([IDTipoLayoutParametro])
GO
ALTER TABLE [Nomina].[tblLayoutPagoParametros] CHECK CONSTRAINT [FK_NominatblCatTiposLayoutParametros_NominatblLayoutPagoParametros_IDTipoLayoutParametro]
GO
ALTER TABLE [Nomina].[tblLayoutPagoParametros]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblLayoutPago_NominaTblLayoutPagoParametros_IDLayoutPago] FOREIGN KEY([IDLayoutPago])
REFERENCES [Nomina].[tblLayoutPago] ([IDLayoutPago])
GO
ALTER TABLE [Nomina].[tblLayoutPagoParametros] CHECK CONSTRAINT [FK_NominaTblLayoutPago_NominaTblLayoutPagoParametros_IDLayoutPago]
GO
