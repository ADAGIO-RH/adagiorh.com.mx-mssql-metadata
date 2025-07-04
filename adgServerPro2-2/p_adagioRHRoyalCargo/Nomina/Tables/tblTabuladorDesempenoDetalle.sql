USE [p_adagioRHRoyalCargo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblTabuladorDesempenoDetalle](
	[IDTabuladorDesempenoDetalle] [int] IDENTITY(1,1) NOT NULL,
	[IDTabuladorDesempeno] [int] NOT NULL,
	[Minimo] [decimal](18, 4) NOT NULL,
	[Maximo] [decimal](18, 4) NOT NULL,
	[Porcentaje] [decimal](5, 2) NOT NULL,
 CONSTRAINT [PK_NominatblTabuladorDesempenoDetalle_IDTabuladorDesempenoDetalle] PRIMARY KEY CLUSTERED 
(
	[IDTabuladorDesempenoDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblTabuladorDesempenoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_NominatblTabuladorDesempenoDetalle_NominatblTabuladorDesempeno_IDTabuladorDesempeno] FOREIGN KEY([IDTabuladorDesempeno])
REFERENCES [Nomina].[tblTabuladorDesempeno] ([IDTabuladorDesempeno])
GO
ALTER TABLE [Nomina].[tblTabuladorDesempenoDetalle] CHECK CONSTRAINT [FK_NominatblTabuladorDesempenoDetalle_NominatblTabuladorDesempeno_IDTabuladorDesempeno]
GO
