USE [p_adagioRHAfosa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tempDataEmpleadosPTU](
	[IDEmpleado] [int] NULL,
	[ClaveEmpleado] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NOMBRECOMPLETO] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Departamento] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Sucursal] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Puesto] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SalarioDiario] [decimal](18, 2) NULL,
	[Empresa] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaAlta] [date] NULL,
	[FechaBaja] [date] NULL,
	[FechaReingreso] [date] NULL,
	[FechaIni] [date] NOT NULL,
	[FechaFin] [date] NOT NULL,
	[FechaInicioHistoria] [date] NULL,
	[FechaFinHistoria] [date] NULL,
	[IDTipoPrestacion] [int] NULL,
	[TipoPrestacion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Sindical] [bit] NULL,
	[Salario] [decimal](38, 2) NULL
) ON [PRIMARY]
GO
