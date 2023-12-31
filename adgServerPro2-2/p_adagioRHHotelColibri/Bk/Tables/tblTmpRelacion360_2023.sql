USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblTmpRelacion360_2023](
	[CLAVE] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[COLABORADOR] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PUESTO_COLABORADOR] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SUCURSAL_COLABORADOR] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NIVEL_EMPLEADO] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CLAVE_EVALUADOR] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RELACION] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[EVALUADOR] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PUESTO_EVALUADOR] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SUCURSAL_EVALUADOR] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RELACION_CORRECTO] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NIVEL_EVALUADOR] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
