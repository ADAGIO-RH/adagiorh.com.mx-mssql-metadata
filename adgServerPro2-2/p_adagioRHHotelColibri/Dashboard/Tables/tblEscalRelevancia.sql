USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dashboard].[tblEscalRelevancia](
	[label] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[min] [float] NULL,
	[max] [float] NULL,
	[indiceRelevancia] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
