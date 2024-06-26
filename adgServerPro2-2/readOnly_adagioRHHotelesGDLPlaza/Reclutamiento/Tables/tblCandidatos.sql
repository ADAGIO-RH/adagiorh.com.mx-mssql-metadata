USE [readOnly_adagioRHHotelesGDLPlaza]
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
	[IDAFORE] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEstadoCivil] [int] NULL,
	[Estatura] [decimal](10, 2) NULL,
	[Peso] [decimal](10, 2) NULL,
	[TipoSangre] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Extranjero] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[IDCandidato] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
