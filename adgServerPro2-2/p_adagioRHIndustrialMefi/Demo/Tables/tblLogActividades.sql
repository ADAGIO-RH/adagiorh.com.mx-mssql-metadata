USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Demo].[tblLogActividades](
	[IDLogActividad] [int] IDENTITY(1,1) NOT NULL,
	[Error] [bit] NULL,
	[Mensaje] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Fecha] [datetime] NULL,
 CONSTRAINT [Pk_DemoTblLogActividades_IDLogActividad] PRIMARY KEY CLUSTERED 
(
	[IDLogActividad] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Demo].[tblLogActividades] ADD  CONSTRAINT [D_DemoTblLogActividades_Error]  DEFAULT ((0)) FOR [Error]
GO
ALTER TABLE [Demo].[tblLogActividades] ADD  CONSTRAINT [D_DemoTblLogActividades_Fecha]  DEFAULT (getdate()) FOR [Fecha]
GO
