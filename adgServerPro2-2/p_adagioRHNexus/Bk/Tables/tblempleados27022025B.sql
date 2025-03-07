USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblempleados27022025B](
	[IDEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[ClaveEmpleado] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[RFC] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CURP] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IMSS] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Nombre] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SegundoNombre] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Paterno] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Materno] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDMunicipioNacimiento] [int] NULL,
	[IDEstadoNacimiento] [int] NULL,
	[IDPaisNacimiento] [int] NULL,
	[FechaNacimiento] [date] NULL,
	[IDEstadoCivil] [int] NULL,
	[Sexo] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEscolaridad] [int] NULL,
	[DescripcionEscolaridad] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaPrimerIngreso] [date] NULL,
	[FechaIngreso] [date] NULL,
	[FechaAntiguedad] [date] NULL,
	[Sindicalizado] [bit] NULL,
	[IDJornadaLaboral] [int] NULL,
	[UMF] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CuentaContable] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDPreferencia] [int] NULL,
	[Password] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDTipoRegimen] [int] NULL,
	[MunicipioNacimiento] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[EstadoNacimiento] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PaisNacimiento] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDInstitucion] [int] NULL,
	[IDProbatorio] [int] NULL,
	[IDAfore] [int] NULL,
	[IDLocalidadNacimiento] [int] NULL,
	[LocalidadNacimiento] [varchar](256) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PermiteChecar] [bit] NOT NULL,
	[RequiereChecar] [bit] NOT NULL,
	[PagarTiempoExtra] [bit] NOT NULL,
	[PagarPrimaDominical] [bit] NOT NULL,
	[PagarDescansoLaborado] [bit] NOT NULL,
	[PagarFestivoLaborado] [bit] NOT NULL,
	[DomicilioFiscal] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDRegimenFiscal] [int] NULL,
	[CodigoLector] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDTipoJornada] [int] NULL,
	[RequiereTransporte] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
