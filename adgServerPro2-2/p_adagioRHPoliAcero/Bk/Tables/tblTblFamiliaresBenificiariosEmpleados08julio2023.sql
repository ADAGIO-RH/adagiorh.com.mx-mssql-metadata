USE [p_adagioRHPoliAcero]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblTblFamiliaresBenificiariosEmpleados08julio2023](
	[IDFamiliarBenificiarioEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDParentesco] [int] NOT NULL,
	[NombreCompleto] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[FechaNacimiento] [date] NULL,
	[Sexo] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TelefonoMovil] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TelefonoCelular] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Emergencia] [bit] NULL,
	[Beneficiario] [bit] NULL,
	[Dependiente] [bit] NULL,
	[Porcentaje] [decimal](5, 2) NULL
) ON [PRIMARY]
GO
