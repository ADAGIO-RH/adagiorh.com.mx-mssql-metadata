USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Enrutamiento].[tblRutaSteps](
	[IDRutaStep] [int] IDENTITY(1,1) NOT NULL,
	[IDCatRuta] [int] NOT NULL,
	[IDCatTipoStep] [int] NOT NULL,
	[Orden] [int] NOT NULL,
 CONSTRAINT [PK_EnrutamientoTblRutaSteps_IDRutaStep] PRIMARY KEY CLUSTERED 
(
	[IDRutaStep] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Enrutamiento].[tblRutaSteps] ADD  DEFAULT ((0)) FOR [Orden]
GO
ALTER TABLE [Enrutamiento].[tblRutaSteps]  WITH CHECK ADD  CONSTRAINT [FK_EnrutamientotblCatRutas_EnrutamientoTblRutaSteps_IDRuta] FOREIGN KEY([IDCatRuta])
REFERENCES [Enrutamiento].[tblCatRutas] ([IDCatRuta])
GO
ALTER TABLE [Enrutamiento].[tblRutaSteps] CHECK CONSTRAINT [FK_EnrutamientotblCatRutas_EnrutamientoTblRutaSteps_IDRuta]
GO
