USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [InfoDir].[tblReclutamientoNormalizado](
	[FechaNormalizacion] [date] NULL,
	[IDCandidato] [int] NULL,
	[Candidato] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDPlaza] [int] NULL,
	[IDPuesto] [int] NULL,
	[Puesto] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDRequisitoPuesto] [int] NULL,
	[RequisitoPuesto] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDTipoCaracteristica] [int] NULL,
	[TipoCaracteristica] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ValorEsperado] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ResultadoCandidato] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Resultado] [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
