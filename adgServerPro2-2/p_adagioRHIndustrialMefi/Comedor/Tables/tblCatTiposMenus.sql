USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Comedor].[tblCatTiposMenus](
	[IDTipoMenu] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[HoraDisponibilidadInicio] [time](7) NULL,
	[HoraDisponibilidadFin] [time](7) NULL,
	[Disponible] [bit] NULL,
	[FechaHora] [datetime] NULL,
 CONSTRAINT [Pk_ComedorTblCatTiposMenus_IDTipoMenu] PRIMARY KEY CLUSTERED 
(
	[IDTipoMenu] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Comedor].[tblCatTiposMenus] ADD  CONSTRAINT [D_ComedorTblCatTiposMenus_HoraDisponibilidadInicio]  DEFAULT ('00:00') FOR [HoraDisponibilidadInicio]
GO
ALTER TABLE [Comedor].[tblCatTiposMenus] ADD  CONSTRAINT [D_ComedorTblCatTiposMenus_HoraDisponibilidadFin]  DEFAULT ('00:00') FOR [HoraDisponibilidadFin]
GO
ALTER TABLE [Comedor].[tblCatTiposMenus] ADD  CONSTRAINT [D_ComedorTblCatTiposMenus_Disponible]  DEFAULT ((0)) FOR [Disponible]
GO
ALTER TABLE [Comedor].[tblCatTiposMenus] ADD  CONSTRAINT [D_ComedorTblCatTiposMenus_FechaHora]  DEFAULT (getdate()) FOR [FechaHora]
GO
