USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblcatTiposAvisosInfonavit](
	[IDTipoAvisoInfonavit] [int] NOT NULL,
	[Codigo] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Clasificacion] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Descripcion] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_RHtblcatTiposAvisosInfonavit_IDTipoAvisoInfonavit] PRIMARY KEY CLUSTERED 
(
	[IDTipoAvisoInfonavit] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
