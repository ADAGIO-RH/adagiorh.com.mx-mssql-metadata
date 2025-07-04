USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Asistencia].[tblCatTiposLectores](
	[IDTipoLector] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[TipoLector] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [App].[MDDescription] NULL,
	[Activo] [bit] NULL,
	[Configuracion] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_AsistenciaTblCatTiposLectores_IDTipoLector] PRIMARY KEY CLUSTERED 
(
	[IDTipoLector] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Asistencia].[tblCatTiposLectores] ADD  CONSTRAINT [D_AsistenciaTblCatTiposLectores_Activo]  DEFAULT ((0)) FOR [Activo]
GO
ALTER TABLE [Asistencia].[tblCatTiposLectores]  WITH CHECK ADD  CONSTRAINT [Chk_AsistenciaTblCatTiposLectores_Configuracion_is_json] CHECK  ((isjson([Configuracion])>(0)))
GO
ALTER TABLE [Asistencia].[tblCatTiposLectores] CHECK CONSTRAINT [Chk_AsistenciaTblCatTiposLectores_Configuracion_is_json]
GO
