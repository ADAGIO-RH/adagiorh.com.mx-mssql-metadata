USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Enrutamiento].[tblRutaStepsEjecucion](
	[IDRutaStepsEjecucion] [int] IDENTITY(1,1) NOT NULL,
	[IDRutaStep] [int] NOT NULL,
	[IDPosicion] [int] NOT NULL,
 CONSTRAINT [PK_EnrutamientoTblRutaStepsEjecucion_IDRutaStepsEjecucion] PRIMARY KEY CLUSTERED 
(
	[IDRutaStepsEjecucion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Enrutamiento].[tblRutaStepsEjecucion]  WITH CHECK ADD  CONSTRAINT [FK_EnrutamientoTblRutaSteps_EnrutamientoTblRutaStepsEjecucion_IDRutaStep] FOREIGN KEY([IDRutaStep])
REFERENCES [Enrutamiento].[tblRutaSteps] ([IDRutaStep])
GO
ALTER TABLE [Enrutamiento].[tblRutaStepsEjecucion] CHECK CONSTRAINT [FK_EnrutamientoTblRutaSteps_EnrutamientoTblRutaStepsEjecucion_IDRutaStep]
GO
ALTER TABLE [Enrutamiento].[tblRutaStepsEjecucion]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatPosiciones_EnrutamientoTblRutaStepsEjecucion_IDPosicion] FOREIGN KEY([IDPosicion])
REFERENCES [RH].[tblCatPosiciones] ([IDPosicion])
GO
ALTER TABLE [Enrutamiento].[tblRutaStepsEjecucion] CHECK CONSTRAINT [FK_RHTblCatPosiciones_EnrutamientoTblRutaStepsEjecucion_IDPosicion]
GO
