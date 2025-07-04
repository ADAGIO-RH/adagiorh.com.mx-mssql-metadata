USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Asistencia].[TblCatDiasFestivos](
	[IDDiaFestivo] [int] IDENTITY(1,1) NOT NULL,
	[Fecha] [date] NOT NULL,
	[FechaReal] [date] NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Autorizado] [bit] NULL,
	[IDPais] [int] NULL,
	[Traduccion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_AsistenciaTblCatDiasFestivos_IDDiaFestivo] PRIMARY KEY CLUSTERED 
(
	[IDDiaFestivo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_AsistenciaTblCatDiasFestivos_FechaIDPais] UNIQUE NONCLUSTERED 
(
	[Fecha] ASC,
	[IDPais] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciaTblCatDiasFestivos_Autorizado] ON [Asistencia].[TblCatDiasFestivos]
(
	[Autorizado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciaTblCatDiasFestivos_Fecha] ON [Asistencia].[TblCatDiasFestivos]
(
	[Fecha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciaTblCatDiasFestivos_FechaReal] ON [Asistencia].[TblCatDiasFestivos]
(
	[FechaReal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Asistencia].[TblCatDiasFestivos] ADD  DEFAULT ((0)) FOR [Autorizado]
GO
ALTER TABLE [Asistencia].[TblCatDiasFestivos]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatPaises_AsistenciaTblCatDiasFestivos_IDPais] FOREIGN KEY([IDPais])
REFERENCES [Sat].[tblCatPaises] ([IDPais])
GO
ALTER TABLE [Asistencia].[TblCatDiasFestivos] CHECK CONSTRAINT [FK_SatTblCatPaises_AsistenciaTblCatDiasFestivos_IDPais]
GO
ALTER TABLE [Asistencia].[TblCatDiasFestivos]  WITH CHECK ADD  CONSTRAINT [Chk_RHTblCatDiasFestivos_Traduccion] CHECK  ((isjson([Traduccion])>(0)))
GO
ALTER TABLE [Asistencia].[TblCatDiasFestivos] CHECK CONSTRAINT [Chk_RHTblCatDiasFestivos_Traduccion]
GO
