USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblConfiguracionesCliente20220318](
	[IDConfiguracionCliente] [int] IDENTITY(1,1) NOT NULL,
	[IDCliente] [int] NOT NULL,
	[IDTipoConfiguracionCliente] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Valor] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL
) ON [PRIMARY]
GO
