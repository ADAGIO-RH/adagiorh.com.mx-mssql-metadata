USE [p_adagioRHAfosa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblTempAcumPTU](
	[Clave] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Nombre] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SueldoAcumulado] [decimal](18, 2) NULL
) ON [PRIMARY]
GO
