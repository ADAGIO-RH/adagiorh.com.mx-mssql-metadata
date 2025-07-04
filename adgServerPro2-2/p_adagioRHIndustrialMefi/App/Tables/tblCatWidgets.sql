USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblCatWidgets](
	[IDWidget] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDAplicacion] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Component] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Activo] [bit] NULL,
	[Orden] [int] NULL,
	[Nombre] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY]
GO
