USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblCatDocumentos](
	[IDDocumento] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Template] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Plantilla] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Codigo] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[EsContrato] [bit] NULL,
 CONSTRAINT [PK_tblCatDocumentos_IDDocumento] PRIMARY KEY CLUSTERED 
(
	[IDDocumento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [RH].[tblCatDocumentos] ADD  DEFAULT ((0)) FOR [EsContrato]
GO
