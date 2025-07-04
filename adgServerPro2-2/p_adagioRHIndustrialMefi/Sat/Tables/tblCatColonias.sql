USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Sat].[tblCatColonias](
	[IDColonia] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDCodigoPostal] [int] NULL,
	[NombreAsentamiento] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
 CONSTRAINT [PK_tblCatColonias_IDColonia] PRIMARY KEY CLUSTERED 
(
	[IDColonia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_SatTblCatColonia_Codigo_IDCodigoPostal] UNIQUE NONCLUSTERED 
(
	[Codigo] ASC,
	[IDCodigoPostal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Sat].[tblCatColonias]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatCodigosPostales_IDCodigoPostal] FOREIGN KEY([IDCodigoPostal])
REFERENCES [Sat].[tblCatCodigosPostales] ([IDCodigoPostal])
GO
ALTER TABLE [Sat].[tblCatColonias] CHECK CONSTRAINT [FK_SatTblCatCodigosPostales_IDCodigoPostal]
GO
