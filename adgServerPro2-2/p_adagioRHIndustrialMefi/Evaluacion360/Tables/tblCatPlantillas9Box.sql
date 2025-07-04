USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblCatPlantillas9Box](
	[IDPlantilla] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[EjeX] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[EjeY] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IsDefault] [bit] NOT NULL,
 CONSTRAINT [Pk_Evaluacion360tblCatPlantillas9Box_IDPlantilla] PRIMARY KEY CLUSTERED 
(
	[IDPlantilla] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblCatPlantillas9Box]  WITH CHECK ADD  CONSTRAINT [Chk_Evaluacion360tblCatPlantillas9Box_EjeX] CHECK  ((isjson([EjeX])>(0)))
GO
ALTER TABLE [Evaluacion360].[tblCatPlantillas9Box] CHECK CONSTRAINT [Chk_Evaluacion360tblCatPlantillas9Box_EjeX]
GO
ALTER TABLE [Evaluacion360].[tblCatPlantillas9Box]  WITH CHECK ADD  CONSTRAINT [Chk_Evaluacion360tblCatPlantillas9Box_EjeY] CHECK  ((isjson([EjeY])>(0)))
GO
ALTER TABLE [Evaluacion360].[tblCatPlantillas9Box] CHECK CONSTRAINT [Chk_Evaluacion360tblCatPlantillas9Box_EjeY]
GO
