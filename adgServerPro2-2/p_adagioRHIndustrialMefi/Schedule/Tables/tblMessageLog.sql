USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Schedule].[tblMessageLog](
	[IDMessageLog] [int] IDENTITY(1,1) NOT NULL,
	[IDSchedule] [int] NOT NULL,
	[dest] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[msg] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[send] [int] NOT NULL,
	[date] [datetime] NOT NULL,
 CONSTRAINT [PK_ScheduleTblMessageLog_IDMessageLog] PRIMARY KEY CLUSTERED 
(
	[IDMessageLog] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Schedule].[tblMessageLog]  WITH CHECK ADD  CONSTRAINT [FK_ScheduletblSchedule_ScheduletblMessageLog_IDSchedule] FOREIGN KEY([IDSchedule])
REFERENCES [Schedule].[tblSchedule] ([IDSchedule])
GO
ALTER TABLE [Schedule].[tblMessageLog] CHECK CONSTRAINT [FK_ScheduletblSchedule_ScheduletblMessageLog_IDSchedule]
GO
