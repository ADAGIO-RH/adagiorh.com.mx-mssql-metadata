USE [p_adagioRHEdman]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reclutamiento].[tblCandidatos](
	[IDCandidato] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SegundoNombre] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Paterno] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Materno] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Sexo] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaNacimiento] [date] NULL,
	[IDPaisNacimiento] [int] NOT NULL,
	[IDEstadoNacimiento] [int] NOT NULL,
	[IDMunicipioNacimiento] [int] NOT NULL,
	[IDLocalidadNacimiento] [int] NOT NULL,
	[RFC] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CURP] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NSS] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDAFORE] [int] NULL,
	[IDEstadoCivil] [int] NULL,
	[Estatura] [decimal](10, 2) NULL,
	[Peso] [decimal](10, 2) NULL,
	[TipoSangre] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Extranjero] [bit] NULL,
	[Email] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Password] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEmpleado] [int] NULL,
 CONSTRAINT [PK__tblCandi__125B89DB37D769B5] PRIMARY KEY CLUSTERED 
(
	[IDCandidato] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Reclutamiento].[tblCandidatos]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpleados_ReclutamientoTblCandidatos_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Reclutamiento].[tblCandidatos] CHECK CONSTRAINT [FK_RHTblEmpleados_ReclutamientoTblCandidatos_IDEmpleado]
GO
