USE [p_adagioRHDXN-Mexico]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblCatUbicaciones](
	[IDUbicacion] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Latitud] [float] NULL,
	[Longitud] [float] NULL,
	[Activo] [bit] NULL,
 CONSTRAINT [PK_RHtblCatUbicaciones_IDUbicacion] PRIMARY KEY CLUSTERED 
(
	[IDUbicacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
