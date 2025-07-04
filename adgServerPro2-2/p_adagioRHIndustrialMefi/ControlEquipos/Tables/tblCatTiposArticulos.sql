USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ControlEquipos].[tblCatTiposArticulos](
	[IDTipoArticulo] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Etiquetar] [bit] NOT NULL,
	[PrefijoEtiqueta] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[LongitudEtiqueta] [int] NOT NULL,
	[Traduccion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDCatEstatusTipoArticulo] [int] NULL,
 CONSTRAINT [PK_ControlEquiposTblCatTiposArticulos_IDTipoArticulo] PRIMARY KEY CLUSTERED 
(
	[IDTipoArticulo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_ControlEquiposTblCatTiposArticulos_PrefijoEtiqueta] ON [ControlEquipos].[tblCatTiposArticulos]
(
	[PrefijoEtiqueta] ASC
)
WHERE ([PrefijoEtiqueta] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [ControlEquipos].[tblCatTiposArticulos] ADD  CONSTRAINT [D_ControlEquiposTblCatTiposArticulos_Etiquetar]  DEFAULT ((1)) FOR [Etiquetar]
GO
ALTER TABLE [ControlEquipos].[tblCatTiposArticulos] ADD  CONSTRAINT [D_ControlEquiposTblCatTiposArticulos_LongitudEtiqueta]  DEFAULT ((0)) FOR [LongitudEtiqueta]
GO
ALTER TABLE [ControlEquipos].[tblCatTiposArticulos]  WITH CHECK ADD  CONSTRAINT [Fk_ControlEquiposTblCatTiposArticulos_ControlEquiposTblCatEstatusTiposArticulos_IDCatEstatusTipoArticulo] FOREIGN KEY([IDCatEstatusTipoArticulo])
REFERENCES [ControlEquipos].[tblCatEstatusTiposArticulos] ([IDCatEstatusTipoArticulo])
GO
ALTER TABLE [ControlEquipos].[tblCatTiposArticulos] CHECK CONSTRAINT [Fk_ControlEquiposTblCatTiposArticulos_ControlEquiposTblCatEstatusTiposArticulos_IDCatEstatusTipoArticulo]
GO
