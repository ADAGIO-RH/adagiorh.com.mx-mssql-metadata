USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblAdministradoresProyecto](
	[IDAdministradorProyecto] [int] IDENTITY(1,1) NOT NULL,
	[IDProyecto] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[FechaHoraReg] [datetime] NULL,
	[CreadoPorIDUsuario] [int] NULL,
 CONSTRAINT [Pk_Evaluacion360TblAdministradoresProyecto_IDAdministradorProyecto] PRIMARY KEY CLUSTERED 
(
	[IDAdministradorProyecto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_Evaluacion360TblAdministradoresProyecto_IDProyectoIDUsuario] UNIQUE NONCLUSTERED 
(
	[IDProyecto] ASC,
	[IDUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblAdministradoresProyecto] ADD  CONSTRAINT [D_Evaluacion360TblAdministradoresProyecto_FechaHoraReg]  DEFAULT (getdate()) FOR [FechaHoraReg]
GO
ALTER TABLE [Evaluacion360].[tblAdministradoresProyecto]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblAdministradoresProyecto_CreadoPorIDUsuario] FOREIGN KEY([CreadoPorIDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
ON DELETE CASCADE
GO
ALTER TABLE [Evaluacion360].[tblAdministradoresProyecto] CHECK CONSTRAINT [Fk_Evaluacion360TblAdministradoresProyecto_CreadoPorIDUsuario]
GO
