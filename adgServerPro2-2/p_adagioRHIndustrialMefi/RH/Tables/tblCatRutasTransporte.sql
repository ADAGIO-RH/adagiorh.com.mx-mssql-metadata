USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblCatRutasTransporte](
	[IDRuta] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Traduccion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_RHTblCatRutasTransporte_IDRuta] PRIMARY KEY CLUSTERED 
(
	[IDRuta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [RH].[tblCatRutasTransporte]  WITH CHECK ADD  CONSTRAINT [Chk_RHTblCatRutasTransporte_Traduccion] CHECK  ((isjson([Traduccion])>(0)))
GO
ALTER TABLE [RH].[tblCatRutasTransporte] CHECK CONSTRAINT [Chk_RHTblCatRutasTransporte_Traduccion]
GO
