USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Efisco].[tblSolicitudesCreadas](
	[IDSolicitud] [int] IDENTITY(1,1) NOT NULL,
	[IDEfisco] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[RFC] [nvarchar](13) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[TipoDocumento] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[FechaCreacion] [datetime] NOT NULL,
	[FechaInicial] [datetime] NOT NULL,
	[FechaFinal] [datetime] NOT NULL,
	[Estado] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[TipoSolicitud] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Mensaje] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TotalArchivos] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[IDSolicitud] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Efisco].[tblSolicitudesCreadas] ADD  DEFAULT ((0)) FOR [TotalArchivos]
GO
