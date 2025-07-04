USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Salud].[tblCuestionariosEmpleados](
	[IDCuestionarioEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDPruebaEmpleado] [int] NOT NULL,
	[FechaCreacion] [datetime] NULL,
	[IDUsuario] [int] NOT NULL,
	[ConfiguracioSemaforo] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Resultado] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_SaludtblCuestionariosEmpleados_IDPruebaEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDCuestionarioEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Salud].[tblCuestionariosEmpleados] ADD  CONSTRAINT [D_SaludtblCuestionariosEmpleados_FechaCreacion]  DEFAULT (getdate()) FOR [FechaCreacion]
GO
ALTER TABLE [Salud].[tblCuestionariosEmpleados]  WITH CHECK ADD  CONSTRAINT [Fk_SaludTblCuestionariosEmpleados_SeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Salud].[tblCuestionariosEmpleados] CHECK CONSTRAINT [Fk_SaludTblCuestionariosEmpleados_SeguridadTblUsuarios_IDUsuario]
GO
ALTER TABLE [Salud].[tblCuestionariosEmpleados]  WITH CHECK ADD  CONSTRAINT [FK_SaludTblPruebasEmpleados_SaludtblCuestionariosEmpleados_IDPruebaEmpleado] FOREIGN KEY([IDPruebaEmpleado])
REFERENCES [Salud].[tblPruebasEmpleados] ([IDPruebaEmpleado])
GO
ALTER TABLE [Salud].[tblCuestionariosEmpleados] CHECK CONSTRAINT [FK_SaludTblPruebasEmpleados_SaludtblCuestionariosEmpleados_IDPruebaEmpleado]
GO
