USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reclutamiento].[tblCandidatosProceso](
	[IDCandidatoProceso] [int] IDENTITY(1,1) NOT NULL,
	[IDCandidato] [int] NULL,
	[SueldoDeseado] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDPuestoPreasignado] [int] NULL,
	[SueldoPreasignado] [int] NULL,
	[IDEstatusProceso] [int] NULL,
	[IDPlaza] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[IDCandidatoProceso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
