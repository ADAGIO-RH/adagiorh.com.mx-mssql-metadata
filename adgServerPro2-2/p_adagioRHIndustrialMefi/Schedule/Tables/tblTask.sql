USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Schedule].[tblTask](
	[IDTask] [int] IDENTITY(1,1) NOT NULL,
	[IDScheduler] [int] NOT NULL,
	[IDTipoSchedule] [int] NOT NULL,
	[OneTimeDate] [date] NULL,
	[OneTimeTime] [time](7) NULL,
	[OcurrsFrecuency] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[RecursEveryDaily] [int] NOT NULL,
	[RecursEveryWeek] [int] NOT NULL,
	[WeekDays] [int] NOT NULL,
	[MonthlyType] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[MonthlyAbsoluteDayOfMonth] [int] NOT NULL,
	[MonthlyAbsoluteNumberOfMonths] [int] NOT NULL,
	[MonthlyRelativeDay] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[MonthlyRelativeDayOfWeek] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[MonthlyRelativeDayOfWeekShort] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[MonthlyRelativeNumberOfMonths] [int] NOT NULL,
	[FrecuencyType] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[DailyFrecuencyOnce] [time](7) NULL,
	[MultipleFrecuencyValues] [int] NOT NULL,
	[MultipleFrecuencyValueTypes] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[MultipleFrecuencyStartTime] [time](7) NULL,
	[MultipleFrecuencyEndTime] [time](7) NULL,
	[DurationStartDate] [date] NOT NULL,
	[DurationEndDate] [date] NOT NULL,
	[RunForever] [bit] NOT NULL,
	[LastRun] [datetime] NULL,
	[LastResult] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CounterPass] [int] NOT NULL,
	[CounterFail] [int] NOT NULL,
 CONSTRAINT [PK_ScheduleTblTareas_IDTask] PRIMARY KEY CLUSTERED 
(
	[IDTask] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Schedule].[tblTask] ADD  DEFAULT ((0)) FOR [CounterPass]
GO
ALTER TABLE [Schedule].[tblTask] ADD  DEFAULT ((0)) FOR [CounterFail]
GO
ALTER TABLE [Schedule].[tblTask]  WITH CHECK ADD  CONSTRAINT [FK_ApptblScheduler_AppTblTareas_IDScheduler] FOREIGN KEY([IDScheduler])
REFERENCES [Schedule].[tblSchedule] ([IDSchedule])
GO
ALTER TABLE [Schedule].[tblTask] CHECK CONSTRAINT [FK_ApptblScheduler_AppTblTareas_IDScheduler]
GO
ALTER TABLE [Schedule].[tblTask]  WITH CHECK ADD  CONSTRAINT [FK_ApptblTipoSchedule_ApptblTask_IDTipoSchedule] FOREIGN KEY([IDTipoSchedule])
REFERENCES [Schedule].[tblTipoSchedule] ([IDTipoSchedule])
GO
ALTER TABLE [Schedule].[tblTask] CHECK CONSTRAINT [FK_ApptblTipoSchedule_ApptblTask_IDTipoSchedule]
GO
