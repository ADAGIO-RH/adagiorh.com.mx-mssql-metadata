USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblCatBrigadas](
	[IDBrigada] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Traduccion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_RHTblCatBrigadas_IDBrigada] PRIMARY KEY CLUSTERED 
(
	[IDBrigada] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [RH].[tblCatBrigadas]  WITH CHECK ADD  CONSTRAINT [Chk_RHTblCatBrigadas_Traduccion] CHECK  ((isjson([Traduccion])>(0)))
GO
ALTER TABLE [RH].[tblCatBrigadas] CHECK CONSTRAINT [Chk_RHTblCatBrigadas_Traduccion]
GO
