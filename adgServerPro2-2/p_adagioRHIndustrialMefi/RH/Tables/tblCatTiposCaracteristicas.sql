USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblCatTiposCaracteristicas](
	[IDTipoCaracteristica] [int] IDENTITY(1,1) NOT NULL,
	[Activo] [bit] NOT NULL,
	[Color] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Traduccion] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_RHTblCatTiposCaracteristicas_IDTipoCaracteristica] PRIMARY KEY CLUSTERED 
(
	[IDTipoCaracteristica] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [RH].[tblCatTiposCaracteristicas] ADD  CONSTRAINT [Pk_RHTblCatTiposCaracteristicas_Activo]  DEFAULT ((0)) FOR [Activo]
GO
