USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblCatTiposLayout_20241010](
	[IDTipoLayout] [int] IDENTITY(1,1) NOT NULL,
	[TipoLayout] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDBanco] [int] NULL,
	[IDConcepto] [int] NULL,
	[NombreProcedimiento] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
