USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblCatTiposFiltrosjunio2024](
	[Filtro] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[DOMElementID] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Orden] [int] NULL,
	[Prefijo] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY]
GO
