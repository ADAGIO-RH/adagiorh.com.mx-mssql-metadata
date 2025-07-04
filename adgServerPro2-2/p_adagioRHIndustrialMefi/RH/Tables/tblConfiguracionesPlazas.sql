USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblConfiguracionesPlazas](
	[IDConfiguracionPlaza] [int] IDENTITY(1,1) NOT NULL,
	[IDPlaza] [int] NOT NULL,
	[IDTipoConfiguracionPlaza] [App].[SMName] NOT NULL,
	[Valor] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_RHTblConfiguracionesPlazas_IDConfiguracionPlaza] PRIMARY KEY CLUSTERED 
(
	[IDConfiguracionPlaza] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [RH].[tblConfiguracionesPlazas]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblConfiguracionesPlazas_RHTblCatPlazas_IDPlaza] FOREIGN KEY([IDPlaza])
REFERENCES [RH].[tblCatPlazas] ([IDPlaza])
ON DELETE CASCADE
GO
ALTER TABLE [RH].[tblConfiguracionesPlazas] CHECK CONSTRAINT [Fk_RHTblConfiguracionesPlazas_RHTblCatPlazas_IDPlaza]
GO
ALTER TABLE [RH].[tblConfiguracionesPlazas]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblConfiguracionesPlazas_RHTblCatTiposConfiguracionesPlazas_IDTipoConfiguracionPlaza] FOREIGN KEY([IDTipoConfiguracionPlaza])
REFERENCES [RH].[tblCatTiposConfiguracionesPlazas] ([IDTipoConfiguracionPlaza])
ON DELETE CASCADE
GO
ALTER TABLE [RH].[tblConfiguracionesPlazas] CHECK CONSTRAINT [Fk_RHTblConfiguracionesPlazas_RHTblCatTiposConfiguracionesPlazas_IDTipoConfiguracionPlaza]
GO
