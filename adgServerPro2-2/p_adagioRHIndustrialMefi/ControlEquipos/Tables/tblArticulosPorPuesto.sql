USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ControlEquipos].[tblArticulosPorPuesto](
	[IDArticulosPorPuesto] [int] IDENTITY(1,1) NOT NULL,
	[IDPuesto] [int] NOT NULL,
	[IDArticulo] [int] NOT NULL,
	[FechaHora] [datetime] NOT NULL,
	[Cantidad] [int] NULL,
 CONSTRAINT [Pk_ControlEquiposTblArticulosPorPuesto_IDArticulosPorPuesto] PRIMARY KEY CLUSTERED 
(
	[IDArticulosPorPuesto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_ControlEquiposTblArticulosPorPuesto_IDPuesto_IDArticulo] UNIQUE NONCLUSTERED 
(
	[IDPuesto] ASC,
	[IDArticulo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [ControlEquipos].[tblArticulosPorPuesto] ADD  CONSTRAINT [D_ControlEquiposTblArticulosPorPuesto_FechaHora]  DEFAULT (getdate()) FOR [FechaHora]
GO
ALTER TABLE [ControlEquipos].[tblArticulosPorPuesto]  WITH CHECK ADD  CONSTRAINT [Fk_ControlEquiposTblArticulosPorPuesto_ControlEquiposTblArticulos_IDArticulo] FOREIGN KEY([IDArticulo])
REFERENCES [ControlEquipos].[tblArticulos] ([IDArticulo])
ON DELETE CASCADE
GO
ALTER TABLE [ControlEquipos].[tblArticulosPorPuesto] CHECK CONSTRAINT [Fk_ControlEquiposTblArticulosPorPuesto_ControlEquiposTblArticulos_IDArticulo]
GO
ALTER TABLE [ControlEquipos].[tblArticulosPorPuesto]  WITH CHECK ADD  CONSTRAINT [Fk_ControlEquiposTblArticulosPorPuesto_RHTblCatPuestos_IDPuesto] FOREIGN KEY([IDPuesto])
REFERENCES [RH].[tblCatPuestos] ([IDPuesto])
ON DELETE CASCADE
GO
ALTER TABLE [ControlEquipos].[tblArticulosPorPuesto] CHECK CONSTRAINT [Fk_ControlEquiposTblArticulosPorPuesto_RHTblCatPuestos_IDPuesto]
GO
