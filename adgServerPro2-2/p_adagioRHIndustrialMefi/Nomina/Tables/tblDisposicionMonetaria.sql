USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblDisposicionMonetaria](
	[IDDisposicionMonetaria] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoDisposicionMonetaria] [int] NOT NULL,
	[IDPeriodo] [int] NOT NULL,
	[FechaTransferencia] [date] NOT NULL,
	[Monto] [decimal](18, 2) NOT NULL,
 CONSTRAINT [PK_NominaTblDisposicionMonetaria_IDDisposicionMonetaria] PRIMARY KEY CLUSTERED 
(
	[IDDisposicionMonetaria] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblDisposicionMonetaria]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblCatPeriodos_NominaTblDisposicionMonetaria_IDPeriodo] FOREIGN KEY([IDPeriodo])
REFERENCES [Nomina].[tblCatPeriodos] ([IDPeriodo])
GO
ALTER TABLE [Nomina].[tblDisposicionMonetaria] CHECK CONSTRAINT [FK_NominaTblCatPeriodos_NominaTblDisposicionMonetaria_IDPeriodo]
GO
ALTER TABLE [Nomina].[tblDisposicionMonetaria]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblCatTipoDisposicionMonetaria_NominaTblDisposicionMonetaria_IDTipoDisposicionMonetaria] FOREIGN KEY([IDTipoDisposicionMonetaria])
REFERENCES [Nomina].[tblCatTipoDisposicionMonetaria] ([IDTipoDisposicionMonetaria])
GO
ALTER TABLE [Nomina].[tblDisposicionMonetaria] CHECK CONSTRAINT [FK_NominaTblCatTipoDisposicionMonetaria_NominaTblDisposicionMonetaria_IDTipoDisposicionMonetaria]
GO
