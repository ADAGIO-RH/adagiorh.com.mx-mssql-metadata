USE [p_adagioRHAfosa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblPTU24ENERO2024](
	[IDPTU] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpresa] [int] NOT NULL,
	[Ejercicio] [int] NOT NULL,
	[ConceptosIntegranSueldo] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[DiasDescontar] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DescontarIncapacidades] [bit] NULL,
	[TiposIncapacidadesADescontar] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CantidadGanancia] [decimal](18, 2) NULL,
	[CantidadRepartir] [decimal](18, 2) NULL,
	[CantidadPendiente] [decimal](18, 2) NULL,
	[DiasMinimosTrabajados] [int] NULL,
	[EjercicioPago] [int] NOT NULL,
	[IDPeriodo] [int] NULL,
	[MontoSueldo] [decimal](18, 2) NULL,
	[MontoDias] [decimal](18, 2) NULL,
	[FactorSueldo] [decimal](18, 9) NULL,
	[FactorDias] [decimal](18, 9) NULL,
	[IDEmpleadoTipoSalarioMensualConfianza] [int] NULL,
	[TopeSalarioMensualConfianza] [decimal](18, 2) NULL,
	[TopeConfianza] [decimal](18, 2) NULL,
	[AplicarReforma] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
