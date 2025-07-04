USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ControlEquipos].[tblCatPropiedades](
	[IDPropiedad] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoArticulo] [int] NOT NULL,
	[IDInputType] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Traduccion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Data] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Orden] [int] NULL,
 CONSTRAINT [Pk_ControlEquiposTblCatPropiedades_IDPropiedad] PRIMARY KEY CLUSTERED 
(
	[IDPropiedad] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [ControlEquipos].[tblCatPropiedades]  WITH CHECK ADD  CONSTRAINT [Fk_ControlEquiposTblCatPropiedades_AppTblCatInputsTypes_IDInputType] FOREIGN KEY([IDInputType])
REFERENCES [App].[tblCatInputsTypes] ([IDInputType])
GO
ALTER TABLE [ControlEquipos].[tblCatPropiedades] CHECK CONSTRAINT [Fk_ControlEquiposTblCatPropiedades_AppTblCatInputsTypes_IDInputType]
GO
ALTER TABLE [ControlEquipos].[tblCatPropiedades]  WITH CHECK ADD  CONSTRAINT [Fk_ControlEquiposTblCatPropiedades_ControlEquiposTblCatTiposArticulos_IDTipoArticulo] FOREIGN KEY([IDTipoArticulo])
REFERENCES [ControlEquipos].[tblCatTiposArticulos] ([IDTipoArticulo])
ON DELETE CASCADE
GO
ALTER TABLE [ControlEquipos].[tblCatPropiedades] CHECK CONSTRAINT [Fk_ControlEquiposTblCatPropiedades_ControlEquiposTblCatTiposArticulos_IDTipoArticulo]
GO
ALTER TABLE [ControlEquipos].[tblCatPropiedades]  WITH CHECK ADD  CONSTRAINT [Chk_ControlEquiposTblCatPropiedades_Traduccion] CHECK  ((isjson([Traduccion])>(0)))
GO
ALTER TABLE [ControlEquipos].[tblCatPropiedades] CHECK CONSTRAINT [Chk_ControlEquiposTblCatPropiedades_Traduccion]
GO
