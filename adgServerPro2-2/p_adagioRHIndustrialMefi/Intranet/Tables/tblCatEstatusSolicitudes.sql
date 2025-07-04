USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Intranet].[tblCatEstatusSolicitudes](
	[IDEstatusSolicitud] [int] NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Traduccion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CssClas] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[VueBindingStyle] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_IntranetTblCatEstatusSolicitudes_IDEstatusSolicitud] PRIMARY KEY CLUSTERED 
(
	[IDEstatusSolicitud] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Intranet].[tblCatEstatusSolicitudes] ADD  DEFAULT ('') FOR [VueBindingStyle]
GO
