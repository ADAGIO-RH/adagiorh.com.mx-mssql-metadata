USE [p_adagioRHLya]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Norma035].[tblEncuestaEmpleado](
	[IDEncuestaEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NULL,
	[IDEncuesta] [int] NULL,
	[Fecha] [datetime] NULL,
	[Estatus] [int] NULL,
	[NivelRiesgo] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Resultado] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_Norma035TblEncuestaEmpleado_tblEncuestaEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDEncuestaEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
