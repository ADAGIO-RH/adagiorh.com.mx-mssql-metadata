USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [zkteco].[tblTempDeviceCmds](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DevSN] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Template] [varchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[CreatedAt] [datetime] NULL,
	[ExecutedAt] [datetime] NULL,
	[Executed] [bit] NULL,
	[Content] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[BioDataTemplate] [text] COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_zktecoTblTempDeviceCmds_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_TblTempDeviceCmds_DevSN_Executed] ON [zkteco].[tblTempDeviceCmds]
(
	[DevSN] ASC
)
INCLUDE([Executed]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [zkteco].[tblTempDeviceCmds] ADD  CONSTRAINT [D_zktecoTblTempDeviceCmds_CreatedAt]  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [zkteco].[tblTempDeviceCmds] ADD  CONSTRAINT [D_zktecoTblTempDeviceCmds_Executed]  DEFAULT ((0)) FOR [Executed]
GO
