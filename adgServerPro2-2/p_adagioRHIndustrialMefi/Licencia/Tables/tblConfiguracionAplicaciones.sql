USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Licencia].[tblConfiguracionAplicaciones](
	[IDConfiguracion] [int] IDENTITY(1,1) NOT NULL,
	[IDAplicacion] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Configuracion] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
 CONSTRAINT [Pk_LicenciatblConfiguracionAplicaciones_IDConfiguracion] PRIMARY KEY CLUSTERED 
(
	[IDConfiguracion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_LicenciatblConfiguracionAplicaciones_IDAplicacion] UNIQUE NONCLUSTERED 
(
	[IDAplicacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Licencia].[tblConfiguracionAplicaciones]  WITH CHECK ADD  CONSTRAINT [FK_LicenciatblConfiguracionAplicaciones_AppTblCatAplicaciones_IDAplicacion] FOREIGN KEY([IDAplicacion])
REFERENCES [App].[tblCatAplicaciones] ([IDAplicacion])
GO
ALTER TABLE [Licencia].[tblConfiguracionAplicaciones] CHECK CONSTRAINT [FK_LicenciatblConfiguracionAplicaciones_AppTblCatAplicaciones_IDAplicacion]
GO
