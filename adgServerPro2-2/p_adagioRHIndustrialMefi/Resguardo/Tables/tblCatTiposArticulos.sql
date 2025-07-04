USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Resguardo].[tblCatTiposArticulos](
	[IDTipoArticulo] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaHora] [datetime] NULL,
 CONSTRAINT [Pk_ResguardoTblCatTiposArticulos_IDTipoArticulo] PRIMARY KEY CLUSTERED 
(
	[IDTipoArticulo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Resguardo].[tblCatTiposArticulos] ADD  CONSTRAINT [D_ResguardoTblCatTiposArticulos_FechaHora]  DEFAULT (getdate()) FOR [FechaHora]
GO
