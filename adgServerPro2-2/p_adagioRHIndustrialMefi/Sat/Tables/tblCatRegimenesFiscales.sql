USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Sat].[tblCatRegimenesFiscales](
	[IDRegimenFiscal] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[PersonaFisica] [bit] NOT NULL,
	[PersonaMoral] [bit] NOT NULL,
 CONSTRAINT [PK_tblCatRegimenesFiscales_IDRegimenFiscal] PRIMARY KEY CLUSTERED 
(
	[IDRegimenFiscal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_TblCatRegimenFiscal_Codigo] UNIQUE NONCLUSTERED 
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Sat].[tblCatRegimenesFiscales] ADD  CONSTRAINT [d_tblCatRegimenFiscal_PersonaFisica]  DEFAULT ((0)) FOR [PersonaFisica]
GO
ALTER TABLE [Sat].[tblCatRegimenesFiscales] ADD  CONSTRAINT [d_tblCatRegimenFiscal_PersonaMoral]  DEFAULT ((0)) FOR [PersonaMoral]
GO
