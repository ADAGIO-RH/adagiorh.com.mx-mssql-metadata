USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Enrutamiento].[tblRutaStepsAutorizacion](
	[IDRutaStepsAutorizacion] [int] IDENTITY(1,1) NOT NULL,
	[IDRutaStep] [int] NOT NULL,
	[IDPosicion] [int] NULL,
	[IDUsuario] [int] NULL,
	[Orden] [int] NOT NULL,
 CONSTRAINT [PK_EnrutamientotblRutaStepsAutorizacion_IDRutaStepsAutorizacion] PRIMARY KEY CLUSTERED 
(
	[IDRutaStepsAutorizacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Enrutamiento].[tblRutaStepsAutorizacion] ADD  DEFAULT ((0)) FOR [Orden]
GO
ALTER TABLE [Enrutamiento].[tblRutaStepsAutorizacion]  WITH CHECK ADD  CONSTRAINT [FK_EnrutamientotblRutaSteps_EnrutamientotblRutaStepsAutorizacion_IDRutaStep] FOREIGN KEY([IDRutaStep])
REFERENCES [Enrutamiento].[tblRutaSteps] ([IDRutaStep])
ON DELETE CASCADE
GO
ALTER TABLE [Enrutamiento].[tblRutaStepsAutorizacion] CHECK CONSTRAINT [FK_EnrutamientotblRutaSteps_EnrutamientotblRutaStepsAutorizacion_IDRutaStep]
GO
