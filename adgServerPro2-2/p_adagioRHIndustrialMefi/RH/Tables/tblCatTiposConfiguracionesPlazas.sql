USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblCatTiposConfiguracionesPlazas](
	[IDTipoConfiguracionPlaza] [App].[SMName] NOT NULL,
	[Nombre] [App].[MDName] NOT NULL,
	[Disponible] [bit] NULL,
	[Configuracion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Orden] [int] NULL,
	[TableName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Filtro] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_RHTblCatTiposConfiguracionesPlazas_IDTipoConfiguracionPlaza] PRIMARY KEY CLUSTERED 
(
	[IDTipoConfiguracionPlaza] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [RH].[tblCatTiposConfiguracionesPlazas] ADD  CONSTRAINT [D_RHTblCatTiposConfiguracionesPlazas_Disponible]  DEFAULT ((0)) FOR [Disponible]
GO
ALTER TABLE [RH].[tblCatTiposConfiguracionesPlazas] ADD  CONSTRAINT [D_RHTblCatTiposConfiguracionesPlazas_Orden]  DEFAULT ((0)) FOR [Orden]
GO
