USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Compensaciones].[tblMatrizIncremento](
	[IDMatrizIncremento] [int] IDENTITY(1,1) NOT NULL,
	[Fecha] [date] NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDEvaluacion] [int] NULL,
	[ValorInicial] [decimal](18, 4) NULL,
	[QtyNivelesAmplitud] [int] NULL,
	[ValorNivelesAmplitud] [decimal](18, 4) NULL,
	[ValorCentralAmplitud] [decimal](18, 4) NULL,
	[QtyNivelesProgresion] [int] NULL,
	[ValorNivelesProgresion] [decimal](18, 4) NULL,
	[Progresiva] [bit] NULL,
 CONSTRAINT [PK_CompensacionesTblMatrizIncremento_IDMatrizIncremento] PRIMARY KEY CLUSTERED 
(
	[IDMatrizIncremento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_CompensacionesTblMatrizIncremento_Fecha] UNIQUE NONCLUSTERED 
(
	[Fecha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Compensaciones].[tblMatrizIncremento] ADD  CONSTRAINT [d_CompensacionesTblMAtrizIncremento_Progresiva]  DEFAULT ((0)) FOR [Progresiva]
GO
