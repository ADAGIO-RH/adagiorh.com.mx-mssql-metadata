USE [p_adagioRHSakata]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblSaldosVacacionesConRefactor](
	[CLAVE] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NOMBRE] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DEPARTAMENTO] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SUCURSAL] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PUESTO] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DIVISION] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TIPO PRESTACIÓN] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FECHA_DE_ANTIGUEDAD] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ANTIGUEDAD_AÑOS] [int] NULL,
	[VACACIONES_AÑO_ACTUAL] [decimal](18, 2) NULL,
	[VACACIONES_GENERADAS] [decimal](38, 2) NULL,
	[DIAS_TOMADOS] [decimal](38, 2) NULL,
	[DIAS_VENCIDOS] [decimal](38, 2) NULL,
	[VACACIONES_DISPONIBLES] [decimal](38, 2) NULL,
	[ERRORES] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY]
GO
