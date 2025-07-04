USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [zkteco].[tblStats](
	[IDStat] [int] IDENTITY(1,1) NOT NULL,
	[FechaHora] [datetime] NULL,
	[DevSN] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[LastRequestTime] [datetime] NULL,
	[Total] [int] NULL,
	[Orden] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[IDStat] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [zkteco].[tblStats] ADD  DEFAULT (getdate()) FOR [FechaHora]
GO
