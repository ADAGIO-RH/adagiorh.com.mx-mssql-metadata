USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scheduler].[tblTask](
	[IDTask] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[StoreProcedure] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[interval] [int] NOT NULL,
	[active] [bit] NOT NULL,
	[IDTipoAccion] [int] NOT NULL,
	[JsonConfig] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_SchedulerTblTask_IDTask] PRIMARY KEY CLUSTERED 
(
	[IDTask] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Scheduler].[tblTask]  WITH CHECK ADD  CONSTRAINT [FK_SchedulerTblCatTipoAcciones_SchedulerTblTask_IDTipoAccion] FOREIGN KEY([IDTipoAccion])
REFERENCES [Scheduler].[tblCatTipoAcciones] ([IDTipoAccion])
GO
ALTER TABLE [Scheduler].[tblTask] CHECK CONSTRAINT [FK_SchedulerTblCatTipoAcciones_SchedulerTblTask_IDTipoAccion]
GO
