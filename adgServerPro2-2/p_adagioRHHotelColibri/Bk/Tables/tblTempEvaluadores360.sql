USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblTempEvaluadores360](
	[SUCURSAL COLABORADOR] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CLAVE EMPLEADO] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[COLABORADOR] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PUESTO COLABORADOR] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NIVEL EMPLEADO] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CLAVE EVALUADOR] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[EVALUADOR] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PUESTO EVALUADOR] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RELACIÓN DEL EVALUADOR] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RELACIÓN CORRECTO] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NIVEL EVALUADOR] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
