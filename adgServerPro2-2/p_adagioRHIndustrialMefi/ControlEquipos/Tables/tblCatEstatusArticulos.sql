USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ControlEquipos].[tblCatEstatusArticulos](
	[IDCatEstatusArticulo] [int] NOT NULL,
	[Nombre] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Descripcion] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[OpcionArticuloNuevo] [bit] NULL,
 CONSTRAINT [PK_ControlEquiposTblCatEstatusArticulos_IDCatEstatusArticulo] PRIMARY KEY CLUSTERED 
(
	[IDCatEstatusArticulo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [ControlEquipos].[tblCatEstatusArticulos] ADD  CONSTRAINT [D_ControlEquiposTblCatEstatusArticulos_OpcionArticuloNuevo]  DEFAULT ((0)) FOR [OpcionArticuloNuevo]
GO
