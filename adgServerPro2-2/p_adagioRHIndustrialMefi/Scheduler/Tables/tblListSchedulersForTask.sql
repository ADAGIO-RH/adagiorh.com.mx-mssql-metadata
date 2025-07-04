USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scheduler].[tblListSchedulersForTask](
	[IDListScheduleForTask] [int] IDENTITY(1,1) NOT NULL,
	[IDTask] [int] NOT NULL,
	[IDSchedule] [int] NOT NULL,
 CONSTRAINT [Pk_SchedulerTblListSchedulersForTask_IDListScheduleForTask] PRIMARY KEY CLUSTERED 
(
	[IDListScheduleForTask] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_SchedulerTblListSchedulersForTask_IDTaskIDSchedule] UNIQUE NONCLUSTERED 
(
	[IDTask] ASC,
	[IDSchedule] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Scheduler].[tblListSchedulersForTask]  WITH CHECK ADD  CONSTRAINT [Fk_SchedulerTblListSchedulersForTask_SchedulerTblSchedule_IDSchedule] FOREIGN KEY([IDSchedule])
REFERENCES [Scheduler].[tblSchedule] ([IDSchedule])
GO
ALTER TABLE [Scheduler].[tblListSchedulersForTask] CHECK CONSTRAINT [Fk_SchedulerTblListSchedulersForTask_SchedulerTblSchedule_IDSchedule]
GO
ALTER TABLE [Scheduler].[tblListSchedulersForTask]  WITH CHECK ADD  CONSTRAINT [Fk_SchedulerTblListSchedulersForTask_SchedulerTblTask_IDTask] FOREIGN KEY([IDTask])
REFERENCES [Scheduler].[tblTask] ([IDTask])
GO
ALTER TABLE [Scheduler].[tblListSchedulersForTask] CHECK CONSTRAINT [Fk_SchedulerTblListSchedulersForTask_SchedulerTblTask_IDTask]
GO
