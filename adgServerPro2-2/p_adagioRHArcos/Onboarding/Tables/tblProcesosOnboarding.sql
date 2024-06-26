USE [p_adagioRHArcos]
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
	[Terminado] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
