USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dashboard].[tblPermisosDepartamentos](
	[IDUsuario] [int] NOT NULL,
	[CodigoDepartamento] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY]
GO
