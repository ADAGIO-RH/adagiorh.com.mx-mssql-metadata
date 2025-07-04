USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblUbicacionesEmpleados](
	[IDUbicacionEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDUbicacion] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblUbicacionesEmpleados]  WITH CHECK ADD  CONSTRAINT [FK_RHTblUbicacionesEmpleados_RHTblCatUbicaciones_IDUbicacion] FOREIGN KEY([IDUbicacion])
REFERENCES [RH].[tblCatUbicaciones] ([IDUbicacion])
ON DELETE CASCADE
GO
ALTER TABLE [RH].[tblUbicacionesEmpleados] CHECK CONSTRAINT [FK_RHTblUbicacionesEmpleados_RHTblCatUbicaciones_IDUbicacion]
GO
