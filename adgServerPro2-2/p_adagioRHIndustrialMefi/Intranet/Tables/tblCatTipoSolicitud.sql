USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Intranet].[tblCatTipoSolicitud](
	[IDTipoSolicitud] [int] NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Traduccion] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Intranet] [bit] NULL,
	[SPValidaciones] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_IntranetTblCatTipoSolicitud_IDTipoSolicitud] PRIMARY KEY CLUSTERED 
(
	[IDTipoSolicitud] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Intranet].[tblCatTipoSolicitud] ADD  DEFAULT ((1)) FOR [Intranet]
GO
