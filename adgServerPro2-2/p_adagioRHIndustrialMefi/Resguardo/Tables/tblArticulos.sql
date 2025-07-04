USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Resguardo].[tblArticulos](
	[IDArticulo] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoArticulo] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
 CONSTRAINT [Pk_ResguardoTblArticulos_IDArticulo] PRIMARY KEY CLUSTERED 
(
	[IDArticulo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Resguardo].[tblArticulos]  WITH CHECK ADD  CONSTRAINT [Fk_ResguardoTblArticulos_ResguardoTblCatTiposArticulos_IDTipoArticulo] FOREIGN KEY([IDTipoArticulo])
REFERENCES [Resguardo].[tblCatTiposArticulos] ([IDTipoArticulo])
ON DELETE CASCADE
GO
ALTER TABLE [Resguardo].[tblArticulos] CHECK CONSTRAINT [Fk_ResguardoTblArticulos_ResguardoTblCatTiposArticulos_IDTipoArticulo]
GO
ALTER TABLE [Resguardo].[tblArticulos]  WITH CHECK ADD  CONSTRAINT [Fk_ResguardoTblArticulosRHTblEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
ON DELETE CASCADE
GO
ALTER TABLE [Resguardo].[tblArticulos] CHECK CONSTRAINT [Fk_ResguardoTblArticulosRHTblEmpleados_IDEmpleado]
GO
