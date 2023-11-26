USE [p_adagioRHOwen]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reportes].[tblCatReportes](
	[IDItem] [int] IDENTITY(1,1) NOT NULL,
	[TipoItem] [int] NOT NULL,
	[IDCarpeta] [int] NOT NULL,
	[Nombre] [varchar](254) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[FullPath] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_ReportesTblCatReportes_IDItem] PRIMARY KEY CLUSTERED 
(
	[IDItem] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_ReportesTblCatReportes_TipoItemIDCarpetaNombre] UNIQUE NONCLUSTERED 
(
	[TipoItem] ASC,
	[IDCarpeta] ASC,
	[Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Reportes].[tblCatReportes] ADD  CONSTRAINT [D_ReportesTblCatReportes_IDCarpeta]  DEFAULT ((0)) FOR [IDCarpeta]
GO
