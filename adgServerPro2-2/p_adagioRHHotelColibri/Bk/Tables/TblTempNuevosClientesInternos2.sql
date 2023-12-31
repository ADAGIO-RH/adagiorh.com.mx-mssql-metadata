USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[TblTempNuevosClientesInternos2](
	[UDN] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NOMBRE] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DEPARTAMENTO] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PUESTO] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[UDN_EVALUADOR] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[EVALUADOR] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEmpleado] [int] NULL,
	[IDEvaluador] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
