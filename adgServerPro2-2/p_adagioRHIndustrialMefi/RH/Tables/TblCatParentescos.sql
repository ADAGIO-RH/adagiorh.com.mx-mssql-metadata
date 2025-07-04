USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[TblCatParentescos](
	[IDParentesco] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Traduccion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_RHTblCatParentescos_IDParentesco] PRIMARY KEY CLUSTERED 
(
	[IDParentesco] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [RH].[TblCatParentescos]  WITH CHECK ADD  CONSTRAINT [Chk_RHTblCatParentescos_Traduccion] CHECK  ((isjson([Traduccion])>(0)))
GO
ALTER TABLE [RH].[TblCatParentescos] CHECK CONSTRAINT [Chk_RHTblCatParentescos_Traduccion]
GO
