USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Norma35].[tblCatEstatusDenuncia](
	[IDEstatusDenuncia] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[EstatusColor] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[EstatusBackground] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_Norma35tblCatEstatusDenuncia_IDEstatusDenuncia] PRIMARY KEY CLUSTERED 
(
	[IDEstatusDenuncia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
