USE [p_adagioRHSakata]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblVacaciones](
	[ClaveEmpleado] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Nombre] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Fecha de Ingreso] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Hoy] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Antigüedad] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Entero] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Aniversario2223] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Días  de Vacaciones2223] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Vencimiento2223] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Saldo2122] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Vencimiento2122] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Vacaciones Disftrutadas] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Saldo] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Proporcional de Días2223] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Total de Días] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SaldoAdagioRH] [int] NULL,
	[SaldoAdagioRHProporcional] [float] NULL,
	[ID] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
