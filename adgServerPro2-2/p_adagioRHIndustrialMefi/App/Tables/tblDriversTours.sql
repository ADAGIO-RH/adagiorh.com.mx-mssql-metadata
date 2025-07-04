USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblDriversTours](
	[IDDriverTour] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Type] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDAplicacion] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Url] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[JSONConfiguration] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Active] [bit] NOT NULL,
 CONSTRAINT [Pk_AppTblDriversTours_IDDriverTour] PRIMARY KEY CLUSTERED 
(
	[IDDriverTour] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_AppTblDriversTours_IDAplicacionUrl] UNIQUE NONCLUSTERED 
(
	[IDAplicacion] ASC,
	[Url] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [App].[tblDriversTours] ADD  CONSTRAINT [D_AppTblDriversTours_Active]  DEFAULT ((1)) FOR [Active]
GO
ALTER TABLE [App].[tblDriversTours]  WITH CHECK ADD  CONSTRAINT [Fk_AppTblDriversTours_AppTblCatAplicaciones_IDAplicacion] FOREIGN KEY([IDAplicacion])
REFERENCES [App].[tblCatAplicaciones] ([IDAplicacion])
GO
ALTER TABLE [App].[tblDriversTours] CHECK CONSTRAINT [Fk_AppTblDriversTours_AppTblCatAplicaciones_IDAplicacion]
GO
