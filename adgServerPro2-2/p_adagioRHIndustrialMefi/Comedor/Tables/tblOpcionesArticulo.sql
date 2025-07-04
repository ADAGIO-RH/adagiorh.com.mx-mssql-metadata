USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Comedor].[tblOpcionesArticulo](
	[IDOpcionArticulo] [int] NOT NULL,
	[IDArticulo] [int] NOT NULL,
	[Nombre] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[PrecioExtra] [money] NULL,
	[Disponible] [bit] NULL,
 CONSTRAINT [Pk_ComedorTblOpcionesArticulo_IDOpcionArticuloIDArticulo] PRIMARY KEY CLUSTERED 
(
	[IDOpcionArticulo] ASC,
	[IDArticulo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Comedor].[tblOpcionesArticulo] ADD  CONSTRAINT [D_ComedorTblOpcionesArticulo_PrecioExtra]  DEFAULT ((0.00)) FOR [PrecioExtra]
GO
ALTER TABLE [Comedor].[tblOpcionesArticulo] ADD  CONSTRAINT [D_ComedorTblOpcionesArticulo_Disponible]  DEFAULT ((0)) FOR [Disponible]
GO
ALTER TABLE [Comedor].[tblOpcionesArticulo]  WITH CHECK ADD  CONSTRAINT [Fk_ComedorTblOpcionesArticulo_ComedorTblCatArticulo_IDArticulo] FOREIGN KEY([IDArticulo])
REFERENCES [Comedor].[tblCatArticulos] ([IDArticulo])
ON DELETE CASCADE
GO
ALTER TABLE [Comedor].[tblOpcionesArticulo] CHECK CONSTRAINT [Fk_ComedorTblOpcionesArticulo_ComedorTblCatArticulo_IDArticulo]
GO
