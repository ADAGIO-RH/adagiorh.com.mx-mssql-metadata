USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblDatosExtraEmpleados_2025_01_09](
	[IDDatoExtraEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDDatoExtra] [int] NOT NULL,
	[Valor] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEmpleado] [int] NOT NULL
) ON [PRIMARY]
GO
