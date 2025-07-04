USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblConfiguracionNomina](
	[Configuracion] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Valor] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[TipoDato] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDConfiguracionNomina] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [Pk_NominaTblConfiguracionNomina_Configuracion] PRIMARY KEY CLUSTERED 
(
	[Configuracion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
