USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblTabuladorNivelSalarialAumentosDesempenoDetalle](
	[IDTabuladorNivelSalarialAumentosDesempenoDetalle] [int] IDENTITY(1,1) NOT NULL,
	[IDTabuladorNivelSalarialAumentosDesempeno] [int] NOT NULL,
	[Nivel] [int] NOT NULL,
	[Minimo] [decimal](18, 4) NOT NULL,
	[Maximo] [decimal](18, 4) NOT NULL,
 CONSTRAINT [PK_NominatblTabuladorNivelSalarialAumentosDesempenoDetalle_IDTabuladorNivelSalarialAumentosDesempenoDetalle] PRIMARY KEY CLUSTERED 
(
	[IDTabuladorNivelSalarialAumentosDesempenoDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblTabuladorNivelSalarialAumentosDesempenoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_NominatblTabuladorNivelSalarialAumentosDesempenoDetalle_NominatblTabuladorNivelSalarialAumentosDesempeno_IDTabuladorNivelS] FOREIGN KEY([IDTabuladorNivelSalarialAumentosDesempeno])
REFERENCES [Nomina].[tblTabuladorNivelSalarialAumentosDesempeno] ([IDTabuladorNivelSalarialAumentosDesempeno])
GO
ALTER TABLE [Nomina].[tblTabuladorNivelSalarialAumentosDesempenoDetalle] CHECK CONSTRAINT [FK_NominatblTabuladorNivelSalarialAumentosDesempenoDetalle_NominatblTabuladorNivelSalarialAumentosDesempeno_IDTabuladorNivelS]
GO
