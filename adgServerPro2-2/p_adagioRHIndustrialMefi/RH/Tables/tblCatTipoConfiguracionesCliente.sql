USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblCatTipoConfiguracionesCliente](
	[IDTipoConfiguracionCliente] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[TipoConfiguracionCliente] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TipoDato] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDAplicacion] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Data] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_RHTblCatTipoConfiguracionesCliente_IDTipoConfiguracionCliente] PRIMARY KEY CLUSTERED 
(
	[IDTipoConfiguracionCliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [RH].[tblCatTipoConfiguracionesCliente]  WITH CHECK ADD  CONSTRAINT [FK_AppTblCatAplicaciones_RHtblCatTipoConfiguracionesCliente_IDAplicacion] FOREIGN KEY([IDAplicacion])
REFERENCES [App].[tblCatAplicaciones] ([IDAplicacion])
GO
ALTER TABLE [RH].[tblCatTipoConfiguracionesCliente] CHECK CONSTRAINT [FK_AppTblCatAplicaciones_RHtblCatTipoConfiguracionesCliente_IDAplicacion]
GO
