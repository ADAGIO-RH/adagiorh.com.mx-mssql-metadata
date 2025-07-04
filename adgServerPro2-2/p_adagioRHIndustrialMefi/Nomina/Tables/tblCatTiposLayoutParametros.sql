USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblCatTiposLayoutParametros](
	[IDTipoLayoutParametro] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoLayout] [int] NOT NULL,
	[Parametro] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
 CONSTRAINT [PK_NominaTblCatTipoLayoutParametros_IDTipoLayoutParametros] PRIMARY KEY CLUSTERED 
(
	[IDTipoLayoutParametro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblCatTiposLayoutParametros_IDTipoLayout] ON [Nomina].[tblCatTiposLayoutParametros]
(
	[IDTipoLayout] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblCatTiposLayoutParametros]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblCatTipoLayout_IDTipoLayout] FOREIGN KEY([IDTipoLayout])
REFERENCES [Nomina].[tblCatTiposLayout] ([IDTipoLayout])
GO
ALTER TABLE [Nomina].[tblCatTiposLayoutParametros] CHECK CONSTRAINT [FK_NominaTblCatTipoLayout_IDTipoLayout]
GO
