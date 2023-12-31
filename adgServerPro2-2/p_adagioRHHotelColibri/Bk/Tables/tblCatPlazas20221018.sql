USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblCatPlazas20221018](
	[IDPlaza] [int] IDENTITY(1,1) NOT NULL,
	[IDCliente] [int] NOT NULL,
	[Codigo] [App].[SMName] NOT NULL,
	[ParentId] [int] NOT NULL,
	[TotalPosiciones] [int] NOT NULL,
	[PosicionesOcupadas] [int] NOT NULL,
	[PosicionesDisponibles] [int] NOT NULL,
	[Configuraciones] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDPuesto] [int] NULL,
	[IDNivelSalarial] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
