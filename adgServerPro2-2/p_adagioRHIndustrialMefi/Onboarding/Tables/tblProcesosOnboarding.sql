USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Onboarding].[tblProcesosOnboarding](
	[IDProcesoOnboarding] [int] IDENTITY(1,1) NOT NULL,
	[NombreProceso] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDNuevoEmpleado] [int] NOT NULL,
	[IDsPlantilla] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEmpleadoEncargado] [int] NOT NULL,
	[Terminado] [bit] NULL,
 CONSTRAINT [PK_tblProcesosOnboarding] PRIMARY KEY CLUSTERED 
(
	[IDProcesoOnboarding] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
