USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [IMSS].[tblCatRazonesMovAfiliatorios](
	[IDRazonMovimiento] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Alta] [bit] NULL,
	[Baja] [bit] NULL,
	[ReIngreso] [bit] NULL,
	[MovSueldo] [bit] NULL,
	[IDCatTipoRazonMovimiento] [int] NULL,
 CONSTRAINT [PK_tblCatRazonesMovAfiliatorios_IDRazonMovimiento] PRIMARY KEY CLUSTERED 
(
	[IDRazonMovimiento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_tblCatRazonesMovAfiliatorios_Codigo] UNIQUE NONCLUSTERED 
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [IMSS].[tblCatRazonesMovAfiliatorios]  WITH CHECK ADD  CONSTRAINT [FK_IMSStblCatTiposRazonesMovimientos_IMSSTblCatRazonesMovAfiliatorios_IDCatTipoRazonMovimiento] FOREIGN KEY([IDCatTipoRazonMovimiento])
REFERENCES [IMSS].[tblCatTiposRazonesMovimientos] ([IDCatTipoRazonMovimiento])
GO
ALTER TABLE [IMSS].[tblCatRazonesMovAfiliatorios] CHECK CONSTRAINT [FK_IMSStblCatTiposRazonesMovimientos_IMSSTblCatRazonesMovAfiliatorios_IDCatTipoRazonMovimiento]
GO
