USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblTemplateContainersEmail](
	[IDContainer] [int] NOT NULL,
	[Container] [text] COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Head] [text] COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Body] [text] COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Footer] [text] COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[HeadCustomer] [text] COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[BodyCustomerContainer] [text] COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FooterCustomer] [text] COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CloseDiv] [text] COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_ApptblTemplateContainersEmail_IDContainer] PRIMARY KEY CLUSTERED 
(
	[IDContainer] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
