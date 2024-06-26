USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblPerfilPublicacionVacante](
	[idplaza] [int] NULL,
	[idmodalidadtrabajo] [int] NULL,
	[idtipotrabajo] [int] NULL,
	[idtipocontrato] [int] NULL,
	[ocultarsalario] [bit] NULL,
	[linkvideo] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[beneficios] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[tags] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[vacantePCD] [bit] NULL,
	[edadminima] [int] NULL,
	[edadmaxima] [int] NULL,
	[idgenero] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[aniosexperiencia] [int] NULL,
	[idestudio] [int] NULL,
	[formacioncomplementaria] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[idiomas] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[habilidades] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[licenciaconducir] [bit] NULL,
	[disponibilidadviajar] [bit] NULL,
	[vehiculopropio] [bit] NULL,
	[disponibilidadcambiovivienda] [bit] NULL,
	[incluirpreguntasfiltro] [bit] NULL,
	[descripcionvacante] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[uuid] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
