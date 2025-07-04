USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Asistencia].[tblUsuariosZK](
	[IDUsuarioZK] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDLector] [int] NOT NULL,
	[EnrollNumber] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[NombreUsuario] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Password] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NumeroTarjeta] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Grupo] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TimeZone] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Privilegio] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_AsistenciaTblUsuariosZK_IDUsuarioZK] PRIMARY KEY CLUSTERED 
(
	[IDUsuarioZK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Asistencia].[tblUsuariosZK]  WITH CHECK ADD  CONSTRAINT [FK_AsistenciaTblLectores_AsistenciaTtblUsuariosZK_IDLector] FOREIGN KEY([IDLector])
REFERENCES [Asistencia].[tblLectores] ([IDLector])
GO
ALTER TABLE [Asistencia].[tblUsuariosZK] CHECK CONSTRAINT [FK_AsistenciaTblLectores_AsistenciaTtblUsuariosZK_IDLector]
GO
ALTER TABLE [Asistencia].[tblUsuariosZK]  WITH CHECK ADD  CONSTRAINT [FK_RHtblEmpleados_AsistenciaTtblUsuariosZK_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Asistencia].[tblUsuariosZK] CHECK CONSTRAINT [FK_RHtblEmpleados_AsistenciaTtblUsuariosZK_IDEmpleado]
GO
