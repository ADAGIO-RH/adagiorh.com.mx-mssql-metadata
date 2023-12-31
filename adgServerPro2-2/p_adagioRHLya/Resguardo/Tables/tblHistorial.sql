USE [p_adagioRHLya]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Resguardo].[tblHistorial](
	[IDHistorial] [int] IDENTITY(1,1) NOT NULL,
	[IDLocker] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDArticulo] [int] NOT NULL,
	[FechaRecibe] [datetime] NULL,
	[FechaEntrega] [datetime] NULL,
	[Entregado] [bit] NULL,
	[IDUsuarioRecibe] [int] NULL,
	[IDUsuarioEntrega] [int] NULL,
 CONSTRAINT [Pk_ResguardoTblHistorial_IDHistorial] PRIMARY KEY CLUSTERED 
(
	[IDHistorial] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Resguardo].[tblHistorial]  WITH NOCHECK ADD  CONSTRAINT [Fk_ResguardoTblHistorial_ResguardoTblArticulos_IDArticulo] FOREIGN KEY([IDArticulo])
REFERENCES [Resguardo].[tblArticulos] ([IDArticulo])
GO
ALTER TABLE [Resguardo].[tblHistorial] CHECK CONSTRAINT [Fk_ResguardoTblHistorial_ResguardoTblArticulos_IDArticulo]
GO
ALTER TABLE [Resguardo].[tblHistorial]  WITH NOCHECK ADD  CONSTRAINT [Fk_ResguardoTblHistorial_ResguardoTblCatLockers_IDLocker] FOREIGN KEY([IDLocker])
REFERENCES [Resguardo].[tblCatLockers] ([IDLocker])
GO
ALTER TABLE [Resguardo].[tblHistorial] CHECK CONSTRAINT [Fk_ResguardoTblHistorial_ResguardoTblCatLockers_IDLocker]
GO
ALTER TABLE [Resguardo].[tblHistorial]  WITH NOCHECK ADD  CONSTRAINT [Fk_ResguardoTblHistorial_RHTblEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Resguardo].[tblHistorial] CHECK CONSTRAINT [Fk_ResguardoTblHistorial_RHTblEmpleados_IDEmpleado]
GO
