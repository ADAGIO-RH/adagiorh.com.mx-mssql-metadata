USE [p_adagioRHOwen]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ControlEquipos].[tblEstatusArticulos](
	[IDEstatusArticulo] [int] IDENTITY(1,1) NOT NULL,
	[IDCatEstatusArticulo] [int] NOT NULL,
	[FechaHora] [datetime] NULL,
	[Empleados] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDUsuario] [int] NULL,
	[IDDetalleArticulo] [int] NULL,
	[Notas] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaADevolver] [datetime] NULL,
 CONSTRAINT [PK_ControlEquiposTblEstatusArticulos_IDArticulo] PRIMARY KEY CLUSTERED 
(
	[IDEstatusArticulo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [ControlEquipos].[tblEstatusArticulos]  WITH CHECK ADD  CONSTRAINT [FK_ControlEquiposTblEstatusArticulos_ControlEquipostblCatEstatusArticulos_IDCatEstatusArticulo] FOREIGN KEY([IDCatEstatusArticulo])
REFERENCES [ControlEquipos].[tblCatEstatusArticulos] ([IDCatEstatusArticulo])
GO
ALTER TABLE [ControlEquipos].[tblEstatusArticulos] CHECK CONSTRAINT [FK_ControlEquiposTblEstatusArticulos_ControlEquipostblCatEstatusArticulos_IDCatEstatusArticulo]
GO
ALTER TABLE [ControlEquipos].[tblEstatusArticulos]  WITH CHECK ADD  CONSTRAINT [FK_ControlEquiposTblEstatusArticulos_IDDetalleArticulo] FOREIGN KEY([IDDetalleArticulo])
REFERENCES [ControlEquipos].[tblDetalleArticulos] ([IDDetalleArticulo])
ON DELETE CASCADE
GO
ALTER TABLE [ControlEquipos].[tblEstatusArticulos] CHECK CONSTRAINT [FK_ControlEquiposTblEstatusArticulos_IDDetalleArticulo]
GO
ALTER TABLE [ControlEquipos].[tblEstatusArticulos]  WITH CHECK ADD  CONSTRAINT [Fk_ControlEquiposTblEstatusArticulos_SeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [ControlEquipos].[tblEstatusArticulos] CHECK CONSTRAINT [Fk_ControlEquiposTblEstatusArticulos_SeguridadTblUsuarios_IDUsuario]
GO
ALTER TABLE [ControlEquipos].[tblEstatusArticulos]  WITH NOCHECK ADD  CONSTRAINT [Chk_ControlEquiposTblEstatusArticulos_Empleados] CHECK  ((isjson([Empleados])>(0)))
GO
ALTER TABLE [ControlEquipos].[tblEstatusArticulos] CHECK CONSTRAINT [Chk_ControlEquiposTblEstatusArticulos_Empleados]
GO
