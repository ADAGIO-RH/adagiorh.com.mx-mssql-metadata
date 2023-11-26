USE [p_adagioRHCRHIrkon]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblNewFeatures](
	[IDFeature] [int] NOT NULL,
	[Name] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Active] [bit] NOT NULL,
 CONSTRAINT [Pk_AppTblNewFeatures_IDFeature] PRIMARY KEY CLUSTERED 
(
	[IDFeature] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_AppTblNewFeatures_Name] UNIQUE NONCLUSTERED 
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [App].[tblNewFeatures] ADD  CONSTRAINT [U_AppTblNewFeatures_Active]  DEFAULT ((1)) FOR [Active]
GO
