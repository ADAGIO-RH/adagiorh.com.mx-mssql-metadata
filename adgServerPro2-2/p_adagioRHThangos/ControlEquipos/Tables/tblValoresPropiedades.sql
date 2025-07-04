USE [p_adagioRHThangos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ControlEquipos].[tblValoresPropiedades](
	[IDValorPropiedad] [int] IDENTITY(1,1) NOT NULL,
	[IDPropiedad] [int] NOT NULL,
	[Valor] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDDetalleArticulo] [int] NULL,
 CONSTRAINT [PK_ControlEquiposTblValoresPropiedades_IDValorPropiedad] PRIMARY KEY CLUSTERED 
(
	[IDValorPropiedad] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_Propiedad_DetalleArticulo] UNIQUE NONCLUSTERED 
(
	[IDPropiedad] ASC,
	[IDDetalleArticulo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [ControlEquipos].[tblValoresPropiedades]  WITH CHECK ADD  CONSTRAINT [FK_ControlEquiposTblValoresPropiedades_ControlEquiposTblCatPropiedades_IDPropiedad] FOREIGN KEY([IDPropiedad])
REFERENCES [ControlEquipos].[tblCatPropiedades] ([IDPropiedad])
ON DELETE CASCADE
GO
ALTER TABLE [ControlEquipos].[tblValoresPropiedades] CHECK CONSTRAINT [FK_ControlEquiposTblValoresPropiedades_ControlEquiposTblCatPropiedades_IDPropiedad]
GO
ALTER TABLE [ControlEquipos].[tblValoresPropiedades]  WITH CHECK ADD  CONSTRAINT [Fk_ControlEquiposTblValoresPropiedades_ControlEquiposTblDetalleArticulos_IDDetalleArticulo] FOREIGN KEY([IDDetalleArticulo])
REFERENCES [ControlEquipos].[tblDetalleArticulos] ([IDDetalleArticulo])
ON DELETE CASCADE
GO
ALTER TABLE [ControlEquipos].[tblValoresPropiedades] CHECK CONSTRAINT [Fk_ControlEquiposTblValoresPropiedades_ControlEquiposTblDetalleArticulos_IDDetalleArticulo]
GO
