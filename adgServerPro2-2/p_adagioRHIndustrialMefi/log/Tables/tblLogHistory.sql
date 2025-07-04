USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [log].[tblLogHistory](
	[IDLogHistory] [int] IDENTITY(1,1) NOT NULL,
	[LogLevel] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Mensaje] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDSource] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDCategory] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDAplicacion] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Url] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[HTMLElement] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Keywords] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Data] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDUsuario] [int] NOT NULL,
	[FechaHora] [datetime] NULL,
	[IDReferencia] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_log_tblLogHistory_IDLogHistory] PRIMARY KEY CLUSTERED 
(
	[IDLogHistory] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [log].[tblLogHistory] ADD  DEFAULT (getdate()) FOR [FechaHora]
GO
ALTER TABLE [log].[tblLogHistory]  WITH CHECK ADD  CONSTRAINT [FK_tblLogHistory_logtblCatCategories_IDCategory] FOREIGN KEY([IDCategory])
REFERENCES [log].[tblCatCategories] ([IDCategory])
GO
ALTER TABLE [log].[tblLogHistory] CHECK CONSTRAINT [FK_tblLogHistory_logtblCatCategories_IDCategory]
GO
ALTER TABLE [log].[tblLogHistory]  WITH CHECK ADD  CONSTRAINT [FK_tblLogHistory_logtblCatSources_IDSource] FOREIGN KEY([IDSource])
REFERENCES [log].[tblCatSources] ([IDSource])
GO
ALTER TABLE [log].[tblLogHistory] CHECK CONSTRAINT [FK_tblLogHistory_logtblCatSources_IDSource]
GO
ALTER TABLE [log].[tblLogHistory]  WITH CHECK ADD  CONSTRAINT [FK_tblLogHistory_SegurdadIDUsuario_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [log].[tblLogHistory] CHECK CONSTRAINT [FK_tblLogHistory_SegurdadIDUsuario_IDUsuario]
GO
