USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PROCOM].[TblFacturasPeriodos](
	[IDFacturaPeriodo] [int] IDENTITY(1,1) NOT NULL,
	[IDFactura] [int] NOT NULL,
	[IDPeriodo] [int] NOT NULL,
 CONSTRAINT [PK_ProcomFacturasPeriodos_IDFacturaPeriodo] PRIMARY KEY CLUSTERED 
(
	[IDFacturaPeriodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [PROCOM].[TblFacturasPeriodos]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblCatPeriodos_ProcomTblFacturasPeriodos_IDPeriodo] FOREIGN KEY([IDPeriodo])
REFERENCES [Nomina].[tblCatPeriodos] ([IDPeriodo])
GO
ALTER TABLE [PROCOM].[TblFacturasPeriodos] CHECK CONSTRAINT [FK_NominaTblCatPeriodos_ProcomTblFacturasPeriodos_IDPeriodo]
GO
ALTER TABLE [PROCOM].[TblFacturasPeriodos]  WITH CHECK ADD  CONSTRAINT [FK_ProcomTblFacturas_ProcomTblFacturasPeriodos_IDFactura] FOREIGN KEY([IDFactura])
REFERENCES [PROCOM].[TblFacturas] ([IDFactura])
ON DELETE CASCADE
GO
ALTER TABLE [PROCOM].[TblFacturasPeriodos] CHECK CONSTRAINT [FK_ProcomTblFacturas_ProcomTblFacturasPeriodos_IDFactura]
GO
