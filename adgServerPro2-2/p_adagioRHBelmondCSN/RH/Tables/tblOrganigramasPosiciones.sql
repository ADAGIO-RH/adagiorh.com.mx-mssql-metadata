USE [p_adagioRHBelmondCSN]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblOrganigramasPosiciones](
	[IDOrganigramaPosicion] [int] IDENTITY(1,1) NOT NULL,
	[Data] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Nombre] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_AsistenciaTblOrganigramasPosiciones_IDOrganigramaPosicion] PRIMARY KEY CLUSTERED 
(
	[IDOrganigramaPosicion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
