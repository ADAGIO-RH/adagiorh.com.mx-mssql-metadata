USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblDetalleCuadros9Box](
	[IDCuadro] [int] IDENTITY(1,1) NOT NULL,
	[NoCuadro] [int] NOT NULL,
	[Traduccion] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Coordenada_X_DE] [decimal](18, 2) NOT NULL,
	[Coordenada_X_A] [decimal](18, 2) NOT NULL,
	[Coordenada_Y_DE] [decimal](18, 2) NOT NULL,
	[Coordenada_Y_A] [decimal](18, 2) NOT NULL,
	[BackgroundColor] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Color] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDPlantilla] [int] NOT NULL,
 CONSTRAINT [Pk_Evaluacion360tblDetalleCuadros9Box_IDCuadro] PRIMARY KEY CLUSTERED 
(
	[IDCuadro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblDetalleCuadros9Box]  WITH CHECK ADD  CONSTRAINT [FK_Evaluacion360tblDetalleCuadros9Box_Evaluacion360tblCatPlantillas9Box_IDPlantilla] FOREIGN KEY([IDPlantilla])
REFERENCES [Evaluacion360].[tblCatPlantillas9Box] ([IDPlantilla])
GO
ALTER TABLE [Evaluacion360].[tblDetalleCuadros9Box] CHECK CONSTRAINT [FK_Evaluacion360tblDetalleCuadros9Box_Evaluacion360tblCatPlantillas9Box_IDPlantilla]
GO
ALTER TABLE [Evaluacion360].[tblDetalleCuadros9Box]  WITH CHECK ADD  CONSTRAINT [Chk_Evaluacion360tblDetalleCuadros9Box_Traduccion] CHECK  ((isjson([Traduccion])>(0)))
GO
ALTER TABLE [Evaluacion360].[tblDetalleCuadros9Box] CHECK CONSTRAINT [Chk_Evaluacion360tblDetalleCuadros9Box_Traduccion]
GO
