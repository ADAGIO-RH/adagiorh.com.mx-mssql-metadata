USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Asistencia].[tblPrivilegiosUsuarioLectoresZK](
	[IDPrivilegioUsuarioLectorZK] [int] IDENTITY(1,1) NOT NULL,
	[IDLector] [int] NOT NULL,
	[IDTipoPrivilegioLectorZK] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[FechaReg] [datetime] NOT NULL,
 CONSTRAINT [Pk_AsistenciaTblPrivilegiosUsuariosLectoresZK_IDPrivilegioUsuarioLectoreZK] PRIMARY KEY CLUSTERED 
(
	[IDPrivilegioUsuarioLectorZK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_AsistenciaTblPrivilegiosUsuarioLectoresZK_IDEmpleado_IDCatPrivilegioUsuarioLectorZk] UNIQUE NONCLUSTERED 
(
	[IDEmpleado] ASC,
	[IDTipoPrivilegioLectorZK] ASC,
	[IDLector] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Asistencia].[tblPrivilegiosUsuarioLectoresZK] ADD  CONSTRAINT [D_AsistenciaTblPrivilegiosUsuarioLectoresZK_FechaReg]  DEFAULT (getdate()) FOR [FechaReg]
GO
ALTER TABLE [Asistencia].[tblPrivilegiosUsuarioLectoresZK]  WITH CHECK ADD  CONSTRAINT [Fk_AsistenciaTblPrivilegiosUsuariosLectoresZK_AsistenciaCatTiposPrivilegiosLectoresZK_IDTipoPrivilegioLectorZK] FOREIGN KEY([IDTipoPrivilegioLectorZK])
REFERENCES [Asistencia].[tblCatTiposPrivilegiosLectoresZK] ([IDTipoPrivilegioLectorZK])
GO
ALTER TABLE [Asistencia].[tblPrivilegiosUsuarioLectoresZK] CHECK CONSTRAINT [Fk_AsistenciaTblPrivilegiosUsuariosLectoresZK_AsistenciaCatTiposPrivilegiosLectoresZK_IDTipoPrivilegioLectorZK]
GO
ALTER TABLE [Asistencia].[tblPrivilegiosUsuarioLectoresZK]  WITH CHECK ADD  CONSTRAINT [Fk_AsistenciaTblPrivilegiosUsuariosLectoresZK_AsistenciaTblLectores_IDLectore] FOREIGN KEY([IDLector])
REFERENCES [Asistencia].[tblLectores] ([IDLector])
ON DELETE CASCADE
GO
ALTER TABLE [Asistencia].[tblPrivilegiosUsuarioLectoresZK] CHECK CONSTRAINT [Fk_AsistenciaTblPrivilegiosUsuariosLectoresZK_AsistenciaTblLectores_IDLectore]
GO
ALTER TABLE [Asistencia].[tblPrivilegiosUsuarioLectoresZK]  WITH CHECK ADD  CONSTRAINT [Fk_AsistenciaTblPrivilegiosUsuariosLectoresZK_RHTblEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
ON DELETE CASCADE
GO
ALTER TABLE [Asistencia].[tblPrivilegiosUsuarioLectoresZK] CHECK CONSTRAINT [Fk_AsistenciaTblPrivilegiosUsuariosLectoresZK_RHTblEmpleados_IDEmpleado]
GO
